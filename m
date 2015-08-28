From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 4/4] vxlan: do not receive IPv4 packets on IPv6 socket
Date: Fri, 28 Aug 2015 16:27:28 +0200
Message-ID: <888eec65faaa0cd6ae87d52ab223c1cb50458add.1440771116.git.jbenc@redhat.com>
References: <cover.1440771116.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752677AbbH1O1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 10:27:44 -0400
In-Reply-To: <cover.1440771116.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default (subject to the sysctl settings), IPv6 sockets listen also for
IPv4 traffic. Vxlan is not prepared for that and expects IPv6 header in
packets received through an IPv6 socket.

In addition, it's currently not possible to have both IPv4 and IPv6 vxlan
tunnel on the same port (unless bindv6only sysctl is enabled), as it's not
possible to create and bind both IPv4 and IPv6 vxlan interfaces and there's
no way to specify both IPv4 and IPv6 remote/group IP addresses.

Set IPV6_V6ONLY on vxlan sockets to fix both of these issues. This is not
done globally in udp_tunnel, as l2tp and tipc seems to work okay when
receiving IPv4 packets on IPv6 socket and people may rely on this behavior.
The other tunnels (geneve and fou) do not support IPv6.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c       | 1 +
 include/net/udp_tunnel.h  | 3 ++-
 net/ipv6/ip6_udp_tunnel.c | 9 +++++++++
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e3adfe0ef66b..6c5269aea544 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2530,6 +2530,7 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 		udp_conf.family = AF_INET6;
 		udp_conf.use_udp6_rx_checksums =
 		    !(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
+		udp_conf.ipv6_v6only = 1;
 	} else {
 		udp_conf.family = AF_INET;
 	}
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 35041d0fc21e..cb2f89f20f5c 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -31,7 +31,8 @@ struct udp_port_cfg {
 	__be16			peer_udp_port;
 	unsigned int		use_udp_checksums:1,
 				use_udp6_tx_checksums:1,
-				use_udp6_rx_checksums:1;
+				use_udp6_rx_checksums:1,
+				ipv6_v6only:1;
 };
 
 int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index e1a1136bda7c..14dacf1df529 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -23,6 +23,15 @@ int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 	if (err < 0)
 		goto error;
 
+	if (cfg->ipv6_v6only) {
+		int val = 1;
+
+		err = kernel_setsockopt(sock, IPPROTO_IPV6, IPV6_V6ONLY,
+					(char *) &val, sizeof(val));
+		if (err < 0)
+			goto error;
+	}
+
 	udp6_addr.sin6_family = AF_INET6;
 	memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
 	       sizeof(udp6_addr.sin6_addr));
-- 
1.8.3.1
