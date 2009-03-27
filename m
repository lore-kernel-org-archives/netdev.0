From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 5/6] netlabel: Cleanup the Smack/NetLabel code to fix incoming
	TCP connections
Date: Fri, 27 Mar 2009 17:10:54 -0400
Message-ID: <20090327211054.17777.2771.stgit@flek.lan>
References: <20090327205520.17777.32557.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, casey@schaufler-ca.com,
	etienne.basset@numericable.fr
To: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090327205520.17777.32557.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleans up a lot of the Smack network access control code.  The
largest changes are to fix the labeling of incoming TCP connections in a
manner similar to the recent SELinux changes which use the
security_inet_conn_request() hook to label the request_sock and let the label
move to the child socket via the normal network stack mechanisms.  In addition
to the incoming TCP connection fixes this patch also removes the smk_labled
field from the socket_smack struct as the minor optimization advantage was
outweighed by the difficulty in maintaining it's proper state.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/net/netlabel.h       |    5 +
 net/netlabel/netlabel_kapi.c |   13 ++
 security/smack/smack.h       |    1 
 security/smack/smack_lsm.c   |  260 +++++++++++++++++++++++-------------------
 4 files changed, 161 insertions(+), 118 deletions(-)

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
index cae2f5f..b0e582f 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -861,6 +861,19 @@ req_setattr_return:
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
diff --git a/security/smack/smack.h b/security/smack/smack.h
index 64164f8..5e5a3bc 100644
--- a/security/smack/smack.h
+++ b/security/smack/smack.h
@@ -42,7 +42,6 @@ struct superblock_smack {
 struct socket_smack {
 	char		*smk_out;			/* outbound label */
 	char		*smk_in;			/* inbound label */
-	int		smk_labeled;			/* label scheme */
 	char		smk_packet[SMK_LABELLEN];	/* TCP peer label */
 };
 
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 23ad420..8ed502c 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -7,6 +7,8 @@
  *	Casey Schaufler <casey@schaufler-ca.com>
  *
  *  Copyright (C) 2007 Casey Schaufler <casey@schaufler-ca.com>
+ *  Copyright (C) 2009 Hewlett-Packard Development Company, L.P.
+ *                Paul Moore <paul.moore@hp.com>
  *
  *	This program is free software; you can redistribute it and/or modify
  *	it under the terms of the GNU General Public License version 2,
@@ -20,6 +22,7 @@
 #include <linux/ext2_fs.h>
 #include <linux/kd.h>
 #include <asm/ioctls.h>
+#include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/mutex.h>
@@ -1275,7 +1278,6 @@ static int smack_sk_alloc_security(struct sock *sk, int family, gfp_t gfp_flags)
 
 	ssp->smk_in = csp;
 	ssp->smk_out = csp;
-	ssp->smk_labeled = SMACK_CIPSO_SOCKET;
 	ssp->smk_packet[0] = '\0';
 
 	sk->sk_security = ssp;
@@ -1295,6 +1297,39 @@ static void smack_sk_free_security(struct sock *sk)
 }
 
 /**
+* smack_host_label - check host based restrictions
+* @sip: the object end
+*
+* looks for host based access restrictions
+*
+* This version will only be appropriate for really small sets of single label
+* hosts.  The caller is responsible for ensuring that the RCU read lock is
+* taken before calling this function.
+*
+* Returns the label of the far end or NULL if it's not special.
+*/
+static char *smack_host_label(struct sockaddr_in *sip)
+{
+	struct smk_netlbladdr *snp;
+	struct in_addr *siap = &sip->sin_addr;
+
+	if (siap->s_addr == 0)
+		return NULL;
+
+	list_for_each_entry_rcu(snp, &smk_netlbladdr_list, list)
+		/*
+		* we break after finding the first match because
+		* the list is sorted from longest to shortest mask
+		* so we have found the most specific match
+		*/
+		if ((&snp->smk_host.sin_addr)->s_addr ==
+		    (siap->s_addr & (&snp->smk_mask)->s_addr))
+			return snp->smk_label;
+
+	return NULL;
+}
+
+/**
  * smack_set_catset - convert a capset to netlabel mls categories
  * @catset: the Smack categories
  * @sap: where to put the netlabel categories
@@ -1365,11 +1400,10 @@ static void smack_to_secattr(char *smack, struct netlbl_lsm_secattr *nlsp)
  */
 static int smack_netlabel(struct sock *sk, int labeled)
 {
-	struct socket_smack *ssp;
+	struct socket_smack *ssp = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
 	int rc = 0;
 
-	ssp = sk->sk_security;
 	/*
 	 * Usually the netlabel code will handle changing the
 	 * packet labeling based on the label.
@@ -1393,21 +1427,45 @@ static int smack_netlabel(struct sock *sk, int labeled)
 
 	bh_unlock_sock(sk);
 	local_bh_enable();
-	/*
-	 * Remember the label scheme used so that it is not
-	 * necessary to do the netlabel setting if it has not
-	 * changed the next time through.
-	 *
-	 * The -EDESTADDRREQ case is an indication that there's
-	 * a single level host involved.
-	 */
-	if (rc == 0)
-		ssp->smk_labeled = labeled;
 
 	return rc;
 }
 
 /**
+ * smack_netlbel_send - Set the secattr on a socket and perform access checks
+ * @sk: the socket
+ * @sap: the destination address
+ *
+ * Set the correct secattr for the given socket based on the destination
+ * address and perform any outbound access checks needed.
+ *
+ * Returns 0 on success or an error code.
+ *
+ */
+static int smack_netlabel_send(struct sock *sk, struct sockaddr_in *sap)
+{
+	int rc;
+	int sk_lbl;
+	char *hostsp;
+	struct socket_smack *ssp = sk->sk_security;
+
+	rcu_read_lock();
+	hostsp = smack_host_label(sap);
+	if (hostsp != NULL) {
+		sk_lbl = SMACK_UNLABELED_SOCKET;
+		rc = smk_access(ssp->smk_out, hostsp, MAY_WRITE);
+	} else {
+		sk_lbl = SMACK_CIPSO_SOCKET;
+		rc = 0;
+	}
+	rcu_read_unlock();
+	if (rc != 0)
+		return rc;
+
+	return smack_netlabel(sk, sk_lbl);
+}
+
+/**
  * smack_inode_setsecurity - set smack xattrs
  * @inode: the object
  * @name: attribute name
@@ -1488,43 +1546,6 @@ static int smack_socket_post_create(struct socket *sock, int family,
 	return smack_netlabel(sock->sk, SMACK_CIPSO_SOCKET);
 }
 
-
-/**
- * smack_host_label - check host based restrictions
- * @sip: the object end
- *
- * looks for host based access restrictions
- *
- * This version will only be appropriate for really small
- * sets of single label hosts.
- *
- * Returns the label of the far end or NULL if it's not special.
- */
-static char *smack_host_label(struct sockaddr_in *sip)
-{
-	struct smk_netlbladdr *snp;
-	struct in_addr *siap = &sip->sin_addr;
-
-	if (siap->s_addr == 0)
-		return NULL;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(snp, &smk_netlbladdr_list, list) {
-		/*
-		 * we break after finding the first match because
-		 * the list is sorted from longest to shortest mask
-		 * so we have found the most specific match
-		 */
-		if ((&snp->smk_host.sin_addr)->s_addr  ==
-			(siap->s_addr & (&snp->smk_mask)->s_addr)) {
-			rcu_read_unlock();
-			return snp->smk_label;
-		}
-	}
-	rcu_read_unlock();
-	return NULL;
-}
-
 /**
  * smack_socket_connect - connect access check
  * @sock: the socket
@@ -1538,30 +1559,12 @@ static char *smack_host_label(struct sockaddr_in *sip)
 static int smack_socket_connect(struct socket *sock, struct sockaddr *sap,
 				int addrlen)
 {
-	struct socket_smack *ssp = sock->sk->sk_security;
-	char *hostsp;
-	int rc;
-
 	if (sock->sk == NULL || sock->sk->sk_family != PF_INET)
 		return 0;
-
 	if (addrlen < sizeof(struct sockaddr_in))
 		return -EINVAL;
 
-	hostsp = smack_host_label((struct sockaddr_in *)sap);
-	if (hostsp == NULL) {
-		if (ssp->smk_labeled != SMACK_CIPSO_SOCKET)
-			return smack_netlabel(sock->sk, SMACK_CIPSO_SOCKET);
-		return 0;
-	}
-
-	rc = smk_access(ssp->smk_out, hostsp, MAY_WRITE);
-	if (rc != 0)
-		return rc;
-
-	if (ssp->smk_labeled != SMACK_UNLABELED_SOCKET)
-		return smack_netlabel(sock->sk, SMACK_UNLABELED_SOCKET);
-	return 0;
+	return smack_netlabel_send(sock->sk, (struct sockaddr_in *)sap);
 }
 
 /**
@@ -2262,9 +2265,6 @@ static int smack_socket_sendmsg(struct socket *sock, struct msghdr *msg,
 				int size)
 {
 	struct sockaddr_in *sip = (struct sockaddr_in *) msg->msg_name;
-	struct socket_smack *ssp = sock->sk->sk_security;
-	char *hostsp;
-	int rc;
 
 	/*
 	 * Perfectly reasonable for this to be NULL
@@ -2272,22 +2272,7 @@ static int smack_socket_sendmsg(struct socket *sock, struct msghdr *msg,
 	if (sip == NULL || sip->sin_family != PF_INET)
 		return 0;
 
-	hostsp = smack_host_label(sip);
-	if (hostsp == NULL) {
-		if (ssp->smk_labeled != SMACK_CIPSO_SOCKET)
-			return smack_netlabel(sock->sk, SMACK_CIPSO_SOCKET);
-		return 0;
-	}
-
-	rc = smk_access(ssp->smk_out, hostsp, MAY_WRITE);
-	if (rc != 0)
-		return rc;
-
-	if (ssp->smk_labeled != SMACK_UNLABELED_SOCKET)
-		return smack_netlabel(sock->sk, SMACK_UNLABELED_SOCKET);
-
-	return 0;
-
+	return smack_netlabel_send(sock->sk, sip);
 }
 
 
@@ -2492,31 +2477,24 @@ static int smack_socket_getpeersec_dgram(struct socket *sock,
 }
 
 /**
- * smack_sock_graft - graft access state between two sockets
- * @sk: fresh sock
- * @parent: donor socket
+ * smack_sock_graft - Initialize a newly created socket with an existing sock
+ * @sk: child sock
+ * @parent: parent socket
  *
- * Sets the netlabel socket state on sk from parent
+ * Set the smk_{in,out} state of an existing sock based on the process that
+ * is creating the new socket.
  */
 static void smack_sock_graft(struct sock *sk, struct socket *parent)
 {
 	struct socket_smack *ssp;
-	int rc;
-
-	if (sk == NULL)
-		return;
 
-	if (sk->sk_family != PF_INET && sk->sk_family != PF_INET6)
+	if (sk == NULL ||
+	    (sk->sk_family != PF_INET && sk->sk_family != PF_INET6))
 		return;
 
 	ssp = sk->sk_security;
 	ssp->smk_in = ssp->smk_out = current_security();
-	ssp->smk_packet[0] = '\0';
-
-	rc = smack_netlabel(sk, SMACK_CIPSO_SOCKET);
-	if (rc != 0)
-		printk(KERN_WARNING "Smack: \"%s\" netlbl error %d.\n",
-		       __func__, -rc);
+	/* cssp->smk_packet is already set in smack_inet_csk_clone() */
 }
 
 /**
@@ -2531,35 +2509,82 @@ static void smack_sock_graft(struct sock *sk, struct socket *parent)
 static int smack_inet_conn_request(struct sock *sk, struct sk_buff *skb,
 				   struct request_sock *req)
 {
-	struct netlbl_lsm_secattr skb_secattr;
+	u16 family = sk->sk_family;
 	struct socket_smack *ssp = sk->sk_security;
+	struct netlbl_lsm_secattr secattr;
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
-	 * Receiving a packet requires that the other end
-	 * be able to write here. Read access is not required.
-	 *
-	 * If the request is successful save the peer's label
-	 * so that SO_PEERCRED can report it.
+	 * Receiving a packet requires that the other end be able to write
+	 * here. Read access is not required.
 	 */
 	rc = smk_access(smack, ssp->smk_in, MAY_WRITE);
-	if (rc == 0)
-		strncpy(ssp->smk_packet, smack, SMK_MAXLEN);
+	if (rc != 0)
+		return rc;
+
+	/*
+	 * Save the peer's label in the request_sock so we can later setup
+	 * smk_packet in the child socket so that SO_PEERCRED can report it.
+	 */
+	req->peer_secid = smack_to_secid(smack);
+
+	/*
+	 * We need to decide if we want to label the incoming connection here
+	 * if we do we only need to label the request_sock and the stack will
+	 * propogate the wire-label to the sock when it is created.
+	 */
+	hdr = ip_hdr(skb);
+	addr.sin_addr.s_addr = hdr->saddr;
+	rcu_read_lock();
+	if (smack_host_label(&addr) == NULL) {
+		rcu_read_unlock();
+		netlbl_secattr_init(&secattr);
+		smack_to_secattr(smack, &secattr);
+		rc = netlbl_req_setattr(req, &secattr);
+		netlbl_secattr_destroy(&secattr);
+	} else {
+		rcu_read_unlock();
+		netlbl_req_delattr(req);
+	}
 
 	return rc;
 }
 
+/**
+ * smack_inet_csk_clone - Copy the connection information to the new socket
+ * @sk: the new socket
+ * @req: the connection's request_sock
+ *
+ * Transfer the connection's peer label to the newly created socket.
+ */
+static void smack_inet_csk_clone(struct sock *sk,
+				 const struct request_sock *req)
+{
+	struct socket_smack *ssp = sk->sk_security;
+	char *smack;
+
+	if (req->peer_secid != 0) {
+		smack = smack_from_secid(req->peer_secid);
+		strncpy(ssp->smk_packet, smack, SMK_MAXLEN);
+	} else
+		ssp->smk_packet[0] = '\0';
+}
+
 /*
  * Key management security hooks
  *
@@ -2911,6 +2936,7 @@ struct security_operations smack_ops = {
 	.sk_free_security = 		smack_sk_free_security,
 	.sock_graft = 			smack_sock_graft,
 	.inet_conn_request = 		smack_inet_conn_request,
+	.inet_csk_clone =		smack_inet_csk_clone,
 
  /* key management security hooks */
 #ifdef CONFIG_KEYS

