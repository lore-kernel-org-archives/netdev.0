From: Oussama Ghorbel <oghorbell@gmail.com>
Subject: [PATCH] IPv6: Allow the MTU of ipip6 tunnel to be set below 1280
Date: Thu, 26 Sep 2013 15:51:48 +0100
Message-ID: <1380207108-20030-1-git-send-email-oghorbell@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oussama Ghorbel <oghorbell@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f194.google.com ([209.85.212.194]:64101 "EHLO
	mail-wi0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab3IZOwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 10:52:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The (inner) MTU of a ipip6 (IPv4-in-IPv6) tunnel cannot be set below 1280, which is the minimum MTU in IPv6.
However, there should be no IPv6 on the tunnel interface at all, so the IPv6 rules should not apply.
More info at https://bugzilla.kernel.org/show_bug.cgi?id=15530

This patch allows to check the minimum MTU for ipv6 tunnel according to these rules:
 -In case the tunnel is configured with ipip6 mode the minimum MTU is 68.
 -In case the tunnel is configured with ip6ip6 or any mode the minimum MTU is 1280.

Signed-off-by: Oussama Ghorbel <oghorbell@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 1e55866..a66ead2 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1423,8 +1423,14 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static int
 ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu < IPV6_MIN_MTU) {
-		return -EINVAL;
+	struct ip6_tnl *t = netdev_priv(dev);
+
+	if (t->parms.proto == IPPROTO_IPIP) {
+		if (new_mtu < 68)
+			return -EINVAL;
+	} else {
+		if (new_mtu < IPV6_MIN_MTU)
+			return -EINVAL;
 	}
 	dev->mtu = new_mtu;
 	return 0;
-- 
1.7.9.5
