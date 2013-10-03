From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: [PATCHv2] IPv6: Allow the MTU of ipip6 tunnel to be set below 1280
Date: Thu,  3 Oct 2013 14:49:26 +0100
Message-ID: <1380808166-13280-1-git-send-email-ou.ghorbel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oussama Ghorbel <ou.ghorbel@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The (inner) MTU of a ipip6 (IPv4-in-IPv6) tunnel cannot be set below 1280, which is the minimum MTU in IPv6.
However, there should be no IPv6 on the tunnel interface at all, so the IPv6 rules should not apply.
More info at https://bugzilla.kernel.org/show_bug.cgi?id=15530

This patch allows to check the minimum MTU for ipv6 tunnel according to these rules:
-In case the tunnel is configured with ipip6 mode the minimum MTU is 68.
-In case the tunnel is configured with ip6ip6 or any mode the minimum MTU is 1280.

Signed-off-by: Oussama Ghorbel <ou.ghorbel@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 46ba243..4b51b03 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1429,9 +1429,17 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static int
 ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu < IPV6_MIN_MTU) {
-		return -EINVAL;
+	struct ip6_tnl *tnl = netdev_priv(dev);
+
+	if (tnl->parms.proto == IPPROTO_IPIP) {
+		if (new_mtu < 68)
+			return -EINVAL;
+	} else {
+		if (new_mtu < IPV6_MIN_MTU)
+			return -EINVAL;
 	}
+	if (new_mtu > 0xFFF8 - dev->hard_header_len)
+		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
 }
-- 
1.7.9.5
