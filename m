From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/13] inet_diag: Remove indirect sizeof from inet diag handlers
Date: Fri, 09 Dec 2011 20:21:16 +0400
Message-ID: <4EE2357C.2080502@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26363 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785Ab1LIQVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:21:21 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's an info_size value stored on inet_diag_handler, but for existing
code this value is effectively constant, so just use sizeof(struct tcp_info)
where required.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    1 -
 net/dccp/diag.c           |    1 -
 net/ipv4/inet_diag.c      |    5 ++---
 net/ipv4/tcp_diag.c       |    1 -
 4 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index defe8ff..851feff 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -141,7 +141,6 @@ struct inet_diag_handler {
 	void			(*idiag_get_info)(struct sock *sk,
 						  struct inet_diag_msg *r,
 						  void *info);
-	__u16                   idiag_info_size;
 	__u16                   idiag_type;
 };
 
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 424dcd8..9343f52 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -52,7 +52,6 @@ static const struct inet_diag_handler dccp_diag_handler = {
 	.idiag_hashinfo	 = &dccp_hashinfo,
 	.idiag_get_info	 = dccp_diag_get_info,
 	.idiag_type	 = IPPROTO_DCCP,
-	.idiag_info_size = sizeof(struct tcp_info),
 };
 
 static int __init dccp_diag_init(void)
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index b56b7ba..a247f85 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -98,8 +98,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 		minfo = INET_DIAG_PUT(skb, INET_DIAG_MEMINFO, sizeof(*minfo));
 
 	if (ext & (1 << (INET_DIAG_INFO - 1)))
-		info = INET_DIAG_PUT(skb, INET_DIAG_INFO,
-				     handler->idiag_info_size);
+		info = INET_DIAG_PUT(skb, INET_DIAG_INFO, sizeof(struct tcp_info));
 
 	if ((ext & (1 << (INET_DIAG_CONG - 1))) && icsk->icsk_ca_ops) {
 		const size_t len = strlen(icsk->icsk_ca_ops->name);
@@ -299,7 +298,7 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	err = -ENOMEM;
 	rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
 				     sizeof(struct inet_diag_meminfo) +
-				     handler->idiag_info_size + 64)),
+				     sizeof(struct tcp_info) + 64)),
 			GFP_KERNEL);
 	if (!rep)
 		goto out;
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 9814977..42e6bec 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -38,7 +38,6 @@ static const struct inet_diag_handler tcp_diag_handler = {
 	.idiag_hashinfo	 = &tcp_hashinfo,
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = IPPROTO_TCP,
-	.idiag_info_size = sizeof(struct tcp_info),
 };
 
 static int __init tcp_diag_init(void)
-- 
1.5.5.6
