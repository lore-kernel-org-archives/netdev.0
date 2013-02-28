From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 2/4] ixgbe: Remove driver specific fdb handlers.
Date: Thu, 28 Feb 2013 18:13:01 -0500
Message-ID: <1362093183-5938-3-git-send-email-vyasevic@redhat.com>
References: <1362093183-5938-1-git-send-email-vyasevic@redhat.com>
Cc: john.r.fastabend@intel.com, Vlad Yasevich <vyasevic@redhat.com>,
	"CC: Gregory Rose" <gregory.v.rose@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164Ab3B1XN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 18:13:56 -0500
In-Reply-To: <1362093183-5938-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove driver specific fdb handlers since they are the same
as the default ones.

CC: John Fastabend <john.r.fastabend@intel.com>
CC: CC: Gregory Rose <gregory.v.rose@intel.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   81 -------------------------
 1 files changed, 0 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 68478d6..212b74e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6998,84 +6998,6 @@ static int ixgbe_set_features(struct net_device *netdev,
 	return 0;
 }
 
-static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
-			     struct net_device *dev,
-			     const unsigned char *addr,
-			     u16 flags)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int err;
-
-	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
-		return -EOPNOTSUPP;
-
-	/* Hardware does not support aging addresses so if a
-	 * ndm_state is given only allow permanent addresses
-	 */
-	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
-		pr_info("%s: FDB only supports static addresses\n",
-			ixgbe_driver_name);
-		return -EINVAL;
-	}
-
-	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr)) {
-		u32 rar_uc_entries = IXGBE_MAX_PF_MACVLANS;
-
-		if (netdev_uc_count(dev) < rar_uc_entries)
-			err = dev_uc_add_excl(dev, addr);
-		else
-			err = -ENOMEM;
-	} else if (is_multicast_ether_addr(addr)) {
-		err = dev_mc_add_excl(dev, addr);
-	} else {
-		err = -EINVAL;
-	}
-
-	/* Only return duplicate errors if NLM_F_EXCL is set */
-	if (err == -EEXIST && !(flags & NLM_F_EXCL))
-		err = 0;
-
-	return err;
-}
-
-static int ixgbe_ndo_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
-			     struct net_device *dev,
-			     const unsigned char *addr)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int err = -EOPNOTSUPP;
-
-	if (ndm->ndm_state & NUD_PERMANENT) {
-		pr_info("%s: FDB only supports static addresses\n",
-			ixgbe_driver_name);
-		return -EINVAL;
-	}
-
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
-		if (is_unicast_ether_addr(addr))
-			err = dev_uc_del(dev, addr);
-		else if (is_multicast_ether_addr(addr))
-			err = dev_mc_del(dev, addr);
-		else
-			err = -EINVAL;
-	}
-
-	return err;
-}
-
-static int ixgbe_ndo_fdb_dump(struct sk_buff *skb,
-			      struct netlink_callback *cb,
-			      struct net_device *dev,
-			      int idx)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(dev);
-
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
-		idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
-
-	return idx;
-}
-
 static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 				    struct nlmsghdr *nlh)
 {
@@ -7170,9 +7092,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #endif /* IXGBE_FCOE */
 	.ndo_set_features = ixgbe_set_features,
 	.ndo_fix_features = ixgbe_fix_features,
-	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
-	.ndo_fdb_del		= ixgbe_ndo_fdb_del,
-	.ndo_fdb_dump		= ixgbe_ndo_fdb_dump,
 	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 };
-- 
1.7.7.6
