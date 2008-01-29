From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] cxgb3: Remove incorrect __devinit annotations
Date: Tue, 29 Jan 2008 14:45:11 -0800
Message-ID: <adak5lsdzew.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:40196 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbYA2WpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 17:45:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When PCI error recovery was added to cxgb3, a function t3_io_slot_reset()
was added.  This function can call back into t3_prep_adapter() at any
time, so t3_prep_adapter() can no longer be marked __devinit.
This patch removes the __devinit annotation from t3_prep_adapter() and
all the functions that it calls, which fixes

    WARNING: drivers/net/cxgb3/built-in.o(.text+0x2427): Section mismatch in reference from the function t3_io_slot_reset() to the function .devinit.text:t3_prep_adapter()

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/cxgb3/mc5.c   |    2 +-
 drivers/net/cxgb3/sge.c   |    2 +-
 drivers/net/cxgb3/t3_hw.c |   22 ++++++++++------------
 3 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cxgb3/mc5.c b/drivers/net/cxgb3/mc5.c
index 84c1ffa..4c4d6e8 100644
--- a/drivers/net/cxgb3/mc5.c
+++ b/drivers/net/cxgb3/mc5.c
@@ -452,7 +452,7 @@ void t3_mc5_intr_handler(struct mc5 *mc5)
 	t3_write_reg(adap, A_MC5_DB_INT_CAUSE, cause);
 }
 
-void __devinit t3_mc5_prep(struct adapter *adapter, struct mc5 *mc5, int mode)
+void t3_mc5_prep(struct adapter *adapter, struct mc5 *mc5, int mode)
 {
 #define K * 1024
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index cb684d3..9ca8c66 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2836,7 +2836,7 @@ void t3_sge_init(struct adapter *adap, struct sge_params *p)
  *	defaults for the assorted SGE parameters, which admins can change until
  *	they are used to initialize the SGE.
  */
-void __devinit t3_sge_prep(struct adapter *adap, struct sge_params *p)
+void t3_sge_prep(struct adapter *adap, struct sge_params *p)
 {
 	int i;
 
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 7469935..a99496a 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -2675,7 +2675,7 @@ void t3_tp_set_max_rxsize(struct adapter *adap, unsigned int size)
 		     V_PMMAXXFERLEN0(size) | V_PMMAXXFERLEN1(size));
 }
 
-static void __devinit init_mtus(unsigned short mtus[])
+static void init_mtus(unsigned short mtus[])
 {
 	/*
 	 * See draft-mathis-plpmtud-00.txt for the values.  The min is 88 so
@@ -2703,7 +2703,7 @@ static void __devinit init_mtus(unsigned short mtus[])
 /*
  * Initial congestion control parameters.
  */
-static void __devinit init_cong_ctrl(unsigned short *a, unsigned short *b)
+static void init_cong_ctrl(unsigned short *a, unsigned short *b)
 {
 	a[0] = a[1] = a[2] = a[3] = a[4] = a[5] = a[6] = a[7] = a[8] = 1;
 	a[9] = 2;
@@ -3354,8 +3354,7 @@ out_err:
  *	Determines a card's PCI mode and associated parameters, such as speed
  *	and width.
  */
-static void __devinit get_pci_mode(struct adapter *adapter,
-				   struct pci_params *p)
+static void get_pci_mode(struct adapter *adapter, struct pci_params *p)
 {
 	static unsigned short speed_map[] = { 33, 66, 100, 133 };
 	u32 pci_mode, pcie_cap;
@@ -3395,8 +3394,7 @@ static void __devinit get_pci_mode(struct adapter *adapter,
  *	capabilities and default speed/duplex/flow-control/autonegotiation
  *	settings.
  */
-static void __devinit init_link_config(struct link_config *lc,
-				       unsigned int caps)
+static void init_link_config(struct link_config *lc, unsigned int caps)
 {
 	lc->supported = caps;
 	lc->requested_speed = lc->speed = SPEED_INVALID;
@@ -3419,7 +3417,7 @@ static void __devinit init_link_config(struct link_config *lc,
  *	Calculates the size of an MC7 memory in bytes from the value of its
  *	configuration register.
  */
-static unsigned int __devinit mc7_calc_size(u32 cfg)
+static unsigned int mc7_calc_size(u32 cfg)
 {
 	unsigned int width = G_WIDTH(cfg);
 	unsigned int banks = !!(cfg & F_BKS) + 1;
@@ -3430,8 +3428,8 @@ static unsigned int __devinit mc7_calc_size(u32 cfg)
 	return MBs << 20;
 }
 
-static void __devinit mc7_prep(struct adapter *adapter, struct mc7 *mc7,
-			       unsigned int base_addr, const char *name)
+static void mc7_prep(struct adapter *adapter, struct mc7 *mc7,
+		     unsigned int base_addr, const char *name)
 {
 	u32 cfg;
 
@@ -3517,7 +3515,7 @@ static int t3_reset_adapter(struct adapter *adapter)
 	return 0;
 }
 
-static int __devinit init_parity(struct adapter *adap)
+static int init_parity(struct adapter *adap)
 {
 		int i, err, addr;
 
@@ -3552,8 +3550,8 @@ static int __devinit init_parity(struct adapter *adap)
  * for some adapter tunables, take PHYs out of reset, and initialize the MDIO
  * interface.
  */
-int __devinit t3_prep_adapter(struct adapter *adapter,
-			      const struct adapter_info *ai, int reset)
+int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
+		    int reset)
 {
 	int ret;
 	unsigned int i, j = 0;
