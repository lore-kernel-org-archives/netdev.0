From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: add NETLINK_BROADCAST_ERROR socket option
Date: Tue, 17 Feb 2009 16:52:08 +0100
Message-ID: <499ADD28.3060806@trash.net>
References: <20090217135602.25864.20453.stgit@Decadence> <499AC746.5070403@trash.net> <499ADBB6.1030007@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59095 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290AbZBQPwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 10:52:10 -0500
In-Reply-To: <499ADBB6.1030007@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>>> @@ -994,13 +995,15 @@ static inline int do_one_broadcast(struct sock *sk,
>>>      if (p->skb2 == NULL) {
>>>          netlink_overrun(sk);
>>>          /* Clone failed. Notify ALL listeners. */
>>> -        p->failure = 1;
>>> +        if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
>>> +            p->failure = 1;
>> Almost :) If we didn't manage to clone, we can't deliver to *any*
>> socket, so the check in the first chunk above is incorrect. It
>> needs to always call netlink_overrun(), additionally it needs to
>> set delivery_failure when the SEND_ERROR flag is present.
> 
> Hm, I'm getting lost with this :), I thought that we agreed that sockets
> without the flag set should not skip.

Right, but you don't have a choice in that case as you don't
even have the first skb cloned. It will crash.

>> Something like this:
>>
>>      if (p->failure) {
>>  +        if (nlk->flags & NETLINK_BROADCAST_SEND_ERROR)
>>  +            p->delivery_failure = 1;
> 
> Then, I think that the previous patch that I sent should be OK
> (including the flag renaming, of course), because p->delivery_failure is
> set if delivery failed and p->failure is set when clone failed. In any
> case, (p->failure || p->delivery_failure) results in a error report, so
> this would not change anything.

The last one set p->failure for a deliver failure. It
should set p->delivery_failure, otherwise you *do*
start skipping other sockets.
