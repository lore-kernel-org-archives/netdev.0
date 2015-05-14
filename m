From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] ip_tunnel: Report Rx dropped in
 ip_tunnel_get_stats64
Date: Thu, 14 May 2015 14:01:27 -0700
Message-ID: <1431637287.27831.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150514200454.1537.43655.stgit@ahduyck-vm-fedora22>
	 <1431636994.27831.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36716 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933271AbbENVBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 17:01:30 -0400
Received: by qkgw4 with SMTP id w4so17929693qkg.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 14:01:29 -0700 (PDT)
In-Reply-To: <1431636994.27831.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 13:56 -0700, Eric Dumazet wrote:

> 
> Or use netdev_stats_to_stats64() to remove all these copies, as we
> obviously can miss some of them.

Something like following untested patch :

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 3998b1822d8521ad391ac26db1e694a3cd7ad011..3f298193d19ffc3a9e57fac4654c59bbe65545e1 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -165,6 +165,7 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 {
 	int i;
 
+	netdev_stats_to_stats64(tot, &dev->stats);
 	for_each_possible_cpu(i) {
 		const struct pcpu_sw_netstats *tstats =
 						   per_cpu_ptr(dev->tstats, i);
@@ -184,23 +185,6 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 		tot->rx_bytes   += rx_bytes;
 		tot->tx_bytes   += tx_bytes;
 	}
-
-	tot->multicast = dev->stats.multicast;
-
-	tot->rx_crc_errors = dev->stats.rx_crc_errors;
-	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
-	tot->rx_length_errors = dev->stats.rx_length_errors;
-	tot->rx_frame_errors = dev->stats.rx_frame_errors;
-	tot->rx_errors = dev->stats.rx_errors;
-
-	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
-	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
-	tot->tx_dropped = dev->stats.tx_dropped;
-	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
-	tot->tx_errors = dev->stats.tx_errors;
-
-	tot->collisions  = dev->stats.collisions;
-
 	return tot;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_get_stats64);
