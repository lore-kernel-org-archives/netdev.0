From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v2 1/2] [iproute2/tc] tc_core: add size table
Date: Tue, 24 Jun 2008 11:55:14 +0300
Message-ID: <20080624085514.22540.91038.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:36378 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757684AbYFXIzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 04:55:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch adds size table that is similiar to rate table, with difference that
size table stores link layer packet size. It's needed for HFSC link
layer adaption patch as it converts skb->len to link layer packet size
directly, unlike HTB/CFQ/etc that convert packet length to link layer
transfer time using rate tables.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |   10 ++++++
 tc/tc_core.c              |   73 ++++++++++++++++++++++++++++++++++++---------
 tc/tc_core.h              |    2 +
 3 files changed, 70 insertions(+), 15 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..b8366fb 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,16 @@ struct tc_ratespec
 
 #define TC_RTAB_SIZE	1024
 
+struct tc_sizespec {
+	unsigned char	cell_log;
+	unsigned char	size_log;
+	unsigned short	overhead;
+	short		cell_align;
+	unsigned short	mpu;
+};
+
+#define TC_STAB_SIZE	1024
+
 /* FIFO section */
 
 struct tc_fifo_qopt
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 855c115..ca509d9 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -87,6 +87,25 @@ unsigned tc_align_to_atm(unsigned size)
 	return linksize;
 }
 
+unsigned tc_adjust_size(unsigned sz, unsigned mpu, enum link_layer linklayer)
+{
+	if (sz < mpu)
+		sz = mpu;
+
+	switch (linklayer) {
+	case LINKLAYER_ATM:
+		sz = tc_align_to_atm(sz);
+		break;
+	case LINKLAYER_ETHERNET:
+		// No size adjustments on Ethernet
+		break;
+	default:
+		break;
+	}
+
+	return sz;
+}
+
 /*
    rtab[pkt_len>>cell_log] = pkt_xmit_time
  */
@@ -109,21 +128,7 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 	}
 
 	for (i=0; i<256; i++) {
-		unsigned sz = (i+1)<<cell_log;
-		if (sz < mpu)
-			sz = mpu;
-
-		switch (linklayer) {
-		case LINKLAYER_ATM:
-			sz = tc_align_to_atm(sz);
-			break;
-		case LINKLAYER_ETHERNET:
-			// No size adjustments on Ethernet
-			break;
-		default:
-			break;
-		}
-
+		unsigned sz = tc_adjust_size((i+1)<<cell_log, mpu, linklayer);
 		rtab[i] = tc_calc_xmittime(bps, sz);
 	}
 
@@ -132,6 +137,44 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 	return cell_log;
 }
 
+/*
+   stab[pkt_len>>cell_log] = pkt_xmit_size
+ */
+
+int tc_calc_stable(struct tc_sizespec *s, __u16 *stab,
+		   int cell_log, unsigned mtu,
+		   enum link_layer linklayer)
+{
+	int i;
+	unsigned mpu = s->mpu;
+	unsigned size_log = 0;
+	unsigned sz;
+
+	if (mtu == 0)
+		mtu = 2047;
+
+	if (cell_log < 0) {
+		cell_log = 0;
+		while ((mtu >> cell_log) > 512 - 1)
+			cell_log++;
+	}
+
+again:
+	for (i = 512 - 1; i >= 0; i--) {
+		sz = tc_adjust_size((i + 1) << cell_log, mpu, linklayer);
+		if ((sz >> size_log) > UINT16_MAX) {
+			size_log++;
+			goto again;
+		}
+		stab[i] = sz >> size_log;
+	}
+
+	s->size_log = size_log;
+	s->cell_align = -1; // Due to the sz calc
+	s->cell_log = cell_log;
+	return cell_log;
+}
+
 int tc_core_init()
 {
 	FILE *fp;
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 9f835e8..97a4894 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -21,6 +21,8 @@ unsigned tc_calc_xmittime(unsigned rate, unsigned size);
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
 int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab,
 		   int cell_log, unsigned mtu, enum link_layer link_layer);
+int tc_calc_stable(struct tc_sizespec *r, __u16 *stab,
+		   int cell_log, unsigned mtu, enum link_layer link_layer);
 
 int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator *est);
 

