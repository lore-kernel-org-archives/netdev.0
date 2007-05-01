From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/2] AFS/AF_RXRPC: Miscellaneous fixes
Date: Tue, 01 May 2007 18:47:52 +0100
Message-ID: <20070501174752.19112.82814.stgit@warthog.cambridge.redhat.com>
References: <20070501174747.19112.1985.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, geert@linux-m68k.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070501174747.19112.1985.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make miscellaneous fixes to AFS and AF_RXRPC:

 (*) Make AF_RXRPC select KEYS rather than RXKAD or AFS_FS in Kconfig.

 (*) Don't use FS_BINARY_MOUNTDATA.

 (*) Remove a done 'TODO' item in a comemnt on afs_get_sb().

 (*) Don't pass a void * as the page pointer argument of kmap_atomic() as this
     breaks on m68k.  Patch from Geert Uytterhoeven <geert@linux-m68k.org>.

 (*) Use match_*() functions rather than doing my own parsing.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/Kconfig        |    1 -
 fs/afs/fsclient.c |    3 +-
 fs/afs/super.c    |  100 +++++++++++++++++++++++------------------------------
 net/rxrpc/Kconfig |    3 +-
 4 files changed, 47 insertions(+), 60 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index a42f767..e33c089 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -2020,7 +2020,6 @@ config AFS_FS
 	tristate "Andrew File System support (AFS) (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
 	select AF_RXRPC
-	select KEYS
 	help
 	  If you say Y here, you will get an experimental Andrew File System
 	  driver. It currently only supports unsecured read-only AFS access.
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 2393d2a..e54e6c2 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -266,7 +266,8 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call,
 		call->unmarshall++;
 
 		if (call->count < PAGE_SIZE) {
-			buffer = kmap_atomic(call->reply3, KM_USER0);
+			page = call->reply3;
+			buffer = kmap_atomic(page, KM_USER0);
 			memset(buffer + PAGE_SIZE - call->count, 0,
 			       call->count);
 			kunmap_atomic(buffer, KM_USER0);
diff --git a/fs/afs/super.c b/fs/afs/super.c
index cebd03c..41173f8 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -20,6 +20,7 @@
 #include <linux/slab.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
+#include <linux/parser.h>
 #include "internal.h"
 
 #define AFS_FS_MAGIC 0x6B414653 /* 'kAFS' */
@@ -42,7 +43,7 @@ struct file_system_type afs_fs_type = {
 	.name		= "afs",
 	.get_sb		= afs_get_sb,
 	.kill_sb	= kill_anon_super,
-	.fs_flags	= FS_BINARY_MOUNTDATA,
+	.fs_flags	= 0,
 };
 
 static const struct super_operations afs_super_ops = {
@@ -58,6 +59,20 @@ static const struct super_operations afs_super_ops = {
 static struct kmem_cache *afs_inode_cachep;
 static atomic_t afs_count_active_inodes;
 
+enum {
+	afs_no_opt,
+	afs_opt_cell,
+	afs_opt_rwpath,
+	afs_opt_vol,
+};
+
+static const match_table_t afs_options_list = {
+	{ afs_opt_cell,		"cell=%s"	},
+	{ afs_opt_rwpath,	"rwpath"	},
+	{ afs_opt_vol,		"vol=%s"	},
+	{ afs_no_opt,		NULL		},
+};
+
 /*
  * initialise the filesystem
  */
@@ -115,31 +130,6 @@ void __exit afs_fs_exit(void)
 }
 
 /*
- * check that an argument has a value
- */
-static int want_arg(char **_value, const char *option)
-{
-	if (!_value || !*_value || !**_value) {
-		printk(KERN_NOTICE "kAFS: %s: argument missing\n", option);
-		return 0;
-	}
-	return 1;
-}
-
-/*
- * check that there's no subsequent value
- */
-static int want_no_value(char *const *_value, const char *option)
-{
-	if (*_value && **_value) {
-		printk(KERN_NOTICE "kAFS: %s: Invalid argument: %s\n",
-		       option, *_value);
-		return 0;
-	}
-	return 1;
-}
-
-/*
  * parse the mount options
  * - this function has been shamelessly adapted from the ext3 fs which
  *   shamelessly adapted it from the msdos fs
@@ -148,48 +138,46 @@ static int afs_parse_options(struct afs_mount_params *params,
 			     char *options, const char **devname)
 {
 	struct afs_cell *cell;
-	char *key, *value;
-	int ret;
+	substring_t args[MAX_OPT_ARGS];
+	char *p;
+	int token;
 
 	_enter("%s", options);
 
 	options[PAGE_SIZE - 1] = 0;
 
-	ret = 0;
-	while ((key = strsep(&options, ","))) {
-		value = strchr(key, '=');
-		if (value)
-			*value++ = 0;
-
-		_debug("kAFS: KEY: %s, VAL:%s", key, value ?: "-");
+	while ((p = strsep(&options, ","))) {
+		if (!*p)
+			continue;
 
-		if (strcmp(key, "rwpath") == 0) {
-			if (!want_no_value(&value, "rwpath"))
-				return -EINVAL;
-			params->rwpath = 1;
-		} else if (strcmp(key, "vol") == 0) {
-			if (!want_arg(&value, "vol"))
-				return -EINVAL;
-			*devname = value;
-		} else if (strcmp(key, "cell") == 0) {
-			if (!want_arg(&value, "cell"))
-				return -EINVAL;
-			cell = afs_cell_lookup(value, strlen(value));
+		token = match_token(p, afs_options_list, args);
+		switch (token) {
+		case afs_opt_cell:
+			cell = afs_cell_lookup(args[0].from,
+					       args[0].to - args[0].from);
 			if (IS_ERR(cell))
 				return PTR_ERR(cell);
 			afs_put_cell(params->cell);
 			params->cell = cell;
-		} else {
-			printk("kAFS: Unknown mount option: '%s'\n",  key);
-			ret = -EINVAL;
-			goto error;
+			break;
+
+		case afs_opt_rwpath:
+			params->rwpath = 1;
+			break;
+
+		case afs_opt_vol:
+			*devname = args[0].from;
+			break;
+
+		default:
+			printk(KERN_ERR "kAFS:"
+			       " Unknown or invalid mount option: '%s'\n", p);
+			return -EINVAL;
 		}
 	}
 
-	ret = 0;
-error:
-	_leave(" = %d", ret);
-	return ret;
+	_leave(" = 0");
+	return 0;
 }
 
 /*
@@ -361,7 +349,6 @@ error:
 
 /*
  * get an AFS superblock
- * - TODO: don't use get_sb_nodev(), but rather call sget() directly
  */
 static int afs_get_sb(struct file_system_type *fs_type,
 		      int flags,
@@ -386,7 +373,6 @@ static int afs_get_sb(struct file_system_type *fs_type,
 			goto error;
 	}
 
-
 	ret = afs_parse_device_name(&params, dev_name);
 	if (ret < 0)
 		goto error;
diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index 8750f6d..91b3d52 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -5,6 +5,7 @@
 config AF_RXRPC
 	tristate "RxRPC session sockets"
 	depends on EXPERIMENTAL
+	select KEYS
 	help
 	  Say Y or M here to include support for RxRPC session sockets (just
 	  the transport part, not the presentation part: (un)marshalling is
@@ -29,7 +30,7 @@ config AF_RXRPC_DEBUG
 
 config RXKAD
 	tristate "RxRPC Kerberos security"
-	depends on AF_RXRPC && KEYS
+	depends on AF_RXRPC
 	select CRYPTO
 	select CRYPTO_MANAGER
 	select CRYPTO_BLKCIPHER

