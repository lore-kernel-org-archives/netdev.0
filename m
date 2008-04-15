From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 2/7][IP6TUNNEL]: Add (ip6_tnl_)net argument to
 some calls.
Date: Tue, 15 Apr 2008 18:00:54 +0400
Message-ID: <4804B516.7060409@openvz.org>
References: <4804B478.3040606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58123 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753475AbYDON0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:26:36 -0400
In-Reply-To: <4804B478.3040606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hashes and fallback device used in them will be per-net.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/ip6_tunnel.c |   47 ++++++++++++++++++++++++++++-------------------
 1 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2365eb0..fad1af8 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -136,7 +136,7 @@ static inline void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
  **/
 
 static struct ip6_tnl *
-ip6_tnl_lookup(struct in6_addr *remote, struct in6_addr *local)
+ip6_tnl_lookup(struct net *net, struct in6_addr *remote, struct in6_addr *local)
 {
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(local);
@@ -166,7 +166,7 @@ ip6_tnl_lookup(struct in6_addr *remote, struct in6_addr *local)
  **/
 
 static struct ip6_tnl **
-ip6_tnl_bucket(struct ip6_tnl_parm *p)
+ip6_tnl_bucket(struct ip6_tnl_net *ip6n, struct ip6_tnl_parm *p)
 {
 	struct in6_addr *remote = &p->raddr;
 	struct in6_addr *local = &p->laddr;
@@ -186,9 +186,9 @@ ip6_tnl_bucket(struct ip6_tnl_parm *p)
  **/
 
 static void
-ip6_tnl_link(struct ip6_tnl *t)
+ip6_tnl_link(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 {
-	struct ip6_tnl **tp = ip6_tnl_bucket(&t->parms);
+	struct ip6_tnl **tp = ip6_tnl_bucket(ip6n, &t->parms);
 
 	t->next = *tp;
 	write_lock_bh(&ip6_tnl_lock);
@@ -202,11 +202,11 @@ ip6_tnl_link(struct ip6_tnl *t)
  **/
 
 static void
-ip6_tnl_unlink(struct ip6_tnl *t)
+ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 {
 	struct ip6_tnl **tp;
 
-	for (tp = ip6_tnl_bucket(&t->parms); *tp; tp = &(*tp)->next) {
+	for (tp = ip6_tnl_bucket(ip6n, &t->parms); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
 			write_lock_bh(&ip6_tnl_lock);
 			*tp = t->next;
@@ -228,12 +228,13 @@ ip6_tnl_unlink(struct ip6_tnl *t)
  *   created tunnel or NULL
  **/
 
-static struct ip6_tnl *ip6_tnl_create(struct ip6_tnl_parm *p)
+static struct ip6_tnl *ip6_tnl_create(struct net *net, struct ip6_tnl_parm *p)
 {
 	struct net_device *dev;
 	struct ip6_tnl *t;
 	char name[IFNAMSIZ];
 	int err;
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
 	if (p->name[0])
 		strlcpy(name, p->name, IFNAMSIZ);
@@ -257,7 +258,7 @@ static struct ip6_tnl *ip6_tnl_create(struct ip6_tnl_parm *p)
 		goto failed_free;
 
 	dev_hold(dev);
-	ip6_tnl_link(t);
+	ip6_tnl_link(ip6n, t);
 	return t;
 
 failed_free:
@@ -280,20 +281,22 @@ failed:
  *   matching tunnel or NULL
  **/
 
-static struct ip6_tnl *ip6_tnl_locate(struct ip6_tnl_parm *p, int create)
+static struct ip6_tnl *ip6_tnl_locate(struct net *net,
+		struct ip6_tnl_parm *p, int create)
 {
 	struct in6_addr *remote = &p->raddr;
 	struct in6_addr *local = &p->laddr;
 	struct ip6_tnl *t;
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
-	for (t = *ip6_tnl_bucket(p); t; t = t->next) {
+	for (t = *ip6_tnl_bucket(ip6n, p); t; t = t->next) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
 		    ipv6_addr_equal(remote, &t->parms.raddr))
 			return t;
 	}
 	if (!create)
 		return NULL;
-	return ip6_tnl_create(p);
+	return ip6_tnl_create(net, p);
 }
 
 /**
@@ -308,13 +311,15 @@ static void
 ip6_tnl_dev_uninit(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
+	struct net *net = dev_net(dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
 	if (dev == ip6_fb_tnl_dev) {
 		write_lock_bh(&ip6_tnl_lock);
 		tnls_wc[0] = NULL;
 		write_unlock_bh(&ip6_tnl_lock);
 	} else {
-		ip6_tnl_unlink(t);
+		ip6_tnl_unlink(ip6n, t);
 	}
 	ip6_tnl_dst_reset(t);
 	dev_put(dev);
@@ -407,7 +412,8 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	   processing of the error. */
 
 	read_lock(&ip6_tnl_lock);
-	if ((t = ip6_tnl_lookup(&ipv6h->daddr, &ipv6h->saddr)) == NULL)
+	if ((t = ip6_tnl_lookup(&init_net, &ipv6h->daddr,
+					&ipv6h->saddr)) == NULL)
 		goto out;
 
 	if (t->parms.proto != ipproto && t->parms.proto != 0)
@@ -690,7 +696,8 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 
 	read_lock(&ip6_tnl_lock);
 
-	if ((t = ip6_tnl_lookup(&ipv6h->saddr, &ipv6h->daddr)) != NULL) {
+	if ((t = ip6_tnl_lookup(&init_net, &ipv6h->saddr,
+					&ipv6h->daddr)) != NULL) {
 		if (t->parms.proto != ipproto && t->parms.proto != 0) {
 			read_unlock(&ip6_tnl_lock);
 			goto discard;
@@ -1197,6 +1204,8 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	int err = 0;
 	struct ip6_tnl_parm p;
 	struct ip6_tnl *t = NULL;
+	struct net *net = dev_net(dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
@@ -1205,7 +1214,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				err = -EFAULT;
 				break;
 			}
-			t = ip6_tnl_locate(&p, 0);
+			t = ip6_tnl_locate(net, &p, 0);
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);
@@ -1226,7 +1235,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (p.proto != IPPROTO_IPV6 && p.proto != IPPROTO_IPIP &&
 		    p.proto != 0)
 			break;
-		t = ip6_tnl_locate(&p, cmd == SIOCADDTUNNEL);
+		t = ip6_tnl_locate(net, &p, cmd == SIOCADDTUNNEL);
 		if (dev != ip6_fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
@@ -1236,9 +1245,9 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			} else
 				t = netdev_priv(dev);
 
-			ip6_tnl_unlink(t);
+			ip6_tnl_unlink(ip6n, t);
 			err = ip6_tnl_change(t, &p);
-			ip6_tnl_link(t);
+			ip6_tnl_link(ip6n, t);
 			netdev_state_change(dev);
 		}
 		if (t) {
@@ -1259,7 +1268,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
 				break;
 			err = -ENOENT;
-			if ((t = ip6_tnl_locate(&p, 0)) == NULL)
+			if ((t = ip6_tnl_locate(net, &p, 0)) == NULL)
 				break;
 			err = -EPERM;
 			if (t->dev == ip6_fb_tnl_dev)
-- 
1.5.3.4

