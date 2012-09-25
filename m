From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] be2net: fix vfs enumeration
Date: Tue, 25 Sep 2012 14:50:42 +0200
Message-ID: <1348577442-7720-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, ajit.khaparde@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753452Ab2IYMur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 08:50:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current VFs enumeration algorithm used in be_find_vfs does not take domain
number into the match. The match found in igb/ixgbe is more elegant and
safe.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 84379f4..966d9af 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1076,7 +1076,7 @@ static int be_set_vf_tx_rate(struct net_device *netdev,
 static int be_find_vfs(struct be_adapter *adapter, int vf_state)
 {
 	struct pci_dev *dev, *pdev = adapter->pdev;
-	int vfs = 0, assigned_vfs = 0, pos, vf_fn;
+	int vfs = 0, assigned_vfs = 0, pos;
 	u16 offset, stride;
 
 	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
@@ -1087,9 +1087,7 @@ static int be_find_vfs(struct be_adapter *adapter, int vf_state)
 
 	dev = pci_get_device(pdev->vendor, PCI_ANY_ID, NULL);
 	while (dev) {
-		vf_fn = (pdev->devfn + offset + stride * vfs) & 0xFFFF;
-		if (dev->is_virtfn && dev->devfn == vf_fn &&
-			dev->bus->number == pdev->bus->number) {
+		if (dev->is_virtfn && dev->physfn == pdev) {
 			vfs++;
 			if (dev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
 				assigned_vfs++;
-- 
1.7.8.6
