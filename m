From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 7 Nov 2006 05:41:19 -0500
Message-ID: <20061107104119.GA6802@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:47750 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1753285AbWKGKlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 05:41:21 -0500
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/b44.c              |    5 +++--
 drivers/net/e1000/e1000_main.c |    7 +++++++
 2 files changed, 10 insertions(+), 2 deletions(-)

Auke Kok:
      e1000: Fix regression: garbled stats and irq allocation during swsusp

Johannes Berg:
      b44: change comment about irq mask register

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 1ec2174..474a4e3 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -908,8 +908,9 @@ static irqreturn_t b44_interrupt(int irq
 	istat = br32(bp, B44_ISTAT);
 	imask = br32(bp, B44_IMASK);
 
-	/* ??? What the fuck is the purpose of the interrupt mask
-	 * ??? register if we have to mask it out by hand anyways?
+	/* The interrupt mask register controls which interrupt bits
+	 * will actually raise an interrupt to the CPU when set by hw/firmware,
+	 * but doesn't mask off the bits.
 	 */
 	istat &= imask;
 	if (istat) {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8d04752..726ec5e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4800,6 +4800,9 @@ #endif
 	if (adapter->hw.phy_type == e1000_phy_igp_3)
 		e1000_phy_powerdown_workaround(&adapter->hw);
 
+	if (netif_running(netdev))
+		e1000_free_irq(adapter);
+
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
 	e1000_release_hw_control(adapter);
@@ -4830,6 +4833,10 @@ e1000_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
+	if (netif_running(netdev) && (err = e1000_request_irq(adapter)))
+		return err;
+
+	e1000_power_up_phy(adapter);
 	e1000_reset(adapter);
 	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
 
