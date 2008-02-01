From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/6] e1000e: tweak irq allocation messages
Date: Fri, 01 Feb 2008 08:21:44 -0800
Message-ID: <20080201162144.29347.82494.stgit@localhost.localdomain>
References: <20080201162118.29347.13268.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55260 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888AbYBAQWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:22:36 -0500
In-Reply-To: <20080201162118.29347.13268.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

There's too much noise on systems that don't support MSI.  Let's get rid
of a few and make the real error message more specific.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0a2cb79..f58f017 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -945,11 +945,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	int irq_flags = IRQF_SHARED;
 	int err;
 
-	err = pci_enable_msi(adapter->pdev);
-	if (err) {
-		ndev_warn(netdev,
-		 "Unable to allocate MSI interrupt Error: %d\n", err);
-	} else {
+	if (!pci_enable_msi(adapter->pdev)) {
 		adapter->flags |= FLAG_MSI_ENABLED;
 		handler = e1000_intr_msi;
 		irq_flags = 0;
@@ -958,10 +954,12 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
 			  netdev);
 	if (err) {
+		ndev_err(netdev,
+		       "Unable to allocate %s interrupt (return: %d)\n",
+			adapter->flags & FLAG_MSI_ENABLED ? "MSI":"INTx",
+			err);
 		if (adapter->flags & FLAG_MSI_ENABLED)
 			pci_disable_msi(adapter->pdev);
-		ndev_err(netdev,
-		       "Unable to allocate interrupt Error: %d\n", err);
 	}
 
 	return err;

