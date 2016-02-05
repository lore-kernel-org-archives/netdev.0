From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 2/4] lib: update single-char callers of strtobool
Date: Fri,  5 Feb 2016 13:12:47 -0800
Message-ID: <1454706769-8729-3-git-send-email-keescook@chromium.org>
References: <1454706769-8729-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454706769-8729-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some callers of strtobool were passing a pointer to unterminated strings.
In preparation of adding multi-character processing to kstrtobool, update
the callers to not pass single-character pointers, and switch to using the
new kstrtobool_from_user helper where possible.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: Amitkumar Karwar <akarwar@marvell.com>
Cc: Nishant Sarmukadam <nishants@marvell.com>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: Steve French <sfrench@samba.org>
Cc: linux-cifs@vger.kernel.org
---
v3:
- drop needless buffer, andy.shevchenko
- drop unused "base" argument
---
 drivers/net/wireless/marvell/mwifiex/debugfs.c | 10 ++---
 fs/cifs/cifs_debug.c                           | 56 +++++++-------------------
 fs/cifs/cifs_debug.h                           |  2 +-
 fs/cifs/cifsfs.c                               |  6 +--
 fs/cifs/cifsglob.h                             |  4 +-
 5 files changed, 24 insertions(+), 54 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/debugfs.c b/drivers/net/wireless/marvell/mwifiex/debugfs.c
index 0b9c580af988..2eff989c6d9f 100644
--- a/drivers/net/wireless/marvell/mwifiex/debugfs.c
+++ b/drivers/net/wireless/marvell/mwifiex/debugfs.c
@@ -880,14 +880,12 @@ mwifiex_reset_write(struct file *file,
 {
 	struct mwifiex_private *priv = file->private_data;
 	struct mwifiex_adapter *adapter = priv->adapter;
-	char cmd;
 	bool result;
+	int rc;
 
-	if (copy_from_user(&cmd, ubuf, sizeof(cmd)))
-		return -EFAULT;
-
-	if (strtobool(&cmd, &result))
-		return -EINVAL;
+	rc = kstrtobool_from_user(ubuf, count, &result);
+	if (rc)
+		return rc;
 
 	if (!result)
 		return -EINVAL;
diff --git a/fs/cifs/cifs_debug.c b/fs/cifs/cifs_debug.c
index 50b268483302..788e19195991 100644
--- a/fs/cifs/cifs_debug.c
+++ b/fs/cifs/cifs_debug.c
@@ -255,7 +255,6 @@ static const struct file_operations cifs_debug_data_proc_fops = {
 static ssize_t cifs_stats_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
-	char c;
 	bool bv;
 	int rc;
 	struct list_head *tmp1, *tmp2, *tmp3;
@@ -263,11 +262,8 @@ static ssize_t cifs_stats_proc_write(struct file *file,
 	struct cifs_ses *ses;
 	struct cifs_tcon *tcon;
 
-	rc = get_user(c, buffer);
-	if (rc)
-		return rc;
-
-	if (strtobool(&c, &bv) == 0) {
+	rc = kstrtobool_from_user(buffer, count, &bv);
+	if (rc == 0) {
 #ifdef CONFIG_CIFS_STATS2
 		atomic_set(&totBufAllocCount, 0);
 		atomic_set(&totSmBufAllocCount, 0);
@@ -290,6 +286,8 @@ static ssize_t cifs_stats_proc_write(struct file *file,
 			}
 		}
 		spin_unlock(&cifs_tcp_ses_lock);
+	} else {
+		return rc;
 	}
 
 	return count;
@@ -433,17 +431,17 @@ static int cifsFYI_proc_open(struct inode *inode, struct file *file)
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
@@ -471,20 +469,12 @@ static int cifs_linux_ext_proc_open(struct inode *inode, struct file *file)
 static ssize_t cifs_linux_ext_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
-	char c;
-	bool bv;
 	int rc;
 
-	rc = get_user(c, buffer);
+	rc = kstrtobool_from_user(buffer, count, &linuxExtEnabled);
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
 
@@ -511,20 +501,12 @@ static int cifs_lookup_cache_proc_open(struct inode *inode, struct file *file)
 static ssize_t cifs_lookup_cache_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *ppos)
 {
-	char c;
-	bool bv;
 	int rc;
 
-	rc = get_user(c, buffer);
+	rc = kstrtobool_from_user(buffer, count, &lookupCacheEnabled);
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
 
@@ -551,20 +533,12 @@ static int traceSMB_proc_open(struct inode *inode, struct file *file)
 static ssize_t traceSMB_proc_write(struct file *file, const char __user *buffer,
 		size_t count, loff_t *ppos)
 {
-	char c;
-	bool bv;
 	int rc;
 
-	rc = get_user(c, buffer);
+	rc = kstrtobool_from_user(buffer, count, &traceSMB);
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
 
@@ -622,7 +596,6 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
 	int rc;
 	unsigned int flags;
 	char flags_string[12];
-	char c;
 	bool bv;
 
 	if ((count < 1) || (count > 11))
@@ -635,11 +608,10 @@ static ssize_t cifs_security_flags_proc_write(struct file *file,
 
 	if (count < 3) {
 		/* single char or single char followed by null */
-		c = flags_string[0];
-		if (strtobool(&c, &bv) == 0) {
+		if (strtobool(flags_string, &bv) == 0) {
 			global_secflags = bv ? CIFSSEC_MAX : CIFSSEC_DEF;
 			return count;
-		} else if (!isdigit(c)) {
+		} else if (!isdigit(flags_string[0])) {
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
