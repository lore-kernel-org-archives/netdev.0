From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] i40e: enable fdb add code, remove unused code
Date: Thu, 20 Nov 2014 16:30:02 -0800
Message-ID: <1416529802-16055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:33255 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755788AbaKUAa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 19:30:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The original FDB code submission wasn't correct and the code
wasn't enabled.  This removes some dead code (can use the common kernel
code for fdb_del and fdb_dump) and correctly enables the fdb_add
function pointer.

The fdb_add functionality is important to i40e because it is needed
for a workaround to allow bridges to work correctly on the i40e
hardware.

Reported-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 71 ++++-------------------------
 1 file changed, 8 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3913329..7262077 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7526,18 +7526,18 @@ static int i40e_get_phys_port_id(struct net_device *netdev,
 	return 0;
 }
 
-#ifdef HAVE_FDB_OPS
-#ifdef USE_CONST_DEV_UC_CHAR
+/**
+ * i40e_ndo_fdb_add - add an entry to the hardware database
+ * @ndm: the input from the stack
+ * @tb: pointer to array of nladdr (unused)
+ * @dev: the net device pointer
+ * @addr: the MAC address entry being added
+ * @flags: instructions from stack about fdb operation
+ */
 static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			    struct net_device *dev,
 			    const unsigned char *addr,
 			    u16 flags)
-#else
-static int i40e_ndo_fdb_add(struct ndmsg *ndm,
-			    struct net_device *dev,
-			    unsigned char *addr,
-			    u16 flags)
-#endif
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_pf *pf = np->vsi->back;
@@ -7568,55 +7568,6 @@ static int i40e_ndo_fdb_add(struct ndmsg *ndm,
 	return err;
 }
 
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
@@ -7650,13 +7601,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_del_vxlan_port	= i40e_del_vxlan_port,
 #endif
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
-#ifdef HAVE_FDB_OPS
 	.ndo_fdb_add		= i40e_ndo_fdb_add,
-#ifndef USE_DEFAULT_FDB_DEL_DUMP
-	.ndo_fdb_del		= i40e_ndo_fdb_del,
-	.ndo_fdb_dump		= i40e_ndo_fdb_dump,
-#endif
-#endif
 };
 
 /**
-- 
1.9.3
