From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 2/10][TCP_IPV4]: Use kmemdup where appropriate
Date: Fri, 17 Nov 2006 13:16:36 -0200
Message-ID: <20061117151635.GC17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:12686 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1753728AbWKQPQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 10:16:47 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also use a variable to avoid the longish tp->md5sig_info-> use
in tcp_v4_md5_do_add.

Code diff stats:

[acme@newtoy net-2.6.20]$ codiff /tmp/tcp_ipv4.o.before /tmp/tcp_ipv4.o.after
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/tcp_ipv4.c:
  tcp_v4_md5_do_add     |  -62
  tcp_v4_syn_recv_sock  |  -32
  tcp_v4_parse_md5_keys |  -86
 3 functions changed, 180 bytes removed
[acme@newtoy net-2.6.20]$

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ipv4/tcp_ipv4.c |   49 +++++++++++++++++++++++++------------------------
 1 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 010dff4..b7d5522 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -855,15 +855,18 @@ int tcp_v4_md5_do_add(struct sock *sk, _
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp4_md5sig_key *keys;
 
-	key = (struct tcp4_md5sig_key *) tcp_v4_md5_do_lookup(sk, addr);
+	key = (struct tcp4_md5sig_key *)tcp_v4_md5_do_lookup(sk, addr);
 	if (key) {
 		/* Pre-existing entry - just update that one. */
-		kfree (key->key);
+		kfree(key->key);
 		key->key = newkey;
 		key->keylen = newkeylen;
 	} else {
+		struct tcp_md5sig_info *md5sig;
+
 		if (!tp->md5sig_info) {
-			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info), GFP_ATOMIC);
+			tp->md5sig_info = kzalloc(sizeof(*tp->md5sig_info),
+						  GFP_ATOMIC);
 			if (!tp->md5sig_info) {
 				kfree(newkey);
 				return -ENOMEM;
@@ -873,30 +876,31 @@ int tcp_v4_md5_do_add(struct sock *sk, _
 			kfree(newkey);
 			return -ENOMEM;
 		}
-		if (tp->md5sig_info->alloced4 == tp->md5sig_info->entries4) {
-			keys = kmalloc((sizeof(struct tcp4_md5sig_key) *
-				       (tp->md5sig_info->entries4 + 1)), GFP_ATOMIC);
+		md5sig = tp->md5sig_info;
+
+		if (md5sig->alloced4 == md5sig->entries4) {
+			keys = kmalloc((sizeof(*keys) *
+				        (md5sig->entries4 + 1)), GFP_ATOMIC);
 			if (!keys) {
 				kfree(newkey);
 				tcp_free_md5sig_pool();
 				return -ENOMEM;
 			}
 
-			if (tp->md5sig_info->entries4)
-				memcpy(keys, tp->md5sig_info->keys4,
-				       (sizeof (struct tcp4_md5sig_key) *
-					tp->md5sig_info->entries4));
+			if (md5sig->entries4)
+				memcpy(keys, md5sig->keys4,
+				       sizeof(*keys) * md5sig->entries4);
 
 			/* Free old key list, and reference new one */
-			if (tp->md5sig_info->keys4)
-				kfree(tp->md5sig_info->keys4);
-			tp->md5sig_info->keys4 = keys;
-			tp->md5sig_info->alloced4++;
+			if (md5sig->keys4)
+				kfree(md5sig->keys4);
+			md5sig->keys4 = keys;
+			md5sig->alloced4++;
 		}
-		tp->md5sig_info->entries4++;
-		tp->md5sig_info->keys4[tp->md5sig_info->entries4 - 1].addr = addr;
-		tp->md5sig_info->keys4[tp->md5sig_info->entries4 - 1].key = newkey;
-		tp->md5sig_info->keys4[tp->md5sig_info->entries4 - 1].keylen = newkeylen;
+		md5sig->entries4++;
+		md5sig->keys4[md5sig->entries4 - 1].addr   = addr;
+		md5sig->keys4[md5sig->entries4 - 1].key    = newkey;
+		md5sig->keys4[md5sig->entries4 - 1].keylen = newkeylen;
 	}
 	return 0;
 }
@@ -998,10 +1002,9 @@ static int tcp_v4_parse_md5_keys(struct 
 
 	}
 
-	newkey = kmalloc(cmd.tcpm_keylen, GFP_KERNEL);
+	newkey = kmemdup(cmd.tcpm_key, cmd.tcpm_keylen, GFP_KERNEL);
 	if (!newkey)
 		return -ENOMEM;
-	memcpy(newkey, cmd.tcpm_key, cmd.tcpm_keylen);
 	return tcp_v4_md5_do_add(sk, sin->sin_addr.s_addr,
 				 newkey, cmd.tcpm_keylen);
 }
@@ -1494,12 +1497,10 @@ #ifdef CONFIG_TCP_MD5SIG
 		 * memory, then we end up not copying the key
 		 * across. Shucks.
 		 */
-		char *newkey = kmalloc(key->keylen, GFP_ATOMIC);
-		if (newkey) {
-			memcpy(newkey, key->key, key->keylen);
+		char *newkey = kmemdup(key->key, key->keylen, GFP_ATOMIC);
+		if (newkey != NULL)
 			tcp_v4_md5_do_add(newsk, inet_sk(sk)->daddr,
 					  newkey, key->keylen);
-		}
 	}
 #endif
 
-- 
1.4.2.1.g3d5c

