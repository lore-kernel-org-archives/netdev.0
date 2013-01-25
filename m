From: Nivedita Singhvi <niveditasinghvi@gmail.com>
Subject: [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in tcp_v4_conn_request()
Date: Thu, 24 Jan 2013 23:03:28 -0800
Message-ID: <1359097408-9786-1-git-send-email-niv@us.ibm.com>
Cc: Leandro Lucarella <leandro.lucarella@sociomantic.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:55638 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063Ab3AYHEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 02:04:08 -0500
Received: by mail-ia0-f174.google.com with SMTP id o25so90693iad.5
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 23:04:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We drop a connection request if the accept backlog, syn queue are full when processing reaches tcp_v4_conn_request(). Increment the appropriate counter so this isn't silent, for accurate stats and help in debugging.

Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
---
 net/ipv4/tcp_ipv4.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bbbdcc5..49b4f50 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1502,8 +1502,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * clogging syn queue with openreqs with exponentially increasing
 	 * timeout.
 	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 		goto drop;
+	}
 
 	req = inet_reqsk_alloc(&tcp_request_sock_ops);
 	if (!req)
-- 
1.7.5.4
