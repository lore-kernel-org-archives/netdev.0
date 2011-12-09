From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/13] inet_diag: Split inet_diag_get_exact into parts
Date: Fri, 09 Dec 2011 20:22:10 +0400
Message-ID: <4EE235B2.8070903@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44811 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab1LIQWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:22:15 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 1st part locks the inet handler and the 2nd one dump the
inet connection sock.

In the next patches the 1st part will be generalized to call
the socket dumping routine indirectly (i.e. TCP/UDP/DCCP) and
the 2nd part will be used by TCP and DCCP handlers.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/inet_diag.c |   38 ++++++++++++++++++++++----------------
 1 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index ba3ae1f..64abe47 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -258,25 +258,14 @@ int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req)
 }
 EXPORT_SYMBOL_GPL(inet_diag_check_cookie);
 
-static int inet_diag_get_exact(struct sk_buff *in_skb,
-			       const struct nlmsghdr *nlh,
-			       struct inet_diag_req *req)
+static int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
+		const struct nlmsghdr *nlh, struct inet_diag_req *req)
 {
 	int err;
 	struct sock *sk;
 	struct sk_buff *rep;
-	struct inet_hashinfo *hashinfo;
-	const struct inet_diag_handler *handler;
 
-	handler = inet_diag_lock_handler(req->sdiag_protocol);
-	if (IS_ERR(handler)) {
-		err = PTR_ERR(handler);
-		goto unlock;
-	}
-
-	hashinfo = handler->idiag_hashinfo;
 	err = -EINVAL;
-
 	if (req->sdiag_family == AF_INET) {
 		sk = inet_lookup(&init_net, hashinfo, req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
@@ -293,12 +282,12 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	}
 #endif
 	else {
-		goto unlock;
+		goto out_nosk;
 	}
 
 	err = -ENOENT;
 	if (sk == NULL)
-		goto unlock;
+		goto out_nosk;
 
 	err = inet_diag_check_cookie(sk, req);
 	if (err)
@@ -332,8 +321,25 @@ out:
 		else
 			sock_put(sk);
 	}
-unlock:
+out_nosk:
+	return err;
+}
+
+static int inet_diag_get_exact(struct sk_buff *in_skb,
+			       const struct nlmsghdr *nlh,
+			       struct inet_diag_req *req)
+{
+	const struct inet_diag_handler *handler;
+	int err;
+
+	handler = inet_diag_lock_handler(req->sdiag_protocol);
+	if (IS_ERR(handler))
+		err = PTR_ERR(handler);
+	else
+		err = inet_diag_dump_one_icsk(handler->idiag_hashinfo,
+				in_skb, nlh, req);
 	inet_diag_unlock_handler(handler);
+
 	return err;
 }
 
-- 
1.5.5.6
