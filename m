From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: net-next build failure due to 16e5cc64?
Date: Tue, 1 Mar 2016 12:42:33 -0500
Message-ID: <20160301174233.GO16369@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, john.fastabend@gmail.com,
	john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38712 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbcCARmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 12:42:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


John,

I'm getting a failure when I try to build the latest net-next. I see

net/sched/sch_mqprio.c: In function `mqprio_init':
net/sched/sch_mqprio.c:145: error: unknown field `tc' specified in initializer
net/sched/sch_mqprio.c:145: warning: missing braces around initializer
net/sched/sch_mqprio.c:145: warning: (near initialization for `tc.<anonymous>')
make[2]: *** [net/sched/sch_mqprio.o] Error 1

I'm not sure why this wasn't noticed before, but in case this is due to my
compiler version:
   # gcc --version
   gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-16)
   Copyright (C) 2010 Free Software Foundation, Inc.

I'm finding that the minimum fix to avoid this error should be something like

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e52077f..8b7199f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -794,7 +794,7 @@ struct tc_to_netdev {
        union {
                u8 tc;
                struct tc_cls_u32_offload *cls_u32;
-       };
+       } tc_u;
 };

But then all the users of this structure would need to be changed,
which results in this patch below. Should I submit this to net-next,
or is it addressed elsewhere? 

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 45843d1..34ff0e8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4277,7 +4277,7 @@ int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 {
 	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
-	return bnx2x_setup_tc(dev, tc->tc);
+	return bnx2x_setup_tc(dev, tc->tc_u.tc);
 }
 
 /* called with rtnl_lock */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cf4b729..b2c9355 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8403,20 +8403,20 @@ int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 		if (!(dev->features & NETIF_F_HW_TC))
 			return -EINVAL;
 
-		switch (tc->cls_u32->command) {
+		switch (tc->tc_u.cls_u32->command) {
 		case TC_CLSU32_NEW_KNODE:
 		case TC_CLSU32_REPLACE_KNODE:
 			return ixgbe_configure_clsu32(adapter,
-						      proto, tc->cls_u32);
+						      proto, tc->tc_u.cls_u32);
 		case TC_CLSU32_DELETE_KNODE:
-			return ixgbe_delete_clsu32(adapter, tc->cls_u32);
+			return ixgbe_delete_clsu32(adapter, tc->tc_u.cls_u32);
 		case TC_CLSU32_NEW_HNODE:
 		case TC_CLSU32_REPLACE_HNODE:
 			return ixgbe_configure_clsu32_add_hnode(adapter, proto,
-								tc->cls_u32);
+								tc->tc_u.cls_u32);
 		case TC_CLSU32_DELETE_HNODE:
 			return ixgbe_configure_clsu32_del_hnode(adapter,
-								tc->cls_u32);
+								tc->tc_u.cls_u32);
 		default:
 			return -EINVAL;
 		}
@@ -8425,7 +8425,7 @@ int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return ixgbe_setup_tc(dev, tc->tc);
+	return ixgbe_setup_tc(dev, tc->tc_u.tc);
 }
 
 #ifdef CONFIG_PCI_IOV
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 96d95cb..90aac4d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -75,7 +75,7 @@ static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return mlx4_en_setup_tc(dev, tc->tc);
+	return mlx4_en_setup_tc(dev, tc->tc_u.tc);
 }
 
 #ifdef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 2cdb571..8925426 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -574,7 +574,7 @@ int efx_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
 	if (handle != TC_H_ROOT || ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	num_tc = ntc->tc;
+	num_tc = ntc->tc_u.tc;
 
 	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0 || num_tc > EFX_MAX_TX_TC)
 		return -EINVAL;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e52077f..8b7199f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -794,7 +794,7 @@ struct tc_to_netdev {
 	union {
 		u8 tc;
 		struct tc_cls_u32_offload *cls_u32;
-	};
+	} tc_u;
 };
 
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index d54bc94..b41071f 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -432,11 +432,11 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	struct tc_to_netdev offload;
 
 	offload.type = TC_SETUP_CLSU32;
-	offload.cls_u32 = &u32_offload;
+	offload.tc_u.cls_u32 = &u32_offload;
 
 	if (dev->netdev_ops->ndo_setup_tc) {
-		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
-		offload.cls_u32->knode.handle = handle;
+		offload.tc_u.cls_u32->command = TC_CLSU32_DELETE_KNODE;
+		offload.tc_u.cls_u32->knode.handle = handle;
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					      tp->protocol, &offload);
 	}
@@ -449,13 +449,13 @@ static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	struct tc_to_netdev offload;
 
 	offload.type = TC_SETUP_CLSU32;
-	offload.cls_u32 = &u32_offload;
+	offload.tc_u.cls_u32 = &u32_offload;
 
 	if (dev->netdev_ops->ndo_setup_tc) {
-		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
-		offload.cls_u32->hnode.divisor = h->divisor;
-		offload.cls_u32->hnode.handle = h->handle;
-		offload.cls_u32->hnode.prio = h->prio;
+		offload.tc_u.cls_u32->command = TC_CLSU32_NEW_HNODE;
+		offload.tc_u.cls_u32->hnode.divisor = h->divisor;
+		offload.tc_u.cls_u32->hnode.handle = h->handle;
+		offload.tc_u.cls_u32->hnode.prio = h->prio;
 
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					      tp->protocol, &offload);
@@ -469,13 +469,13 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	struct tc_to_netdev offload;
 
 	offload.type = TC_SETUP_CLSU32;
-	offload.cls_u32 = &u32_offload;
+	offload.tc_u.cls_u32 = &u32_offload;
 
 	if (dev->netdev_ops->ndo_setup_tc) {
-		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
-		offload.cls_u32->hnode.divisor = h->divisor;
-		offload.cls_u32->hnode.handle = h->handle;
-		offload.cls_u32->hnode.prio = h->prio;
+		offload.tc_u.cls_u32->command = TC_CLSU32_DELETE_HNODE;
+		offload.tc_u.cls_u32->hnode.divisor = h->divisor;
+		offload.tc_u.cls_u32->hnode.handle = h->handle;
+		offload.tc_u.cls_u32->hnode.prio = h->prio;
 
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					      tp->protocol, &offload);
@@ -489,23 +489,23 @@ static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
 	struct tc_to_netdev offload;
 
 	offload.type = TC_SETUP_CLSU32;
-	offload.cls_u32 = &u32_offload;
+	offload.tc_u.cls_u32 = &u32_offload;
 
 	if (dev->netdev_ops->ndo_setup_tc) {
-		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
-		offload.cls_u32->knode.handle = n->handle;
-		offload.cls_u32->knode.fshift = n->fshift;
+		offload.tc_u.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
+		offload.tc_u.cls_u32->knode.handle = n->handle;
+		offload.tc_u.cls_u32->knode.fshift = n->fshift;
 #ifdef CONFIG_CLS_U32_MARK
-		offload.cls_u32->knode.val = n->val;
-		offload.cls_u32->knode.mask = n->mask;
+		offload.tc_u.cls_u32->knode.val = n->val;
+		offload.tc_u.cls_u32->knode.mask = n->mask;
 #else
-		offload.cls_u32->knode.val = 0;
-		offload.cls_u32->knode.mask = 0;
+		offload.tc_u.cls_u32->knode.val = 0;
+		offload.tc_u.cls_u32->knode.mask = 0;
 #endif
-		offload.cls_u32->knode.sel = &n->sel;
-		offload.cls_u32->knode.exts = &n->exts;
+		offload.tc_u.cls_u32->knode.sel = &n->sel;
+		offload.tc_u.cls_u32->knode.exts = &n->exts;
 		if (n->ht_down)
-			offload.cls_u32->knode.link_handle = n->ht_down->handle;
+			offload.tc_u.cls_u32->knode.link_handle = n->ht_down->handle;
 
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					      tp->protocol, &offload);
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index f9947d1..b399faf 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -142,7 +142,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	 */
 	if (qopt->hw) {
 		struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
-					  .tc = qopt->num_tc};
+					  .tc_u.tc = qopt->num_tc};
 
 		priv->hw_owned = 1;
 		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 70d9605..00b4561 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5330,7 +5330,7 @@ static int __i40e_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
 {
 	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
-	return i40e_setup_tc(netdev, tc->tc);
+	return i40e_setup_tc(netdev, tc->tc_u.tc);
 }
 
 /**
