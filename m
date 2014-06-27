From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/5] rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is exposed through PCI Passthrough
Date: Fri, 27 Jun 2014 19:23:47 +0530
Message-ID: <1403877231-8661-2-git-send-email-hariprasad@chelsio.com>
References: <1403877231-8661-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403877231-8661-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Change logic which determines our Physical Function at PCI Probe time.
Now we read the PL_WHOAMI register and get the Physical Function.

Pass Physical Function to Upper Layer Drivers in lld_info structure in the
new field "pf" added to lld_info.  This is useful for the cases where the
PF, say PF4, is attached to a Virtual Machine via some form of "PCI
Pass Through" technology and the PCI Function shows up as PF0 in the VM.

Based on original work by Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Signed-off-by: Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c                |    3 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   18 ++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    1 +
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 5e153f6..d62a0f9 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -465,7 +465,8 @@ static void send_flowc(struct c4iw_ep *ep, struct sk_buff *skb)
 					  16)) | FW_WR_FLOWID(ep->hwtid));
 
 	flowc->mnemval[0].mnemonic = FW_FLOWC_MNEM_PFNVFN;
-	flowc->mnemval[0].val = cpu_to_be32(PCI_FUNC(ep->com.dev->rdev.lldi.pdev->devfn) << 8);
+	flowc->mnemval[0].val = cpu_to_be32(FW_PFVF_CMD_PFN
+					    (ep->com.dev->rdev.lldi.pf));
 	flowc->mnemval[1].mnemonic = FW_FLOWC_MNEM_CH;
 	flowc->mnemval[1].val = cpu_to_be32(ep->tx_chan);
 	flowc->mnemval[2].mnemonic = FW_FLOWC_MNEM_PORT;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index b7154dc..e8e77b8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4053,6 +4053,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	unsigned short i;
 
 	lli.pdev = adap->pdev;
+	lli.pf = adap->fn;
 	lli.l2t = adap->l2t;
 	lli.tids = &adap->tids;
 	lli.ports = adap->port;
@@ -6294,13 +6295,6 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return err;
 	}
 
-	/* We control everything through one PF */
-	func = PCI_FUNC(pdev->devfn);
-	if (func != ent->driver_data) {
-		pci_save_state(pdev);        /* to restore SR-IOV later */
-		goto sriov;
-	}
-
 	err = pci_enable_device(pdev);
 	if (err) {
 		dev_err(&pdev->dev, "cannot enable PCI device\n");
@@ -6344,6 +6338,15 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_free_adapter;
 	}
 
+	/* We control everything through one PF */
+	func = SOURCEPF_GET(readl(adapter->regs + PL_WHOAMI));
+	if ((pdev->device == 0xa000 && func != 0) ||
+	    func != ent->driver_data) {
+		pci_save_state(pdev);        /* to restore SR-IOV later */
+		err = 0;
+		goto out_unmap_bar0;
+	}
+
 	adapter->pdev = pdev;
 	adapter->pdev_dev = &pdev->dev;
 	adapter->mbox = func;
@@ -6507,7 +6510,6 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (is_offload(adapter))
 		attach_ulds(adapter);
 
-sriov:
 #ifdef CONFIG_PCI_IOV
 	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
 		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index d719dec..8f60851 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -253,6 +253,7 @@ struct cxgb4_lld_info {
 	int dbfifo_int_thresh;		     /* doorbell fifo int threshold */
 	unsigned int sge_pktshift;           /* Padding between CPL and */
 					     /*	packet data */
+	unsigned int pf;		     /* Physical Function we're using */
 	bool enable_fw_ofld_conn;            /* Enable connection through fw */
 					     /* WR */
 	bool ulptx_memwrite_dsgl;            /* use of T5 DSGL allowed */
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
