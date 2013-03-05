From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH 2/2] benet: Wait I/O while resuming device
Date: Tue, 5 Mar 2013 07:59:32 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C0F257AA2@CMEXMB1.ad.emulex.com>
References: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1362383327-32362-2-git-send-email-shangw@linux.vnet.ibm.com>
 <1433171e-68da-4ebb-924f-e18b3f43858c@CMEXHTCAS2.ad.emulex.com>
 <20130304101841.GA20882@shangw.(null)>
 <67feeaf6-cd7c-4892-b76d-0344f9367ff4@CMEXHTCAS1.ad.emulex.com>
 <20130305072126.GA19947@shangw.(null)>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:47795 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619Ab3CEH7e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 02:59:34 -0500
In-Reply-To: <20130305072126.GA19947@shangw.(null)>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Gavin Shan [mailto:shangw@linux.vnet.ibm.com]
> 
> On Mon, Mar 04, 2013 at 11:11:21AM +0000, Perla, Sathya wrote:
> >> >> After resetting the adapter, the config space register (0x7c)
> >> >> might give fake information to indicate the f/w is ready. In turn,
> >> >> 0xFF's is always returned while accessing on I/O space registers.
> >> >> The patch adds more check to make sure the I/O space is ready for
> >> >> access before
> >> accessing that region.
> >> >>
> >> >...
> >> >>
....
> >> >
> >>
> >> I don't think 0xffffffff here indicates a new EEH error and the
> >> adapter was recovering from EEH error, which already happened before.
> >
> >>
> >> Actually, I'm developing new feature to support EEH for PowerNV (PPC)
> >> platform. While the benet adapter detected EEH error and tried to
> >> resume, the I/O access always returned 0xffffffff even through I
> >> could get correct values from the config space. Since I don't have
> >> the specification, I would guess the config space becomes ready prior
> >> to I/O space after resetting the adapter and its firmware.
> >
> >The root-cause here is that the config-space/0x7c register is
> >incorrectly reflecting the POST state to be FW_READY. This causes the
> >driver to go ahead and read I/O space "prematurely" causing a 0xffffffff read.
> >The config-space/0x7c register reflects the correct value a little
> >later. This happens only for BE2/3 chips.
> >
> 
> Yes, Sathya. It's exactly the case happened on BE3.
> 
> >I propose to fix this by polling instead on CSR-BAR/0xac register for
> >POST status for BE2/3 chips.
> >
> 
> Do you mean to poll CSR-BAR/0xac (adapter->db + 0xac) for POST status? I just
> had one experiment. It seems that CSR-BAR/0xac always returns 0x0 even
> though the firmware have been ready completely. Could you please double-
> check on it?

Gavin, The CSR-BAR is not being mapped in the current code.
That should be done as a part of the fix....

Would it be possible for you to test this patch. 
I have it working on my setup but I feel it still needs some regression testing...

---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |   10 ++++++----
 drivers/net/ethernet/emulex/benet/be_hw.h   |    4 ++--
 drivers/net/ethernet/emulex/benet/be_main.c |    9 +++++++++
 4 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 28ceb84..03c638f 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -349,6 +349,7 @@ struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
 
+	u8 __iomem *csr;
 	u8 __iomem *db;		/* Door Bell */
 
 	struct mutex mbox_lock; /* For serializing mbox cmds to BE card */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 071aea7..91b4f88 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -476,12 +476,14 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
 static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 {
 	u32 sem;
-	u32 reg = skyhawk_chip(adapter) ? SLIPORT_SEMAPHORE_OFFSET_SH :
-					  SLIPORT_SEMAPHORE_OFFSET_BE;
 
-	pci_read_config_dword(adapter->pdev, reg, &sem);
-	*stage = sem & POST_STAGE_MASK;
+	if (BEx_chip(adapter))
+		sem  = ioread32(adapter->csr + SLIPORT_SEMAPHORE_OFFSET_BEx);
+	else
+		pci_read_config_dword(adapter->pdev,
+				      SLIPORT_SEMAPHORE_OFFSET_SH, &sem);
 
+	*stage = sem & POST_STAGE_MASK;
 	if ((sem >> POST_ERR_SHIFT) & POST_ERR_MASK)
 		return -1;
 	else
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 541d453..62dc220 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -32,8 +32,8 @@
 #define MPU_EP_CONTROL 		0
 
 /********** MPU semphore: used for SH & BE  *************/
-#define SLIPORT_SEMAPHORE_OFFSET_BE		0x7c
-#define SLIPORT_SEMAPHORE_OFFSET_SH		0x94
+#define SLIPORT_SEMAPHORE_OFFSET_BEx		0xac  /* CSR BAR offset */
+#define SLIPORT_SEMAPHORE_OFFSET_SH		0x94  /* PCI-CFG offset */
 #define POST_STAGE_MASK				0x0000FFFF
 #define POST_ERR_MASK				0x1
 #define POST_ERR_SHIFT				31
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3860888..bd0d56f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3688,6 +3688,8 @@ static void be_netdev_init(struct net_device *netdev)
 
 static void be_unmap_pci_bars(struct be_adapter *adapter)
 {
+	if (adapter->csr)
+		pci_iounmap(adapter->pdev, adapter->csr);
 	if (adapter->db)
 		pci_iounmap(adapter->pdev, adapter->db);
 }
@@ -3721,6 +3723,13 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
 				SLI_INTF_IF_TYPE_SHIFT;
 
+	if (be_physfn(adapter) && BEx_chip(adapter)) {
+		addr = pci_iomap(adapter->pdev, 2, 0);
+		if (addr == NULL)
+			return -ENOMEM;
+		adapter->csr = addr;
+	}
+
 	addr = pci_iomap(adapter->pdev, db_bar(adapter), 0);
 	if (addr == NULL)
 		goto pci_map_err;
-- 
1.7.1
