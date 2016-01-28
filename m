From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] lib: fix callers of strtobool to use char array
Date: Wed, 27 Jan 2016 16:45:42 -0800
Message-ID: <20160128004542.GA15247@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some callers of strtobool were passing a pointer to unterminated strings.
This fixes the issue and consolidates some logic in cifs.

Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Cc: Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Cc: Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Cc: linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
This is preparation for adding "on"/"off" support to strtobool(), and I
want to make sure the solution isn't upsetting to the two callers. :)
---
 drivers/net/wireless/marvell/mwifiex/debugfs.c |  6 +-
 fs/cifs/cifs_debug.c                           | 78 ++++++++++++--------------
 fs/cifs/cifs_debug.h                           |  2 +-
 fs/cifs/cifsfs.c                               |  6 +-
 fs/cifs/cifsglob.h                             |  4 +-
 5 files changed, 44 insertions(+), 52 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/debugfs.c b/drivers/net/wireless/marvell/mwifiex/debugfs.c
index 0b9c580af988..76af60899c69 100644
--- a/drivers/net/wireless/marvell/mwifiex/debugfs.c
+++ b/drivers/net/wireless/marvell/mwifiex/debugfs.c
@@ -880,13 +880,13 @@ mwifiex_reset_write(struct file *file,
 {
 	struct mwifiex_private *priv = file->private_data;
 	struct mwifiex_adapter *adapter = priv->adapter;
-	char cmd;
+	char cmd[2] = { '\0' };
 	bool result;
 
-	if (copy_from_user(&cmd, ubuf, sizeof(cmd)))
+	if (copy_from_user(cmd, ubuf, sizeof(char)))
 		return -EFAULT;
 
-	if (strtobool(&cmd, &result))
+	if (strtobool(cmd, &result))
 		return -EINVAL;
 
 	if (!result)
diff --git a/fs/cifs/cifs_debug.c b/fs/cifs/cifs_debug.c
index 50b268483302..cafe464fa1b7 100644
--- a/fs/cifs/cifs_debug.c
+++ b/fs/cifs/cifs_debug.c
@@ -251,11 +251,29 @@ static const struct file_operations cifs_debug_data_proc_fops = {
 	.release	= single_release,
 };
 
+static int get_user_bool(const char __user *buffer, bool *store)
+{
+	char c[2] = { '\0' };
+	bool bv;
+	int rc;
+
+	rc = get_user(c[0], buffer);
+	if (rc)
+		return rc;
+
+	rc = strtobool(c, &bv);
+	if (rc)
+		return rc;
+
+	*store = bv;
+
+	return 0;
+}
+
 #ifdef CONFIG_CIFS_STATS
 static ssize_t cifs_stats_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
-	char c;
 	bool bv;
 	int rc;
 	struct list_head *tmp1, *tmp2, *tmp3;
@@ -263,11 +281,8 @@ static ssize_t cifs_stats_proc_write(struct file *file,
 	struct cifs_ses *ses;
 	struct cifs_tcon *tcon;
 
-	rc = get_user(c, buffer);
-	if (rc)
-		return rc;
-
-	if (strtobool(&c, &bv) == 0) {
+	rc = get_user_bool(buffer, &bv);
+	if (rc == 0) {
 #ifdef CONFIG_CIFS_STATS2
 		atomic_set(&totBufAllocCount, 0);
 		atomic_set(&totSmBufAllocCount, 0);
@@ -290,7 +305,8 @@ static ssize_t cifs_stats_proc_write(struct file *file,
 			}
 		}
 		spin_unlock(&cifs_tcp_ses_lock);
-	}
+	} else
+		return rc;
 
 	return count;
 }
@@ -433,17 +449,17 @@ static int cifsFYI_proc_open(struct inode *inode, struct file *file)
 static ssize_t cifsFYI_proc_write(struct file *file, const char __user *buffer,
 		size_t count, loff_t *ppos)
 {
-	char c;
+	char c[2] = { '\0' };
 	bool bv;
 	int rc;
 
-	rc = get_user(c, buffer);
+	rc = get_user(c[0], buffer);
 	if (rc)
 		return rc;
-	if (strtobool(&c, &bv) == 0)
+	if (strtobool(c, &bv) == 0)
 		cifsFYI = bv;
-	else if ((c > '1') && (c <= '9'))
-		cifsFYI = (int) (c - '0'); /* see cifs_debug.h for meanings */
+	else if ((c[0] > '1') && (c[0] <= '9'))
+		cifsFYI = (int) (c[0] - '0'); /* see cifs_debug.h for meanings */
 
 	return count;
 }
@@ -471,20 +487,12 @@ static int cifs_linux_ext_proc_open(struct inode *inode, struct file *file)
 static ssize_t cifs_linux_ext_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
-	char c;
-	bool bv;
 	int rc;
 
-	rc = get_user(c, buffer);
+	rc = get_user_bool(buffer, &linuxExtEnabled);
 	if (rc)
 		return rc;
 
-	rc = strtobool(&c, &bv);
-	if (rc)
-		return rc;
-
-	linuxExtEnabled = bv;
-
 	return count;
 }
 
@@ -511,20 +519,12 @@ static int cifs_lookup_cache_proc_open(struct inode *inode, struct file *file)
 static ssize_t cifs_lookup_cache_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
-	char c;
-	bool bv;
 	int rc;
 
-	rc = get_user(c, buffer);
+	rc = get_user_bool(buffer, &lookupCacheEnabled);
 	if (rc)
 		return rc;
 
-	rc = strtobool(&c, &bv);
-	if (rc)
-		return rc;
-
-	lookupCacheEnabled = bv;
-
 	return count;
 }
 
@@ -551,20 +551,12 @@ static int traceSMB_proc_open(struct inode *inode, struct file *file)
 static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
 		size_t count, loff_t *ppos)
 {
-	char c;
-	bool bv;
 	int rc;
 
-	rc = get_user(c, buffer);
+	rc = get_user_bool(buffer, &traceSMB);
 	if (rc)
 		return rc;
 
-	rc = strtobool(&c, &bv);
-	if (rc)
-		return rc;
-
-	traceSMB = bv;
-
 	return count;
 }
 
@@ -622,7 +614,7 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
 	int rc;
 	unsigned int flags;
 	char flags_string[12];
-	char c;
+	char c[2] = { '\0' };
 	bool bv;
 
 	if ((count < 1) || (count > 11))
@@ -635,11 +627,11 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
 
 	if (count < 3) {
 		/* single char or single char followed by null */
-		c = flags_string[0];
-		if (strtobool(&c, &bv) == 0) {
+		c[0] = flags_string[0];
+		if (strtobool(c, &bv) == 0) {
 			global_secflags = bv ? CIFSSEC_MAX : CIFSSEC_DEF;
 			return count;
-		} else if (!isdigit(c)) {
+		} else if (!isdigit(c[0])) {
 			cifs_dbg(VFS, "Invalid SecurityFlags: %s\n",
 					flags_string);
 			return -EINVAL;
diff --git a/fs/cifs/cifs_debug.h b/fs/cifs/cifs_debug.h
index 66cf0f9fff89..c611ca2339d7 100644
--- a/fs/cifs/cifs_debug.h
+++ b/fs/cifs/cifs_debug.h
@@ -25,7 +25,7 @@
 void cifs_dump_mem(char *label, void *data, int length);
 void cifs_dump_detail(void *);
 void cifs_dump_mids(struct TCP_Server_Info *);
-extern int traceSMB;		/* flag which enables the function below */
+extern bool traceSMB;		/* flag which enables the function below */
 void dump_smb(void *, int);
 #define CIFS_INFO	0x01
 #define CIFS_RC		0x02
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index c48ca13673e3..931b446f2a44 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -54,10 +54,10 @@
 #endif
 
 int cifsFYI = 0;
-int traceSMB = 0;
+bool traceSMB;
 bool enable_oplocks = true;
-unsigned int linuxExtEnabled = 1;
-unsigned int lookupCacheEnabled = 1;
+bool linuxExtEnabled = true;
+bool lookupCacheEnabled = true;
 unsigned int global_secflags = CIFSSEC_DEF;
 /* unsigned int ntlmv2_support = 0; */
 unsigned int sign_CIFS_PDUs = 1;
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index a25b2513f146..d21da9f05bae 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -1596,11 +1596,11 @@ GLOBAL_EXTERN atomic_t midCount;
 
 /* Misc globals */
 GLOBAL_EXTERN bool enable_oplocks; /* enable or disable oplocks */
-GLOBAL_EXTERN unsigned int lookupCacheEnabled;
+GLOBAL_EXTERN bool lookupCacheEnabled;
 GLOBAL_EXTERN unsigned int global_secflags;	/* if on, session setup sent
 				with more secure ntlmssp2 challenge/resp */
 GLOBAL_EXTERN unsigned int sign_CIFS_PDUs;  /* enable smb packet signing */
-GLOBAL_EXTERN unsigned int linuxExtEnabled;/*enable Linux/Unix CIFS extensions*/
+GLOBAL_EXTERN bool linuxExtEnabled;/*enable Linux/Unix CIFS extensions*/
 GLOBAL_EXTERN unsigned int CIFSMaxBufSize;  /* max size not including hdr */
 GLOBAL_EXTERN unsigned int cifs_min_rcv;    /* min size of big ntwrk buf pool */
 GLOBAL_EXTERN unsigned int cifs_min_small;  /* min size of small buf pool */
-- 
2.6.3


-- 
Kees Cook
Chrome OS & Brillo Security
