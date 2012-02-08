From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 50/50] use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:57 +0100
Message-ID: <1328735457-29986-51-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christian Benvenuti <benve@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	David Wang <dwang2@cisco.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ab3f67f..3e7cb54 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -865,6 +865,8 @@ static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 	}
 
 	memcpy(netdev->dev_addr, addr, netdev->addr_len);
+	if (netdev->addr_assign_type & NET_ADDR_RANDOM)
+		netdev->addr_assign_type ^= NET_ADDR_RANDOM;
 
 	return 0;
 }
@@ -1119,7 +1121,7 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 		memcpy(pp->mac_addr, prev_pp.vf_mac, ETH_ALEN);
 
 	if (vf == PORT_SELF_VF && is_zero_ether_addr(netdev->dev_addr))
-		random_ether_addr(netdev->dev_addr);
+		dev_hw_addr_random(netdev, netdev->dev_addr);
 
 	err = enic_process_set_pp_request(enic, vf, &prev_pp, &restore_pp);
 	if (err) {
@@ -2272,6 +2274,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	int err;
 #ifdef CONFIG_PCI_IOV
 	int pos = 0;
+	bool random_mac = false;
 #endif
 	int num_pps = 1;
 
@@ -2467,11 +2470,17 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	(void)enic_change_mtu(netdev, enic->port_mtu);
 
 #ifdef CONFIG_PCI_IOV
-	if (enic_is_sriov_vf(enic) && is_zero_ether_addr(enic->mac_addr))
+	if (enic_is_sriov_vf(enic) && is_zero_ether_addr(enic->mac_addr)) {
 		random_ether_addr(enic->mac_addr);
+		random_mac = true;
+	}
 #endif
 
 	err = enic_set_mac_addr(netdev, enic->mac_addr);
+#ifdef CONFIG_PCI_IOV
+	if (random_mac)
+		netdev->addr_assign_type |= NET_ADDR_RANDOM;
+#endif
 	if (err) {
 		dev_err(dev, "Invalid MAC address, aborting\n");
 		goto err_out_dev_deinit;
-- 
1.7.7.3
