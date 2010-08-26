From: Brian Haley <brian.haley@hp.com>
Subject: Re: [net-next] ipv6: Enable netlink notification for tentative addresses.
Date: Thu, 26 Aug 2010 15:57:51 -0400
Message-ID: <4C76C73F.4080206@hp.com>
References: <1282760777-15381-1-git-send-email-greearb@candelatech.com> <20100825.212456.71107442.davem@davemloft.net> <4C76B770.4030800@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:11718 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab0HZT5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 15:57:54 -0400
In-Reply-To: <4C76B770.4030800@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2010 02:50 PM, Ben Greear wrote:
> On 08/25/2010 09:24 PM, David Miller wrote:
>> From: Ben Greear<greearb@candelatech.com>
>> Date: Wed, 25 Aug 2010 11:26:17 -0700
>>
>>> By default, netlink messages are not sent when an IPv6 address
>>> is added if it is in tentative state.  This makes it harder
>>> for user-space applications to know the current state of the
>>> IPv6 addresses.  This patch adds an ipv6 sysctl that will
>>> allow tentative address notifications to be sent.  The sysctl
>>> is off by default.
>>>
>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>
>> It's inconsistent to send two NEWADDR events for the same add.
>>
>> I would advise that we unconditionally do the NEWADDR once,
>> when the tentative state address is added, and completely
>> elide the one we current send when it leaves tentative state.

But then we get a message for an address that can't be used because
it hasn't passed DAD, I'm not so sure that is a good thing,
especially if we don't get notified when it passes DAD.

> @@ -697,9 +698,10 @@ ipv6_add_addr(struct inet6_dev *idev, const struct
> in6_addr *addr, int pfxlen,
>  out2:
>         rcu_read_unlock_bh();
> 
> -       if (likely(err == 0))
> +       if (likely(err == 0)) {
>                 atomic_notifier_call_chain(&inet6addr_chain, NETDEV_UP,
> ifa);
> -       else {
> +               inet6_ifa_notify(RTM_NEWADDR, ifa);
> +       } else {
>                 kfree(ifa);
>                 ifa = ERR_PTR(err);
>         }

This will generate two messages in some cases, for example, when lo is
configured, or a SIT tunnel is added, see add_addr() in addrconf.c.

-Brian
