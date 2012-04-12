From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v3 5/8] ixgbe: enable FDB netdevice ops
Date: Thu, 12 Apr 2012 10:07:15 -0700
Message-ID: <20120412170714.2717.76360.stgit@jf-dev1-dcblab>
References: <20120412170258.2717.34628.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: shemminger@vyatta.com, mst@redhat.com, davem@davemloft.net,
	bhutchings@solarflare.com, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63974 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757865Ab2DLRUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 13:20:19 -0400
In-Reply-To: <20120412170258.2717.34628.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable FDB ops on ixgbe when in SR-IOV mode.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   71 +++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3e26b1f..8b37395 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6681,6 +6681,74 @@ static int ixgbe_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static int ixgbe_ndo_fdb_add(struct ndmsg *ndm,
+			     struct net_device *dev,
+			     unsigned char *addr,
+			     u16 flags)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int err = -EOPNOTSUPP;
+
+	if (ndm->ndm_state & NUD_PERMANENT) {
+		pr_info("%s: FDB only supports static addresses\n",
+			ixgbe_driver_name);
+		return -EINVAL;
+	}
+
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		if (is_unicast_ether_addr(addr))
+			err = dev_uc_add_excl(dev, addr);
+		else if (is_multicast_ether_addr(addr))
+			err = dev_mc_add_excl(dev, addr);
+		else
+			err = -EINVAL;
+	}
+
+	/* Only return duplicate errors if NLM_F_EXCL is set */
+	if (err == -EEXIST && !(flags & NLM_F_EXCL))
+		err = 0;
+
+	return err;
+}
+
+static int ixgbe_ndo_fdb_del(struct ndmsg *ndm,
+			     struct net_device *dev,
+			     unsigned char *addr)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int err = -EOPNOTSUPP;
+
+	if (ndm->ndm_state & NUD_PERMANENT) {
+		pr_info("%s: FDB only supports static addresses\n",
+			ixgbe_driver_name);
+		return -EINVAL;
+	}
+
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
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
+static int ixgbe_ndo_fdb_dump(struct sk_buff *skb,
+			      struct netlink_callback *cb,
+			      struct net_device *dev,
+			      int idx)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
+
+	return idx;
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -6717,6 +6785,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #endif /* IXGBE_FCOE */
 	.ndo_set_features = ixgbe_set_features,
 	.ndo_fix_features = ixgbe_fix_features,
+	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
+	.ndo_fdb_del		= ixgbe_ndo_fdb_del,
+	.ndo_fdb_dump		= ixgbe_ndo_fdb_dump,
 };
 
 static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
