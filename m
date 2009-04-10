From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/3] igb: do not check for vf_data if we didn't enable vfs
Date: Fri, 10 Apr 2009 01:49:39 -0700
Message-ID: <20090410084939.14739.79760.stgit@localhost.localdomain>
References: <20090410084901.14739.20428.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:44878
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S939036AbZDJRSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 13:18:09 -0400
In-Reply-To: <20090410084901.14739.20428.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The driver is currently dumping a message in the log about failing to
allocate vf data when max_vfs is equal to 0.  This change makes it so the
error message is only displayed if we set max_vfs to a non zero value.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   37 ++++++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index db7274e..08c8014 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1261,25 +1261,32 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		int i;
 		unsigned char mac_addr[ETH_ALEN];
 
-		if (num_vfs)
+		if (num_vfs) {
 			adapter->vf_data = kcalloc(num_vfs,
 						sizeof(struct vf_data_storage),
 						GFP_KERNEL);
-		if (!adapter->vf_data) {
-			dev_err(&pdev->dev, "Could not allocate VF private "
-				"data - IOV enable failed\n");
-		} else {
-			err = pci_enable_sriov(pdev, num_vfs);
-			if (!err) {
-				adapter->vfs_allocated_count = num_vfs;
-				dev_info(&pdev->dev, "%d vfs allocated\n", num_vfs);
-				for (i = 0; i < adapter->vfs_allocated_count; i++) {
-					random_ether_addr(mac_addr);
-					igb_set_vf_mac(adapter, i, mac_addr);
-				}
+			if (!adapter->vf_data) {
+				dev_err(&pdev->dev,
+				        "Could not allocate VF private data - "
+					"IOV enable failed\n");
 			} else {
-				kfree(adapter->vf_data);
-				adapter->vf_data = NULL;
+				err = pci_enable_sriov(pdev, num_vfs);
+				if (!err) {
+					adapter->vfs_allocated_count = num_vfs;
+					dev_info(&pdev->dev,
+					         "%d vfs allocated\n",
+					         num_vfs);
+					for (i = 0;
+					     i < adapter->vfs_allocated_count;
+					     i++) {
+						random_ether_addr(mac_addr);
+						igb_set_vf_mac(adapter, i,
+						               mac_addr);
+					}
+				} else {
+					kfree(adapter->vf_data);
+					adapter->vf_data = NULL;
+				}
 			}
 		}
 	}

