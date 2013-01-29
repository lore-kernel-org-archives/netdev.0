From: Nivedita Singhvi <niveditasinghvi@gmail.com>
Subject: [PATCH] tcp: Increment LISTENOVERFLOW and LISTENDROPS in tcp_v4_conn_request()
Date: Mon, 28 Jan 2013 19:52:37 -0800
Message-ID: <1359431557-4587-1-git-send-email-niveditasinghvi@gmail.com>
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f179.google.com ([209.85.161.179]:45829 "EHLO
	mail-gg0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058Ab3A2EAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 23:00:07 -0500
Received: by mail-gg0-f179.google.com with SMTP id h4so209ggn.38
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2013 20:00:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nivedita Singhvi <niv@us.ibm.com>

We drop a connection request if the accept backlog is full and there are
sufficient packets in the syn queue to warrant starting drops. Increment the
appropriate counters so this isn't silent, for accurate stats and help in
debugging.

This patch assumes LINUX_MIB_LISTENDROPS is a superset of/includes the
counter LINUX_MIB_LISTENOVERFLOWS.

Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
---
 net/ipv4/tcp_ipv4.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bbbdcc5..df8ed59 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1502,8 +1502,11 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * clogging syn queue with openreqs with exponentially increasing
 	 * timeout.
 	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 		goto drop;
+	}
 
 	req = inet_reqsk_alloc(&tcp_request_sock_ops);
 	if (!req)
-- 
1.7.5.4
