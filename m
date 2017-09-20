From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 04/31] dcache: Define usercopy region in dentry_cache slab cache
Date: Wed, 20 Sep 2017 13:45:10 -0700
Message-ID: <1505940337-79069-5-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        David Windsor <dave@nullcore.net>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        linux-mm@kvack.org, kernel-hardening@lists.openwall.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Windsor <dave@nullcore.net>

When a dentry name is short enough, it can be stored directly in the
dentry itself (instead in a separate kmalloc allocation). These dentry
short names, stored in struct dentry.d_iname and therefore contained in
the dentry_cache slab cache, need to be coped to userspace.

cache object allocation:
    fs/dcache.c:
        __d_alloc(...):
            ...
            dentry = kmem_cache_alloc(dentry_cache, ...);
            ...
            dentry->d_name.name = dentry->d_iname;

example usage trace:
    filldir+0xb0/0x140
    dcache_readdir+0x82/0x170
    iterate_dir+0x142/0x1b0
    SyS_getdents+0xb5/0x160

    fs/readdir.c:
        (called via ctx.actor by dir_emit)
        filldir(..., const char *name, ...):
            ...
            copy_to_user(..., name, namlen)

    fs/libfs.c:
        dcache_readdir(...):
            ...
            next = next_positive(dentry, p, 1)
            ...
            dir_emit(..., next->d_name.name, ...)

In support of usercopy hardening, this patch defines a region in the
dentry_cache slab cache in which userspace copy operations are allowed.

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust hunks for kmalloc-specific things moved later]
[kees: adjust commit log, provide usage trace]
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/dcache.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index f90141387f01..5f5e7c1fcf4b 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3603,8 +3603,9 @@ static void __init dcache_init(void)
 	 * but it is probably not worth it because of the cache nature
 	 * of the dcache.
 	 */
-	dentry_cache = KMEM_CACHE(dentry,
-		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT);
+	dentry_cache = KMEM_CACHE_USERCOPY(dentry,
+		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
+		d_iname);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
-- 
2.7.4
