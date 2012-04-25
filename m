From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH BUG-FIX] udp_diag: implement idiag_get_info for udp/udplite
 to get queue information
Date: Wed, 25 Apr 2012 12:15:41 +0800
Message-ID: <4F977A6D.1050508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, davidshan <davidshan@tencent.com>
To: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:35444 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab2DYEOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 00:14:54 -0400
Received: by dadz8 with SMTP id z8so1804934dad.10
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 21:14:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <davidshan@tencent.com>

When we use netlink to monitor queue information for udp socket,
idiag_rqueue and idiag_wqueue of inet_diag_msg are returned with 0.

Keep consistent with netstat, just return back allocated rmem/wmem size.

Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 net/ipv4/inet_diag.c |    2 +-
 net/ipv4/udp_diag.c  |    9 +++++++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 8d25a1c..8f8db72 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -141,7 +141,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			goto rtattr_failure;
 
 	if (icsk == NULL) {
-		r->idiag_rqueue = r->idiag_wqueue = 0;
+		handler->idiag_get_info(sk, r, NULL);
 		goto out;
 	}
 
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 8a949f1..a7f86a3 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -146,9 +146,17 @@ static int udp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
 	return udp_dump_one(&udp_table, in_skb, nlh, req);
 }
 
+static void udp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
+		void *info)
+{
+	r->idiag_rqueue = sk_rmem_alloc_get(sk);
+	r->idiag_wqueue = sk_wmem_alloc_get(sk);
+}
+
 static const struct inet_diag_handler udp_diag_handler = {
 	.dump		 = udp_diag_dump,
 	.dump_one	 = udp_diag_dump_one,
+	.idiag_get_info  = udp_diag_get_info,
 	.idiag_type	 = IPPROTO_UDP,
 };
 
@@ -167,6 +175,7 @@ static int udplite_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *
 static const struct inet_diag_handler udplite_diag_handler = {
 	.dump		 = udplite_diag_dump,
 	.dump_one	 = udplite_diag_dump_one,
+	.idiag_get_info  = udp_diag_get_info,
 	.idiag_type	 = IPPROTO_UDPLITE,
 };
 
-- 
1.7.1
