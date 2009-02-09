From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [9/9] pohmelfs: kconfig/makefile and vfs changes.
Date: Mon,  9 Feb 2009 17:02:42 +0300
Message-ID: <1234188162-14727-10-git-send-email-zbr@ioremap.net>
References: <1234188162-14727-1-git-send-email-zbr@ioremap.net>
 <1234188162-14727-2-git-send-email-zbr@ioremap.net>
 <1234188162-14727-3-git-send-email-zbr@ioremap.net>
 <1234188162-14727-4-git-send-email-zbr@ioremap.net>
 <1234188162-14727-5-git-send-email-zbr@ioremap.net>
 <1234188162-14727-6-git-send-email-zbr@ioremap.net>
 <1234188162-14727-7-git-send-email-zbr@ioremap.net>
 <1234188162-14727-8-git-send-email-zbr@ioremap.net>
 <1234188162-14727-9-git-send-email-zbr@ioremap.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: GregKH <greg@kroah.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1234188162-14727-9-git-send-email-zbr@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds Kconfig and Makefile entries and exports to
VFS functions to be used by POHMELFS.

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/mm/filemap.c b/mm/filemap.c
index f3e5f89..3f77548 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -513,6 +513,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 	}
 	return ret;
 }
+EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
 struct page *__page_cache_alloc(gfp_t gfp)
@@ -627,6 +628,7 @@ int __lock_page_killable(struct page *page)
 	return __wait_on_bit_lock(page_waitqueue(page), &wait,
 					sync_page_killable, TASK_KILLABLE);
 }
+EXPORT_SYMBOL_GPL(__lock_page_killable);
 
 /**
  * __lock_page_nosync - get a lock on the page, without calling sync_page()


diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 5d457c9..a089649 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -41,6 +41,8 @@ config STAGING_EXCLUDE_BUILD
 
 if !STAGING_EXCLUDE_BUILD
 
+source "drivers/staging/pohmelfs/Kconfig"
+
 source "drivers/staging/et131x/Kconfig"
 
 source "drivers/staging/slicoss/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 71c4d53..631ce75 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -3,6 +3,7 @@
 # fix for build system bug...
 obj-$(CONFIG_STAGING)		+= staging.o
 
+obj-$(CONFIG_POHMELFS)		+= pohmelfs/
 obj-$(CONFIG_ET131X)		+= et131x/
 obj-$(CONFIG_SLICOSS)		+= slicoss/
 obj-$(CONFIG_SXG)		+= sxg/
diff --git a/drivers/staging/pohmelfs/Makefile b/drivers/staging/pohmelfs/Makefile
new file mode 100644
index 0000000..196561c
--- /dev/null
+++ b/drivers/staging/pohmelfs/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_POHMELFS)	+= pohmelfs.o
+
+pohmelfs-y := inode.o config.o dir.o net.o path_entry.o trans.o crypto.o lock.o mcache.o
diff --git a/drivers/staging/pohmelfs/Kconfig b/drivers/staging/pohmelfs/Kconfig
new file mode 100644
index 0000000..82d13ad
--- /dev/null
+++ b/drivers/staging/pohmelfs/Kconfig
@@ -0,0 +1,23 @@
+config POHMELFS
+	tristate "POHMELFS filesystem support"
+	select CONNECTOR
+	help
+	  POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.
+	  This is a network filesystem which supports coherent caching of data and metadata
+	  on clients.
+
+config POHMELFS_DEBUG
+	bool "POHMELFS debugging"
+	depends on POHMELFS
+	default n
+	help
+	  Turns on excessive POHMELFS debugging facilities.
+	  You usually do not want to slow things down noticebly and get really lots of kernel
+	  messages in syslog.
+
+config POHMELFS_CRYPTO
+	bool "POHMELFS crypto support"
+	depends on CONFIG_CRYPTO_BLKCIPHER && CONFIG_CRYPTO_HASH
+	help
+	  This option allows to encrypt and/or protect with strong cryptographic hash all dataflow
+	  between server and clients. Each config group can have own keys.
