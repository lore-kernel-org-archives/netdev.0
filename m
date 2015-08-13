From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 2/2] ppp: implement x-netns support
Date: Thu, 13 Aug 2015 15:28:20 +0200
Message-ID: <27e1cd9ff2168fd6944995bd05954d42518da77b.1439471390.git.g.nault@alphalink.fr>
References: <cover.1439471390.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:34730 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751590AbbHMN21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 09:28:27 -0400
Content-Disposition: inline
In-Reply-To: <cover.1439471390.git.g.nault@alphalink.fr>
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
 drivers/net/ppp/ppp_generic.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 1dc478a..bdde5d8 100644
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
 	idr_for_each_entry(&pn->units_idr, ppp, id) {
-		unregister_netdevice_queue(ppp->dev, &list);
+		/* Skip devices already unregistered by previous loop */
+		if (!net_eq(dev_net(ppp->dev), net))
+			unregister_netdevice_queue(ppp->dev, &list);
 	}
 
 	unregister_netdevice_many(&list);
@@ -1018,6 +1029,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	proto = npindex_to_proto[npi];
 	put_unaligned_be16(proto, pp);
 
+	skb_scrub_packet(skb, !net_eq(ppp->ppp_net, dev_net(dev)));
 	skb_queue_tail(&ppp->file.xq, skb);
 	ppp_xmit_process(ppp);
 	return NETDEV_TX_OK;
@@ -1138,7 +1150,6 @@ static void ppp_setup(struct net_device *dev)
 	dev->tx_queue_len = 3;
 	dev->type = ARPHRD_PPP;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
-	dev->features |= NETIF_F_NETNS_LOCAL;
 	netif_keep_dst(dev);
 }
 
@@ -1901,6 +1912,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
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
