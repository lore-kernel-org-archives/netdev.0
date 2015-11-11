From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3] af-unix: fix use-after-free with concurrent
 readers while splicing
Date: Wed, 11 Nov 2015 11:42:49 -0800
Message-ID: <1447270969.22599.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447168995-25820-1-git-send-email-hannes@stressinduktion.org>
	 <1447268331.17135.116.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447269259.3708910.436352857.78EBF47C@webmail.messagingengine.com>
	 <1447270092.22599.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447270544.3713125.436369065.0FEEDEDA@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36617 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbKKTmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:42:51 -0500
Received: by pacdm15 with SMTP id dm15so39388696pac.3
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:42:51 -0800 (PST)
In-Reply-To: <1447270544.3713125.436369065.0FEEDEDA@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-11 at 20:35 +0100, Hannes Frederic Sowa wrote:
> 
> On Wed, Nov 11, 2015, at 20:28, Eric Dumazet wrote:
> > On Wed, 2015-11-11 at 20:14 +0100, Hannes Frederic Sowa wrote:
> > > On Wed, Nov 11, 2015, at 19:58, Eric Dumazet wrote:
> > 
> > > Can you elaborate?
> > > 
> > > I use tail as a cookie and check if we already tried to append to the
> > > same tail skb with skb_append_pagefrags. If during allocation, which we
> > > do outside of the locks, a new skb arrives, we take that and try to
> > > append again (and free the old skb), to correctly not create any
> > > reordering in the data stream.
> > > 
> > > You think that tail could be reused in the meanwhile?
> > 
> > Hmmm, there is some funky stuff at least.
> > 
> > Are you sure the __skb_queue_tail(&other->sk_receive_queue, newskb)
> > is appropriate ?
> > 
> > (Why not locking sk_receive_queue is safe ?)
> 
> We hold the other's state lock at that time.

Well, this is not safe enough :(

Look at unix_stream_sendmsg() : It uses skb_queue_tail(), not
__skb_queue_tail()

Think of concurrent splice() (or sendfile()) and sendmsg() on the same
af_unix socket.
