From: "Alexey Andriyanov" <alan@al-an.info>
Subject: [net-next 2/2] ip6_tunnel: allow to change mode for the ip6tnl0
Date: Tue, 21 Oct 2014 12:19:56 +0400
Message-ID: <1413879596-13726-2-git-send-email-alan@al-an.info>
References: <1413879596-13726-1-git-send-email-alan@al-an.info>
Cc: Alexey Andriyanov <alan@al-an.info>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Roman Gushchin <klamm@yandex-team.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward8l.mail.yandex.net ([84.201.143.141]:50559 "EHLO
	forward8l.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484AbaJUIUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 04:20:04 -0400
In-Reply-To: <1413879596-13726-1-git-send-email-alan@al-an.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fallback device is in ipv6 mode by default.
The mode can not be changed in runtime, so there
is no way to decapsulate ip4in6 packets coming from
various sources without creating the specific tunnel
ifaces for each peer.

This allows to update the fallback tunnel device, but only
the mode could be changed.

Cc: David Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexey Andriyanov <alan@al-an.info>
---
 net/ipv6/ip6_tunnel.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a48f212..0e45ec9 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1285,6 +1285,14 @@ static int ip6_tnl_update(struct ip6_tnl *t, struct __ip6_tnl_parm *p)
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
@@ -1384,7 +1392,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			break;
 		ip6_tnl_parm_from_user(&p1, &p);
 		t = ip6_tnl_locate(net, &p1, cmd == SIOCADDTUNNEL);
-		if (dev != ip6n->fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
+		if (cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -1392,8 +1400,10 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
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
