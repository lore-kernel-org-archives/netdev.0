From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: [PATCH] fix use after free in e100
Date: 02 Jun 2003 01:04:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054508698.24777.17.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Scott.

Here's a fix for a use-after-free in the e100 driver.
You can't touch the skb after a call to netif_rx(), it might have been
free'd. Caught with Manfred's unmap-page-debugging patch in -mm.

Applies to both 2.4 and 2.5

--- linux-2.5.69-mm9/drivers/net/e100/e100_main.c.orig	2003-06-02 00:48:13.000000000 +0200
+++ linux-2.5.69-mm9/drivers/net/e100/e100_main.c	2003-06-02 00:50:09.000000000 +0200
@@ -2052,13 +2052,14 @@
 			skb->ip_summed = CHECKSUM_NONE;
 		}
 
+		bdp->drv_stats.net_stats.rx_bytes += skb->len;
+
 		if(bdp->vlgrp && (rfd_status & CB_STATUS_VLAN)) {
 			vlan_hwaccel_rx(skb, bdp->vlgrp, be16_to_cpu(rfd->vlanid));
 		} else {
 			netif_rx(skb);
 		}
 		dev->last_rx = jiffies;
-		bdp->drv_stats.net_stats.rx_bytes += skb->len;
 		
 		rfd_cnt++;
 	}			/* end of rfd loop */


-- 
/Martin
