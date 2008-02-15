From: Casey Schaufler <casey@schaufler-ca.com>
Subject: [PATCH] (02/15/08 Linus git) Smack unlabeled outgoing ambient packets
 - v4
Date: Fri, 15 Feb 2008 15:24:25 -0800
Message-ID: <47B61F29.3040203@schaufler-ca.com>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	paul.moore@hp.com, casey@schaufler-ca.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp117.plus.mail.mud.yahoo.com ([209.191.106.148]:48651 "HELO
	smtp117.plus.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757202AbYBPBAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 20:00:50 -0500
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

Cleaned up some issues noted in review.
Make smk_cipso_doi() static.
Create a hook for the new security_secctx_to_secid()
using existing underlying code.
Fill in audit data for netlbl domain calls.
Collapse unnecessary multiple assignments.

Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>

---

 security/smack/smack_lsm.c |   36 ++++++++++++++++----
 security/smack/smackfs.c   |   61 ++++++++++++++++++++++++++---------
 2 files changed, 74 insertions(+), 23 deletions(-)

diff -uprN -X linux-2.6.25-g0215-base//Documentation/dontdiff linux-2.6.25-g0215-base/security/smack/smackfs.c linux-2.6.25-g0215/security/smack/smackfs.c
--- linux-2.6.25-g0215-base/security/smack/smackfs.c	2008-02-15 14:25:37.000000000 -0800
+++ linux-2.6.25-g0215/security/smack/smackfs.c	2008-02-15 14:30:36.000000000 -0800
@@ -24,6 +24,7 @@
 #include <net/cipso_ipv4.h>
 #include <linux/seq_file.h>
 #include <linux/ctype.h>
+#include <linux/audit.h>
 #include "smack.h"
 
 /*
@@ -45,6 +46,7 @@ enum smk_inos {
  */
 static DEFINE_MUTEX(smack_list_lock);
 static DEFINE_MUTEX(smack_cipso_lock);
+static DEFINE_MUTEX(smack_ambient_lock);
 
 /*
  * This is the "ambient" label for network traffic.
@@ -342,6 +344,9 @@ void smk_cipso_doi(void)
 	struct cipso_v4_doi *doip;
 	struct netlbl_audit audit_info;
 
+	audit_info.loginuid = audit_get_loginuid(current);
+	audit_info.secid = smack_to_secid(current->security);
+
 	rc = netlbl_cfg_map_del(NULL, &audit_info);
 	if (rc != 0)
 		printk(KERN_WARNING "%s:%d remove rc = %d\n",
@@ -363,6 +368,30 @@ void smk_cipso_doi(void)
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
+	audit_info.loginuid = audit_get_loginuid(current);
+	audit_info.secid = smack_to_secid(current->security);
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
@@ -709,7 +738,6 @@ static ssize_t smk_read_ambient(struct f
 				size_t cn, loff_t *ppos)
 {
 	ssize_t rc;
-	char out[SMK_LABELLEN];
 	int asize;
 
 	if (*ppos != 0)
@@ -717,23 +745,18 @@ static ssize_t smk_read_ambient(struct f
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
+
+	if (cn >= asize)
+		rc = simple_read_from_buffer(buf, cn, ppos,
+					     smack_net_ambient, asize);
+	else
+		rc = -EINVAL;
 
-	rc = simple_read_from_buffer(buf, cn, ppos, out, asize);
+	mutex_unlock(&smack_ambient_lock);
 
 	return rc;
 }
@@ -751,6 +774,7 @@ static ssize_t smk_write_ambient(struct 
 				 size_t count, loff_t *ppos)
 {
 	char in[SMK_LABELLEN];
+	char *oldambient;
 	char *smack;
 
 	if (!capable(CAP_MAC_ADMIN))
@@ -766,7 +790,13 @@ static ssize_t smk_write_ambient(struct 
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
@@ -974,6 +1004,7 @@ static int __init init_smk_fs(void)
 
 	sema_init(&smack_write_sem, 1);
 	smk_cipso_doi();
+	smk_unlbl_ambient(NULL);
 
 	return err;
 }
diff -uprN -X linux-2.6.25-g0215-base//Documentation/dontdiff linux-2.6.25-g0215-base/security/smack/smack_lsm.c linux-2.6.25-g0215/security/smack/smack_lsm.c
--- linux-2.6.25-g0215-base/security/smack/smack_lsm.c	2008-02-15 14:25:37.000000000 -0800
+++ linux-2.6.25-g0215/security/smack/smack_lsm.c	2008-02-15 14:31:21.000000000 -0800
@@ -1251,9 +1251,8 @@ static void smack_to_secattr(char *smack
 
 	switch (smack_net_nltype) {
 	case NETLBL_NLTYPE_CIPSOV4:
-		nlsp->domain = NULL;
-		nlsp->flags = NETLBL_SECATTR_DOMAIN;
-		nlsp->flags |= NETLBL_SECATTR_MLS_LVL;
+		nlsp->domain = kstrdup(smack, GFP_ATOMIC);
+		nlsp->flags = NETLBL_SECATTR_DOMAIN | NETLBL_SECATTR_MLS_LVL;
 
 		rc = smack_to_cipso(smack, &cipso);
 		if (rc == 0) {
@@ -1282,15 +1281,14 @@ static int smack_netlabel(struct sock *s
 {
 	struct socket_smack *ssp;
 	struct netlbl_lsm_secattr secattr;
-	int rc = 0;
+	int rc;
 
 	ssp = sk->sk_security;
 	netlbl_secattr_init(&secattr);
 	smack_to_secattr(ssp->smk_out, &secattr);
-	if (secattr.flags != NETLBL_SECATTR_NONE)
-		rc = netlbl_sock_setattr(sk, &secattr);
-
+	rc = netlbl_sock_setattr(sk, &secattr);
 	netlbl_secattr_destroy(&secattr);
+
 	return rc;
 }
 
@@ -1313,6 +1311,7 @@ static int smack_inode_setsecurity(struc
 	struct inode_smack *nsp = inode->i_security;
 	struct socket_smack *ssp;
 	struct socket *sock;
+	int rc = 0;
 
 	if (value == NULL || size > SMK_LABELLEN)
 		return -EACCES;
@@ -1341,7 +1340,10 @@ static int smack_inode_setsecurity(struc
 		ssp->smk_in = sp;
 	else if (strcmp(name, XATTR_SMACK_IPOUT) == 0) {
 		ssp->smk_out = sp;
-		return smack_netlabel(sock->sk);
+		rc = smack_netlabel(sock->sk);
+		if (rc != 0)
+			printk(KERN_WARNING "Smack: \"%s\" netlbl error %d.\n",
+			       __func__, -rc);
 	} else
 		return -EOPNOTSUPP;
 
@@ -2214,6 +2216,9 @@ static void smack_sock_graft(struct sock
 	ssp->smk_packet[0] = '\0';
 
 	rc = smack_netlabel(sk);
+	if (rc != 0)
+		printk(KERN_WARNING "Smack: \"%s\" netlbl error %d.\n",
+		       __func__, -rc);
 }
 
 /**
@@ -2346,6 +2351,20 @@ static int smack_secid_to_secctx(u32 sec
 }
 
 /*
+ * smack_secctx_to_secid - return the secid for a smack label
+ * @secdata: smack label
+ * @seclen: how long result is
+ * @secid: outgoing integer
+ *
+ * Exists for audit and networking code.
+ */
+static int smack_secctx_to_secid(char *secdata, u32 seclen, u32 *secid)
+{
+	*secid = smack_to_secid(secdata);
+	return 0;
+}
+
+/*
  * smack_release_secctx - don't do anything.
  * @key_ref: unused
  * @context: unused
@@ -2475,6 +2494,7 @@ static struct security_operations smack_
 	.key_permission = 		smack_key_permission,
 #endif /* CONFIG_KEYS */
 	.secid_to_secctx = 		smack_secid_to_secctx,
+	.secctx_to_secid = 		smack_secctx_to_secid,
 	.release_secctx = 		smack_release_secctx,
 };
 
 


