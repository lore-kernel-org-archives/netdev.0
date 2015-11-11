From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v3] af-unix: fix use-after-free with concurrent readers
 while splicing
Date: Wed, 11 Nov 2015 20:58:29 +0100
Message-ID: <1447271909.3719084.436387065.64388554@webmail.messagingengine.com>
References: <1447168995-25820-1-git-send-email-hannes@stressinduktion.org>
 <1447268331.17135.116.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447269259.3708910.436352857.78EBF47C@webmail.messagingengine.com>
 <1447270092.22599.3.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447270544.3713125.436369065.0FEEDEDA@webmail.messagingengine.com>
 <1447270969.22599.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56594 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751743AbbKKT6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:58:30 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 36C6820AE8
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 14:58:30 -0500 (EST)
In-Reply-To: <1447270969.22599.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Nov 11, 2015, at 20:42, Eric Dumazet wrote:
> On Wed, 2015-11-11 at 20:35 +0100, Hannes Frederic Sowa wrote:
> > 
> > On Wed, Nov 11, 2015, at 20:28, Eric Dumazet wrote:
> > > On Wed, 2015-11-11 at 20:14 +0100, Hannes Frederic Sowa wrote:
> > > > On Wed, Nov 11, 2015, at 19:58, Eric Dumazet wrote:
> > > 
> > > > Can you elaborate?
> > > > 
> > > > I use tail as a cookie and check if we already tried to append to the
> > > > same tail skb with skb_append_pagefrags. If during allocation, which we
> > > > do outside of the locks, a new skb arrives, we take that and try to
> > > > append again (and free the old skb), to correctly not create any
> > > > reordering in the data stream.
> > > > 
> > > > You think that tail could be reused in the meanwhile?
> > > 
> > > Hmmm, there is some funky stuff at least.
> > > 
> > > Are you sure the __skb_queue_tail(&other->sk_receive_queue, newskb)
> > > is appropriate ?
> > > 
> > > (Why not locking sk_receive_queue is safe ?)
> > 
> > We hold the other's state lock at that time.
> 
> Well, this is not safe enough :(
> 
> Look at unix_stream_sendmsg() : It uses skb_queue_tail(), not
> __skb_queue_tail()
> 
> Think of concurrent splice() (or sendfile()) and sendmsg() on the same
> af_unix socket.

Well,

unix_stream_sendmsg:

unix_state_lock(other);
skb_queue_tail(&other->sk_receive_queue);
unix_state_unlock(other);

unix_stream_sendpage:

unix_state_lock(other);
__skb_queue_tail(&other->sk_receive_queue, skb);
unix_state_unlock(other);

unix_stream_read_generic:

I only see the skb_unlink as a dangerous operation because outside of
other lock and solely taking the sk_receivie_queue lock. Actually I
think skb_queue_tail can be converted to __skb_queue_tail.

But then the logic in unix_stream_connect() does not match, but it also
holds the other's socket lock durign sk_receive_queue modification.

Hmm, something is wrong here, that is clear. :/

Bye,
Hannes
