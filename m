From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/8][IPIP]: Add net/ipip_net argument to some functions.
Date: Tue, 15 Apr 2008 16:31:40 +0400
Message-ID: <4804A02C.20505@openvz.org>
References: <48049E9C.1020207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42436 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbYDOL5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:57:22 -0400
In-Reply-To: <48049E9C.1020207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hashes of tunnels will be per-net too, so prepare all the 
functions that uses them for this change by adding an argument.

Use init_net temporarily in places, where the net does not exist
explicitly yet.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipip.c |   44 +++++++++++++++++++++++++-------------------
 1 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index e657a66..bc4d4cb 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -138,7 +138,8 @@ static struct ip_tunnel **tunnels[4] = { tunnels_wc, tunnels_l, tunnels_r, tunne
 
 static DEFINE_RWLOCK(ipip_lock);
 
-static struct ip_tunnel * ipip_tunnel_lookup(__be32 remote, __be32 local)
+static struct ip_tunnel * ipip_tunnel_lookup(struct net *net,
+		__be32 remote, __be32 local)
 {
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(local);
@@ -162,7 +163,8 @@ static struct ip_tunnel * ipip_tunnel_lookup(__be32 remote, __be32 local)
 	return NULL;
 }
 
-static struct ip_tunnel **__ipip_bucket(struct ip_tunnel_parm *parms)
+static struct ip_tunnel **__ipip_bucket(struct ipip_net *ipn,
+		struct ip_tunnel_parm *parms)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
@@ -180,16 +182,17 @@ static struct ip_tunnel **__ipip_bucket(struct ip_tunnel_parm *parms)
 	return &tunnels[prio][h];
 }
 
-static inline struct ip_tunnel **ipip_bucket(struct ip_tunnel *t)
+static inline struct ip_tunnel **ipip_bucket(struct ipip_net *ipn,
+		struct ip_tunnel *t)
 {
-	return __ipip_bucket(&t->parms);
+	return __ipip_bucket(ipn, &t->parms);
 }
 
-static void ipip_tunnel_unlink(struct ip_tunnel *t)
+static void ipip_tunnel_unlink(struct ipip_net *ipn, struct ip_tunnel *t)
 {
 	struct ip_tunnel **tp;
 
-	for (tp = ipip_bucket(t); *tp; tp = &(*tp)->next) {
+	for (tp = ipip_bucket(ipn, t); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
 			write_lock_bh(&ipip_lock);
 			*tp = t->next;
@@ -199,9 +202,9 @@ static void ipip_tunnel_unlink(struct ip_tunnel *t)
 	}
 }
 
-static void ipip_tunnel_link(struct ip_tunnel *t)
+static void ipip_tunnel_link(struct ipip_net *ipn, struct ip_tunnel *t)
 {
-	struct ip_tunnel **tp = ipip_bucket(t);
+	struct ip_tunnel **tp = ipip_bucket(ipn, t);
 
 	t->next = *tp;
 	write_lock_bh(&ipip_lock);
@@ -209,15 +212,17 @@ static void ipip_tunnel_link(struct ip_tunnel *t)
 	write_unlock_bh(&ipip_lock);
 }
 
-static struct ip_tunnel * ipip_tunnel_locate(struct ip_tunnel_parm *parms, int create)
+static struct ip_tunnel * ipip_tunnel_locate(struct net *net,
+		struct ip_tunnel_parm *parms, int create)
 {
 	__be32 remote = parms->iph.daddr;
 	__be32 local = parms->iph.saddr;
 	struct ip_tunnel *t, **tp, *nt;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
+	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 
-	for (tp = __ipip_bucket(parms); (t = *tp) != NULL; tp = &t->next) {
+	for (tp = __ipip_bucket(ipn, parms); (t = *tp) != NULL; tp = &t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
 			return t;
 	}
@@ -246,7 +251,7 @@ static struct ip_tunnel * ipip_tunnel_locate(struct ip_tunnel_parm *parms, int c
 		goto failed_free;
 
 	dev_hold(dev);
-	ipip_tunnel_link(nt);
+	ipip_tunnel_link(ipn, nt);
 	return nt;
 
 failed_free:
@@ -264,7 +269,7 @@ static void ipip_tunnel_uninit(struct net_device *dev)
 		tunnels_wc[0] = NULL;
 		write_unlock_bh(&ipip_lock);
 	} else
-		ipip_tunnel_unlink(netdev_priv(dev));
+		ipip_tunnel_unlink(ipn, netdev_priv(dev));
 	dev_put(dev);
 }
 
@@ -313,7 +318,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 	err = -ENOENT;
 
 	read_lock(&ipip_lock);
-	t = ipip_tunnel_lookup(iph->daddr, iph->saddr);
+	t = ipip_tunnel_lookup(&init_net, iph->daddr, iph->saddr);
 	if (t == NULL || t->parms.iph.daddr == 0)
 		goto out;
 
@@ -473,7 +478,8 @@ static int ipip_rcv(struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 
 	read_lock(&ipip_lock);
-	if ((tunnel = ipip_tunnel_lookup(iph->saddr, iph->daddr)) != NULL) {
+	if ((tunnel = ipip_tunnel_lookup(&init_net,
+					iph->saddr, iph->daddr)) != NULL) {
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 			read_unlock(&ipip_lock);
 			kfree_skb(skb);
@@ -706,7 +712,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				err = -EFAULT;
 				break;
 			}
-			t = ipip_tunnel_locate(&p, 0);
+			t = ipip_tunnel_locate(net, &p, 0);
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);
@@ -732,7 +738,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (p.iph.ttl)
 			p.iph.frag_off |= htons(IP_DF);
 
-		t = ipip_tunnel_locate(&p, cmd == SIOCADDTUNNEL);
+		t = ipip_tunnel_locate(net, &p, cmd == SIOCADDTUNNEL);
 
 		if (dev != ipn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
@@ -747,12 +753,12 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 					break;
 				}
 				t = netdev_priv(dev);
-				ipip_tunnel_unlink(t);
+				ipip_tunnel_unlink(ipn, t);
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
 				memcpy(dev->dev_addr, &p.iph.saddr, 4);
 				memcpy(dev->broadcast, &p.iph.daddr, 4);
-				ipip_tunnel_link(t);
+				ipip_tunnel_link(ipn, t);
 				netdev_state_change(dev);
 			}
 		}
@@ -785,7 +791,7 @@ ipip_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
 			err = -ENOENT;
-			if ((t = ipip_tunnel_locate(&p, 0)) == NULL)
+			if ((t = ipip_tunnel_locate(net, &p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
 			if (t->dev == ipn->fb_tunnel_dev)
-- 
1.5.3.4

