From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: [PATCH net-2.6] key: Free dumping state on socket close
Date: Wed, 01 Oct 2008 13:55:15 +0300
Message-ID: <48E35713.6030200@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:41359 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbYJAKz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 06:55:26 -0400
Received: by ug-out-1314.google.com with SMTP id k3so763895ugf.37
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 03:55:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a xfrm_{state,policy}_walk leak if pfkey socket is closed while
dumping is on-going.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
Should go to -stable too.

 net/key/af_key.c |   30 +++++++++++++++++++-----------
 1 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index d628df9..b7f5a1c 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -73,22 +73,18 @@ static int pfkey_can_dump(struct sock *sk)
 	return 0;
 }
 
-static int pfkey_do_dump(struct pfkey_sock *pfk)
+static void pfkey_terminate_dump(struct pfkey_sock *pfk)
 {
-	int rc;
-
-	rc = pfk->dump.dump(pfk);
-	if (rc == -ENOBUFS)
-		return 0;
-
-	pfk->dump.done(pfk);
-	pfk->dump.dump = NULL;
-	pfk->dump.done = NULL;
-	return rc;
+	if (pfk->dump.dump) {
+		pfk->dump.done(pfk);
+		pfk->dump.dump = NULL;
+		pfk->dump.done = NULL;
+	}
 }
 
 static void pfkey_sock_destruct(struct sock *sk)
 {
+	pfkey_terminate_dump(pfkey_sk(sk));
 	skb_queue_purge(&sk->sk_receive_queue);
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
@@ -310,6 +306,18 @@ static int pfkey_broadcast(struct sk_buff *skb, gfp_t allocation,
 	return err;
 }
 
+static int pfkey_do_dump(struct pfkey_sock *pfk)
+{
+	int rc;
+
+	rc = pfk->dump.dump(pfk);
+	if (rc == -ENOBUFS)
+		return 0;
+
+	pfkey_terminate_dump(pfk);
+	return rc;
+}
+
 static inline void pfkey_hdr_dup(struct sadb_msg *new, struct sadb_msg *orig)
 {
 	*new = *orig;
-- 
1.5.4.3
