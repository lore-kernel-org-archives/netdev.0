From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] Revert "inet: fix double request socket freeing"
Date: Wed, 14 Oct 2015 10:58:37 -0700
Message-ID: <1444845519-20064-2-git-send-email-edumazet@google.com>
References: <1444845519-20064-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35778 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbJNR6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:58:53 -0400
Received: by padcn9 with SMTP id cn9so29512304pad.2
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:58:53 -0700 (PDT)
In-Reply-To: <1444845519-20064-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit c69736696cf3742b37d850289dc0d7ead177bb14.

At the time of above commit, tcp_req_err() and dccp_req_err()
were dead code, as SYN_RECV request sockets were not yet in ehash table.

Real bug was fixed later in a different commit.

We need to revert to not leak a refcount on request socket.

inet_csk_reqsk_queue_drop_and_put() will be added
in following commit to make clean inet_csk_reqsk_queue_drop()
does not release the reference owned by caller.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/ipv4.c     | 2 +-
 net/ipv4/tcp_ipv4.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 0dcf1963b323..644af510d932 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -208,7 +208,6 @@ void dccp_req_err(struct sock *sk, u64 seq)
 
 	if (!between48(seq, dccp_rsk(req)->dreq_iss, dccp_rsk(req)->dreq_gss)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
-		reqsk_put(req);
 	} else {
 		/*
 		 * Still in RESPOND, just remove it silently.
@@ -218,6 +217,7 @@ void dccp_req_err(struct sock *sk, u64 seq)
 		 */
 		inet_csk_reqsk_queue_drop(req->rsk_listener, req);
 	}
+	reqsk_put(req);
 }
 EXPORT_SYMBOL(dccp_req_err);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1ff0923df715..aad2298de7ad 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -324,7 +324,6 @@ void tcp_req_err(struct sock *sk, u32 seq)
 
 	if (seq != tcp_rsk(req)->snt_isn) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
-		reqsk_put(req);
 	} else {
 		/*
 		 * Still in SYN_RECV, just remove it silently.
@@ -332,9 +331,10 @@ void tcp_req_err(struct sock *sk, u32 seq)
 		 * created socket, and POSIX does not want network
 		 * errors returned from accept().
 		 */
-		NET_INC_STATS_BH(net, LINUX_MIB_LISTENDROPS);
 		inet_csk_reqsk_queue_drop(req->rsk_listener, req);
+		NET_INC_STATS_BH(net, LINUX_MIB_LISTENDROPS);
 	}
+	reqsk_put(req);
 }
 EXPORT_SYMBOL(tcp_req_err);
 
-- 
2.6.0.rc2.230.g3dd15c0
