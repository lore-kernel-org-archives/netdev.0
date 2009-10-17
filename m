From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT v2 4/7] netxen: onchip memory access change
Date: Fri, 16 Oct 2009 18:50:09 -0700
Message-ID: <1255744212-28074-5-git-send-email-dhananjay@netxen.com>
References: <1255744212-28074-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:49995 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752285AbZJQBuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 21:50:10 -0400
In-Reply-To: <1255744212-28074-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@netxen.com>

Add support for different windowing scheme for on chip
memory in future chip revisions. This is required by
diagnostic tools.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hdr.h  |    3 +++
 drivers/net/netxen/netxen_nic_hw.c   |   17 +++++++++--------
 drivers/net/netxen/netxen_nic_main.c |    6 +++++-
 3 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index d40fe33..7386a7c 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -867,6 +867,9 @@ enum {
 		(PCIX_SN_WINDOW_F0 + (0x20 * (func))) :\
 		(PCIX_SN_WINDOW_F4 + (0x10 * ((func)-4))))
 
+#define PCIX_OCM_WINDOW		(0x10800)
+#define PCIX_OCM_WINDOW_REG(func)	(PCIX_OCM_WINDOW + 0x20 * (func))
+
 #define PCIX_TARGET_STATUS	(0x10118)
 #define PCIX_TARGET_STATUS_F1	(0x10160)
 #define PCIX_TARGET_STATUS_F2	(0x10164)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 52a2f2d..a633246 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -31,6 +31,7 @@
 #define MASK(n) ((1ULL<<(n))-1)
 #define MN_WIN(addr) (((addr & 0x1fc0000) >> 1) | ((addr >> 25) & 0x3ff))
 #define OCM_WIN(addr) (((addr & 0x1ff0000) >> 1) | ((addr >> 25) & 0x3ff))
+#define OCM_WIN_P3P(addr) (addr & 0xffc0000)
 #define MS_WIN(addr) (addr & 0x0ffc0000)
 
 #define GET_MEM_OFFS_2M(addr) (addr & MASK(18))
@@ -1338,7 +1339,7 @@ static int
 netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		u64 addr, u32 *start)
 {
-	u32 win_read, window;
+	u32 window;
 	struct pci_dev *pdev = adapter->pdev;
 
 	if ((addr & 0x00ff800) == 0xff800) {
@@ -1347,14 +1348,14 @@ netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 		return -EIO;
 	}
 
-	window = OCM_WIN(addr);
+	if (NX_IS_REVISION_P3P(adapter->ahw.revision_id))
+		window = OCM_WIN_P3P(addr);
+	else
+		window = OCM_WIN(addr);
+
 	writel(window, adapter->ahw.ocm_win_crb);
-	win_read = readl(adapter->ahw.ocm_win_crb);
-	if ((win_read >> 7) != window) {
-		if (printk_ratelimit())
-			dev_warn(&pdev->dev, "failed to set OCM window\n");
-		return -EIO;
-	}
+	/* read back to flush */
+	readl(adapter->ahw.ocm_win_crb);
 
 	adapter->ahw.ocm_win = window;
 	*start = NETXEN_PCI_OCM0_2M + GET_MEM_OFFS_2M(addr);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2d772dd..30d9afe 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -649,7 +649,11 @@ netxen_setup_pci_map(struct netxen_adapter *adapter)
 	adapter->ahw.pci_base1 = mem_ptr1;
 	adapter->ahw.pci_base2 = mem_ptr2;
 
-	if (!NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+	if (NX_IS_REVISION_P3P(adapter->ahw.revision_id)) {
+		adapter->ahw.ocm_win_crb = netxen_get_ioaddr(adapter,
+			NETXEN_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(pci_func)));
+
+	} else if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		adapter->ahw.ocm_win_crb = netxen_get_ioaddr(adapter,
 			NETXEN_PCIX_PS_REG(PCIE_MN_WINDOW_REG(pci_func)));
 	}
-- 
1.6.0.2

