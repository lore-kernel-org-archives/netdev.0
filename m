From: Karlis Peisenieks <karlis@mt.lv>
Subject: Re: IFF_NOARP & broadcasting
Date: Wed, 24 Jul 2002 21:06:08 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0207242054370.3022-100000@karlis.dev.mt.lv>
References: <200207241652.UAA19057@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200207241652.UAA19057@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Wed, 24 Jul 2002 kuznet@ms2.inr.ac.ru wrote:

> > Is there any serious reason why when device has IFF_NOARP set, devices ll
> > address is used as destination address even for broadcasts (and even when
> > devices broadcast address is valid)?
> 
> No reasons, I think. Instead of that your patch, it may be better just 
> exchange order of tests. As I remember, ll addr is initialized

Ok, please consider the attached patch.

> No, it is surely not impossible. f.e.
> 
> ip neigh add 255.255.255.255 dev dummy0 lladdr ff:ff:ff:ff:ff:ff

Umm, did not think of this. Anyway, this forces to add one neigh for each 
broadcast address in use on interface.

Here comes the patch:

--- arp.c.orig	Wed Jul 24 20:43:13 2002
+++ arp.c	Wed Jul 24 20:42:53 2002
@@ -289,12 +289,12 @@
 		if (neigh->type == RTN_MULTICAST) {
 			neigh->nud_state = NUD_NOARP;
 			arp_mc_map(addr, neigh->ha, dev, 1);
-		} else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
-			neigh->nud_state = NUD_NOARP;
-			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
 		} else if (neigh->type == RTN_BROADCAST || dev->flags&IFF_POINTOPOINT) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
+		} else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
+			neigh->nud_state = NUD_NOARP;
+			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
 		}
 		if (dev->hard_header_cache)
 			neigh->ops = &arp_hh_ops;



Karlis
