From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v3] af-unix: fix use-after-free with concurrent readers
 while splicing
Date: Wed, 11 Nov 2015 20:14:19 +0100
Message-ID: <1447269259.3708910.436352857.78EBF47C@webmail.messagingengine.com>
References: <1447168995-25820-1-git-send-email-hannes@stressinduktion.org>
 <1447268331.17135.116.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:40286 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751808AbbKKTOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:14:20 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 276E720141
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 14:14:20 -0500 (EST)
In-Reply-To: <1447268331.17135.116.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015, at 19:58, Eric Dumazet wrote:
> On Tue, 2015-11-10 at 16:23 +0100, Hannes Frederic Sowa wrote:
> > During splicing an af-unix socket to a pipe we have to drop all
> > af-unix socket locks. While doing so we allow another reader to enter
> > unix_stream_read_generic which can read, copy and finally free another
> > skb. If exactly this skb is just in process of being spliced we get a
> > use-after-free report by kasan.
> > 
> > First, we must make sure to not have a free while the skb is used during
> > the splice operation. We simply increment its use counter before unlocking
> > the reader lock.
> > 
> > Stream sockets have the nice characteristic that we don't care about
> > zero length writes and they never reach the peer socket's queue. That
> > said, we can take the UNIXCB.consumed field as the indicator if the
> > skb was already freed from the socket's receive queue. If the skb was
> > fully consumed after we locked the reader side again we know it has been
> > dropped by a second reader. We indicate a short read to user space and
> > abort the current splice operation.
> > 
> > This bug has been found with syzkaller
> > (http://github.com/google/syzkaller) by Dmitry Vyukov.
> > 
> > Fixes: 2b514574f7e8 ("net: af_unix: implement splice for stream af_unix sockets")
> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
> > Cc: Dmitry Vyukov <dvyukov@google.com>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Acked-by: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> > v2: add missing consume_skb in error path of recv_actor
> > v3: move skb_get to separate line as proposed by Eric Dumazet (thanks!)
> > 
> 
> I believe there is another bug in unix_stream_sendpage()
> 
> skb = skb_peek_tail(&other->sk_receive_queue);   
> if (tail && tail == skb) {
> 
> Is clearly not safe ?

Can you elaborate?

I use tail as a cookie and check if we already tried to append to the
same tail skb with skb_append_pagefrags. If during allocation, which we
do outside of the locks, a new skb arrives, we take that and try to
append again (and free the old skb), to correctly not create any
reordering in the data stream.

You think that tail could be reused in the meanwhile?

Bye,
Hannes
