From: John Myers <jgmyers@proofpoint.com>
Subject: [PATCH] ipv6: fix incorrect unregistration of sysctl when last ip deleted
Date: Wed, 27 Apr 2011 16:12:38 -0700
Message-ID: <201104272312.p3RNCcl6002068__44353.525635279$1303946480$gmane$org@jgmyers-vm1.eng.proofpoint.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.proofpoint.com ([208.86.202.10]:10530 "EHLO
	mx2.proofpoint.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757166Ab1D0XUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 19:20:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the last ip address is deleted, the kernel disables IPv6 on the
interface. (Not sure why, but that's beside the point.) The call that
does this is over-aggressive--it indicates the interface is about to
be removed even though that isn't necessarily so.

This causes IPv6 to, among other things, unregister its sysctl
parameters for the interface. Thus, the "accept_ra" and "addrconf"
settings can't be set on the interface until after the interface has
been brought back up, which is too late.

Signed-off-by: John Gardiner Myers <jgmyers@proofpoint.com>
Cc: stable@kernel.org

---

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1493534..042d0aa 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2215,7 +2215,7 @@ static int inet6_addr_del(struct net *net, int ifindex, struct in6_addr *pfx,
 			   disable IPv6 on this interface.
 			 */
 			if (list_empty(&idev->addr_list))
-				addrconf_ifdown(idev->dev, 1);
+				addrconf_ifdown(idev->dev, 0);
 			return 0;
 		}
 	}
