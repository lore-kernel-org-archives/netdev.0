From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v0 2/2] ixgbe: add NETIF_F_HW_FDB to supported flags
Date: Wed, 08 Feb 2012 19:22:11 -0800
Message-ID: <20120209032211.32468.90929.stgit@jf-dev1-dcblab>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com,
	shemminger@vyatta.com, kvm@vger.kernel.org, sri@us.ibm.com
To: bhutchings@solarflare.com, roprabhu@cisco.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for NETIF_F_HW_FDB flag when SR-IOV is enabled. This
allows the bridge to push fdb entries into the hardware so the
VF can communicate with virtual devices attached to the bridge.


          veth0  veth2
            |      |
          ------------
          |  bridge0 |   <---- software bridging
          ------------
               /
               /
  ethx.y      ethx
    VF         PF
     \         \          <---- propagate FDB entries to HW
     \         \
  --------------------
  |  Embedded Bridge |    <---- hardware offloaded switching
  --------------------


Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   35 +++++++++++++++++--------
 1 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ecc46ce..66261fa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3207,6 +3207,11 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev)
 		netdev_for_each_uc_addr(ha, netdev) {
 			if (!rar_entries)
 				break;
+
+			netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
+				     "%s %s: write vfn %i %pM\n",
+				     __func__, netdev->name, vfn, ha->addr);
+
 			hw->mac.ops.set_rar(hw, rar_entries--, ha->addr,
 					    vfn, IXGBE_RAH_AV);
 			count++;
@@ -3268,16 +3273,17 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		}
 		ixgbe_vlan_filter_enable(adapter);
 		hw->addr_ctrl.user_set_promisc = false;
-		/*
-		 * Write addresses to available RAR registers, if there is not
-		 * sufficient space to store all the addresses then enable
-		 * unicast promiscuous mode
-		 */
-		count = ixgbe_write_uc_addr_list(netdev);
-		if (count < 0) {
-			fctrl |= IXGBE_FCTRL_UPE;
-			vmolr |= IXGBE_VMOLR_ROPE;
-		}
+	}
+
+	/*
+	 * Write addresses to available RAR registers, if there is not
+	 * sufficient space to store all the addresses then enable
+	 * unicast promiscuous mode
+	 */
+	count = ixgbe_write_uc_addr_list(netdev);
+	if (count < 0) {
+		fctrl |= IXGBE_FCTRL_UPE;
+		vmolr |= IXGBE_VMOLR_ROPE;
 	}
 
 	if (adapter->num_vfs) {
@@ -7214,6 +7220,10 @@ static netdev_features_t ixgbe_fix_features(struct net_device *netdev,
 		e_info(probe, "rx-usecs set too low, not enabling RSC\n");
 	}
 
+	/* Only use offloaded FDB if SR-IOV is enabled */
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		data &= ~NETIF_F_HW_FDB;
+
 	return data;
 }
 
@@ -7549,9 +7559,12 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
 		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
 				    IXGBE_FLAG_DCB_ENABLED);
+		netdev->hw_features |= NETIF_F_HW_FDB;
+		netdev->features |= NETIF_F_HW_FDB;
+	}
 
 #ifdef CONFIG_IXGBE_DCB
 	netdev->dcbnl_ops = &dcbnl_ops;

