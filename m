From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v3] af-unix: fix use-after-free with concurrent readers
 while splicing
Date: Wed, 11 Nov 2015 20:35:44 +0100
Message-ID: <1447270544.3713125.436369065.0FEEDEDA@webmail.messagingengine.com>
References: <1447168995-25820-1-git-send-email-hannes@stressinduktion.org>
 <1447268331.17135.116.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447269259.3708910.436352857.78EBF47C@webmail.messagingengine.com>
 <1447270092.22599.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:44902 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751591AbbKKTfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:35:45 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id D590720EB5
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 14:35:44 -0500 (EST)
In-Reply-To: <1447270092.22599.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Nov 11, 2015, at 20:28, Eric Dumazet wrote:
> On Wed, 2015-11-11 at 20:14 +0100, Hannes Frederic Sowa wrote:
> > On Wed, Nov 11, 2015, at 19:58, Eric Dumazet wrote:
> 
> > Can you elaborate?
> > 
> > I use tail as a cookie and check if we already tried to append to the
> > same tail skb with skb_append_pagefrags. If during allocation, which we
> > do outside of the locks, a new skb arrives, we take that and try to
> > append again (and free the old skb), to correctly not create any
> > reordering in the data stream.
> > 
> > You think that tail could be reused in the meanwhile?
> 
> Hmmm, there is some funky stuff at least.
> 
> Are you sure the __skb_queue_tail(&other->sk_receive_queue, newskb)
> is appropriate ?
> 
> (Why not locking sk_receive_queue is safe ?)

We hold the other's state lock at that time.

But I see another problem in unix_stream_read_generic:


		/* Mark read part of skb as used */
		if (!(flags & MSG_PEEK)) {
			UNIXCB(skb).consumed += chunk;

			sk_peek_offset_bwd(sk, chunk);

			if (UNIXCB(skb).fp)
				unix_detach_fds(&scm, skb);

			if (unix_skb_len(skb))
				break;

			skb_unlink(skb, &sk->sk_receive_queue);
			consume_skb(skb);

			if (scm.fp)
				break;


The skb_unlink happens solely on the list lock and not on the state lock
of the sk, so it is not synchronized to the other locks.

Bye,
Hannes
