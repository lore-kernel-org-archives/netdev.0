From: Dmitriy Monakhov <dmonakhov@openvz.org>
Subject: [PATCH 3/5] fixing errors handling during pci_driver resume stage [fusion]
Date: Tue, 09 Jan 2007 12:01:37 +0300
Message-ID: <87slekmv4e.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Andrew Morton <akpm@osdl.org>, devel@openvz.org,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751185AbXAIJBr@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=

fusion pci drivers have to return correct error code during resume stage in
case of errors.
Signed-off-by: Dmitriy Monakhov <dmonakhov@openvz.org>
-----

--=-=-=
Content-Disposition: inline; filename=diff-pci-fusion

diff --git a/drivers/message/fusion/mptbase.c b/drivers/message/fusion/mptbase.c
index 6e068cf..51a3621 100644
--- a/drivers/message/fusion/mptbase.c
+++ b/drivers/message/fusion/mptbase.c
@@ -1524,7 +1524,7 @@ mpt_resume(struct pci_dev *pdev)
 {
 	MPT_ADAPTER *ioc = pci_get_drvdata(pdev);
 	u32 device_state = pdev->current_state;
-	int recovery_state;
+	int recovery_state, err;
 
 	printk(MYIOC_s_INFO_FMT
 	"pci-resume: pdev=0x%p, slot=%s, Previous operating state [D%d]\n",
@@ -1532,7 +1532,11 @@ mpt_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot enable PCI device, aborting.\n");
+		return err;
+	}
 
 	/* enable interrupts */
 	CHIPREG_WRITE32(&ioc->chip->IntMask, MPI_HIM_DIM);
diff --git a/drivers/message/fusion/mptscsih.c b/drivers/message/fusion/mptscsih.c
index 2c72c36..5324866 100644
--- a/drivers/message/fusion/mptscsih.c
+++ b/drivers/message/fusion/mptscsih.c
@@ -1120,8 +1120,10 @@ mptscsih_resume(struct pci_dev *pdev)
 	MPT_ADAPTER 		*ioc = pci_get_drvdata(pdev);
 	struct Scsi_Host 	*host = ioc->sh;
 	MPT_SCSI_HOST		*hd;
+	int err;
 
-	mpt_resume(pdev);
+	if ((err = mpt_resume(pdev)))
+		return err;
 
 	if(!host)
 		return 0;

--=-=-=--
