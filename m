From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 resent net-next 2/4] ixgbe: Make use of the default fdb handlers.
Date: Wed,  6 Mar 2013 20:39:43 -0500
Message-ID: <1362620385-14553-3-git-send-email-vyasevic@redhat.com>
References: <1362620385-14553-1-git-send-email-vyasevic@redhat.com>
Cc: or.gerlitz@gmail.com, Vlad Yasevich <vyasevic@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"CC: Gregory Rose" <gregory.v.rose@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758526Ab3CGBjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 20:39:53 -0500
In-Reply-To: <1362620385-14553-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For fdb_add, use the default handler in the non-SRIOV case.
For the other fdb handlers, just remove them and use the
default ones.

CC: John Fastabend <john.r.fastabend@intel.com>
Acked-By: John Fastabend <john.r.fastabend@intel.com>
CC: CC: Gregory Rose <gregory.v.rose@intel.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   42 +------------------------
 1 files changed, 1 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index db5611a..e56a3d1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7007,7 +7007,7 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	int err;
 
 	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
-		return -EOPNOTSUPP;
+		return ndo_dflt_fdb_add(ndm, tb, dev, addr, flags);
 
 	/* Hardware does not support aging addresses so if a
 	 * ndm_state is given only allow permanent addresses
@@ -7038,44 +7038,6 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return err;
 }
 
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
@@ -7171,8 +7133,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_features = ixgbe_set_features,
 	.ndo_fix_features = ixgbe_fix_features,
 	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
-	.ndo_fdb_del		= ixgbe_ndo_fdb_del,
-	.ndo_fdb_dump		= ixgbe_ndo_fdb_dump,
 	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 };
-- 
1.7.7.6
