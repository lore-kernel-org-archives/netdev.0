From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][IPV6] Consolidate the ip cork destruction in ip6_output.c
Date: Fri, 02 Nov 2007 19:05:38 +0300
Message-ID: <472B4AD2.5050202@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35564 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755553AbXKBQF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 12:05:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ip6_push_pending_frames and ip6_flush_pending_frames do the
same things to flush the sock's cork. Move this into a separate
function and save ~100 bytes from the .text

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 653fc0a..f4e9e73 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1339,6 +1339,19 @@ error:
 	return err;
 }
 
+static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
+{
+	inet->cork.flags &= ~IPCORK_OPT;
+	kfree(np->cork.opt);
+	np->cork.opt = NULL;
+	if (np->cork.rt) {
+		dst_release(&np->cork.rt->u.dst);
+		np->cork.rt = NULL;
+		inet->cork.flags &= ~IPCORK_ALLFRAG;
+	}
+	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
+}
+
 int ip6_push_pending_frames(struct sock *sk)
 {
 	struct sk_buff *skb, *tmp_skb;
@@ -1415,15 +1428,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	}
 
 out:
-	inet->cork.flags &= ~IPCORK_OPT;
-	kfree(np->cork.opt);
-	np->cork.opt = NULL;
-	if (np->cork.rt) {
-		dst_release(&np->cork.rt->u.dst);
-		np->cork.rt = NULL;
-		inet->cork.flags &= ~IPCORK_ALLFRAG;
-	}
-	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
+	ip6_cork_release(inet, np);
 	return err;
 error:
 	goto out;
@@ -1431,8 +1436,6 @@ error:
 
 void ip6_flush_pending_frames(struct sock *sk)
 {
-	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
@@ -1442,14 +1445,5 @@ void ip6_flush_pending_frames(struct sock *sk)
 		kfree_skb(skb);
 	}
 
-	inet->cork.flags &= ~IPCORK_OPT;
-
-	kfree(np->cork.opt);
-	np->cork.opt = NULL;
-	if (np->cork.rt) {
-		dst_release(&np->cork.rt->u.dst);
-		np->cork.rt = NULL;
-		inet->cork.flags &= ~IPCORK_ALLFRAG;
-	}
-	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
+	ip6_cork_release(inet_sk(sk), inet6_sk(sk));
 }
-- 
1.5.3.4

