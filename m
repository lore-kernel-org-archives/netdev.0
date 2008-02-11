From: Casey Schaufler <casey@schaufler-ca.com>
Subject: [PATCH] [RFC] Smack: unlabeled outgoing ambient packets - v2
Date: Mon, 11 Feb 2008 10:29:19 -0800
Message-ID: <47B093FF.3030202@schaufler-ca.com>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from n1.bullet.mail.re3.yahoo.com ([68.142.237.108]:22214 "HELO
	n1.bullet.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752481AbYBLB3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 20:29:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Schaufler <casey@schaufler-ca.com>

Smack uses CIPSO labeling, but allows for unlabeled packets
by specifying an "ambient" label that is applied to incoming
unlabeled packets. Because the other end of the connection
may dislike IP options, and ssh is one know application that
behaves thus, it is prudent to respond in kind. This patch
changes the network labeling behavior such that an outgoing
packet that would be given a CIPSO label that matches the
ambient label is left unlabeled. An "unlbl" domain is added
and the netlabel defaulting mechanism invoked rather than
assuming that everything is CIPSO. Locking has been added
around changes to the ambient label as the mechanisms used
to do so are more involved.

Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>

---

This patch differs significantly from the previous version.
I think that I am using the netlbl interfaces more appropriately,
Paul, please let me know if there's a better approach.

It's inconvenient that netlbl_sock_setattr frees the domain passed.
I see that it makes sense for SELinux with the way SELinux treats
secctx's, but Smack is more careful about memory usage and I have
to do what I consider a gratuitous kalloc because of this behavior.
Would you be open to a patch to change this if it included the SELinux
changes?

Thank you.

 security/smack/smack_lsm.c |   20 ++++++------
 security/smack/smackfs.c   |   54 +++++++++++++++++++++++++----------
 2 files changed, 49 insertions(+), 25 deletions(-)

diff -uprN -X linux-2.6.25-g0210-base//Documentation/dontdiff linux-2.6.25-g0210-base/security/smack/smackfs.c linux-2.6.25-g0210/security/smack/smackfs.c
--- linux-2.6.25-g0210-base/security/smack/smackfs.c	2008-02-10 19:30:47.000000000 -0800
+++ linux-2.6.25-g0210/security/smack/smackfs.c	2008-02-11 07:14:54.000000000 -0800
@@ -45,6 +45,7 @@ enum smk_inos {
  */
 static DEFINE_MUTEX(smack_list_lock);
 static DEFINE_MUTEX(smack_cipso_lock);
+static DEFINE_MUTEX(smack_ambient_lock);
 
 /*
  * This is the "ambient" label for network traffic.
@@ -363,6 +364,27 @@ void smk_cipso_doi(void)
 		       __func__, __LINE__, rc);
 }
 
+/**
+ * smk_unlbl_ambient - initialize the unlabeled domain
+ */
+void smk_unlbl_ambient(char *oldambient)
+{
+	int rc;
+	struct netlbl_audit audit_info;
+
+	if (oldambient != NULL) {
+		rc = netlbl_cfg_map_del(oldambient, &audit_info);
+		if (rc != 0)
+			printk(KERN_WARNING "%s:%d remove rc = %d\n",
+			       __func__, __LINE__, rc);
+	}
+
+	rc = netlbl_cfg_unlbl_add_map(smack_net_ambient, &audit_info);
+	if (rc != 0)
+		printk(KERN_WARNING "%s:%d add rc = %d\n",
+		       __func__, __LINE__, rc);
+}
+
 /*
  * Seq_file read operations for /smack/cipso
  */
@@ -709,7 +731,6 @@ static ssize_t smk_read_ambient(struct f
 				size_t cn, loff_t *ppos)
 {
 	ssize_t rc;
-	char out[SMK_LABELLEN];
 	int asize;
 
 	if (*ppos != 0)
@@ -717,23 +738,18 @@ static ssize_t smk_read_ambient(struct f
 	/*
 	 * Being careful to avoid a problem in the case where
 	 * smack_net_ambient gets changed in midstream.
-	 * Since smack_net_ambient is always set with a value
-	 * from the label list, including initially, and those
-	 * never get freed, the worst case is that the pointer
-	 * gets changed just after this strncpy, in which case
-	 * the value passed up is incorrect. Locking around
-	 * smack_net_ambient wouldn't be any better than this
-	 * copy scheme as by the time the caller got to look
-	 * at the ambient value it would have cleared the lock
-	 * and been changed.
 	 */
-	strncpy(out, smack_net_ambient, SMK_LABELLEN);
-	asize = strlen(out) + 1;
+	mutex_lock(&smack_ambient_lock);
 
-	if (cn < asize)
-		return -EINVAL;
+	asize = strlen(smack_net_ambient) + 1;
 
-	rc = simple_read_from_buffer(buf, cn, ppos, out, asize);
+	if (cn >= asize)
+		rc = simple_read_from_buffer(buf, cn, ppos,
+					     smack_net_ambient, asize);
+	else
+		rc = -EINVAL;
+
+	mutex_unlock(&smack_ambient_lock);
 
 	return rc;
 }
@@ -751,6 +767,7 @@ static ssize_t smk_write_ambient(struct 
 				 size_t count, loff_t *ppos)
 {
 	char in[SMK_LABELLEN];
+	char *oldambient;
 	char *smack;
 
 	if (!capable(CAP_MAC_ADMIN))
@@ -766,7 +783,13 @@ static ssize_t smk_write_ambient(struct 
 	if (smack == NULL)
 		return -EINVAL;
 
+	mutex_lock(&smack_ambient_lock);
+
+	oldambient = smack_net_ambient;
 	smack_net_ambient = smack;
+	smk_unlbl_ambient(oldambient);
+
+	mutex_unlock(&smack_ambient_lock);
 
 	return count;
 }
@@ -974,6 +997,7 @@ static int __init init_smk_fs(void)
 
 	sema_init(&smack_write_sem, 1);
 	smk_cipso_doi();
+	smk_unlbl_ambient(NULL);
 
 	return err;
 }
diff -uprN -X linux-2.6.25-g0210-base//Documentation/dontdiff linux-2.6.25-g0210-base/security/smack/smack_lsm.c linux-2.6.25-g0210/security/smack/smack_lsm.c
--- linux-2.6.25-g0210-base/security/smack/smack_lsm.c	2008-02-10 19:30:47.000000000 -0800
+++ linux-2.6.25-g0210/security/smack/smack_lsm.c	2008-02-10 20:10:47.000000000 -0800
@@ -1251,7 +1251,7 @@ static void smack_to_secattr(char *smack
 
 	switch (smack_net_nltype) {
 	case NETLBL_NLTYPE_CIPSOV4:
-		nlsp->domain = NULL;
+		nlsp->domain = kstrdup(smack, GFP_ATOMIC);
 		nlsp->flags = NETLBL_SECATTR_DOMAIN;
 		nlsp->flags |= NETLBL_SECATTR_MLS_LVL;
 
@@ -1276,21 +1276,21 @@ static void smack_to_secattr(char *smack
  * Convert the outbound smack value (smk_out) to a
  * secattr and attach it to the socket.
  *
- * Returns 0 on success or an error code
+ * The return from netlbl_sock_setattr is ignored because
+ * the defaulting label behavior provided by netlbl takes
+ * care of the error cases.
  */
-static int smack_netlabel(struct sock *sk)
+static void smack_netlabel(struct sock *sk)
 {
 	struct socket_smack *ssp = sk->sk_security;
 	struct netlbl_lsm_secattr secattr;
-	int rc = 0;
+	int rc;
 
 	netlbl_secattr_init(&secattr);
 	smack_to_secattr(ssp->smk_out, &secattr);
 	if (secattr.flags != NETLBL_SECATTR_NONE)
 		rc = netlbl_sock_setattr(sk, &secattr);
-
 	netlbl_secattr_destroy(&secattr);
-	return rc;
 }
 
 /**
@@ -1340,7 +1340,7 @@ static int smack_inode_setsecurity(struc
 		ssp->smk_in = sp;
 	else if (strcmp(name, XATTR_SMACK_IPOUT) == 0) {
 		ssp->smk_out = sp;
-		return smack_netlabel(sock->sk);
+		smack_netlabel(sock->sk);
 	} else
 		return -EOPNOTSUPP;
 
@@ -1367,7 +1367,8 @@ static int smack_socket_post_create(stru
 	/*
 	 * Set the outbound netlbl.
 	 */
-	return smack_netlabel(sock->sk);
+	smack_netlabel(sock->sk);
+	return 0;
 }
 
 /**
@@ -2199,7 +2200,6 @@ static int smack_socket_getpeersec_dgram
 static void smack_sock_graft(struct sock *sk, struct socket *parent)
 {
 	struct socket_smack *ssp;
-	int rc;
 
 	if (sk == NULL)
 		return;
@@ -2212,7 +2212,7 @@ static void smack_sock_graft(struct sock
 	ssp->smk_out = current->security;
 	ssp->smk_packet[0] = '\0';
 
-	rc = smack_netlabel(sk);
+	smack_netlabel(sk);
 }
 
 /**


