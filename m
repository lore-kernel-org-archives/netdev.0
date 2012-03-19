From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v0 4/5] ixgbe: enable FDB netdevice ops
Date: Sun, 18 Mar 2012 23:52:09 -0700
Message-ID: <20120319065208.10959.83135.stgit@jf-dev1-dcblab>
References: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	chealy@imsco-us.com
To: jhs@mojatatu.com, shemminger@vyatta.com, bhutchings@solarflare.com,
	roprabhu@cisco.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable FDB ops on ixgbe when in SR-IOV mode.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   59 +++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1d8f9f8..32adb4f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7586,6 +7586,62 @@ static int ixgbe_set_features(struct net_device *netdev,
 
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
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		err = dev_uc_add_excl(dev, addr);
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
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		err = dev_uc_del(dev, addr);
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
@@ -7620,6 +7676,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #endif /* IXGBE_FCOE */
 	.ndo_set_features = ixgbe_set_features,
 	.ndo_fix_features = ixgbe_fix_features,
+	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
+	.ndo_fdb_del		= ixgbe_ndo_fdb_del,
+	.ndo_fdb_dump		= ixgbe_ndo_fdb_dump,
 };
 
 static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,

