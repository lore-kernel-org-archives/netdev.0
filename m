From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v1 3/3] ixgbe: add setlink,
	getlink support to ixgbe and ixgbevf
Date: Wed, 24 Oct 2012 09:51:13 -0700
Message-ID: <20121024165113.14221.68413.stgit@jf-dev1-dcblab>
References: <20121024164906.14221.45341.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, chrisw@redhat.com, krkumar2@in.ibm.com,
	samudrala@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, gregory.v.rose@intel.com,
	eilong@broadcom.com
To: shemminger@vyatta.com, buytenh@wantstofly.org, davem@davemloft.net,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64736 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758694Ab2JXRIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 13:08:30 -0400
In-Reply-To: <20121024164906.14221.45341.stgit@jf-dev1-dcblab>
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

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   59 ++++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    3 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   10 ++++
 include/linux/rtnetlink.h                         |    3 +
 net/core/rtnetlink.c                              |   50 ++++++++++++++++++
 5 files changed, 122 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 88d636a..9a88e01 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -44,6 +44,7 @@
 #include <linux/ethtool.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
+#include <linux/if_bridge.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
 
@@ -3224,7 +3225,6 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset ^ 1), reg_offset - 1);
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (~0) << vf_shift);
 	IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset ^ 1), reg_offset - 1);
-	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 
 	/* Map PF MAC address in RAR Entry 0 to first pool following VFs */
 	hw->mac.ops.set_vmdq(hw, 0, VMDQ_P(0));
@@ -3247,8 +3247,6 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 
 	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr_ext);
 
-	/* enable Tx loopback for VF/PF communication */
-	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
 
 	/* Enable MAC Anti-Spoofing */
 	hw->mac.ops.set_mac_anti_spoofing(hw, (adapter->num_vfs != 0),
@@ -7025,6 +7023,59 @@ static int ixgbe_ndo_fdb_dump(struct sk_buff *skb,
 	return idx;
 }
 
+static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
+				    struct nlmsghdr *nlh)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct nlattr *attr, *br_spec;
+	int rem;
+
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		return -EOPNOTSUPP;
+
+	br_spec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
+
+	nla_for_each_nested(attr, br_spec, rem) {
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
+	u16 mode;
+
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+		return 0;
+
+	if (IXGBE_READ_REG(&adapter->hw, IXGBE_PFDTXGSWC) & 1)
+		mode = BRIDGE_MODE_VEB;
+	else
+		mode = BRIDGE_MODE_VEPA;
+
+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode);
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -7064,6 +7115,8 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
 	.ndo_fdb_del		= ixgbe_ndo_fdb_del,
 	.ndo_fdb_dump		= ixgbe_ndo_fdb_dump,
+	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
+	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 96876b7..7e3ac28 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -117,6 +117,9 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 		}
 	}
 
+	/* Initialize default switching mode VEB */
+	IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
+
 	/* If call to enable VFs succeeded then allocate memory
 	 * for per VF control structures.
 	 */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 07d7eab..ac6a76d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -478,6 +478,16 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		}
 		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 
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
 		ixgbevf_receive_skb(q_vector, skb, staterr, rx_desc);
 
 next_desc:
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 7002bbf..489dd7bb 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -69,4 +69,7 @@ extern int ndo_dflt_fdb_dump(struct sk_buff *skb,
 			     struct netlink_callback *cb,
 			     struct net_device *dev,
 			     int idx);
+
+extern int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				   struct net_device *dev, u16 mode);
 #endif	/* __LINUX_RTNETLINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8d2af0f..51dc58f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2252,6 +2252,56 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+			    struct net_device *dev, u16 mode)
+{
+	struct nlmsghdr *nlh;
+	struct ifinfomsg *ifm;
+	struct nlattr *br_afspec;
+	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
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
+	br_afspec = nla_nest_start(skb, IFLA_AF_SPEC);
+	if (!br_afspec)
+		goto nla_put_failure;
+
+	if (nla_put_u16(skb, IFLA_BRIDGE_FLAGS, BRIDGE_FLAGS_SELF) ||
+	    nla_put_u16(skb, IFLA_BRIDGE_MODE, mode)) {
+		nla_nest_cancel(skb, br_afspec);
+		goto nla_put_failure;
+	}
+	nla_nest_end(skb, br_afspec);
+
+	return nlmsg_end(skb, nlh);
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+EXPORT_SYMBOL(ndo_dflt_bridge_getlink);
+
 static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
