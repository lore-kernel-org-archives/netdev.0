From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/8][GRE]: Add net/gre_net argument to some functions.
Date: Tue, 15 Apr 2008 16:53:24 +0400
Message-ID: <4804A544.7000800@openvz.org>
References: <4804A374.9040505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41394 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764628AbYDOMTF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:19:05 -0400
In-Reply-To: <4804A374.9040505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fallback device and hashes are to become per-net, but many
code doesn't have anything to get the struct net pointer from.

So pass the proper net there with an extra argument.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_gre.c |   51 ++++++++++++++++++++++++++++++++-------------------
 1 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d729ca8..6209ab3 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -162,7 +162,8 @@ static DEFINE_RWLOCK(ipgre_lock);
 
 /* Given src, dst and key, find appropriate for input tunnel. */
 
-static struct ip_tunnel * ipgre_tunnel_lookup(__be32 remote, __be32 local, __be32 key)
+static struct ip_tunnel * ipgre_tunnel_lookup(struct net *net,
+		__be32 remote, __be32 local, __be32 key)
 {
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(key);
@@ -198,7 +199,8 @@ static struct ip_tunnel * ipgre_tunnel_lookup(__be32 remote, __be32 local, __be3
 	return NULL;
 }
 
-static struct ip_tunnel **__ipgre_bucket(struct ip_tunnel_parm *parms)
+static struct ip_tunnel **__ipgre_bucket(struct ipgre_net *ign,
+		struct ip_tunnel_parm *parms)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
@@ -216,14 +218,15 @@ static struct ip_tunnel **__ipgre_bucket(struct ip_tunnel_parm *parms)
 	return &tunnels[prio][h];
 }
 
-static inline struct ip_tunnel **ipgre_bucket(struct ip_tunnel *t)
+static inline struct ip_tunnel **ipgre_bucket(struct ipgre_net *ign,
+		struct ip_tunnel *t)
 {
-	return __ipgre_bucket(&t->parms);
+	return __ipgre_bucket(ign, &t->parms);
 }
 
-static void ipgre_tunnel_link(struct ip_tunnel *t)
+static void ipgre_tunnel_link(struct ipgre_net *ign, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp = ipgre_bucket(t);
+	struct ip_tunnel **tp = ipgre_bucket(ign, t);
 
 	t->next = *tp;
 	write_lock_bh(&ipgre_lock);
@@ -231,11 +234,11 @@ static void ipgre_tunnel_link(struct ip_tunnel *t)
 	write_unlock_bh(&ipgre_lock);
 }
 
-static void ipgre_tunnel_unlink(struct ip_tunnel *t)
+static void ipgre_tunnel_unlink(struct ipgre_net *ign, struct ip_tunnel *t)
 {
 	struct ip_tunnel **tp;
 
-	for (tp = ipgre_bucket(t); *tp; tp = &(*tp)->next) {
+	for (tp = ipgre_bucket(ign, t); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
 			write_lock_bh(&ipgre_lock);
 			*tp = t->next;
@@ -245,7 +248,8 @@ static void ipgre_tunnel_unlink(struct ip_tunnel *t)
 	}
 }
 
-static struct ip_tunnel * ipgre_tunnel_locate(struct ip_tunnel_parm *parms, int create)
+static struct ip_tunnel * ipgre_tunnel_locate(struct net *net,
+		struct ip_tunnel_parm *parms, int create)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
@@ -253,8 +257,9 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct ip_tunnel_parm *parms, int
 	struct ip_tunnel *t, **tp, *nt;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 
-	for (tp = __ipgre_bucket(parms); (t = *tp) != NULL; tp = &t->next) {
+	for (tp = __ipgre_bucket(ign, parms); (t = *tp) != NULL; tp = &t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
 			if (key == t->parms.i_key)
 				return t;
@@ -285,7 +290,7 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct ip_tunnel_parm *parms, int
 		goto failed_free;
 
 	dev_hold(dev);
-	ipgre_tunnel_link(nt);
+	ipgre_tunnel_link(ign, nt);
 	return nt;
 
 failed_free:
@@ -295,7 +300,10 @@ failed_free:
 
 static void ipgre_tunnel_uninit(struct net_device *dev)
 {
-	ipgre_tunnel_unlink(netdev_priv(dev));
+	struct net *net = dev_net(dev);
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+
+	ipgre_tunnel_unlink(ign, netdev_priv(dev));
 	dev_put(dev);
 }
 
@@ -369,7 +377,9 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	}
 
 	read_lock(&ipgre_lock);
-	t = ipgre_tunnel_lookup(iph->daddr, iph->saddr, (flags&GRE_KEY) ? *(((__be32*)p) + (grehlen>>2) - 1) : 0);
+	t = ipgre_tunnel_lookup(&init_net, iph->daddr, iph->saddr,
+			(flags&GRE_KEY) ?
+			*(((__be32*)p) + (grehlen>>2) - 1) : 0);
 	if (t == NULL || t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
 		goto out;
@@ -602,7 +612,8 @@ static int ipgre_rcv(struct sk_buff *skb)
 	}
 
 	read_lock(&ipgre_lock);
-	if ((tunnel = ipgre_tunnel_lookup(iph->saddr, iph->daddr, key)) != NULL) {
+	if ((tunnel = ipgre_tunnel_lookup(&init_net,
+					iph->saddr, iph->daddr, key)) != NULL) {
 		secpath_reset(skb);
 
 		skb->protocol = *(__be16*)(h + 2);
@@ -960,6 +971,8 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip_tunnel_parm p;
 	struct ip_tunnel *t;
+	struct net *net = dev_net(dev);
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
@@ -969,7 +982,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				err = -EFAULT;
 				break;
 			}
-			t = ipgre_tunnel_locate(&p, 0);
+			t = ipgre_tunnel_locate(net, &p, 0);
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);
@@ -1001,7 +1014,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!(p.o_flags&GRE_KEY))
 			p.o_key = 0;
 
-		t = ipgre_tunnel_locate(&p, cmd == SIOCADDTUNNEL);
+		t = ipgre_tunnel_locate(net, &p, cmd == SIOCADDTUNNEL);
 
 		if (dev != ipgre_fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
@@ -1023,14 +1036,14 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 					err = -EINVAL;
 					break;
 				}
-				ipgre_tunnel_unlink(t);
+				ipgre_tunnel_unlink(ign, t);
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
 				t->parms.i_key = p.i_key;
 				t->parms.o_key = p.o_key;
 				memcpy(dev->dev_addr, &p.iph.saddr, 4);
 				memcpy(dev->broadcast, &p.iph.daddr, 4);
-				ipgre_tunnel_link(t);
+				ipgre_tunnel_link(ign, t);
 				netdev_state_change(dev);
 			}
 		}
@@ -1063,7 +1076,7 @@ ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
 			err = -ENOENT;
-			if ((t = ipgre_tunnel_locate(&p, 0)) == NULL)
+			if ((t = ipgre_tunnel_locate(net, &p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
 			if (t == netdev_priv(ipgre_fb_tunnel_dev))
-- 
1.5.3.4

