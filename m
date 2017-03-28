From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 05/15] tcp: Add TLS socket options for TCP sockets
Date: Tue, 28 Mar 2017 16:26:22 +0300
Message-ID: <1490707592-1430-6-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47663 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932198AbdC1N0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:26:53 -0400
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds TLS_TX and TLS_RX TCP socket options.

Setting these socket options will change the sk->sk_prot
operations of the TCP socket. The user is responsible to
prevent races between calls to the previous operations
and the new operations. After successful return, data
sent on this socket will be encapsulated in TLS.

Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
---
 include/uapi/linux/tcp.h |  2 ++
 net/ipv4/tcp.c           | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index c53de26..f9f0e29 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -116,6 +116,8 @@ enum {
 #define TCP_SAVE_SYN		27	/* Record SYN headers for new connections */
 #define TCP_SAVED_SYN		28	/* Get SYN headers recorded for connection */
 #define TCP_REPAIR_WINDOW	29	/* Get/set window parameters */
+#define TCP_TLS_TX		30
+#define TCP_TLS_RX		31
 
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 302fee9..2d190e3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -273,6 +273,7 @@
 #include <net/icmp.h>
 #include <net/inet_common.h>
 #include <net/tcp.h>
+#include <net/tls.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/sock.h>
@@ -2676,6 +2677,21 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		tp->notsent_lowat = val;
 		sk->sk_write_space(sk);
 		break;
+	case TCP_TLS_TX:
+	case TCP_TLS_RX: {
+		int (*fn)(struct sock *sk, int optname,
+			  char __user *optval, unsigned int optlen);
+
+		fn = symbol_get(tls_sk_attach);
+		if (!fn) {
+			err = -EINVAL;
+			break;
+		}
+
+		err = fn(sk, optname, optval, optlen);
+		symbol_put(tls_sk_attach);
+		break;
+	}
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -3064,6 +3080,22 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		}
 		return 0;
 	}
+	case TCP_TLS_TX:
+	case TCP_TLS_RX: {
+		int err;
+		int (*fn)(struct sock *sk, int optname,
+			  char __user *optval, int __user *optlen);
+
+		fn = symbol_get(tls_sk_query);
+		if (!fn) {
+			err = -EINVAL;
+			break;
+		}
+
+		err = fn(sk, optname, optval, optlen);
+		symbol_put(tls_sk_query);
+		return err;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
2.7.4
