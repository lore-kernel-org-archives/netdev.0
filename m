From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next v2] be2net: fix vfs enumeration
Date: Mon,  1 Oct 2012 13:56:55 +0200
Message-ID: <1349092615-31894-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, sfr@canb.auug.org.au, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188Ab2JAL5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 07:57:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current VFs enumeration algorithm used in be_find_vfs does not take domain
number into the match. The match found in igb/ixgbe is more elegant and
safe.

This 2nd version uses pci_physfn instead of checking dev->physfn directly.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6accb0c..8dd42b3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1075,7 +1075,7 @@ static int be_set_vf_tx_rate(struct net_device *netdev,
 static int be_find_vfs(struct be_adapter *adapter, int vf_state)
 {
 	struct pci_dev *dev, *pdev = adapter->pdev;
-	int vfs = 0, assigned_vfs = 0, pos, vf_fn;
+	int vfs = 0, assigned_vfs = 0, pos;
 	u16 offset, stride;
 
 	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
@@ -1086,9 +1086,7 @@ static int be_find_vfs(struct be_adapter *adapter, int vf_state)
 
 	dev = pci_get_device(pdev->vendor, PCI_ANY_ID, NULL);
 	while (dev) {
-		vf_fn = (pdev->devfn + offset + stride * vfs) & 0xFFFF;
-		if (dev->is_virtfn && dev->devfn == vf_fn &&
-			dev->bus->number == pdev->bus->number) {
+		if (dev->is_virtfn && pci_physfn(dev) == pdev) {
 			vfs++;
 			if (dev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
 				assigned_vfs++;
-- 
1.7.8.6
