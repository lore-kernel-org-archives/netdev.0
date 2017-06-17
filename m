From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: ensure ep is not destroyed before doing the dump
Date: Sat, 17 Jun 2017 16:10:27 +0800
Message-ID: <6861fd3fc029ccba569fabccf7e05f6a52f28415.1497687027.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34392 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752301AbdFQIKh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 04:10:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now before dumping a sock in sctp_diag, it only holds the sock while
the ep may be already destroyed. It can cause a use-after-free panic
when accessing ep->asocs.

This patch is to set sctp_sk(sk)->ep NULL in sctp_endpoint_destroy,
and check if this ep is already destroyed before dumping this ep.

Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/endpointola.c | 1 +
 net/sctp/sctp_diag.c   | 5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 8c58923..3dcd0ec 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -275,6 +275,7 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 		if (sctp_sk(sk)->bind_hash)
 			sctp_put_port(sk);
 
+		sctp_sk(sk)->ep = NULL;
 		sock_put(sk);
 	}
 
diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index 048954e..9a64721 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -278,7 +278,6 @@ static int sctp_tsp_dump_one(struct sctp_transport *tsp, void *p)
 
 static int sctp_sock_dump(struct sock *sk, void *p)
 {
-	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_comm_param *commp = p;
 	struct sk_buff *skb = commp->skb;
 	struct netlink_callback *cb = commp->cb;
@@ -287,7 +286,9 @@ static int sctp_sock_dump(struct sock *sk, void *p)
 	int err = 0;
 
 	lock_sock(sk);
-	list_for_each_entry(assoc, &ep->asocs, asocs) {
+	if (!sctp_sk(sk)->ep)
+		goto release;
+	list_for_each_entry(assoc, &sctp_sk(sk)->ep->asocs, asocs) {
 		if (cb->args[4] < cb->args[1])
 			goto next;
 
-- 
2.1.0
