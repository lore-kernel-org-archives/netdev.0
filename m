From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 3/3] ixgbe: add setlink,
	getlink support to ixgbe and ixgbevf
Date: Tue, 29 May 2012 20:07:11 -0700
Message-ID: <20120530030711.7443.3965.stgit@jf-dev1-dcblab>
References: <20120530030531.7443.72024.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, gregory.v.rose@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	eric.w.multanen@intel.com
To: krkumar2@in.ibm.com, hadi@cyberus.ca, shemminger@vyatta.com,
	mst@redhat.com, buytenh@wantstofly.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36571 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932261Ab2E3DVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 23:21:22 -0400
In-Reply-To: <20120530030531.7443.72024.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the net device ops to manage the embedded
hardware bridge on ixgbe devices. With this patch the bridge
mode can be toggled between VEB and VEPA to support stacking
macvlan devices or using the embedded switch without any SW
component in 802.1Qbg/br environments.

Additionally, this adds source address pruning to the ixgbevf
driver to prune any frames sent back from a reflective relay on
the switch. This is required because the existing hardware does
not support this. Without it frames get pushed into the stack
with its own src mac which is invalid per 802.1Qbg VEPA
definition.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  100 ++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    3 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   10 ++
 3 files changed, 110 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bf20457..55dfb06 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3144,7 +3144,6 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset ^ 1), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (1 << vf_shift));
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset ^ 1), 0);
-	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 
 	/* Map PF MAC address in RAR Entry 0 to first pool following VFs */
 	hw->mac.ops.set_vmdq(hw, 0, adapter->num_vfs);
@@ -3158,8 +3157,6 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	gcr_ext |= IXGBE_GCR_EXT_VT_MODE_64;
 	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr_ext);
 
-	/* enable Tx loopback for VF/PF communication */
-	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 	/* Enable MAC Anti-Spoofing */
 	hw->mac.ops.set_mac_anti_spoofing(hw,
 					   (adapter->num_vfs != 0),
@@ -6844,6 +6841,101 @@ static int ixgbe_ndo_fdb_dump(struct sk_buff *skb,
 	return idx;
 }
 
+static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
+				    struct nlmsghdr *nlh)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct nlattr *attr, *bridge;
+	int rem;
+
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		return -EOPNOTSUPP;
+
+	bridge = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_BRIDGE);
+
+	nla_for_each_nested(attr, bridge, rem) {
+		__u16 mode;
+		u32 reg = 0;
+
+		if (nla_type(attr) != IFLA_BRIDGE_MODE)
+			continue;
+
+		mode = nla_get_u16(attr);
+		if (mode == BRIDGE_MODE_VEPA)
+			reg = 0;
+		else if (mode == BRIDGE_MODE_VEB)
+			reg = IXGBE_PFDTXGSWC_VT_LBEN;
+		else
+			return -EINVAL;
+
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC, reg);
+
+		e_info(drv, "enabling bridge mode: %s\n",
+			mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
+	}
+
+	return 0;
+}
+
+static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				    struct net_device *dev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct nlmsghdr *nlh;
+	struct ifinfomsg *ifm;
+	struct nlattr *bridge;
+	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
+	u16 bridge_mode;
+
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		return 0;
+
+	nlh = nlmsg_put(skb, pid, seq, RTM_NEWLINK, sizeof(*ifm), NLM_F_MULTI);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	ifm = nlmsg_data(nlh);
+	ifm->ifi_family = AF_BRIDGE;
+	ifm->__ifi_pad = 0;
+	ifm->ifi_type = dev->type;
+	ifm->ifi_index = dev->ifindex;
+	ifm->ifi_flags = dev_get_flags(dev);
+	ifm->ifi_change = 0;
+
+
+	if (nla_put_string(skb, IFLA_IFNAME, dev->name) ||
+	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
+	    nla_put_u8(skb, IFLA_OPERSTATE, operstate) ||
+	    (dev->master &&
+	     nla_put_u32(skb, IFLA_MASTER, dev->master->ifindex)) ||
+	    (dev->addr_len &&
+	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
+	    (dev->ifindex != dev->iflink &&
+	     nla_put_u32(skb, IFLA_LINK, dev->iflink)))
+		goto nla_put_failure;
+
+	if (IXGBE_READ_REG(&adapter->hw, IXGBE_PFDTXGSWC) & 1)
+		bridge_mode = BRIDGE_MODE_VEB;
+	else
+		bridge_mode = BRIDGE_MODE_VEPA;
+
+	bridge = nla_nest_start(skb, IFLA_BRIDGE);
+	if (!bridge)
+		goto nla_put_failure;
+
+	if (nla_put_u16(skb, IFLA_BRIDGE_FLAGS, BRIDGE_FLAGS_SELF) ||
+	    nla_put_u16(skb, IFLA_BRIDGE_MODE, bridge_mode)) {
+		nla_nest_cancel(skb, bridge);
+		goto nla_put_failure;
+	}
+	nla_nest_end(skb, bridge);
+
+	return nlmsg_end(skb, nlh);
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -6883,6 +6975,8 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
 	.ndo_fdb_del		= ixgbe_ndo_fdb_del,
 	.ndo_fdb_dump		= ixgbe_ndo_fdb_dump,
+	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
+	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 };
 
 static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 2d971d1..bd932c6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -135,6 +135,9 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 		}
 	}
 
+	/* Initialize default switching mode VEB */
+	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+
 	/* If call to enable VFs succeeded then allocate memory
 	 * for per VF control structures.
 	 */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f69ec42..f8d6f04 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -575,6 +575,16 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		}
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
 
+		/* Workaround hardware that can't do proper VEPA multicast
+		 * source pruning.
+		 */
+		if ((skb->pkt_type & (PACKET_BROADCAST | PACKET_MULTICAST)) &&
+		    !(compare_ether_addr(adapter->netdev->dev_addr,
+					eth_hdr(skb)->h_source))) {
+			dev_kfree_skb_irq(skb);
+			goto next_desc;
+		}
+
 		ixgbevf_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
 
 next_desc:
