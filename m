From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net] ip_tunnel: Don't allow to add the same tunnel multiple
 times.
Date: Mon, 22 Sep 2014 09:11:08 +0200
Message-ID: <20140922071108.GY6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52744 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882AbaIVHLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 03:11:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we try to add an already existing tunnel, we don't return
an error. Instead we continue and call ip_tunnel_update().
This means that we can change existing tunnels by adding
the same tunnel multiple times. It is even possible to change
the tunnel endpoints of the fallback device.

We fix this by returning an error if we try to add an existing
tunnel.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---

I was not able to find a commit that introduced this bug.
Looks like ipip and ip_gre had similar bugs already with
the initial git commit.

 net/ipv4/ip_tunnel.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index afed1aa..8fb8da9 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -764,9 +764,14 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 
 		t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
 
-		if (!t && (cmd == SIOCADDTUNNEL)) {
-			t = ip_tunnel_create(net, itn, p);
-			err = PTR_ERR_OR_ZERO(t);
+		if (cmd == SIOCADDTUNNEL) {
+			if (!t) {
+				t = ip_tunnel_create(net, itn, p);
+				err = PTR_ERR_OR_ZERO(t);
+				break;
+			}
+
+			err = -EEXIST;
 			break;
 		}
 		if (dev != itn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
-- 
1.9.1
