From: "Alexey Andriyanov" <alan@al-an.info>
Subject: [PATCH v2] ip6_tunnel: allow to change mode for the ip6tnl0
Date: Wed, 29 Oct 2014 10:54:52 +0300
Message-ID: <1414569292-15384-1-git-send-email-alan@al-an.info>
References: <1414563898-10347-1-git-send-email-alan@al-an.info>
Cc: Alexey Andriyanov <alan@al-an.info>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward10l.mail.yandex.net ([84.201.143.143]:38367 "EHLO
	forward10l.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755830AbaJ2HzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 03:55:09 -0400
In-Reply-To: <1414563898-10347-1-git-send-email-alan@al-an.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fallback device is in ipv6 mode by default.
The mode can not be changed in runtime, so there
is no way to decapsulate ip4in6 packets coming from
various sources without creating the specific tunnel
ifaces for each peer.

This allows to update the fallback tunnel device, but only
the mode could be changed. Usual command should work for the
fallback device: `ip -6 tun change ip6tnl0 mode any`

The fallback device can not be hidden from the packet receiver
as a regular tunnel, but there is no need for synchronization
as long as we do single assignment.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexey Andriyanov <alan@al-an.info>
---
 net/ipv6/ip6_tunnel.c | 32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9409887..8c97cd1 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -477,6 +477,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	int rel_msg = 0;
 	u8 rel_type = ICMPV6_DEST_UNREACH;
 	u8 rel_code = ICMPV6_ADDR_UNREACH;
+	u8 tproto;
 	__u32 rel_info = 0;
 	__u16 len;
 	int err = -ENOENT;
@@ -490,7 +491,8 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 					&ipv6h->saddr)) == NULL)
 		goto out;
 
-	if (t->parms.proto != ipproto && t->parms.proto != 0)
+	tproto = ACCESS_ONCE(t->parms.proto);
+	if (tproto != ipproto && tproto != 0)
 		goto out;
 
 	err = 0;
@@ -791,6 +793,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 {
 	struct ip6_tnl *t;
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
+	u8 tproto;
 	int err;
 
 	rcu_read_lock();
@@ -799,7 +802,8 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 					&ipv6h->daddr)) != NULL) {
 		struct pcpu_sw_netstats *tstats;
 
-		if (t->parms.proto != ipproto && t->parms.proto != 0) {
+		tproto = ACCESS_ONCE(t->parms.proto);
+		if (tproto != ipproto && tproto != 0) {
 			rcu_read_unlock();
 			goto discard;
 		}
@@ -1078,9 +1082,11 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct flowi6 fl6;
 	__u8 dsfield;
 	__u32 mtu;
+	u8 tproto;
 	int err;
 
-	if ((t->parms.proto != IPPROTO_IPIP && t->parms.proto != 0) ||
+	tproto = ACCESS_ONCE(t->parms.proto);
+	if ((tproto != IPPROTO_IPIP && tproto != 0) ||
 	    !ip6_tnl_xmit_ctl(t))
 		return -1;
 
@@ -1120,9 +1126,11 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct flowi6 fl6;
 	__u8 dsfield;
 	__u32 mtu;
+	u8 tproto;
 	int err;
 
-	if ((t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) ||
+	tproto = ACCESS_ONCE(t->parms.proto);
+	if ((tproto != IPPROTO_IPV6 && tproto != 0) ||
 	    !ip6_tnl_xmit_ctl(t) || ip6_tnl_addr_conflict(t, ipv6h))
 		return -1;
 
@@ -1285,6 +1293,14 @@ static int ip6_tnl_update(struct ip6_tnl *t, struct __ip6_tnl_parm *p)
 	return err;
 }
 
+static int ip6_tnl0_update(struct ip6_tnl *t, struct __ip6_tnl_parm *p)
+{
+	/* for default tnl0 device allow to change only the proto */
+	t->parms.proto = p->proto;
+	netdev_state_change(t->dev);
+	return 0;
+}
+
 static void
 ip6_tnl_parm_from_user(struct __ip6_tnl_parm *p, const struct ip6_tnl_parm *u)
 {
@@ -1384,7 +1400,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			break;
 		ip6_tnl_parm_from_user(&p1, &p);
 		t = ip6_tnl_locate(net, &p1, cmd == SIOCADDTUNNEL);
-		if (dev != ip6n->fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
+		if (cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -1392,8 +1408,10 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 				}
 			} else
 				t = netdev_priv(dev);
-
-			err = ip6_tnl_update(t, &p1);
+			if (dev == ip6n->fb_tnl_dev)
+				err = ip6_tnl0_update(t, &p1);
+			else
+				err = ip6_tnl_update(t, &p1);
 		}
 		if (t) {
 			err = 0;
-- 
1.9.1
