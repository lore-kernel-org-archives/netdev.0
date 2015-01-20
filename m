From: subashab@codeaurora.org
Subject: Re: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Tue, 20 Jan 2015 02:34:25 -0000
Message-ID: <9dd57106ffab140ee31fb4f0390a87dd.squirrel@www.codeaurora.org>
References: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
    <1421412775.11734.117.camel@edumazet-glaptop2.roam.corp.google.com>
    <ff3aa93b48dfedd7721d7fcc8ee7624b.squirrel@www.codeaurora.org>
    <20150116.164830.172588830692811414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:44126 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbbATCe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 21:34:27 -0500
In-Reply-To: <20150116.164830.172588830692811414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David and Eric for the insights. In order for me to steer this
debug in the right direction, can you please help me? Based on your input
I looked into this a little deeper to understand the refcnts for sockets
and skb's in this ping receive path.

from ping_rcv()

                sk = ping_lookup(net, skb, ntohs(icmph->un.echo.id));
                if (sk != NULL) {
                                pr_debug("rcv on socket %p\n", sk);
                                ping_queue_rcv_skb(sk, skb_get(skb));
                                sock_put(sk);
                                return;
                }

>From my understanding I have made the following analysis, please correct
if I am wrong.

1) There is no guarantee that sock_put() in the above code snippet
will not drop the socket refcount to 0 and free the socket. This can
hypothetically happen if say
sock_close()->ping_close()->*->ping_unhash()->sock_put()
can  happen between in a different context between ping_lookup() and
sock_put() in the above code snippet. Is this observation accurate?

2)  Now since this socket is being freed in the ping receive path, I think
the following is what is happening with the skb.
alloc_skb()[skb->users=1]   -> deliver_skb()[skb->users=2]  -> * ->
icmp_rcv() -> ping_rcv() -> sk_free --> inet_sock_destruct()->
__skb_queue_purge()->kfree_skb()[dec ref cnt, skb->users=1]

when stack unwinds to icmp_rcv(), refcnt actually hits zero and packet is
freed calling the destructor which tries to access the freed socket.

If these observations are right, Can you please tell me what is the call
flow that is not supposed to happen but is happening in this issue? I am
trying to understand better to identify next steps to tackle this issue.

--
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project

> From: subashab@codeaurora.org
> Date: Fri, 16 Jan 2015 20:59:14 -0000
>
>>>skb_queue_purge() is also calling skb_orphan() on all skb
>> From my reading, it looked like skb_queue_purge() is dequeuing and
>> calling
>> kfree_skb() which will release a reference. I did not see skb_orphan()
>> being called directly. Am I missing something?
>> I think that if it had really orphaned the skb, then this crash would
>> not
>> be seen in the first place.
>
> The calls to skb->destructor(), done by skb_queue_purge() (via
> kfree_skb()) do this.
>
> But even if it didn't, the fact remains that we are operating on the
> socket right here in the destructor.  It still exists and has not been
> freed yet.
>
> And furthermore, exactly what skb_orphan() does is call skb->destructor(),
> _JUST_LIKE_ skb_queue_purge() will via kfree_skb().
>
> So either sock_rfree() is safe to call here, or it isn't.  You are not
> eliminating the calls to sock_rfree() which operate on this socket at
> all.  If you did, then the socket memory counters would end up being
> corrupts and the warnings would trigger:
>
> 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
> 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
>
> You're just moving the skb->destructor() call up a few lines in the
> same function, it makes therefore no sense why this would fix a bug
> or not.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
