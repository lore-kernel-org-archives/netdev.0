From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: sit: Update lookup to handle links set to L3 slave
Date: Mon, 30 Oct 2017 10:07:17 -0700
Message-ID: <1509383237-26987-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:47128 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932369AbdJ3RHX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 13:07:23 -0400
Received: by mail-pg0-f66.google.com with SMTP id r25so12160796pgn.4
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 10:07:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using SIT tunnels with VRFs works fine if the underlay device is in a
VRF and the link parameter is set to the VRF device. e.g.,

    ip tunnel add jtun mode sit remote <addr> local <addr> dev myvrf

Update the device check to allow the link to be the enslaved device as
well. e.g.,

    ip tunnel add jtun mode sit remote <addr> local <addr> dev eth4

where eth4 is enslaved to myvrf.

Reported-by: Jeff Barnhill <0xeffeff@gmail.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv6/sit.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a799f5258614..d60ddcb0bfe2 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -91,29 +91,35 @@ struct sit_net {
  * Must be invoked with rcu_read_lock
  */
 static struct ip_tunnel *ipip6_tunnel_lookup(struct net *net,
-		struct net_device *dev, __be32 remote, __be32 local)
+					     struct net_device *dev,
+					     __be32 remote, __be32 local,
+					     int sifindex)
 {
 	unsigned int h0 = HASH(remote);
 	unsigned int h1 = HASH(local);
 	struct ip_tunnel *t;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
+	int ifindex = dev ? dev->ifindex : 0;
 
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_r_l[h0 ^ h1]) {
 		if (local == t->parms.iph.saddr &&
 		    remote == t->parms.iph.daddr &&
-		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
+		    (!dev || !t->parms.link || ifindex == t->parms.link ||
+		     sifindex == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_r[h0]) {
 		if (remote == t->parms.iph.daddr &&
-		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
+		    (!dev || !t->parms.link || ifindex == t->parms.link ||
+		     sifindex == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
 	for_each_ip_tunnel_rcu(t, sitn->tunnels_l[h1]) {
 		if (local == t->parms.iph.saddr &&
-		    (!dev || !t->parms.link || dev->ifindex == t->parms.link) &&
+		    (!dev || !t->parms.link || ifindex == t->parms.link ||
+		     sifindex == t->parms.link) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
@@ -486,6 +492,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	const int code = icmp_hdr(skb)->code;
 	unsigned int data_len = 0;
 	struct ip_tunnel *t;
+	int sifindex;
 	int err;
 
 	switch (type) {
@@ -517,10 +524,9 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 
 	err = -ENOENT;
 
-	t = ipip6_tunnel_lookup(dev_net(skb->dev),
-				skb->dev,
-				iph->daddr,
-				iph->saddr);
+	sifindex = netif_is_l3_master(skb->dev) ? IPCB(skb)->iif : 0;
+	t = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
+				iph->daddr, iph->saddr, sifindex);
 	if (!t)
 		goto out;
 
@@ -633,10 +639,12 @@ static int ipip6_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct ip_tunnel *tunnel;
+	int sifindex;
 	int err;
 
+	sifindex = netif_is_l3_master(skb->dev) ? IPCB(skb)->iif : 0;
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
-				     iph->saddr, iph->daddr);
+				     iph->saddr, iph->daddr, sifindex);
 	if (tunnel) {
 		struct pcpu_sw_netstats *tstats;
 
@@ -704,10 +712,13 @@ static int sit_tunnel_rcv(struct sk_buff *skb, u8 ipproto)
 {
 	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
+	int sifindex;
+
+	sifindex = netif_is_l3_master(skb->dev) ? IPCB(skb)->iif : 0;
 
 	iph = ip_hdr(skb);
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
-				     iph->saddr, iph->daddr);
+				     iph->saddr, iph->daddr, sifindex);
 	if (tunnel) {
 		const struct tnl_ptk_info *tpi;
 
-- 
2.1.4
