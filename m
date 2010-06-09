From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: 2.6.35-rc2, CONFIG_RPS is filling the dmesg log
Date: Wed, 09 Jun 2010 09:22:59 -0600
Message-ID: <4C0FB1D3.60901@canonical.com>
References: <4C0EAE3E.4070708@canonical.com>	 <4C0F96B4.2000307@canonical.com> <1276090953.2442.140.camel@edumazet-laptop>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030206050901080004080903"
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:4469 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790Ab0FIPXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 11:23:06 -0400
In-Reply-To: <1276090953.2442.140.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030206050901080004080903
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 06/09/2010 07:42 AM, Eric Dumazet wrote:
> Le mercredi 09 juin 2010 à 07:27 -0600, Tim Gardner a écrit :
>> On 06/08/2010 02:55 PM, Tim Gardner wrote:
>>> With 2.6.35-rc2 my dmesg log is being flooded with messages like this:
>>>
>>> br0 received packet on queue 4, but number of RX queues is 1
>>>
>>> This machine is bridged for KVM and has 2 igb network adapters.
>>>
>>> The root cause appears to be CONFIG_RPS=y and the fact that none of the
>>> drivers that call skb_record_rx_queue() perform their net device
>>> allocation using alloc_netdev_mq(), thereby initializing num_rx_queues
>>> to a maximum of 1.
>>>
>>> Given that this is early RPS days, is the warning in get_rps_cpu()
>>> really necessary? It would appear that _all_ of the multi-receive queue
>>> devices that call skb_record_rx_queue() will cause this log noise.
>>>
>>> By the way, how do you turn off CONFIG_RPS? The only way I could get it
>>> disabled was to change the default in net/Kconfig to 'n'.
>>>
>>> rtg
>>
>> This is the route that I'm taking with Ubuntu in the short term. I'll
>> have lots of server testers complaining pretty soon if I don't take care
>> of this now. It does keep my server logs from filling.
>>
>> rtg
>>
>
> Probably fine, but your commit message is not exact :
>
>    So far no users of skb_record_rx_queue() use alloc_netdev_mq() for
>    network device initialization, so don't print a warning about num_rx_queues
>    imbalances in get_rps_cpu() unless they have actually been allocated.
>
> In fact, drivers that use skb_record_rx_queue() did use alloc_netdev_mq().
>
> Problem is : packets going thru bridge/bonding that are not yet
> multiqueue enabled. If R[PF]S enabled for these "virtual devices",
> we trigger the get_rps_cpu() warning.
>
> Also, in a bonding setup, we still have a problem
> because all tx packets will go thru tx queue 0 (dev_pick_tx() job)
>
> (That might be good to know that for Ubuntu server testers)
>

How about this?

-- 
Tim Gardner tim.gardner@canonical.com

--------------030206050901080004080903
Content-Type: text/x-patch;
 name="0001-UBUNTU-SAUCE-net-Print-num_rx_queues-imbalance-warni.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-UBUNTU-SAUCE-net-Print-num_rx_queues-imbalance-warni.pa";
 filename*1="tch"

>From ad76786a1a0c7b7b3c9bfeb4116fa0e2742f6328 Mon Sep 17 00:00:00 2001
From: Tim Gardner <tim.gardner@canonical.com>
Date: Tue, 8 Jun 2010 17:51:27 -0600
Subject: [PATCH] net: Print num_rx_queues imbalance warning only when there are allocated queues

BugLink: http://bugs.launchpad.net/bugs/591416

There are a number of network drivers (bridge, bonding, etc) that are not yet
receive multi-queue enabled and use alloc_netdev(), so don't print a
num_rx_queues imbalance warning in that case.

Also, only print the warning once for those drivers that _are_ multi-queue
enabled.

Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 net/core/dev.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d03470f..14a8568 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2253,11 +2253,9 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
 		if (unlikely(index >= dev->num_rx_queues)) {
-			if (net_ratelimit()) {
-				pr_warning("%s received packet on queue "
-					"%u, but number of RX queues is %u\n",
-					dev->name, index, dev->num_rx_queues);
-			}
+			WARN_ONCE(dev->num_rx_queues > 1, "%s received packet "
+				"on queue %u, but number of RX queues is %u\n",
+				dev->name, index, dev->num_rx_queues);
 			goto done;
 		}
 		rxqueue = dev->_rx + index;
-- 
1.7.0.4


--------------030206050901080004080903--
