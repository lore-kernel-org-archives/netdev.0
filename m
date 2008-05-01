From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: forwarding table information for >256 devices
Date: Thu, 1 May 2008 13:42:09 -0700
Message-ID: <20080501134209.3012de69@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:46015 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755731AbYEAUmO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 16:42:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The forwarding table binary interface (my bad choice), only exposes the
port number of the first 8 bits. The bridge code was limited to 256 ports
at the time, but now the kernel supports up 1024 ports, so the upper bits
are lost when doing:
   brctl showmacs

The fix is to squeeze the extra bits into small hole left in data structure,
to maintain binary compatiablity.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/linux/if_bridge.h	2008-04-28 15:27:05.000000000 -0700
+++ b/include/linux/if_bridge.h	2008-04-28 15:31:38.000000000 -0700
@@ -97,7 +97,9 @@ struct __fdb_entry
 	__u8 port_no;
 	__u8 is_local;
 	__u32 ageing_timer_value;
-	__u32 unused;
+	__u8 port_hi;
+	__u8 pad0;
+	__u16 unused;
 };
 
 #ifdef __KERNEL__
--- a/net/bridge/br_fdb.c	2008-04-28 15:27:05.000000000 -0700
+++ b/net/bridge/br_fdb.c	2008-04-28 15:31:38.000000000 -0700
@@ -285,7 +285,11 @@ int br_fdb_fillbuf(struct net_bridge *br
 
 			/* convert from internal format to API */
 			memcpy(fe->mac_addr, f->addr.addr, ETH_ALEN);
+
+			/* due to ABI compat need to split into hi/lo */
 			fe->port_no = f->dst->port_no;
+			fe->port_hi = f->dst->port_no >> 8;
+
 			fe->is_local = f->is_local;
 			if (!f->is_static)
 				fe->ageing_timer_value = jiffies_to_clock_t(jiffies - f->ageing_timer);
