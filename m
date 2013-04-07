From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] unix: account skb memory to receiving socket's sk_rmem_alloc on sending
Date: Mon, 8 Apr 2013 00:47:20 +0200
Message-ID: <20130407224719.GA9182@order.stressinduktion.org>
References: <20130204231414.GD6898@order.stressinduktion.org> <20130309214333.GI28531@order.stressinduktion.org> <1362889861.4051.15.camel@edumazet-glaptop> <20130310044043.GB2709@order.stressinduktion.org> <20130311193704.GA24481@order.stressinduktion.org> <20130326001740.GB29705@order.stressinduktion.org> <1364313218.1716.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	xiyou.wangcong@gmail.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56865 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934455Ab3DGWrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 18:47:22 -0400
Content-Disposition: inline
In-Reply-To: <1364313218.1716.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am still unsure if I should just drop this patch from my todo
list. Eric, may I ask you for additional input again? I try to
specifically answer your question now with code samples. If you do think
it is not worth the effort I will finally drop the patch from my queue.
Thanks a lot!

On Tue, Mar 26, 2013 at 08:53:38AM -0700, Eric Dumazet wrote:
> This opens the possibility of a sender to flood a receiver, instead of
> being blocked by its own sndbuf.

In unix_dgram_sendmsg there are two points where the sending process
could be prevented from delivery of the unix dgram msg:

a) The first one is at sock_alloc_send_pskb and checks if the sk_sndbuf
is smaller than the maximum buffer size. I didn't change anything here,
so it only blocks if sndbuf filled up.

b) The second one is where we check if the receiving sockets has less
than sk_max_ack_backlog of outstanding datagrams. This was checked by
unix_recvq_full. I changed the code that it does now check the status of
the other socket's receive buffer instead of the number of outstanding
datagrams in the receiver's queue. If the rcvbuf is full, it stops the
delivery of the message to the receiver (unchanged blocking/o_nonblock
behaviour):

| @@ -1559,7 +1601,7 @@ restart:
|                         goto out_unlock;
|         }
| 
| -       if (unix_peer(other) != sk && unix_recvq_full(other)) {
| +       if (unix_rmem_full(other, skb)) {
|                 if (!timeo) {
|                         err = -EAGAIN;
|                         goto out_unlock;
| 

This is unix_recvq_full:

| +static inline bool unix_rmem_full(struct sock const *sk,
| +                                 struct sk_buff const *skb)
| +{
| +       return sk_rmem_alloc_get(sk) + skb->truesize > sk->sk_rcvbuf;
| +}
| +

These checks ensure that a sending socket can not flood a receiver with
messages but instead has to back down.

The maximum rcvbuf size is taken from
/proc/sys/net/core/rmem_{default,max}, so we already have a safe default
setting (we could actually add seperate net/unix/rmem_{default,max} knobs).

This patch would help to prevent that a server socket in a
request/response kind of protocol could be stopped to answer to furhter
requests because its send buffer has filled up because other clients
did not read their messages yet. Instead it could handle this situation
for each client properly.

I also implemented the necessary changes for ->poll().

I tried to come up with a list what could change for user-space
applications but actually found this one only:

a) the SIOCOUTQ ioctl will report a different value: it won't report the
number of not yet received bytes by the other socket but the number of
not yet delivered bytes. I think this is rather harmless As the memory
overhead is accounted too and an application which does rely on this
feature would also have problems as soon as the kernel internal data
structures grow.

I hope I did not forget an important aspect of this change.

Thanks again,

  Hannes
