From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH RFC] net: error on trying to add a duplicate ipip tunnel
Date: Wed, 13 Nov 2013 19:21:33 +0100
Message-ID: <20131113182133.GA8760@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h32.telenor.se ([213.150.131.5]:38190 "EHLO
	smtprelay-h32.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755888Ab3KMS27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 13:28:59 -0500
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-h32.telenor.se (Postfix) with ESMTP id 9D553E8634
	for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 19:28:54 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After patch:
$ sudo ip tunnel add test1 mode ipip remote 1.2.3.4
$ sudo ip tunnel add test2 mode ipip remote 1.2.3.4
add tunnel "tunl0" failed: File exists

Before the patch, there would be no error and
"test2" (silently) not added.

Originally reported at http://bugs.debian.org/508450

The originally reported problem with sit tunnel seems
to have been resolved since then:
$ sudo ip tun add test3 mode sit
add tunnel "sit0" failed: No buffer space available

The problem still exists for (atleast) ipip tunnels though.

Reported-by: martin f krafft <madduck@debian.org>
Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 net/ipv4/ip_tunnel.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)


Maybe also sit tunnels should explicitly
use EEXISTS instead of ENOBUFS?
Maybe ipip tunnel code should be refactored
to be similar to sit tunnel addition code?
Which other tunnel types should be checked
for how they behave in similar situations?
Other comments?


diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 63a6d6d..1dc4e41 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -732,8 +732,14 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
 
 		t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
 
-		if (!t && (cmd == SIOCADDTUNNEL))
-			t = ip_tunnel_create(net, itn, p);
+		if (cmd == SIOCADDTUNNEL) {
+			if (!t) {
+				t = ip_tunnel_create(net, itn, p);
+			} else {
+				err = -EEXIST;
+				break;
+			}
+		}
 
 		if (dev != itn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
-- 
1.8.4.3
