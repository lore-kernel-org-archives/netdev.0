From: Craig Gallek <kraig@google.com>
Subject: [PATCH net-next 2/3] sock_diag: specify info_size per inet protocol
Date: Mon, 15 Jun 2015 11:26:19 -0400
Message-ID: <1434381980-20588-3-git-send-email-kraig@google.com>
References: <1434381980-20588-1-git-send-email-kraig@google.com>
Cc: edumazet@google.com, mleitner@redhat.com,
	stephen@networkplumber.org, davem@davemloft.net,
	ebiederm@xmission.net, tgraf@suug.ch, xemul@openvz.org,
	Craig Gallek <kraig@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:35353 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505AbbFOP1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 11:27:21 -0400
Received: by ykar6 with SMTP id r6so32673083yka.2
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 08:27:20 -0700 (PDT)
In-Reply-To: <1434381980-20588-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, there was no clear distinction between the inet protocols
that used struct tcp_info to report information and those that didn't.
This change adds a specific size attribute to the inet_diag_handler
struct which defines these interfaces.  This will make dispatching
sock_diag get_info requests identical for all inet protocols in a
following patch.

Tested: ss -au
Tested: ss -at
Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/linux/inet_diag.h | 1 +
 net/dccp/diag.c           | 1 +
 net/ipv4/inet_diag.c      | 4 ++--
 net/ipv4/tcp_diag.c       | 1 +
 net/ipv4/udp_diag.c       | 2 ++
 5 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index ac48b10..0e707f0 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -24,6 +24,7 @@ struct inet_diag_handler {
 					  struct inet_diag_msg *r,
 					  void *info);
 	__u16		idiag_type;
+	__u16		idiag_info_size;
 };
 
 struct inet_connection_sock;
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 5a45f8d..2d84303 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -66,6 +66,7 @@ static const struct inet_diag_handler dccp_diag_handler = {
 	.dump_one	 = dccp_diag_dump_one,
 	.idiag_get_info	 = dccp_diag_get_info,
 	.idiag_type	 = IPPROTO_DCCP,
+	.idiag_info_size = sizeof(struct tcp_info),
 };
 
 static int __init dccp_diag_init(void)
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 4d32262..b1f01174 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -200,9 +200,9 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	}
 #undef EXPIRES_IN_MS
 
-	if (ext & (1 << (INET_DIAG_INFO - 1))) {
+	if ((ext & (1 << (INET_DIAG_INFO - 1))) && handler->idiag_info_size) {
 		attr = nla_reserve(skb, INET_DIAG_INFO,
-				   sizeof(struct tcp_info));
+				   handler->idiag_info_size);
 		if (!attr)
 			goto errout;
 
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 79b34a0..423e388 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -50,6 +50,7 @@ static const struct inet_diag_handler tcp_diag_handler = {
 	.dump_one	 = tcp_diag_dump_one,
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = IPPROTO_TCP,
+	.idiag_info_size = sizeof(struct tcp_info),
 };
 
 static int __init tcp_diag_init(void)
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index b763c39..6116604 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -170,6 +170,7 @@ static const struct inet_diag_handler udp_diag_handler = {
 	.dump_one	 = udp_diag_dump_one,
 	.idiag_get_info  = udp_diag_get_info,
 	.idiag_type	 = IPPROTO_UDP,
+	.idiag_info_size = 0,
 };
 
 static void udplite_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
@@ -190,6 +191,7 @@ static const struct inet_diag_handler udplite_diag_handler = {
 	.dump_one	 = udplite_diag_dump_one,
 	.idiag_get_info  = udp_diag_get_info,
 	.idiag_type	 = IPPROTO_UDPLITE,
+	.idiag_info_size = 0,
 };
 
 static int __init udp_diag_init(void)
-- 
2.2.0.rc0.207.ga3a616c
