From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Tue, 20 Jan 2015 11:42:00 -0800
Message-ID: <CAHA+R7N-j5-iizM2pfjtAExn4Y3rq=UWGn1xyw8Z5OFO9u95ag@mail.gmail.com>
References: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
	<1421412775.11734.117.camel@edumazet-glaptop2.roam.corp.google.com>
	<ff3aa93b48dfedd7721d7fcc8ee7624b.squirrel@www.codeaurora.org>
	<20150116.164830.172588830692811414.davem@davemloft.net>
	<9dd57106ffab140ee31fb4f0390a87dd.squirrel@www.codeaurora.org>
	<1421725837.17892.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: subashab@codeaurora.org, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:37144 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbbATTmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 14:42:01 -0500
Received: by mail-qc0-f172.google.com with SMTP id i8so23919812qcq.3
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 11:42:00 -0800 (PST)
In-Reply-To: <1421725837.17892.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 7:50 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-01-20 at 02:34 +0000, subashab@codeaurora.org wrote:
>> Thanks David and Eric for the insights. In order for me to steer this
>> debug in the right direction, can you please help me? Based on your input
>> I looked into this a little deeper to understand the refcnts for sockets
>> and skb's in this ping receive path.
>>
>> from ping_rcv()
>>
>>                 sk = ping_lookup(net, skb, ntohs(icmph->un.echo.id));
>>                 if (sk != NULL) {
>>                                 pr_debug("rcv on socket %p\n", sk);
>>                                 ping_queue_rcv_skb(sk, skb_get(skb));
>>                                 sock_put(sk);
>>                                 return;
>>                 }
>>
>> From my understanding I have made the following analysis, please correct
>> if I am wrong.
>>
>> 1) There is no guarantee that sock_put() in the above code snippet
>> will not drop the socket refcount to 0 and free the socket. This can
>> hypothetically happen if say
>> sock_close()->ping_close()->*->ping_unhash()->sock_put()
>> can  happen between in a different context between ping_lookup() and
>> sock_put() in the above code snippet. Is this observation accurate?
>>
>> 2)  Now since this socket is being freed in the ping receive path, I think
>> the following is what is happening with the skb.
>> alloc_skb()[skb->users=1]   -> deliver_skb()[skb->users=2]  -> * ->
>> icmp_rcv() -> ping_rcv() -> sk_free --> inet_sock_destruct()->
>> __skb_queue_purge()->kfree_skb()[dec ref cnt, skb->users=1]
>>
>> when stack unwinds to icmp_rcv(), refcnt actually hits zero and packet is
>> freed calling the destructor which tries to access the freed socket.
>>
>> If these observations are right, Can you please tell me what is the call
>> flow that is not supposed to happen but is happening in this issue? I am
>> trying to understand better to identify next steps to tackle this issue.
>
> This is why skb_get() is very often a bug.
>
> There is no guarantee the consume_skb() in icmp_rcv() is done before the
> skb_queue_purge().
>

Or let the socket layer drop the packet instead of unconditionally
dropping all icmp packets after success?
