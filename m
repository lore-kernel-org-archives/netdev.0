From: Jeff Harris <jeff_harris@kentrox.com>
Subject: [PATCH] net: Prefer non link-local source addresses
Date: Thu,  1 Sep 2011 16:20:54 -0400
Message-ID: <1314908454-14359-1-git-send-email-jeff_harris@kentrox.com>
Cc: Jeff Harris <jeff_harris@kentrox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kabe
Return-path: <netdev-owner@vger.kernel.org>
Received: from dubexchange.corp.kentrox.com ([192.228.36.11]:44579 "EHLO
	dubexchange.corp.kentrox.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756861Ab1IAU1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 16:27:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Section 2.6.1 of RFC 3927 specifies that if link-local and routable addresses
are available on an interface, a routable address is preferred.  Update the
IPv4 source address selection algorithm to use a 169.254.x.x address only if
another matching address is not found.

Tested combinations of configured IP addresses with and without link-local to
verify a link-local address was chosen only if no routable address was
present.

Signed-off-by: Jeff Harris <jeff_harris@kentrox.com>
---
 net/ipv4/devinet.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index bc19bd0..70ddf37 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -965,6 +965,8 @@ out:
 __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 {
 	__be32 addr = 0;
+	__be32 lladdr = 0;
+	__be32 firstaddr = 0;
 	struct in_device *in_dev;
 	struct net *net = dev_net(dev);
 
@@ -977,15 +979,27 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 		if (ifa->ifa_scope > scope)
 			continue;
 		if (!dst || inet_ifa_match(dst, ifa)) {
+			if (ipv4_is_linklocal_169(ifa->ifa_address)) {
+				lladdr = ifa->ifa_local;
+				continue;
+			}
 			addr = ifa->ifa_local;
 			break;
 		}
-		if (!addr)
-			addr = ifa->ifa_local;
+		if (!firstaddr)
+			firstaddr = ifa->ifa_local;
 	} endfor_ifa(in_dev);
 
 	if (addr)
 		goto out_unlock;
+	if (lladdr) {
+		addr = lladdr;
+		goto out_unlock;
+	}
+	if (firstaddr) {
+		addr = firstaddr;
+		goto out_unlock;
+	}
 no_in_dev:
 
 	/* Not loopback addresses on loopback should be preferred
-- 
1.7.0.5
