From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sun, 13 Jan 2013 09:44:48 -0500
Message-ID: <50F2C860.1060602@mojatatu.com>
References: <50F1699E.1000200@hartkopp.net>  <20130112.132316.2121287993605534669.davem@davemloft.net>  <20130112.133630.257139657732337147.davem@davemloft.net>  <1358046374.20249.1789.camel@edumazet-glaptop>  <20130113035013.GJ5259@kvack.org> <1358056199.20249.2121.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:43313 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754989Ab3AMOpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 09:45:01 -0500
Received: by mail-ie0-f182.google.com with SMTP id s9so4090247iec.27
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2013 06:45:01 -0800 (PST)
In-Reply-To: <1358056199.20249.2121.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-01-13 12:49 AM, Eric Dumazet wrote:

> Could you elaborate on what could be the problem ?
>
> We hold the RTNL, so I dont think another process could possibly call
> tcf_mirred_init()
>

Eric, the point probably Ben was trying to make is not about 
synchronizing rather about which namespace has the right to that action 
config. Your change is correct for the common use of actions
but does not fix the larger picture.

At the moment a dev is owned by a specific namespace; that owns a tc 
filter that in turn owns an action. So no problem with the change you 
make if all configuration follows those rules i.e something along the 
lines of:
===
tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
match ip dst 10.0.0.229/32 flowid 1:10 \
action mirred egress redirect dev ifb0
=====

I would say most people use the above syntax.
However, there is another way to configure actions so they can be 
shared[1], example control syntax:
----
tc actions add \
action police rate 1kbit burst 90k drop index 3 \
action mirred egress mirror dev eth0 index 5
----

In such a case, the "tc actions" netlink path may be
entered from a different namespace than the one that is
using it. Then current->nsproxy->net_ns is no longer correct.

To correct this, i think what Ben points out in passing the
init() the correct namespace seem like the way to go. Feel free
to make that change - otherwise i will get to it and fix it.

cheers,
jamal

[1]
You can then have multiple filters use this action like so:
===
tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
match ip dst 10.0.0.229/32 flowid 1:10 \
action police index 3
#
tc filter add dev eth0 parent ffff: protocol ip prio 6 u32 \
match ip src 10.0.0.21/32 flowid 1:16 \
action police index 3 action mirred egress mirror dev eth0
=====
