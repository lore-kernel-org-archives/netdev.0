From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/4 net-2.6.26] [TCP]: Merge exit paths in tcp_v4_conn_request.
Date: Mon,  3 Mar 2008 18:48:43 +0300
Message-ID: <1204559323-19953-4-git-send-email-den@openvz.org>
References: <1204559323-19953-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:62519 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755825AbYCCPsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 10:48:37 -0500
In-Reply-To: <1204559323-19953-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/tcp_ipv4.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3b26f95..3873c4d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1355,8 +1355,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 			    (s32)(peer->tcp_ts - req->ts_recent) >
 							TCP_PAWS_WINDOW) {
 				NET_INC_STATS_BH(LINUX_MIB_PAWSPASSIVEREJECTED);
-				dst_release(dst);
-				goto drop_and_free;
+				goto drop_and_release;
 			}
 		}
 		/* Kill the following clause, if you dislike this way. */
@@ -1376,24 +1375,21 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 				       "request from %u.%u.%u.%u/%u\n",
 				       NIPQUAD(saddr),
 				       ntohs(tcp_hdr(skb)->source));
-			dst_release(dst);
-			goto drop_and_free;
+			goto drop_and_release;
 		}
 
 		isn = tcp_v4_init_sequence(skb);
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-	if (__tcp_v4_send_synack(sk, req, dst))
+	if (__tcp_v4_send_synack(sk, req, dst) || want_cookie)
 		goto drop_and_free;
 
-	if (want_cookie) {
-		reqsk_free(req);
-	} else {
-		inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-	}
+	inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	return 0;
 
+drop_and_release:
+	dst_release(dst);
 drop_and_free:
 	reqsk_free(req);
 drop:
-- 
1.5.3.rc5

