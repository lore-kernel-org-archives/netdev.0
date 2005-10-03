From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: [patch] airo: fix resume
Date: Mon, 03 Oct 2005 13:44:50 +0200
Message-ID: <434119B2.2070105@stud.feec.vutbr.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050502030909040204030807"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin Reed <breed@users.sourceforge.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050502030909040204030807
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit

Cisco Aironet doesn't resume properly from swsusp, because the resume 
method confuses a PM_EVENT_* for a PCI power state. It thinks that it is 
resuming from PCI_D1 and doesn't do the necessary initialization of the 
card.

Signed-off-by: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>


--------------050502030909040204030807
Content-Type: text/plain;
 name="airo-fix-resume.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="airo-fix-resume.diff"

--- linux-vanilla/drivers/net/wireless/airo.c	2005-09-29 20:44:01.000000000 +0200
+++ linux-mich/drivers/net/wireless/airo.c	2005-10-01 15:07:34.000000000 +0200
@@ -5515,12 +5515,13 @@ static int airo_pci_resume(struct pci_de
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct airo_info *ai = dev->priv;
 	Resp rsp;
+	pci_power_t prev_state = pdev->current_state;
 
-	pci_set_power_state(pdev, 0);
+	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, ai->power), 0);
+	pci_enable_wake(pdev, PCI_D0, 0);
 
-	if (ai->power.event > 1) {
+	if (prev_state != PCI_D1) {
 		reset_card(dev, 0);
 		mpi_init_descriptors(ai);
 		setup_card(ai, dev->dev_addr, 0);

--------------050502030909040204030807--
