From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 01/11] bonding: Call dev_kfree_skby_any instead of kfree_skb.
Date: Mon, 10 Mar 2014 20:18:07 -0700
Message-ID: <87vbvlpgnk.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42080 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaCKDSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:18:14 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Replace consume_skb with dev_consume_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/bonding/bond_3ad.c  |    2 +-
 drivers/net/bonding/bond_alb.c  |    2 +-
 drivers/net/bonding/bond_main.c |   14 +++++++-------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index a2ef3f72de88..dee2a84a2929 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2479,7 +2479,7 @@ out:
 	return NETDEV_TX_OK;
 err_free:
 	/* no suitable interface, frame not sent */
-	kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	goto out;
 }
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index aaeeacf767f2..9cf836b67b15 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1464,7 +1464,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	}
 
 	/* no suitable interface, frame not sent */
-	kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 out:
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 730d72c706c9..63f8df8af4d4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1115,7 +1115,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 	if (recv_probe) {
 		ret = recv_probe(skb, bond, slave);
 		if (ret == RX_HANDLER_CONSUMED) {
-			consume_skb(skb);
+			dev_consume_skb_any(skb);
 			return ret;
 		}
 	}
@@ -1132,7 +1132,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 
 		if (unlikely(skb_cow_head(skb,
 					  skb->data - skb_mac_header(skb)))) {
-			kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			return RX_HANDLER_CONSUMED;
 		}
 		ether_addr_copy(eth_hdr(skb)->h_dest, bond->dev->dev_addr);
@@ -3548,7 +3548,7 @@ static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int sl
 		}
 	}
 	/* no slave that can tx has been found */
-	kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 }
 
 /**
@@ -3624,7 +3624,7 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	if (slave)
 		bond_dev_queue_xmit(bond, skb, slave->dev);
 	else
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
@@ -3667,7 +3667,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 	if (slave && IS_UP(slave->dev) && slave->link == BOND_LINK_UP)
 		bond_dev_queue_xmit(bond, skb, slave->dev);
 	else
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
@@ -3754,7 +3754,7 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 		pr_err("%s: Error: Unknown bonding mode %d\n",
 		       dev->name, bond->params.mode);
 		WARN_ON_ONCE(1);
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 }
@@ -3775,7 +3775,7 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bond_has_slaves(bond))
 		ret = __bond_start_xmit(skb, dev);
 	else
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 	rcu_read_unlock();
 
 	return ret;
-- 
1.7.5.4
