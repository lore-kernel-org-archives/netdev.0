From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 08/21] chelsio: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:26 +0200
Message-ID: <1310765619-27827-9-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622Ab1GOVeC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:02 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlan_grp and t1_vlan_rx_register
- always enable vlan hw accel

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/chelsio/common.h |    2 --
 drivers/net/chelsio/cxgb2.c  |   19 +------------------
 drivers/net/chelsio/sge.c    |   11 ++++-------
 3 files changed, 5 insertions(+), 27 deletions(-)

diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index c26d863..5ccbed1 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -240,8 +240,6 @@ struct adapter {
 	struct work_struct ext_intr_handler_task;
 	struct adapter_params params;
 
-	struct vlan_group *vlan_grp;
-
 	/* Terminator modules. */
 	struct sge    *sge;
 	struct peespi *espi;
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index b422d83..61731bc 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -227,6 +227,7 @@ static int cxgb_up(struct adapter *adapter)
 		goto out_err;
 	}
 
+	t1_set_vlan_accel(adapter, 1);
 	t1_sge_start(adapter->sge);
 	t1_interrupts_enable(adapter);
 out_err:
@@ -849,19 +850,6 @@ static int t1_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-static void t1_vlan_rx_register(struct net_device *dev,
-				   struct vlan_group *grp)
-{
-	struct adapter *adapter = dev->ml_priv;
-
-	spin_lock_irq(&adapter->async_lock);
-	adapter->vlan_grp = grp;
-	t1_set_vlan_accel(adapter, grp != NULL);
-	spin_unlock_irq(&adapter->async_lock);
-}
-#endif
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void t1_netpoll(struct net_device *dev)
 {
@@ -955,9 +943,6 @@ static const struct net_device_ops cxgb_netdev_ops = {
 	.ndo_do_ioctl		= t1_ioctl,
 	.ndo_change_mtu		= t1_change_mtu,
 	.ndo_set_mac_address	= t1_set_mac_addr,
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-	.ndo_vlan_rx_register	= t1_vlan_rx_register,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= t1_netpoll,
 #endif
@@ -1080,10 +1065,8 @@ static int __devinit init_one(struct pci_dev *pdev,
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
 		if (vlan_tso_capable(adapter)) {
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 			netdev->features |=
 				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
 
 			/* T204: disable TSO */
 			if (!(is_T2(adapter)) || bi->port_number != 4) {
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 58380d2..449ebf3 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1397,12 +1397,11 @@ static void sge_rx(struct sge *sge, struct freelQ *fl, unsigned int len)
 	} else
 		skb_checksum_none_assert(skb);
 
-	if (unlikely(adapter->vlan_grp && p->vlan_valid)) {
+	if (p->vlan_valid) {
 		st->vlan_xtract++;
-		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp,
-					 ntohs(p->vlan));
-	} else
-		netif_receive_skb(skb);
+		__vlan_hwaccel_put_tag(skb, ntohs(p->vlan));
+	}
+	netif_receive_skb(skb);
 }
 
 /*
@@ -1875,13 +1874,11 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	cpl->iff = dev->if_port;
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	if (vlan_tx_tag_present(skb)) {
 		cpl->vlan_valid = 1;
 		cpl->vlan = htons(vlan_tx_tag_get(skb));
 		st->vlan_insert++;
 	} else
-#endif
 		cpl->vlan_valid = 0;
 
 send:
-- 
1.7.6

