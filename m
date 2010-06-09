From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: 2.6.35-rc2, CONFIG_RPS is filling the dmesg log
Date: Wed, 09 Jun 2010 07:27:16 -0600
Message-ID: <4C0F96B4.2000307@canonical.com>
References: <4C0EAE3E.4070708@canonical.com>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060800060503040005000102"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:4583 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757066Ab0FIN1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 09:27:21 -0400
Received: from [10.0.2.5] (unknown [10.0.2.5])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by mail.tpi.com (Postfix) with ESMTP id 2554824C8AA
	for <netdev@vger.kernel.org>; Wed,  9 Jun 2010 06:27:07 -0700 (PDT)
In-Reply-To: <4C0EAE3E.4070708@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060800060503040005000102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 06/08/2010 02:55 PM, Tim Gardner wrote:
> With 2.6.35-rc2 my dmesg log is being flooded with messages like this:
>
> br0 received packet on queue 4, but number of RX queues is 1
>
> This machine is bridged for KVM and has 2 igb network adapters.
>
> The root cause appears to be CONFIG_RPS=y and the fact that none of the
> drivers that call skb_record_rx_queue() perform their net device
> allocation using alloc_netdev_mq(), thereby initializing num_rx_queues
> to a maximum of 1.
>
> Given that this is early RPS days, is the warning in get_rps_cpu()
> really necessary? It would appear that _all_ of the multi-receive queue
> devices that call skb_record_rx_queue() will cause this log noise.
>
> By the way, how do you turn off CONFIG_RPS? The only way I could get it
> disabled was to change the default in net/Kconfig to 'n'.
>
> rtg

This is the route that I'm taking with Ubuntu in the short term. I'll 
have lots of server testers complaining pretty soon if I don't take care 
of this now. It does keep my server logs from filling.

rtg

-- 
Tim Gardner tim.gardner@canonical.com

--------------060800060503040005000102
Content-Type: text/x-patch;
 name="0001-net-Print-num_rx_queues-imbalance-warning-only-when-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-net-Print-num_rx_queues-imbalance-warning-only-when-.pa";
 filename*1="tch"

>From 02598ea1409568654a554fae3ac2c22ecc2474d0 Mon Sep 17 00:00:00 2001
From: Tim Gardner <tim.gardner@canonical.com>
Date: Tue, 8 Jun 2010 17:51:27 -0600
Subject: [PATCH] net: Print num_rx_queues imbalance warning only when there are allocated queues

BugLink: http://bugs.launchpad.net/bugs/591416

So far no users of skb_record_rx_queue() use alloc_netdev_mq() for
network device initialization, so don't print a warning about num_rx_queues
imbalances in get_rps_cpu() unless they have actually been allocated.

Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d03470f..0852608 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2253,7 +2253,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
 		if (unlikely(index >= dev->num_rx_queues)) {
-			if (net_ratelimit()) {
+			if (dev->num_rx_queues > 1 && net_ratelimit()) {
 				pr_warning("%s received packet on queue "
 					"%u, but number of RX queues is %u\n",
 					dev->name, index, dev->num_rx_queues);
-- 
1.7.0.4


--------------060800060503040005000102--
