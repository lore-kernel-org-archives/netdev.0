From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCHv2] tcp: Fix MD5 signature checking on IPv4 mapped sockets
Date: Thu, 16 Jul 2009 10:04:51 -0500
Message-ID: <1247756691.7627.5.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:50506 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757599AbZGPPE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 11:04:58 -0400
Received: by ewy26 with SMTP id 26so193966ewy.37
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 08:04:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This revision to the patch removes a misplaced
blank line.

---
Fix MD5 signature checking so that an IPv4 active open
to an IPv6 socket can succeed.  In particular, use the
correct address family's signature generation function
for the SYN/ACK.

Reported-by:   Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 include/net/tcp.h     |    5 +++++
 net/ipv4/tcp_ipv4.c   |    1 +
 net/ipv4/tcp_output.c |    2 +-
 net/ipv6/tcp_ipv6.c   |    1 +
 4 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 19f4150..88af843 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1425,6 +1425,11 @@ struct tcp_request_sock_ops {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
 						struct request_sock *req);
+	int			(*calc_md5_hash) (char *location,
+						  struct tcp_md5sig_key *md5,
+						  struct sock *sk,
+						  struct request_sock *req,
+						  struct sk_buff *skb);
 #endif
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a1ca26..7c107eb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1160,6 +1160,7 @@ struct request_sock_ops tcp_request_sock_ops __read_mostly = {
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 	.md5_lookup	=	tcp_v4_reqsk_md5_lookup,
+	.calc_md5_hash	=	tcp_v4_md5_hash_skb,
 };
 #endif
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5bdf08d..bd62712 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2261,7 +2261,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
 	if (md5) {
-		tp->af_specific->calc_md5_hash(md5_hash_location,
+		tcp_rsk(req)->af_specific->calc_md5_hash(md5_hash_location,
 					       md5, NULL, req, skb);
 	}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 58810c6..ae3d657 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -896,6 +896,7 @@ struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
 #ifdef CONFIG_TCP_MD5SIG
 static struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 	.md5_lookup	=	tcp_v6_reqsk_md5_lookup,
+	.calc_md5_hash	=	tcp_v6_md5_hash_skb,
 };
 #endif
 
-- 
1.5.4.3




