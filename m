From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 5/6 net-2.6.25][RAW] Consolidate proto->unhash callback
Date: Fri, 16 Nov 2007 17:15:46 +0300
Message-ID: <473DA612.3040906@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55775 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763477AbXKPOP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 09:15:59 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same as the ->hash one, this is easily consolidated.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/raw.h b/include/net/raw.h
index 43f1e3c..81a1773 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -40,5 +40,6 @@ extern void raw_proc_exit(void);
 #endif
 
 void raw_hash_sk(struct sock *sk, struct raw_hashinfo *h);
+void raw_unhash_sk(struct sock *sk, struct raw_hashinfo *h);
 
 #endif	/* _RAW_H */
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3ed4350..ee01811 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -97,6 +97,15 @@ void raw_hash_sk(struct sock *sk, struct raw_hashinfo *h)
 }
 EXPORT_SYMBOL_GPL(raw_hash_sk);
 
+void raw_unhash_sk(struct sock *sk, struct raw_hashinfo *h)
+{
+	write_lock_bh(&h->lock);
+	if (sk_del_node_init(sk))
+		sock_prot_dec_use(sk->sk_prot);
+	write_unlock_bh(&h->lock);
+}
+EXPORT_SYMBOL_GPL(raw_unhash_sk);
+
 static void raw_v4_hash(struct sock *sk)
 {
 	raw_hash_sk(sk, &raw_v4_hashinfo);
@@ -104,10 +113,7 @@ static void raw_v4_hash(struct sock *sk)
 
 static void raw_v4_unhash(struct sock *sk)
 {
-	write_lock_bh(&raw_v4_hashinfo.lock);
-	if (sk_del_node_init(sk))
-		sock_prot_dec_use(sk->sk_prot);
-	write_unlock_bh(&raw_v4_hashinfo.lock);
+	raw_unhash_sk(sk, &raw_v4_hashinfo);
 }
 
 static struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 62b8bc7..07adfcf 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -72,10 +72,7 @@ static void raw_v6_hash(struct sock *sk)
 
 static void raw_v6_unhash(struct sock *sk)
 {
-	write_lock_bh(&raw_v6_hashinfo.lock);
-	if (sk_del_node_init(sk))
-		sock_prot_dec_use(sk->sk_prot);
-	write_unlock_bh(&raw_v6_hashinfo.lock);
+	raw_unhash_sk(sk, &raw_v6_hashinfo);
 }
 
 
