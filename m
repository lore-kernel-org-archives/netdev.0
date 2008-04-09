From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH 2/7] ATM cell alignment.
Date: Wed, 9 Apr 2008 23:01:01 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:60255 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485AbYDIVBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 17:01:04 -0400
In-Reply-To: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Introducing the function that does the ATM cell alignment, and
modifying tc_calc_rtable() to use this based upon a linklayer
parameter.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
  tc/tc_core.c |   36 +++++++++++++++++++++++++++++++++++-
  tc/tc_core.h |    6 +++++-
  2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 9ae4d8e..a9b8076 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -65,11 +65,35 @@ unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
  	return ((double)rate*tc_core_tick2time(ticks))/TIME_UNITS_PER_SEC;
  }

+#define ATM_CELL_SIZE               53  /* ATM cell size incl. header */
+#define ATM_CELL_PAYLOAD            48  /* ATM payload size */
+/*
+ The align to ATM cells is used for determining the (ATM) SAR
+ alignment overhead at the ATM layer. (SAR = Segmentation And
+ Reassembly).  This is for example needed when scheduling packet on an
+ ADSL connection.  Note that the extra ATM-AAL overhead is _not_
+ included in this calculation. This overhead is added in the kernel
+ before doing the rate table lookup, as this gives better precision
+ (as the table will always be aligned for 48 bytes).
+  --Hawk, d.7/11-2004. <hawk@diku.dk>
+ */
+unsigned tc_align_to_atm(unsigned size)
+{
+	int linksize, cells;
+	cells = size / ATM_CELL_PAYLOAD;
+	if ((size % ATM_CELL_PAYLOAD) > 0) {
+		cells++;
+	}
+	linksize = cells * ATM_CELL_SIZE; /* Use full cell size to add ATM tax */
+	return linksize;
+}
+
  /*
     rtab[pkt_len>>cell_log] = pkt_xmit_time
   */

-int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab, int cell_log, unsigned mtu)
+int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab, int cell_log, unsigned mtu,
+		   unsigned int linklayer)
  {
  	int i;
  	unsigned bps = r->rate;
@@ -87,6 +111,16 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab, int cell_log, unsigned mt
  		unsigned sz = ((i+1)<<cell_log);
  		if (sz < mpu)
  			sz = mpu;
+		switch (linklayer) {
+		case LINKLAYER_ATM:
+			sz = tc_align_to_atm(sz);
+			break;
+		case LINKLAYER_ETHERNET:
+			// No size adjustments on Ethernet
+			break;
+		default:
+			break;
+		}
  		rtab[i] = tc_calc_xmittime(bps, sz);
  	}
  	r->cell_align=-1; // Due to the sz calc
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 080a0cd..7b2eaa0 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -6,6 +6,9 @@

  #define TIME_UNITS_PER_SEC	1000000

+#define LINKLAYER_ETHERNET 1
+#define LINKLAYER_ATM      2
+
  int  tc_core_time2big(unsigned time);
  unsigned tc_core_time2tick(unsigned time);
  unsigned tc_core_tick2time(unsigned tick);
@@ -13,7 +16,8 @@ unsigned tc_core_time2ktime(unsigned time);
  unsigned tc_core_ktime2time(unsigned ktime);
  unsigned tc_calc_xmittime(unsigned rate, unsigned size);
  unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks);
-int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab, int cell_log, unsigned mtu);
+int tc_calc_rtable(struct tc_ratespec *r, __u32 *rtab, int cell_log, unsigned mtu,
+		   unsigned int linklayer);

  int tc_setup_estimator(unsigned A, unsigned time_const, struct tc_estimator *est);

-- 
1.5.3

