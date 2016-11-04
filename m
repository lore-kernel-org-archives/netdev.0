From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH net-next 1/5] net: l2tp: fix L2TP_ATTR_UDP_CSUM attribute type
Date: Fri,  4 Nov 2016 22:48:34 +0000
Message-ID: <20161104224838.7925-1-asbjorn@asbjorn.st>
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Miao Wang <shankerwangmiao@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L2TP_ATTR_UDP_CSUM is a flag, and gets read with
nla_get_flag, but it is defined as NLA_U8 in
the nla_policy.

It appears that this is only publicly used in
iproute2, where it's broken, because it's used as
a NLA_FLAG, and fails validation as a NLA_U8.

The only place it's used as a NLA_U8 is in
l2tp_nl_tunnel_send(), but iproute2 again reads that
as a flag, it's therefore always set. Fortunately
it is never used for anything, just read.

CC: Miao Wang <shankerwangmiao@gmail.com>
Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 include/uapi/linux/l2tp.h |  2 +-
 net/l2tp/l2tp_netlink.c   | 12 +++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/l2tp.h b/include/uapi/linux/l2tp.h
index 4bd27d0..73e3a23 100644
--- a/include/uapi/linux/l2tp.h
+++ b/include/uapi/linux/l2tp.h
@@ -104,7 +104,7 @@ enum {
 	L2TP_ATTR_PEER_CONN_ID,		/* u32 */
 	L2TP_ATTR_SESSION_ID,		/* u32 */
 	L2TP_ATTR_PEER_SESSION_ID,	/* u32 */
-	L2TP_ATTR_UDP_CSUM,		/* u8 */
+	L2TP_ATTR_UDP_CSUM,		/* flag */
 	L2TP_ATTR_VLAN_ID,		/* u16 */
 	L2TP_ATTR_COOKIE,		/* 0, 4 or 8 bytes */
 	L2TP_ATTR_PEER_COOKIE,		/* 0, 4 or 8 bytes */
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 59aa2d2..1fe05da 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -379,9 +379,15 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 
 	switch (tunnel->encap) {
 	case L2TP_ENCAPTYPE_UDP:
+		switch (sk->sk_family) {
+		case AF_INET:
+			if ((!sk->sk_no_check_tx) &&
+			    nla_put_flag(skb, L2TP_ATTR_UDP_CSUM))
+				goto nla_put_failure;
+			break;
+		}
 		if (nla_put_u16(skb, L2TP_ATTR_UDP_SPORT, ntohs(inet->inet_sport)) ||
-		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)) ||
-		    nla_put_u8(skb, L2TP_ATTR_UDP_CSUM, !sk->sk_no_check_tx))
+		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)))
 			goto nla_put_failure;
 		/* NOBREAK */
 	case L2TP_ENCAPTYPE_IP:
@@ -873,7 +879,7 @@ static const struct nla_policy l2tp_nl_policy[L2TP_ATTR_MAX + 1] = {
 	[L2TP_ATTR_PEER_CONN_ID]	= { .type = NLA_U32, },
 	[L2TP_ATTR_SESSION_ID]		= { .type = NLA_U32, },
 	[L2TP_ATTR_PEER_SESSION_ID]	= { .type = NLA_U32, },
-	[L2TP_ATTR_UDP_CSUM]		= { .type = NLA_U8, },
+	[L2TP_ATTR_UDP_CSUM]		= { .type = NLA_FLAG, },
 	[L2TP_ATTR_VLAN_ID]		= { .type = NLA_U16, },
 	[L2TP_ATTR_DEBUG]		= { .type = NLA_U32, },
 	[L2TP_ATTR_RECV_SEQ]		= { .type = NLA_U8, },
-- 
2.10.1
