From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 2/2]: [NET_SCHED]: Making rate table lookups more flexible.
Date: Fri, 31 Aug 2007 14:22:58 +0200
Message-ID: <1188562978.18622.13.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <jdb@comx.dk>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:43859 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932558AbXHaM5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 08:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit ac093f5c2f1160ece72a6fef5c779c1892fc3152
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Fri Aug 31 11:53:35 2007 +0200

    [NET_SCHED]: Making rate table lookups more flexible.  Extend the
    tc_ratespec struct, with two parameters: 1) "cell_align" that allow
    adjusting the alignment of the rate table. 2) "overhead" that allow
    adding a packet overhead before the lookup.
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 268c515..a127d63 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -78,7 +78,8 @@ struct tc_ratespec
 	unsigned char	cell_log;
 	unsigned char	__reserved;
 	unsigned short	feature;
-	short		addend;
+	char		cell_align;
+	unsigned char	overhead;
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

