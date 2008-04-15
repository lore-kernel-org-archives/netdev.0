From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/8][SIT]: Add net/sit_net argument to some functions.
Date: Tue, 15 Apr 2008 17:29:28 +0400
Message-ID: <4804ADB8.7060104@openvz.org>
References: <4804ACFA.1040003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45114 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755907AbYDOMzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:55:11 -0400
In-Reply-To: <4804ACFA.1040003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... to make them prepared for future hashes and fallback device
move on the struct sit_net.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/sit.c |   49 ++++++++++++++++++++++++++++++-------------------
 1 files changed, 30 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index aa6efc2..66cf0be 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -82,7 +82,8 @@ static struct ip_tunnel **tunnels[4] = { tunnels_wc, tunnels_l, tunnels_r, tunne
 
 static DEFINE_RWLOCK(ipip6_lock);
 
-static struct ip_tunnel * ipip6_tunnel_lookup(__be32 remote, __be32 local)
+static struct ip_tunnel * ipip6_tunnel_lookup(struct net *net,
+		__be32 remote, __be32 local)
 {
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(local);
@@ -106,7 +107,8 @@ static struct ip_tunnel * ipip6_tunnel_lookup(__be32 remote, __be32 local)
 	return NULL;
 }
 
-static struct ip_tunnel **__ipip6_bucket(struct ip_tunnel_parm *parms)
+static struct ip_tunnel **__ipip6_bucket(struct sit_net *sitn,
+		struct ip_tunnel_parm *parms)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
@@ -124,16 +126,17 @@ static struct ip_tunnel **__ipip6_bucket(struct ip_tunnel_parm *parms)
 	return &tunnels[prio][h];
 }
 
-static inline struct ip_tunnel **ipip6_bucket(struct ip_tunnel *t)
+static inline struct ip_tunnel **ipip6_bucket(struct sit_net *sitn,
+		struct ip_tunnel *t)
 {
-	return __ipip6_bucket(&t->parms);
+	return __ipip6_bucket(sitn, &t->parms);
 }
 
-static void ipip6_tunnel_unlink(struct ip_tunnel *t)
+static void ipip6_tunnel_unlink(struct sit_net *sitn, struct ip_tunnel *t)
 {
 	struct ip_tunnel **tp;
 
-	for (tp = ipip6_bucket(t); *tp; tp = &(*tp)->next) {
+	for (tp = ipip6_bucket(sitn, t); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
 			write_lock_bh(&ipip6_lock);
 			*tp = t->next;
@@ -143,9 +146,9 @@ static void ipip6_tunnel_unlink(struct ip_tunnel *t)
 	}
 }
 
-static void ipip6_tunnel_link(struct ip_tunnel *t)
+static void ipip6_tunnel_link(struct sit_net *sitn, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp = ipip6_bucket(t);
+	struct ip_tunnel **tp = ipip6_bucket(sitn, t);
 
 	t->next = *tp;
 	write_lock_bh(&ipip6_lock);
@@ -153,15 +156,17 @@ static void ipip6_tunnel_link(struct ip_tunnel *t)
 	write_unlock_bh(&ipip6_lock);
 }
 
-static struct ip_tunnel * ipip6_tunnel_locate(struct ip_tunnel_parm *parms, int create)
+static struct ip_tunnel * ipip6_tunnel_locate(struct net *net,
+		struct ip_tunnel_parm *parms, int create)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
 	struct ip_tunnel *t, **tp, *nt;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
+	struct sit_net *sitn = net_generic(net, sit_net_id);
 
-	for (tp = __ipip6_bucket(parms); (t = *tp) != NULL; tp = &t->next) {
+	for (tp = __ipip6_bucket(sitn, parms); (t = *tp) != NULL; tp = &t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
 			return t;
 	}
@@ -194,7 +199,7 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct ip_tunnel_parm *parms, int
 
 	dev_hold(dev);
 
-	ipip6_tunnel_link(nt);
+	ipip6_tunnel_link(sitn, nt);
 	return nt;
 
 failed_free:
@@ -378,13 +383,16 @@ isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 
 static void ipip6_tunnel_uninit(struct net_device *dev)
 {
+	struct net *net = dev_net(dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
+
 	if (dev == ipip6_fb_tunnel_dev) {
 		write_lock_bh(&ipip6_lock);
 		tunnels_wc[0] = NULL;
 		write_unlock_bh(&ipip6_lock);
 		dev_put(dev);
 	} else {
-		ipip6_tunnel_unlink(netdev_priv(dev));
+		ipip6_tunnel_unlink(sitn, netdev_priv(dev));
 		ipip6_tunnel_del_prl(netdev_priv(dev), NULL);
 		dev_put(dev);
 	}
@@ -436,7 +444,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	err = -ENOENT;
 
 	read_lock(&ipip6_lock);
-	t = ipip6_tunnel_lookup(iph->daddr, iph->saddr);
+	t = ipip6_tunnel_lookup(&init_net, iph->daddr, iph->saddr);
 	if (t == NULL || t->parms.iph.daddr == 0)
 		goto out;
 
@@ -556,7 +564,8 @@ static int ipip6_rcv(struct sk_buff *skb)
 	iph = ip_hdr(skb);
 
 	read_lock(&ipip6_lock);
-	if ((tunnel = ipip6_tunnel_lookup(iph->saddr, iph->daddr)) != NULL) {
+	if ((tunnel = ipip6_tunnel_lookup(&init_net,
+					iph->saddr, iph->daddr)) != NULL) {
 		secpath_reset(skb);
 		skb->mac_header = skb->network_header;
 		skb_reset_network_header(skb);
@@ -847,6 +856,8 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_prl prl;
 	struct ip_tunnel *t;
+	struct net *net = dev_net(dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
@@ -856,7 +867,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				err = -EFAULT;
 				break;
 			}
-			t = ipip6_tunnel_locate(&p, 0);
+			t = ipip6_tunnel_locate(net, &p, 0);
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);
@@ -882,7 +893,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (p.iph.ttl)
 			p.iph.frag_off |= htons(IP_DF);
 
-		t = ipip6_tunnel_locate(&p, cmd == SIOCADDTUNNEL);
+		t = ipip6_tunnel_locate(net, &p, cmd == SIOCADDTUNNEL);
 
 		if (dev != ipip6_fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
@@ -897,12 +908,12 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 					break;
 				}
 				t = netdev_priv(dev);
-				ipip6_tunnel_unlink(t);
+				ipip6_tunnel_unlink(sitn, t);
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
 				memcpy(dev->dev_addr, &p.iph.saddr, 4);
 				memcpy(dev->broadcast, &p.iph.daddr, 4);
-				ipip6_tunnel_link(t);
+				ipip6_tunnel_link(sitn, t);
 				netdev_state_change(dev);
 			}
 		}
@@ -934,7 +945,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
 			err = -ENOENT;
-			if ((t = ipip6_tunnel_locate(&p, 0)) == NULL)
+			if ((t = ipip6_tunnel_locate(net, &p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
 			if (t == netdev_priv(ipip6_fb_tunnel_dev))
-- 
1.5.3.4

