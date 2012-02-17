From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 07/10] cisco/enic: use eth_hw_addr_random() instead of random_ether_addr()
Date: Fri, 17 Feb 2012 16:43:28 +0100
Message-ID: <1329493411-25750-8-git-send-email-danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Roopa Prabhu <roprabhu@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	David Wang <dwang2@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christian Benvenuti <benve@cisco.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Couldn't replace random_ether_addr() in enic_probe() since
enic_set_mac_addr() is used which would reset addr_assign_type.
Instead set addr_assign_type directly to NET_ADDR_RANDOM in
case of random mac after call enic_set_mac_addr().

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

v2: use bitops, adapt to eth_hw_addr_random(), add a comment

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ab3f67f..ed00cb3 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -865,6 +865,7 @@ static int enic_set_mac_addr(struct net_device *netdev, char *addr)
 	}
 
 	memcpy(netdev->dev_addr, addr, netdev->addr_len);
+	netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	return 0;
 }
@@ -1119,7 +1120,7 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 		memcpy(pp->mac_addr, prev_pp.vf_mac, ETH_ALEN);
 
 	if (vf == PORT_SELF_VF && is_zero_ether_addr(netdev->dev_addr))
-		random_ether_addr(netdev->dev_addr);
+		eth_hw_addr_random(netdev);
 
 	err = enic_process_set_pp_request(enic, vf, &prev_pp, &restore_pp);
 	if (err) {
@@ -2272,6 +2273,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	int err;
 #ifdef CONFIG_PCI_IOV
 	int pos = 0;
+	bool random_mac = false;
 #endif
 	int num_pps = 1;
 
@@ -2467,8 +2469,10 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	(void)enic_change_mtu(netdev, enic->port_mtu);
 
 #ifdef CONFIG_PCI_IOV
-	if (enic_is_sriov_vf(enic) && is_zero_ether_addr(enic->mac_addr))
+	if (enic_is_sriov_vf(enic) && is_zero_ether_addr(enic->mac_addr)) {
 		random_ether_addr(enic->mac_addr);
+		random_mac = true;
+	}
 #endif
 
 	err = enic_set_mac_addr(netdev, enic->mac_addr);
@@ -2476,6 +2480,12 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		dev_err(dev, "Invalid MAC address, aborting\n");
 		goto err_out_dev_deinit;
 	}
+#ifdef CONFIG_PCI_IOV
+	if (random_mac) {
+		/*Couldn't use eth_hw_addr_random() due to enic_set_mac_addr()*/
+		netdev->addr_assign_type |= NET_ADDR_RANDOM;
+	}
+#endif
 
 	enic->tx_coalesce_usecs = enic->config.intr_timer_usec;
 	enic->rx_coalesce_usecs = enic->tx_coalesce_usecs;
-- 
1.7.8.3
