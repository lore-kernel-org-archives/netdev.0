From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC net-next] tun: implement BQL
Date: Mon, 12 Nov 2012 13:22:41 -0800
Message-ID: <20121112132241.12bb94e4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52625 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117Ab2KLVXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 16:23:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add multiqueue BQL to tap device. Tested with VPN, doesn't have a big impact,
most likely because there is little queueing occuring at TAP device except
under case of forwarding.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tun.c	2012-11-12 07:58:45.527037947 -0800
+++ b/drivers/net/tun.c	2012-11-12 11:20:26.017512742 -0800
@@ -412,6 +412,7 @@ static void __tun_detach(struct tun_file
 		tun_flow_delete_by_queue(tun, tun->numqueues + 1);
 		/* Drop read queue */
 		skb_queue_purge(&tfile->sk.sk_receive_queue);
+		netdev_tx_reset_queue(netdev_get_tx_queue(dev, index));
 		tun_set_real_num_queues(tun);
 
 		if (tun->numqueues == 0 && !(tun->flags & TUN_PERSIST))
@@ -455,6 +456,7 @@ static void tun_detach_all(struct net_de
 						  lockdep_rtnl_is_held());
 		/* Drop read queue */
 		skb_queue_purge(&tfile->sk.sk_receive_queue);
+		netdev_tx_reset_queue(netdev_get_tx_queue(dev, i));
 		sock_put(&tfile->sk);
 	}
 }
@@ -712,6 +714,8 @@ static netdev_tx_t tun_net_xmit(struct s
 	 * for indefinite time. */
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		goto drop;
+
+	netdev_tx_sent_queue(netdev_get_tx_queue(dev, txq), skb->len);
 	skb_orphan(skb);
 
 	/* Enqueue packet */
@@ -1324,6 +1328,10 @@ static ssize_t tun_do_read(struct tun_st
 		netif_wake_subqueue(tun->dev, tfile->queue_index);
 
 		ret = tun_put_user(tun, tfile, skb, iv, len);
+
+		netdev_tx_completed_queue(netdev_get_tx_queue(tun->dev,
+							      tfile->queue_index),
+					  1, skb->len);
 		kfree_skb(skb);
 		break;
 	}
