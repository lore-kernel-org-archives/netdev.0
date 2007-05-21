From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 62/69] sky2: fix oops on shutdown
Date: Mon, 21 May 2007 12:17:14 -0700
Message-ID: <20070521191754.252731000@sous-sol.org>
References: <20070521191612.800400000@sous-sol.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:46477 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765495AbXEUTWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 15:22:06 -0400
Content-Disposition: inline; filename=sky2-fix-oops-on-shutdown.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.
---------------------

From: Stephen Hemminger <shemminger@linux-foundation.org>

If the device fails during module startup for some reason like unsupported chip
version then the driver would crash dereferencing a null pointer, on shutdown
or suspend/resume.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>

---
 drivers/net/sky2.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- linux-2.6.21.1.orig/drivers/net/sky2.c
+++ linux-2.6.21.1/drivers/net/sky2.c
@@ -3719,6 +3719,7 @@ err_out_free_regions:
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 err_out:
+	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -3771,6 +3772,9 @@ static int sky2_suspend(struct pci_dev *
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return 0;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
@@ -3802,6 +3806,9 @@ static int sky2_resume(struct pci_dev *p
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, err;
 
+	if (!hw)
+		return 0;
+
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -3848,6 +3855,9 @@ static void sky2_shutdown(struct pci_dev
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 

-- 
