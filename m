From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/16] i40e: Add bridge FDB add/del/dump ops
Date: Tue, 22 Apr 2014 05:39:16 -0700
Message-ID: <1398170371-3333-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45665 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932544AbaDVMjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:36 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add the netdev ops to support addition of static FDB entries in the
physical function (PF)  MAC/VLAN filter table so that virtual functions
(VFs) can communicate with bridged virtual Ethernet ports such as those
provided by the virtio driver.

Change-ID: Ifbd6817a75074e3b5cdf945a5635f26440bf15df
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 97 +++++++++++++++++++++++++++++
 1 file changed, 97 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 861b722..10f0f41 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6644,6 +6644,96 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 }
 
 #endif
+#ifdef HAVE_FDB_OPS
+#ifdef USE_CONST_DEV_UC_CHAR
+static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			    struct net_device *dev,
+			    const unsigned char *addr,
+			    u16 flags)
+#else
+static int i40e_ndo_fdb_add(struct ndmsg *ndm,
+			    struct net_device *dev,
+			    unsigned char *addr,
+			    u16 flags)
+#endif
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_pf *pf = np->vsi->back;
+	int err = 0;
+
+	if (!(pf->flags & I40E_FLAG_SRIOV_ENABLED))
+		return -EOPNOTSUPP;
+
+	/* Hardware does not support aging addresses so if a
+	 * ndm_state is given only allow permanent addresses
+	 */
+	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
+		netdev_info(dev, "FDB only supports static addresses\n");
+		return -EINVAL;
+	}
+
+	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
+		err = dev_uc_add_excl(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_add_excl(dev, addr);
+	else
+		err = -EINVAL;
+
+	/* Only return duplicate errors if NLM_F_EXCL is set */
+	if (err == -EEXIST && !(flags & NLM_F_EXCL))
+		err = 0;
+
+	return err;
+}
+
+#ifndef USE_DEFAULT_FDB_DEL_DUMP
+#ifdef USE_CONST_DEV_UC_CHAR
+static int i40e_ndo_fdb_del(struct ndmsg *ndm,
+			    struct net_device *dev,
+			    const unsigned char *addr)
+#else
+static int i40e_ndo_fdb_del(struct ndmsg *ndm,
+			    struct net_device *dev,
+			    unsigned char *addr)
+#endif
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_pf *pf = np->vsi->back;
+	int err = -EOPNOTSUPP;
+
+	if (ndm->ndm_state & NUD_PERMANENT) {
+		netdev_info(dev, "FDB only supports static addresses\n");
+		return -EINVAL;
+	}
+
+	if (pf->flags & I40E_FLAG_SRIOV_ENABLED) {
+		if (is_unicast_ether_addr(addr))
+			err = dev_uc_del(dev, addr);
+		else if (is_multicast_ether_addr(addr))
+			err = dev_mc_del(dev, addr);
+		else
+			err = -EINVAL;
+	}
+
+	return err;
+}
+
+static int i40e_ndo_fdb_dump(struct sk_buff *skb,
+			     struct netlink_callback *cb,
+			     struct net_device *dev,
+			     int idx)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_pf *pf = np->vsi->back;
+
+	if (pf->flags & I40E_FLAG_SRIOV_ENABLED)
+		idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
+
+	return idx;
+}
+
+#endif /* USE_DEFAULT_FDB_DEL_DUMP */
+#endif /* HAVE_FDB_OPS */
 static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
@@ -6671,6 +6761,13 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_add_vxlan_port	= i40e_add_vxlan_port,
 	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
 #endif
+#ifdef HAVE_FDB_OPS
+	.ndo_fdb_add		= i40e_ndo_fdb_add,
+#ifndef USE_DEFAULT_FDB_DEL_DUMP
+	.ndo_fdb_del		= i40e_ndo_fdb_del,
+	.ndo_fdb_dump		= i40e_ndo_fdb_dump,
+#endif
+#endif
 };
 
 /**
-- 
1.9.0
