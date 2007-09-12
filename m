From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 2/6] [NET_SCHED]: Making rate table lookups more flexible
Date: Wed, 12 Sep 2007 12:14:02 +0200
Message-ID: <1189592042.26927.23.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:39716 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061AbXILKOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 57e993268df114a4270519b1004b8ea8086f671f
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Tue Sep 11 15:44:15 2007 +0200

    [NET_SCHED]: Making rate table lookups more flexible.
    
     This is done in order to, add support to changing the rate table to
     use the upper-boundry L2T (length to time) value. Currently we use the
     lower-boundry, which result in under-estimating the actual bandwidth
     usage.
    
     Extend the tc_ratespec struct, with two parameters: 1) "cell_align"
     that allow adjusting the alignment of the rate table. 2) "overhead"
     that allow adding a packet overhead before the lookup.
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 268c515..919af93 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -77,8 +77,8 @@ struct tc_ratespec
 {
 	unsigned char	cell_log;
 	unsigned char	__reserved;
-	unsigned short	feature;
-	short		addend;
+	unsigned short	overhead;
+	short		cell_align;
 	unsigned short	mpu;
 	__u32		rate;
 };
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4ebd615..a02ec9e 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -307,7 +307,9 @@ drop:
  */
 static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
 {
-	int slot = pktlen;
+	int slot = pktlen + rtab->rate.cell_align + rtab->rate.overhead;
+	if (slot < 0)
+		slot = 0;
 	slot >>= rtab->rate.cell_log;
 	if (slot > 255)
 		return (rtab->data[255]*(slot >> 8) + rtab->data[slot & 0xFF]);

