From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: diag: Tell user if support for destroying TCP sockets is not enabled
Date: Mon, 16 May 2016 16:53:10 -0700
Message-ID: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35775 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbcEPXxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 19:53:19 -0400
Received: by mail-pf0-f171.google.com with SMTP id 77so72213625pfv.2
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 16:53:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c1e64e298b8c added support for destroying TCP sockets but it is
wrapped in a config option. If the option is not enabled the user is given
no feedback and ss for example just exits 0 which is not a friendly UI:

$ ss -4  state established sport = :22
Netid  Recv-Q Send-Q      Local Address:Port     Peer Address:Port
tcp    0      0           10.1.1.2:ssh           192.168.2.50:47438

$ ss -4  -K state established sport = :22 dport = :47438
Netid  Recv-Q Send-Q      Local Address:Port     Peer Address:Port
(nothing else in the output and the connection lives on).

Fix by returning an error to the user if the config option is not
enabled:

$ ss -4 -K state established sport = :22 dport = :47450
Netid  Recv-Q Send-Q      Local Address:Port     Peer Address:Port
SOCK_DESTROY answers: Operation not supported

Fixes: c1e64e298b8c ("net: diag: Support destroying TCP sockets.")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/tcp_diag.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 4d610934fb39..99590423d468 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -60,6 +60,12 @@ static int tcp_diag_destroy(struct sk_buff *in_skb,
 
 	return sock_diag_destroy(sk, ECONNABORTED);
 }
+#else
+static int tcp_diag_destroy(struct sk_buff *in_skb,
+			    const struct inet_diag_req_v2 *req)
+{
+	return -EOPNOTSUPP;
+}
 #endif
 
 static const struct inet_diag_handler tcp_diag_handler = {
@@ -68,9 +74,7 @@ static const struct inet_diag_handler tcp_diag_handler = {
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = IPPROTO_TCP,
 	.idiag_info_size = sizeof(struct tcp_info),
-#ifdef CONFIG_INET_DIAG_DESTROY
 	.destroy	 = tcp_diag_destroy,
-#endif
 };
 
 static int __init tcp_diag_init(void)
-- 
2.1.4
