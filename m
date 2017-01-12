From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2] tcp: fix tcp_fastopen unaligned access complaints on sparc
Date: Thu, 12 Jan 2017 14:24:58 -0800
Message-ID: <1484259898-30719-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        eric.dumazet@gmail.com, rob.gardner@oracle.com,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix up a data alignment issue on sparc by swapping the order
of the cookie byte array field with the length field in
struct tcp_fastopen_cookie, and making it a proper union
to clean up the typecasting.

This addresses log complaints like these:
    log_unaligned: 113 callbacks suppressed
    Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360
    Kernel unaligned access at TPC[9764ac] tcp_try_fastopen+0x2ec/0x360
    Kernel unaligned access at TPC[9764c8] tcp_try_fastopen+0x308/0x360
    Kernel unaligned access at TPC[9764e4] tcp_try_fastopen+0x324/0x360
    Kernel unaligned access at TPC[976490] tcp_try_fastopen+0x2d0/0x360

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
v2: Use Eric's suggestion for a union in the struct

 include/linux/tcp.h     |    7 ++++++-
 net/ipv4/tcp_fastopen.c |    2 +-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index fc5848d..c93f4b3 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -62,8 +62,13 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 
 /* TCP Fast Open Cookie as stored in memory */
 struct tcp_fastopen_cookie {
+	union {
+		u8	val[TCP_FASTOPEN_COOKIE_MAX];
+#if IS_ENABLED(CONFIG_IPV6)
+		struct in6_addr addr;
+#endif
+	};
 	s8	len;
-	u8	val[TCP_FASTOPEN_COOKIE_MAX];
 	bool	exp;	/* In RFC6994 experimental option format */
 };
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 4e777a3..f519195 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -113,7 +113,7 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
 		struct tcp_fastopen_cookie tmp;
 
 		if (__tcp_fastopen_cookie_gen(&ip6h->saddr, &tmp)) {
-			struct in6_addr *buf = (struct in6_addr *) tmp.val;
+			struct in6_addr *buf = &tmp.addr;
 			int i;
 
 			for (i = 0; i < 4; i++)
-- 
1.7.1

