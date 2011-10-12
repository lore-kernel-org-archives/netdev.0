From: Muraliraja Muniraju <muralira@google.com>
Subject: [PATCH v4] net-netlink: Add a new attribute to expose TOS values via netlink
Date: Wed, 12 Oct 2011 12:00:35 -0700
Message-ID: <1318446035-10267-1-git-send-email-muralira@google.com>
References: <20111012085235.3b78729b@nehalam.linuxnetplumber.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Murali Raja <muralira@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kabe
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111012085235.3b78729b@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Raja <muralira@google.com>

This patch exposes the tos value for the TCP sockets when the TOS flag
is requested in the ext_flags for the inet_diag request. This would mainly be
used to expose TOS values for both for TCP and UDP sockets. Currently it is
supported for TCP. When netlink support for UDP would be added the support
to expose the TOS values would alse be done. For IPV4 tos value is exposed
and for IPV6 tclass value is exposed.

Signed-off-by: Murali Raja <muralira@google.com>
---
Changelog since v3:
- Removed the tos structure from the inet_diag.h

Changelog since v2:
- Added support for IPv6 and used better API.

Changelog since v3:
- Removed reserved fields.

 include/linux/inet_diag.h |    3 ++-
 net/ipv4/inet_diag.c      |    5 +++++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index bc8c490..80b480c 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -97,9 +97,10 @@ enum {
 	INET_DIAG_INFO,
 	INET_DIAG_VEGASINFO,
 	INET_DIAG_CONG,
+	INET_DIAG_TOS,
 };
 
-#define INET_DIAG_MAX INET_DIAG_CONG
+#define INET_DIAG_MAX INET_DIAG_TOS
 
 
 /* INET_DIAG_MEM */
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 389a2e6..f5e2bda 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -108,6 +108,9 @@ static int inet_csk_diag_fill(struct sock *sk,
 		       icsk->icsk_ca_ops->name);
 	}
 
+	if ((ext & (1 << (INET_DIAG_TOS - 1))) && (sk->sk_family != AF_INET6))
+		RTA_PUT_U8(skb, INET_DIAG_TOS, inet->tos);
+
 	r->idiag_family = sk->sk_family;
 	r->idiag_state = sk->sk_state;
 	r->idiag_timer = 0;
@@ -130,6 +133,8 @@ static int inet_csk_diag_fill(struct sock *sk,
 			       &np->rcv_saddr);
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
 			       &np->daddr);
+		if (ext & (1 << (INET_DIAG_TOS - 1)))
+			RTA_PUT_U8(skb, INET_DIAG_TOS, np->tclass);
 	}
 #endif
 
-- 
1.7.3.1
