From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 8/12][PF_KEY] stop using sk_protinfo
Date: Fri, 21 Jan 2005 01:19:28 -0200
Message-ID: <41F074C0.4040201@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060007080002060507000701"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060007080002060507000701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Subject says it all.

Regards,

- Arnaldo


--------------060007080002060507000701
Content-Type: text/plain;
 name="8-pf_key.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="8-pf_key.patch"

===================================================================


ChangeSet@1.2006, 2005-01-20 21:09:34-02:00, acme@toy.ghostprotocols.net
  [PF_KEY] stop using sk_protinfo
  
  Required to introduce struct connection_sock.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 af_key.c |   33 ++++++++++++++-------------------
 1 files changed, 14 insertions(+), 19 deletions(-)


diff -Nru a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c	2005-01-21 00:22:42 -02:00
+++ b/net/key/af_key.c	2005-01-21 00:22:42 -02:00
@@ -42,11 +42,17 @@
 
 static atomic_t pfkey_socks_nr = ATOMIC_INIT(0);
 
-struct pfkey_opt {
-	int	registered;
-	int	promisc;
+struct pfkey_sock {
+	/* struct sock must be the first member of struct pfkey_sock */
+	struct sock	sk;
+	int		registered;
+	int		promisc;
 };
-#define pfkey_sk(__sk) ((struct pfkey_opt *)(__sk)->sk_protinfo)
+
+static inline struct pfkey_sock *pfkey_sk(struct sock *sk)
+{
+	return (struct pfkey_sock *)sk;
+}
 
 static void pfkey_sock_destruct(struct sock *sk)
 {
@@ -60,8 +66,6 @@
 	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
 	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
 
-	kfree(pfkey_sk(sk));
-
 	atomic_dec(&pfkey_socks_nr);
 }
 
@@ -128,7 +132,6 @@
 static int pfkey_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;
-	struct pfkey_opt *pfk;
 	int err;
 
 	if (!capable(CAP_NET_ADMIN))
@@ -139,7 +142,7 @@
 		return -EPROTONOSUPPORT;
 
 	err = -ENOMEM;
-	sk = sk_alloc(PF_KEY, GFP_KERNEL, 1, NULL);
+	sk = sk_alloc(PF_KEY, GFP_KERNEL, sizeof(struct pfkey_sock), NULL);
 	if (sk == NULL)
 		goto out;
 	
@@ -147,14 +150,6 @@
 	sock_init_data(sock, sk);
 	sk_set_owner(sk, THIS_MODULE);
 
-	err = -ENOMEM;
-	pfk = sk->sk_protinfo = kmalloc(sizeof(*pfk), GFP_KERNEL);
-	if (!pfk) {
-		sk_free(sk);
-		goto out;
-	}
-	memset(pfk, 0, sizeof(*pfk));
-
 	sk->sk_family = PF_KEY;
 	sk->sk_destruct = pfkey_sock_destruct;
 
@@ -233,7 +228,7 @@
 
 	pfkey_lock_table();
 	sk_for_each(sk, node, &pfkey_table) {
-		struct pfkey_opt *pfk = pfkey_sk(sk);
+		struct pfkey_sock *pfk = pfkey_sk(sk);
 		int err2;
 
 		/* Yes, it means that if you are meant to receive this
@@ -1418,7 +1413,7 @@
 
 static int pfkey_register(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
-	struct pfkey_opt *pfk = pfkey_sk(sk);
+	struct pfkey_sock *pfk = pfkey_sk(sk);
 	struct sk_buff *supp_skb;
 
 	if (hdr->sadb_msg_satype > SADB_SATYPE_MAX)
@@ -1514,7 +1509,7 @@
 
 static int pfkey_promisc(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hdr, void **ext_hdrs)
 {
-	struct pfkey_opt *pfk = pfkey_sk(sk);
+	struct pfkey_sock *pfk = pfkey_sk(sk);
 	int satype = hdr->sadb_msg_satype;
 
 	if (hdr->sadb_msg_len == (sizeof(*hdr) / sizeof(uint64_t))) {



--------------060007080002060507000701--
