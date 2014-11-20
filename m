From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] i40e: remove dead fdb code
Date: Thu, 20 Nov 2014 14:10:29 +0100
Message-ID: <1416489029-1929-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:47854 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaKTNKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 08:10:33 -0500
Received: by mail-wg0-f46.google.com with SMTP id x12so3656826wgg.19
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 05:10:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is not used now and also it contains some weird ifdefs. So
remove it for now. It can be added when needed.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 98 -----------------------------
 1 file changed, 98 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c998d82..3368bf8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7521,97 +7521,6 @@ static int i40e_get_phys_port_id(struct net_device *netdev,
 	return 0;
 }
 
-#ifdef HAVE_FDB_OPS
-#ifdef USE_CONST_DEV_UC_CHAR
-static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
-			    struct net_device *dev,
-			    const unsigned char *addr,
-			    u16 flags)
-#else
-static int i40e_ndo_fdb_add(struct ndmsg *ndm,
-			    struct net_device *dev,
-			    unsigned char *addr,
-			    u16 flags)
-#endif
-{
-	struct i40e_netdev_priv *np = netdev_priv(dev);
-	struct i40e_pf *pf = np->vsi->back;
-	int err = 0;
-
-	if (!(pf->flags & I40E_FLAG_SRIOV_ENABLED))
-		return -EOPNOTSUPP;
-
-	/* Hardware does not support aging addresses so if a
-	 * ndm_state is given only allow permanent addresses
-	 */
-	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
-		netdev_info(dev, "FDB only supports static addresses\n");
-		return -EINVAL;
-	}
-
-	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
-		err = dev_uc_add_excl(dev, addr);
-	else if (is_multicast_ether_addr(addr))
-		err = dev_mc_add_excl(dev, addr);
-	else
-		err = -EINVAL;
-
-	/* Only return duplicate errors if NLM_F_EXCL is set */
-	if (err == -EEXIST && !(flags & NLM_F_EXCL))
-		err = 0;
-
-	return err;
-}
-
-#ifndef USE_DEFAULT_FDB_DEL_DUMP
-#ifdef USE_CONST_DEV_UC_CHAR
-static int i40e_ndo_fdb_del(struct ndmsg *ndm,
-			    struct net_device *dev,
-			    const unsigned char *addr)
-#else
-static int i40e_ndo_fdb_del(struct ndmsg *ndm,
-			    struct net_device *dev,
-			    unsigned char *addr)
-#endif
-{
-	struct i40e_netdev_priv *np = netdev_priv(dev);
-	struct i40e_pf *pf = np->vsi->back;
-	int err = -EOPNOTSUPP;
-
-	if (ndm->ndm_state & NUD_PERMANENT) {
-		netdev_info(dev, "FDB only supports static addresses\n");
-		return -EINVAL;
-	}
-
-	if (pf->flags & I40E_FLAG_SRIOV_ENABLED) {
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
-static int i40e_ndo_fdb_dump(struct sk_buff *skb,
-			     struct netlink_callback *cb,
-			     struct net_device *dev,
-			     struct net_device *filter_dev,
-			     int idx)
-{
-	struct i40e_netdev_priv *np = netdev_priv(dev);
-	struct i40e_pf *pf = np->vsi->back;
-
-	if (pf->flags & I40E_FLAG_SRIOV_ENABLED)
-		idx = ndo_dflt_fdb_dump(skb, cb, dev, filter_dev, idx);
-
-	return idx;
-}
-
-#endif /* USE_DEFAULT_FDB_DEL_DUMP */
-#endif /* HAVE_FDB_OPS */
 static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
@@ -7645,13 +7554,6 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
 #endif
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
-#ifdef HAVE_FDB_OPS
-	.ndo_fdb_add		= i40e_ndo_fdb_add,
-#ifndef USE_DEFAULT_FDB_DEL_DUMP
-	.ndo_fdb_del		= i40e_ndo_fdb_del,
-	.ndo_fdb_dump		= i40e_ndo_fdb_dump,
-#endif
-#endif
 };
 
 /**
-- 
1.9.3
