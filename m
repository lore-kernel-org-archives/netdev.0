From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgbe: Do not allocate too many netdev
	txqueues
Date: Fri, 26 Feb 2010 01:15:21 -0800
Message-ID: <20100226091519.19796.82441.stgit@localhost.localdomain>
References: <20100226091318.19796.70225.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:41017
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935633Ab0BZJPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:15:39 -0500
In-Reply-To: <20100226091318.19796.70225.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Instead of allocating 128 struct netdev_queue per device, use the
minimum value between 128 and the number of possible txq's, to
reduce ram usage and "tc -s -d class shod dev .." output.

This patch fixes Eric Dumazet's patch to set the TX queues to
the correct minimum.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4a01022..a961da2 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5996,6 +5996,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
 	static int cards_found;
 	int i, err, pci_using_dac;
+	unsigned int indices = num_possible_cpus();
 #ifdef IXGBE_FCOE
 	u16 device_caps;
 #endif
@@ -6034,7 +6035,18 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
-	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX_QUEUES);
+	if (ii->mac == ixgbe_mac_82598EB)
+		indices = min_t(unsigned int, indices, IXGBE_MAX_RSS_INDICES);
+	else
+		indices = min_t(unsigned int, indices, IXGBE_MAX_FDIR_INDICES);
+
+	indices = max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES);
+#ifdef IXGBE_FCOE
+	indices += min_t(unsigned int, num_possible_cpus(),
+			 IXGBE_MAX_FCOE_INDICES);
+#endif
+	indices = min_t(unsigned int, indices, MAX_TX_QUEUES);
+	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), indices);
 	if (!netdev) {
 		err = -ENOMEM;
 		goto err_alloc_etherdev;

