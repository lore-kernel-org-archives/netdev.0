From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next v2] ppp: implement x-netns support
Date: Mon, 24 Aug 2015 11:35:30 +0200
Message-ID: <7bed7d73ab7508dd1898bcb83d9523772a89bcf9.1440408699.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38118 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932792AbbHXJfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 05:35:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let packets move from one netns to the other at PPP encapsulation and
decapsulation time.

PPP units and channels remain in the netns in which they were
originally created. Only the net_device may move to a different
namespace. Cross netns handling is thus transparent to lower PPP
layers (PPPoE, L2TP, etc.).

PPP devices are automatically unregistered when their netns gets
removed. So read() and poll() on the unit file descriptor will
respectively receive EOF and POLLHUP. Channels aren't affected.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
v2: rebase on top of net-next

 drivers/net/ppp/ppp_generic.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index fa8f504..0481daf 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -283,6 +283,8 @@ static int unit_set(struct idr *p, void *ptr, int n);
 static void unit_put(struct idr *p, int n);
 static void *unit_find(struct idr *p, int n);
 
+static const struct net_device_ops ppp_netdev_ops;
+
 static struct class *ppp_class;
 
 /* per net-namespace data */
@@ -919,13 +921,22 @@ static __net_init int ppp_init_net(struct net *net)
 static __net_exit void ppp_exit_net(struct net *net)
 {
 	struct ppp_net *pn = net_generic(net, ppp_net_id);
+	struct net_device *dev;
+	struct net_device *aux;
 	struct ppp *ppp;
 	LIST_HEAD(list);
 	int id;
 
 	rtnl_lock();
+	for_each_netdev_safe(net, dev, aux) {
+		if (dev->netdev_ops == &ppp_netdev_ops)
+			unregister_netdevice_queue(dev, &list);
+	}
+
 	idr_for_each_entry(&pn->units_idr, ppp, id)
-		unregister_netdevice_queue(ppp->dev, &list);
+		/* Skip devices already unregistered by previous loop */
+		if (!net_eq(dev_net(ppp->dev), net))
+			unregister_netdevice_queue(ppp->dev, &list);
 
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
@@ -1017,6 +1028,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	proto = npindex_to_proto[npi];
 	put_unaligned_be16(proto, pp);
 
+	skb_scrub_packet(skb, !net_eq(ppp->ppp_net, dev_net(dev)));
 	skb_queue_tail(&ppp->file.xq, skb);
 	ppp_xmit_process(ppp);
 	return NETDEV_TX_OK;
@@ -1137,7 +1149,6 @@ static void ppp_setup(struct net_device *dev)
 	dev->tx_queue_len = 3;
 	dev->type = ARPHRD_PPP;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
-	dev->features |= NETIF_F_NETNS_LOCAL;
 	netif_keep_dst(dev);
 }
 
@@ -1900,6 +1911,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 			skb->dev = ppp->dev;
 			skb->protocol = htons(npindex_to_ethertype[npi]);
 			skb_reset_mac_header(skb);
+			skb_scrub_packet(skb, !net_eq(ppp->ppp_net,
+						      dev_net(ppp->dev)));
 			netif_rx(skb);
 		}
 	}
-- 
2.5.0
