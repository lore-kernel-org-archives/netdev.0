From: paul.moore@hp.com
Subject: [PATCH 1/6] NetLabel: correctly initialize the NetLabel fields
Date: Tue, 29 Aug 2006 10:42:52 -0400
Message-ID: <20060829144444.202106000@hp.com>
References: <20060829144251.452774000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, akpm@osdl.org,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:55502 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S965002AbWH2Ooq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 10:44:46 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-bug_invalidclass
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a problem where the NetLabel specific fields of the sk_security_struct
structure were not being initialized early enough in some cases.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/hooks.c                    |    6 +++
 security/selinux/include/selinux_netlabel.h |   18 +++++++++++
 security/selinux/ss/services.c              |   45 ++++++++++++++++++++++++++--
 3 files changed, 67 insertions(+), 2 deletions(-)

Index: net-2.6.19/security/selinux/hooks.c
===================================================================
--- net-2.6.19.orig/security/selinux/hooks.c
+++ net-2.6.19/security/selinux/hooks.c
@@ -281,6 +281,8 @@ static int sk_alloc_security(struct sock
 	ssec->sid = SECINITSID_UNLABELED;
 	sk->sk_security = ssec;
 
+	selinux_netlbl_sk_security_init(ssec, family);
+
 	return 0;
 }
 
@@ -3585,6 +3587,8 @@ static void selinux_sk_clone_security(co
 
 	newssec->sid = ssec->sid;
 	newssec->peer_sid = ssec->peer_sid;
+
+	selinux_netlbl_sk_clone_security(ssec, newssec);
 }
 
 static void selinux_sk_getsecid(struct sock *sk, u32 *secid)
@@ -3648,6 +3652,8 @@ static void selinux_inet_csk_clone(struc
 	   new socket in sync, but we don't have the isec available yet.
 	   So we will wait until sock_graft to do it, by which
 	   time it will have been created and available. */
+
+	selinux_netlbl_sk_security_init(newsksec, req->rsk_ops->family);
 }
 
 static void selinux_req_classify_flow(const struct request_sock *req,
Index: net-2.6.19/security/selinux/include/selinux_netlabel.h
===================================================================
--- net-2.6.19.orig/security/selinux/include/selinux_netlabel.h
+++ net-2.6.19/security/selinux/include/selinux_netlabel.h
@@ -39,6 +39,10 @@ int selinux_netlbl_sock_rcv_skb(struct s
 				struct avc_audit_data *ad);
 u32 selinux_netlbl_socket_getpeersec_stream(struct socket *sock);
 u32 selinux_netlbl_socket_getpeersec_dgram(struct sk_buff *skb);
+void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
+				     int family);
+void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
+				      struct sk_security_struct *newssec);
 
 int __selinux_netlbl_inode_permission(struct inode *inode, int mask);
 /**
@@ -115,6 +119,20 @@ static inline u32 selinux_netlbl_socket_
 	return SECSID_NULL;
 }
 
+static inline void selinux_netlbl_sk_security_init(
+	                                       struct sk_security_struct *ssec,
+					       int family)
+{
+	return;
+}
+
+static inline void selinux_netlbl_sk_clone_security(
+	                                   struct sk_security_struct *ssec,
+					   struct sk_security_struct *newssec)
+{
+	return;
+}
+
 static inline int selinux_netlbl_inode_permission(struct inode *inode,
 						  int mask)
 {
Index: net-2.6.19/security/selinux/ss/services.c
===================================================================
--- net-2.6.19.orig/security/selinux/ss/services.c
+++ net-2.6.19/security/selinux/ss/services.c
@@ -2423,6 +2423,45 @@ netlbl_socket_setsid_return:
 }
 
 /**
+ * selinux_netlbl_sk_security_init - Setup the NetLabel fields
+ * @ssec: the sk_security_struct
+ * @family: the socket family
+ *
+ * Description:
+ * Called when a new sk_security_struct is allocated to initialize the NetLabel
+ * fields.
+ *
+ */
+void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
+				     int family)
+{
+        if (family == PF_INET)
+		ssec->nlbl_state = NLBL_REQUIRE;
+	else
+		ssec->nlbl_state = NLBL_UNSET;
+}
+
+/**
+ * selinux_netlbl_sk_clone_security - Copy the NetLabel fields
+ * @ssec: the original sk_security_struct
+ * @newssec: the cloned sk_security_struct
+ *
+ * Description:
+ * Clone the NetLabel specific sk_security_struct fields from @ssec to
+ * @newssec.
+ *
+ */
+void selinux_netlbl_sk_clone_security(struct sk_security_struct *ssec,
+				      struct sk_security_struct *newssec)
+{
+	newssec->sclass = ssec->sclass;
+	if (ssec->nlbl_state != NLBL_UNSET)
+		newssec->nlbl_state = NLBL_REQUIRE;
+	else
+		newssec->nlbl_state = NLBL_UNSET;
+}
+
+/**
  * selinux_netlbl_socket_post_create - Label a socket using NetLabel
  * @sock: the socket to label
  * @sock_family: the socket family
@@ -2440,10 +2479,11 @@ int selinux_netlbl_socket_post_create(st
 	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
 	struct sk_security_struct *sksec = sock->sk->sk_security;
 
+	sksec->sclass = isec->sclass;
+
 	if (sock_family != PF_INET)
 		return 0;
 
-	sksec->sclass = isec->sclass;
 	sksec->nlbl_state = NLBL_REQUIRE;
 	return selinux_netlbl_socket_setsid(sock, sid);
 }
@@ -2463,12 +2503,13 @@ void selinux_netlbl_sock_graft(struct so
 	struct inode_security_struct *isec = SOCK_INODE(sock)->i_security;
 	struct sk_security_struct *sksec = sk->sk_security;
 
+	sksec->sclass = isec->sclass;
+
 	if (sk->sk_family != PF_INET)
 		return;
 
 	sksec->nlbl_state = NLBL_REQUIRE;
 	sksec->peer_sid = sksec->sid;
-	sksec->sclass = isec->sclass;
 
 	/* Try to set the NetLabel on the socket to save time later, if we fail
 	 * here we will pick up the pieces in later calls to

--
paul moore
linux security @ hp
