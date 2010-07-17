From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 1/1] qlcnic: fix pci resource leak
Date: Sat, 17 Jul 2010 00:39:38 -0700
Message-ID: <1279352378-22692-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:40598 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753596Ab0GQHji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jul 2010 03:39:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

pci_get_domain_bus_and_slot: caller must decrement the
reference count by calling pci_dev_put().

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 8d2d62f..f1f7acf 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2695,9 +2695,14 @@ static int qlcnic_is_first_func(struct pci_dev *pdev)
 		oth_pdev = pci_get_domain_bus_and_slot(pci_domain_nr
 			(pdev->bus), pdev->bus->number,
 			PCI_DEVFN(PCI_SLOT(pdev->devfn), val));
+		if (!oth_pdev)
+			continue;
 
-		if (oth_pdev && (oth_pdev->current_state != PCI_D3cold))
+		if (oth_pdev->current_state != PCI_D3cold) {
+			pci_dev_put(oth_pdev);
 			return 0;
+		}
+		pci_dev_put(oth_pdev);
 	}
 	return 1;
 }
-- 
1.6.0.2

