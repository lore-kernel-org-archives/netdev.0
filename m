From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: add NETLINK_BROADCAST_REPORT_ERROR socket option
Date: Mon, 16 Feb 2009 15:06:30 +0100
Message-ID: <499972E6.9090204@trash.net>
References: <20090216105200.29072.99944.stgit@Decadence> <49994A70.5000502@trash.net> <499973DC.3000208@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59029 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbZBPOGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 09:06:34 -0500
In-Reply-To: <499973DC.3000208@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>>>  static inline struct netlink_sock *nlk_sk(struct sock *sk)
>>>  {
>>> @@ -994,13 +995,15 @@ static inline int do_one_broadcast(struct sock 
>>> *sk,
>>>      if (p->skb2 == NULL) {
>>>          netlink_overrun(sk);
>>>          /* Clone failed. Notify ALL listeners. */
>>> -        p->failure = 1;
>>> +        if (nlk->flags & NETLINK_BROADCAST_SEND_REPORT_ERROR)
>>> +            p->failure = 1;
>>
>> This doesn't make sense. *Other* sockets get skipped only iff
>> this socket had the error-report flag set? This should be done
>> in a consistent manner, which means either not set the failure
>> flag at all and retry for all sockets, or set it for any failed
>> socket delivery and determine the return value based on whether
>> one of the skipped sockets had the error-report flag set.
> 
> I can add a check for the flag to allow sockets without the flag set to 
> try to send the message:
> 
>         if ((nlk->flags & NETLINK_BROADCAST_SEND_ERROR) && p->failure) {
>                 netlink_overrun(sk);
>                 goto out;
>         }
> 
> Still, this "skip" behaviour looks to me strange. I don't see why a 
> socket should skip if other socket's clone failed. Wouldn't it be better 
> to remove this?

Yes, that was the first of my suggestions. I don't care much which
way its done, but it should provide a consistent behaviour, which
means skipping should not depend on the setting of a *different*
socket.

