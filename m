From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH 1/3] ipv6: make inet6addr_chain blocking and always call
 with rtnl locked
Date: Mon, 18 May 2015 13:13:55 +0300
Message-ID: <5559BB63.8000309@yandex-team.ru>
References: <20150514134657.14062.87579.stgit@buzz>	<20150514135618.14062.1969.stgit@buzz> <20150516.172214.820543928532454603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, jbenc@redhat.com,
	hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:33084 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752988AbbERKOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 06:14:00 -0400
In-Reply-To: <20150516.172214.820543928532454603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.05.2015 00:22, David Miller wrote:
> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Date: Thu, 14 May 2015 16:56:18 +0300
>
>> Unlike to inetaddr_chain inet6addr_chain is atomic and called from bh
>> context without rtnl when ipv6 receives router advertisement packet.
>>
>> Several drivers don't know about that: ipvlan thinks that it has rtnl
>> here, ocrdma locks mutex inside callback. Probably there is more.
>>
>> This patch makes it blocking and calls from first stage of DAD work.
>> Looks like this is completely safe and rtnl already locked here.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> I don't see how you can make the inet6addr_chain blocking when it is
> invoked from software interrupt context.
>
> You also cannot try to defer these operations to a workqueue or
> similar to get into a blockable context, because various ipv6
> testsuites depend upon the addressing state change happening
> when we process the packet that triggers that change.
>
> Instead, I think you have to make the users of inet6addr_chain
> aware of the context in which they execute.
>
> Thanks.
>

I've defer only calls of inet6addr_notifier_call_chain.
Ipv6 addresses still appears right in interrupt context.

Ordering with netlink events RTM_NEWADDR/RTM_DELADDR stays the same:

inet6addr_notifier_call_chain(NETDEV_UP, ifp);
ipv6_ifa_notify(RTM_NEWADDR, ifp);
...
ipv6_ifa_notify(RTM_DELADDR, ifp);
inet6addr_notifier_call_chain(NETDEV_DOWN, ifp);

As I see ipv6 always send RTM_NEWADDR from dad-work even for
IFA_F_OPTIMISTIC addresses

The only visible change is ordering with event RTM_NEWPREFIX.


And another problem which my patch fixes. at this path:
addrconf_prefix_rcv -> ipv6_add_addr -> inet6addr_notifier_call_chain

inet6addr_notifier_call_chain called without any locks.
Theoretically NETDEV_DOWN event could be delivered before NETDEV_UP
if somebody removes that half-baked address right in that moment.

-- 
Konstantin
