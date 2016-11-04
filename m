From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH net-next 3/5] net: l2tp: netlink: l2tp_nl_tunnel_send: set UDP6 checksum flags
Date: Fri,  4 Nov 2016 22:48:36 +0000
Message-ID: <20161104224838.7925-3-asbjorn@asbjorn.st>
References: <20161104224838.7925-1-asbjorn@asbjorn.st>
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104224838.7925-1-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch causes the proper attribute flags to be set,
in the case that IPv6 UDP checksums are disabled, so that
userspace ie. `ip l2tp show tunnel` knows about it.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 net/l2tp/l2tp_netlink.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index e45c5409..1b3fcde 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -385,6 +385,16 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 			    nla_put_flag(skb, L2TP_ATTR_UDP_CSUM))
 				goto nla_put_failure;
 			break;
+#if IS_ENABLED(CONFIG_IPV6)
+		case AF_INET6:
+			if (udp_get_no_check6_tx(sk) &&
+			    nla_put_flag(skb, L2TP_ATTR_UDP_ZERO_CSUM6_TX))
+				goto nla_put_failure;
+			if (udp_get_no_check6_rx(sk) &&
+			    nla_put_flag(skb, L2TP_ATTR_UDP_ZERO_CSUM6_RX))
+				goto nla_put_failure;
+			break;
+#endif
 		}
 		if (nla_put_u16(skb, L2TP_ATTR_UDP_SPORT, ntohs(inet->inet_sport)) ||
 		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)))
-- 
2.10.1
