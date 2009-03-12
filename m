From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v1 3/3] netlabel: Label incoming TCP connections correctly
	in Smack
Date: Thu, 12 Mar 2009 12:23:10 -0400
Message-ID: <20090312162310.29454.93970.stgit@flek.lan>
References: <20090312160934.29454.31004.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090312160934.29454.31004.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch labels incoming TCP connections correctly in a manner very similar
to SELinux using the security_inet_conn_request() to label the request_sock.
---

 include/net/netlabel.h       |    5 ++++
 net/netlabel/netlabel_kapi.c |   13 +++++++++++
 security/smack/smack_lsm.c   |   51 ++++++++++++++++++++++++++++++++----------
 3 files changed, 57 insertions(+), 12 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index bdb10e5..60ebbc1 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -417,6 +417,7 @@ int netlbl_conn_setattr(struct sock *sk,
 			const struct netlbl_lsm_secattr *secattr);
 int netlbl_req_setattr(struct request_sock *req,
 		       const struct netlbl_lsm_secattr *secattr);
+void netlbl_req_delattr(struct request_sock *req);
 int netlbl_skbuff_setattr(struct sk_buff *skb,
 			  u16 family,
 			  const struct netlbl_lsm_secattr *secattr);
@@ -547,6 +548,10 @@ static inline int netlbl_req_setattr(struct request_sock *req,
 {
 	return -ENOSYS;
 }
+static inline void netlbl_req_delattr(struct request_sock *req)
+{
+	return;
+}
 static inline int netlbl_skbuff_setattr(struct sk_buff *skb,
 				      u16 family,
 				      const struct netlbl_lsm_secattr *secattr)
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index d2e6b5a..ff43eda 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -844,6 +844,19 @@ req_setattr_return:
 }
 
 /**
+* netlbl_req_delattr - Delete all the NetLabel labels on a socket
+* @req: the socket
+*
+* Description:
+* Remove all the NetLabel labeling from @req.
+*
+*/
+void netlbl_req_delattr(struct request_sock *req)
+{
+	cipso_v4_req_delattr(req);
+}
+
+/**
  * netlbl_skbuff_setattr - Label a packet using the correct protocol
  * @skb: the packet
  * @family: protocol family
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 25e953f..b648ac2 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -20,6 +20,7 @@
 #include <linux/ext2_fs.h>
 #include <linux/kd.h>
 #include <asm/ioctls.h>
+#include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/mutex.h>
@@ -2502,7 +2503,7 @@ static int smack_socket_getpeersec_dgram(struct socket *sock,
 static void smack_sock_graft(struct sock *sk, struct socket *parent)
 {
 	struct socket_smack *ssp;
-	int rc;
+	struct netlbl_lsm_secattr secattr;
 
 	if (sk == NULL)
 		return;
@@ -2514,10 +2515,12 @@ static void smack_sock_graft(struct sock *sk, struct socket *parent)
 	ssp->smk_in = ssp->smk_out = current_security();
 	ssp->smk_packet[0] = '\0';
 
-	rc = smack_netlabel(sk, SMACK_CIPSO_SOCKET);
-	if (rc != 0)
-		printk(KERN_WARNING "Smack: \"%s\" netlbl error %d.\n",
-		       __func__, -rc);
+	netlbl_secattr_init(&secattr);
+	if (netlbl_sock_getattr(sk, &secattr) == 0)
+		ssp->smk_labeled = SMACK_CIPSO_SOCKET;
+	else
+		ssp->smk_labeled = SMACK_UNLABELED_SOCKET;
+	netlbl_secattr_destroy(&secattr);
 }
 
 /**
@@ -2532,21 +2535,26 @@ static void smack_sock_graft(struct sock *sk, struct socket *parent)
 static int smack_inet_conn_request(struct sock *sk, struct sk_buff *skb,
 				   struct request_sock *req)
 {
-	struct netlbl_lsm_secattr skb_secattr;
+	u16 family = sk->sk_family;
+	struct netlbl_lsm_secattr secattr;
 	struct socket_smack *ssp = sk->sk_security;
+	struct sockaddr_in addr;
+	struct iphdr *hdr;
 	char smack[SMK_LABELLEN];
 	int rc;
 
-	if (skb == NULL)
-		return -EACCES;
+	/* handle mapped IPv4 packets arriving via IPv6 sockets */
+	if (family == PF_INET6 && skb->protocol == htons(ETH_P_IP))
+		family = PF_INET;
 
-	netlbl_secattr_init(&skb_secattr);
-	rc = netlbl_skbuff_getattr(skb, sk->sk_family, &skb_secattr);
+	netlbl_secattr_init(&secattr);
+	rc = netlbl_skbuff_getattr(skb, family, &secattr);
 	if (rc == 0)
-		smack_from_secattr(&skb_secattr, smack);
+		smack_from_secattr(&secattr, smack);
 	else
 		strncpy(smack, smack_known_huh.smk_known, SMK_MAXLEN);
-	netlbl_secattr_destroy(&skb_secattr);
+	netlbl_secattr_destroy(&secattr);
+
 	/*
 	 * Receiving a packet requires that the other end
 	 * be able to write here. Read access is not required.
@@ -2558,6 +2566,25 @@ static int smack_inet_conn_request(struct sock *sk, struct sk_buff *skb,
 	if (rc == 0)
 		strncpy(ssp->smk_packet, smack, SMK_MAXLEN);
 
+	/*
+	 * We need to decide if we want to label the incoming connection here
+	 * but we are unable to set the smk_labeled state here since we don't
+	 * have a fully formed sock yet, just a request_sock ... so, label the
+	 * request_sock and the stack will propogate the wire-label to the
+	 * sock when it is created.  Later, when the sock is added to its
+	 * corresponding socket in sock_graft() we can set smk_labeled based
+	 * on the presence of the wire-label on the newly created sock.
+	 */
+	hdr = ip_hdr(skb);
+	addr.sin_addr.s_addr = hdr->saddr;
+	if (smack_host_label(&addr) == NULL) {
+		netlbl_secattr_init(&secattr);
+		smack_to_secattr(ssp->smk_out, &secattr);
+		rc = netlbl_req_setattr(req, &secattr);
+		netlbl_secattr_destroy(&secattr);
+	} else
+		netlbl_req_delattr(req);
+
 	return rc;
 }
 

