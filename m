From: Karlis Peisenieks <karlis@mt.lv>
Subject: IFF_NOARP & broadcasting
Date: Wed, 24 Jul 2002 19:04:21 +0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020724190421.A2449@karlis>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Is there any serious reason why when device has IFF_NOARP set, devices ll
address is used as destination address even for broadcasts (and even when
devices broadcast address is valid)? Currently it is impossible to send out
correct broadcast over ethernet when IFF_NOARP is set.

The code in question is in net/ipv4/arp.c, function arp_constructor:

                if (neigh->type == RTN_MULTICAST) {
                        neigh->nud_state = NUD_NOARP;
                        arp_mc_map(addr, neigh->ha, dev, 1);
                } else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
                                       ^^^^^^^^^
                        neigh->nud_state = NUD_NOARP;
                        memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
                } else if (neigh->type == RTN_BROADCAST ||
dev->flags&IFF_POINT neigh->nud_state = NUD_NOARP;
                        memcpy(neigh->ha, dev->broadcast, dev->addr_len);
                }

Is it ok to apply following patch and not break anything:

--- arp.c.orig	Wed Jul 24 19:02:53 2002
+++ arp.c	Wed Jul 24 19:01:06 2002
@@ -289,12 +289,15 @@
 		if (neigh->type == RTN_MULTICAST) {
 			neigh->nud_state = NUD_NOARP;
 			arp_mc_map(addr, neigh->ha, dev, 1);
-		} else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
+		} else if (dev->flags&IFF_LOOPBACK) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
 		} else if (neigh->type == RTN_BROADCAST ||
dev->flags&IFF_POINTOPOINT) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
+		} else if (dev->flags & IFF_NOARP) {
+			neigh->nud_state = NUD_NOARP;
+			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
 		}
 		if (dev->hard_header_cache)
 			neigh->ops = &arp_hh_ops;
