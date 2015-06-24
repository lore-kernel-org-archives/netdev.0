From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2] net: inet_diag: export IPV6_V6ONLY sockopt
Date: Wed, 24 Jun 2015 11:02:51 +0200
Message-ID: <1435136571-18879-1-git-send-email-phil@nwl.cc>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:42142 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340AbbFXJCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 05:02:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For AF_INET6 sockets, the value of struct ipv6_pinfo.ipv6only is
exported to userspace. It indicates whether a socket bound to in6addr_any
listens on IPv4 as well as IPv6. Since the socket is natively IPv6, it is not
listed by e.g. 'ss -l -4'.

This patch is accompanied by an appropriate one for iproute2 to enable
the additional information in 'ss -e'.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Commit message corrected.
- Patch based on current net-next.git.
- Eric's superior solution implemented.
---
 include/uapi/linux/inet_diag.h | 3 ++-
 net/ipv4/inet_diag.c           | 4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index b629fc5..68a1f71 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -112,9 +112,10 @@ enum {
 	INET_DIAG_SHUTDOWN,
 	INET_DIAG_DCTCPINFO,
 	INET_DIAG_PROTOCOL,  /* response attribute only */
+	INET_DIAG_SKV6ONLY,
 };
 
-#define INET_DIAG_MAX INET_DIAG_PROTOCOL
+#define INET_DIAG_MAX INET_DIAG_SKV6ONLY
 
 /* INET_DIAG_MEM */
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 21985d8..653564d 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -151,6 +151,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			if (nla_put_u8(skb, INET_DIAG_TCLASS,
 				       inet6_sk(sk)->tclass) < 0)
 				goto errout;
+
+		if (ipv6_only_sock(sk) &&
+		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, 1))
+			goto errout;
 	}
 #endif
 
-- 
2.1.2
