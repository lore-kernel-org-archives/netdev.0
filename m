From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/13] inet_diag: Split inet_diag_get_exact into parts
Date: Fri, 09 Dec 2011 20:22:26 +0400
Message-ID: <4EE235C2.206@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43045 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801Ab1LIQWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:22:32 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to previous patch: the 1st part locks the inet handler
and will get generalized and the 2nd one dumps icsk-s and will
be used by TCP and DCCP handlers.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/inet_diag.c |   28 ++++++++++++++++------------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 64abe47..f50df2e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -709,19 +709,11 @@ out:
 	return err;
 }
 
-static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req *r, struct nlattr *bc)
+static void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
+		struct netlink_callback *cb, struct inet_diag_req *r, struct nlattr *bc)
 {
 	int i, num;
 	int s_i, s_num;
-	const struct inet_diag_handler *handler;
-	struct inet_hashinfo *hashinfo;
-
-	handler = inet_diag_lock_handler(r->sdiag_protocol);
-	if (IS_ERR(handler))
-		goto unlock;
-
-	hashinfo = handler->idiag_hashinfo;
 
 	s_i = cb->args[1];
 	s_num = num = cb->args[2];
@@ -790,7 +782,7 @@ skip_listen_ht:
 	}
 
 	if (!(r->idiag_states & ~(TCPF_LISTEN | TCPF_SYN_RECV)))
-		goto unlock;
+		goto out;
 
 	for (i = s_i; i <= hashinfo->ehash_mask; i++) {
 		struct inet_ehash_bucket *head = &hashinfo->ehash[i];
@@ -863,8 +855,20 @@ next_dying:
 done:
 	cb->args[1] = i;
 	cb->args[2] = num;
-unlock:
+out:
+	;
+}
+
+static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
+		struct inet_diag_req *r, struct nlattr *bc)
+{
+	const struct inet_diag_handler *handler;
+
+	handler = inet_diag_lock_handler(r->sdiag_protocol);
+	if (!IS_ERR(handler))
+		inet_diag_dump_icsk(handler->idiag_hashinfo, skb, cb, r, bc);
 	inet_diag_unlock_handler(handler);
+
 	return skb->len;
 }
 
-- 
1.5.5.6
