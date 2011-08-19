From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/6] tg3: Restructure tg3_test_loopback
Date: Fri, 19 Aug 2011 16:58:22 -0700
Message-ID: <1313798304-26171-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2236 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810Ab1HSXu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 19:50:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tg3_test_loopback() function is starting to get more complicated as
more loopback tests are added.  This patch cleans up the code.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   80 +++++++++++++++++-----------------
 1 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 5e9d8a0..6827b4f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -390,12 +390,13 @@ static const struct {
 static const struct {
 	const char string[ETH_GSTRING_LEN];
 } ethtool_test_keys[] = {
-	{ "nvram test     (online) " },
-	{ "link test      (online) " },
-	{ "register test  (offline)" },
-	{ "memory test    (offline)" },
-	{ "loopback test  (offline)" },
-	{ "interrupt test (offline)" },
+	{ "nvram test        (online) " },
+	{ "link test         (online) " },
+	{ "register test     (offline)" },
+	{ "memory test       (offline)" },
+	{ "mac loopback test (offline)" },
+	{ "phy loopback test (offline)" },
+	{ "interrupt test    (offline)" },
 };
 
 #define TG3_NUM_TEST	ARRAY_SIZE(ethtool_test_keys)
@@ -11310,10 +11311,6 @@ static int tg3_test_memory(struct tg3 *tp)
 	return err;
 }
 
-#define TG3_MAC_LOOPBACK	0
-#define TG3_PHY_LOOPBACK	1
-#define TG3_TSO_LOOPBACK	2
-
 #define TG3_TSO_MSS		500
 
 #define TG3_TSO_IP_HDR_LEN	20
@@ -11337,7 +11334,7 @@ static const u8 tg3_tso_header[] = {
 0x11, 0x11, 0x11, 0x11,
 };
 
-static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
+static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, bool tso_loopback)
 {
 	u32 rx_start_idx, rx_idx, tx_idx, opaque_key;
 	u32 base_flags = 0, mss = 0, desc_idx, coal_now, data_off, val;
@@ -11373,7 +11370,7 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 
 	tw32(MAC_RX_MTU_SIZE, tx_len + ETH_FCS_LEN);
 
-	if (loopback_mode == TG3_TSO_LOOPBACK) {
+	if (tso_loopback) {
 		struct iphdr *iph = (struct iphdr *)&tx_data[ETH_HLEN];
 
 		u32 hdr_len = TG3_TSO_IP_HDR_LEN + TG3_TSO_TCP_HDR_LEN +
@@ -11493,7 +11490,7 @@ static int tg3_run_loopback(struct tg3 *tp, u32 pktsz, int loopback_mode)
 		rx_len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT)
 			 - ETH_FCS_LEN;
 
-		if (loopback_mode != TG3_TSO_LOOPBACK) {
+		if (!tso_loopback) {
 			if (rx_len != tx_len)
 				goto out;
 
@@ -11540,25 +11537,29 @@ out:
 #define TG3_STD_LOOPBACK_FAILED		1
 #define TG3_JMB_LOOPBACK_FAILED		2
 #define TG3_TSO_LOOPBACK_FAILED		4
+#define TG3_LOOPBACK_FAILED \
+	(TG3_STD_LOOPBACK_FAILED | \
+	 TG3_JMB_LOOPBACK_FAILED | \
+	 TG3_TSO_LOOPBACK_FAILED)
 
-#define TG3_MAC_LOOPBACK_SHIFT		0
-#define TG3_PHY_LOOPBACK_SHIFT		4
-#define TG3_LOOPBACK_FAILED		0x00000077
-
-static int tg3_test_loopback(struct tg3 *tp)
+static int tg3_test_loopback(struct tg3 *tp, u64 *data)
 {
-	int err = 0;
+	int err = -EIO;
 	u32 eee_cap;
 
-	if (!netif_running(tp->dev))
-		return TG3_LOOPBACK_FAILED;
-
 	eee_cap = tp->phy_flags & TG3_PHYFLG_EEE_CAP;
 	tp->phy_flags &= ~TG3_PHYFLG_EEE_CAP;
 
+	if (!netif_running(tp->dev)) {
+		data[0] = TG3_LOOPBACK_FAILED;
+		data[1] = TG3_LOOPBACK_FAILED;
+		goto done;
+	}
+
 	err = tg3_reset_hw(tp, 1);
 	if (err) {
-		err = TG3_LOOPBACK_FAILED;
+		data[0] = TG3_LOOPBACK_FAILED;
+		data[1] = TG3_LOOPBACK_FAILED;
 		goto done;
 	}
 
@@ -11580,14 +11581,12 @@ static int tg3_test_loopback(struct tg3 *tp)
 	    !tg3_flag(tp, CPMU_PRESENT)) {
 		tg3_mac_loopback(tp, true);
 
-		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_MAC_LOOPBACK))
-			err |= TG3_STD_LOOPBACK_FAILED <<
-			       TG3_MAC_LOOPBACK_SHIFT;
+		if (tg3_run_loopback(tp, ETH_FRAME_LEN, false))
+			data[0] |= TG3_STD_LOOPBACK_FAILED;
 
 		if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
-		    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_MAC_LOOPBACK))
-			err |= TG3_JMB_LOOPBACK_FAILED <<
-			       TG3_MAC_LOOPBACK_SHIFT;
+		    tg3_run_loopback(tp, 9000 + ETH_HLEN, false))
+			data[0] |= TG3_JMB_LOOPBACK_FAILED;
 
 		tg3_mac_loopback(tp, false);
 	}
@@ -11605,23 +11604,22 @@ static int tg3_test_loopback(struct tg3 *tp)
 			mdelay(1);
 		}
 
-		if (tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_PHY_LOOPBACK))
-			err |= TG3_STD_LOOPBACK_FAILED <<
-			       TG3_PHY_LOOPBACK_SHIFT;
+		if (tg3_run_loopback(tp, ETH_FRAME_LEN, false))
+			data[1] |= TG3_STD_LOOPBACK_FAILED;
 		if (tg3_flag(tp, TSO_CAPABLE) &&
-		    tg3_run_loopback(tp, ETH_FRAME_LEN, TG3_TSO_LOOPBACK))
-			err |= TG3_TSO_LOOPBACK_FAILED <<
-			       TG3_PHY_LOOPBACK_SHIFT;
+		    tg3_run_loopback(tp, ETH_FRAME_LEN, true))
+			data[1] |= TG3_TSO_LOOPBACK_FAILED;
 		if (tg3_flag(tp, JUMBO_RING_ENABLE) &&
-		    tg3_run_loopback(tp, 9000 + ETH_HLEN, TG3_PHY_LOOPBACK))
-			err |= TG3_JMB_LOOPBACK_FAILED <<
-			       TG3_PHY_LOOPBACK_SHIFT;
+		    tg3_run_loopback(tp, 9000 + ETH_HLEN, false))
+			data[1] |= TG3_JMB_LOOPBACK_FAILED;
 
 		/* Re-enable gphy autopowerdown. */
 		if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
 			tg3_phy_toggle_apd(tp, true);
 	}
 
+	err = (data[0] | data[1]) ? -EIO : 0;
+
 done:
 	tp->phy_flags |= eee_cap;
 
@@ -11676,18 +11674,20 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 			etest->flags |= ETH_TEST_FL_FAILED;
 			data[2] = 1;
 		}
+
 		if (tg3_test_memory(tp) != 0) {
 			etest->flags |= ETH_TEST_FL_FAILED;
 			data[3] = 1;
 		}
-		if ((data[4] = tg3_test_loopback(tp)) != 0)
+
+		if (tg3_test_loopback(tp, &data[4]))
 			etest->flags |= ETH_TEST_FL_FAILED;
 
 		tg3_full_unlock(tp);
 
 		if (tg3_test_interrupt(tp) != 0) {
 			etest->flags |= ETH_TEST_FL_FAILED;
-			data[5] = 1;
+			data[6] = 1;
 		}
 
 		tg3_full_lock(tp, 0);
-- 
1.7.3.4


