From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 12/26] igb: update testing done by ethtool
Date: Sat, 07 Feb 2009 01:18:48 -0800
Message-ID: <20090207091848.15697.60366.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:55536
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbZBGJTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:19:09 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Most of the code for the testing has pretty much become stale at this point
and is need of update.  This update just streamlines most of the code,
widens the range of interrupt testing.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |   87 +++++++++++++++++++++++++++++------------
 1 files changed, 61 insertions(+), 26 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index d7bdc6c..33c23a1 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -855,23 +855,26 @@ static struct igb_reg_test reg_test_82576[] = {
 	{ E1000_RDBAL(0),  0x100, 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
 	{ E1000_RDBAH(0),  0x100, 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ E1000_RDLEN(0),  0x100, 4, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
-	{ E1000_RDBAL(4),  0x40,  8, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
-	{ E1000_RDBAH(4),  0x40,  8, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_RDLEN(4),  0x40,  8, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
-	/* Enable all four RX queues before testing. */
-	{ E1000_RXDCTL(0), 0x100, 1,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
+	{ E1000_RDBAL(4),  0x40, 12, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(4),  0x40, 12, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(4),  0x40, 12, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	/* Enable all RX queues before testing. */
+	{ E1000_RXDCTL(0), 0x100, 4,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
+	{ E1000_RXDCTL(4), 0x40, 12,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
 	/* RDH is read-only for 82576, only test RDT. */
 	{ E1000_RDT(0),	   0x100, 4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_RDT(4),	   0x40, 12,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
 	{ E1000_RXDCTL(0), 0x100, 4,  WRITE_NO_TEST, 0, 0 },
+	{ E1000_RXDCTL(4), 0x40, 12,  WRITE_NO_TEST, 0, 0 },
 	{ E1000_FCRTH,	   0x100, 1,  PATTERN_TEST, 0x0000FFF0, 0x0000FFF0 },
 	{ E1000_FCTTV,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
 	{ E1000_TIPG,	   0x100, 1,  PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
 	{ E1000_TDBAL(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
 	{ E1000_TDBAH(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
 	{ E1000_TDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
-	{ E1000_TDBAL(4),  0x40, 8,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
-	{ E1000_TDBAH(4),  0x40, 8,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
-	{ E1000_TDLEN(4),  0x40, 8,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_TDBAL(4),  0x40, 12,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(4),  0x40, 12,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(4),  0x40, 12,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
 	{ E1000_RCTL,	   0x100, 1,  SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
 	{ E1000_RCTL, 	   0x100, 1,  SET_READ_TEST, 0x04CFB0FE, 0x003FFFFB },
 	{ E1000_RCTL, 	   0x100, 1,  SET_READ_TEST, 0x04CFB0FE, 0xFFFFFFFF },
@@ -918,12 +921,13 @@ static struct igb_reg_test reg_test_82575[] = {
 static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 			     int reg, u32 mask, u32 write)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u32 pat, val;
 	u32 _test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
 	for (pat = 0; pat < ARRAY_SIZE(_test); pat++) {
-		writel((_test[pat] & write), (adapter->hw.hw_addr + reg));
-		val = readl(adapter->hw.hw_addr + reg);
+		wr32(reg, (_test[pat] & write));
+		val = rd32(reg);
 		if (val != (_test[pat] & write & mask)) {
 			dev_err(&adapter->pdev->dev, "pattern test reg %04X "
 				"failed: got 0x%08X expected 0x%08X\n",
@@ -938,9 +942,10 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
 			      int reg, u32 mask, u32 write)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u32 val;
-	writel((write & mask), (adapter->hw.hw_addr + reg));
-	val = readl(adapter->hw.hw_addr + reg);
+	wr32(reg, write & mask);
+	val = rd32(reg);
 	if ((write & mask) != (val & mask)) {
 		dev_err(&adapter->pdev->dev, "set/check reg %04X test failed:"
 			" got 0x%08X expected 0x%08X\n", reg,
@@ -1006,12 +1011,14 @@ static int igb_reg_test(struct igb_adapter *adapter, u64 *data)
 		for (i = 0; i < test->array_len; i++) {
 			switch (test->test_type) {
 			case PATTERN_TEST:
-				REG_PATTERN_TEST(test->reg + (i * test->reg_offset),
+				REG_PATTERN_TEST(test->reg +
+						(i * test->reg_offset),
 						test->mask,
 						test->write);
 				break;
 			case SET_READ_TEST:
-				REG_SET_AND_CHECK(test->reg + (i * test->reg_offset),
+				REG_SET_AND_CHECK(test->reg +
+						(i * test->reg_offset),
 						test->mask,
 						test->write);
 				break;
@@ -1083,16 +1090,17 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	u32 mask, i = 0, shared_int = true;
+	u32 mask, ics_mask, i = 0, shared_int = true;
 	u32 irq = adapter->pdev->irq;
 
 	*data = 0;
 
 	/* Hook up test interrupt handler just for this test */
-	if (adapter->msix_entries) {
+	if (adapter->msix_entries)
 		/* NOTE: we don't test MSI-X interrupts here, yet */
 		return 0;
-	} else if (adapter->flags & IGB_FLAG_HAS_MSI) {
+
+	if (adapter->flags & IGB_FLAG_HAS_MSI) {
 		shared_int = false;
 		if (request_irq(irq, &igb_test_intr, 0, netdev->name, netdev)) {
 			*data = 1;
@@ -1108,16 +1116,31 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	}
 	dev_info(&adapter->pdev->dev, "testing %s interrupt\n",
 		(shared_int ? "shared" : "unshared"));
-
 	/* Disable all the interrupts */
 	wr32(E1000_IMC, 0xFFFFFFFF);
 	msleep(10);
 
+	/* Define all writable bits for ICS */
+	switch(hw->mac.type) {
+	case e1000_82575:
+		ics_mask = 0x37F47EDD;
+		break;
+	case e1000_82576:
+		ics_mask = 0x77D4FBFD;
+		break;
+	default:
+		ics_mask = 0x7FFFFFFF;
+		break;
+	}
+
 	/* Test each interrupt */
-	for (; i < 10; i++) {
+	for (; i < 31; i++) {
 		/* Interrupt to test */
 		mask = 1 << i;
 
+		if (!(mask & ics_mask))
+			continue;
+
 		if (!shared_int) {
 			/* Disable the interrupt to be reported in
 			 * the cause register and then force the same
@@ -1126,8 +1149,12 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 			 * test failed.
 			 */
 			adapter->test_icr = 0;
-			wr32(E1000_IMC, ~mask & 0x00007FFF);
-			wr32(E1000_ICS, ~mask & 0x00007FFF);
+
+			/* Flush any pending interrupts */
+			wr32(E1000_ICR, ~0);
+
+			wr32(E1000_IMC, mask);
+			wr32(E1000_ICS, mask);
 			msleep(10);
 
 			if (adapter->test_icr & mask) {
@@ -1143,6 +1170,10 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 		 * test failed.
 		 */
 		adapter->test_icr = 0;
+
+		/* Flush any pending interrupts */
+		wr32(E1000_ICR, ~0);
+
 		wr32(E1000_IMS, mask);
 		wr32(E1000_ICS, mask);
 		msleep(10);
@@ -1160,11 +1191,15 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 			 * test failed.
 			 */
 			adapter->test_icr = 0;
-			wr32(E1000_IMC, ~mask & 0x00007FFF);
-			wr32(E1000_ICS, ~mask & 0x00007FFF);
+
+			/* Flush any pending interrupts */
+			wr32(E1000_ICR, ~0);
+
+			wr32(E1000_IMC, ~mask);
+			wr32(E1000_ICS, ~mask);
 			msleep(10);
 
-			if (adapter->test_icr) {
+			if (adapter->test_icr & mask) {
 				*data = 5;
 				break;
 			}
@@ -1172,7 +1207,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	}
 
 	/* Disable all the interrupts */
-	wr32(E1000_IMC, 0xFFFFFFFF);
+	wr32(E1000_IMC, ~0);
 	msleep(10);
 
 	/* Unhook test interrupt handler */
@@ -1450,7 +1485,7 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 			 E1000_CTRL_TFCE |
 			 E1000_CTRL_LRST);
 		reg |= E1000_CTRL_SLU |
-		       E1000_CTRL_FD; 
+		       E1000_CTRL_FD;
 		wr32(E1000_CTRL, reg);
 
 		/* Unset switch control to serdes energy detect */

