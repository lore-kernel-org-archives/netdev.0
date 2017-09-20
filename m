From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 14/31] vxfs: Define usercopy region in vxfs_inode slab cache
Date: Wed, 20 Sep 2017 13:45:20 -0700
Message-ID: <1505940337-79069-15-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
	David Windsor <dave@nullcore.net>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-mm@kvack.org,
	kernel-hardening@lists.openwall.com
To: linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: David Windsor <dave@nullcore.net>

vxfs symlink pathnames, stored in struct vxfs_inode_info field
vii_immed.vi_immed and therefore contained in the vxfs_inode slab cache,
need to be copied to/from userspace.

cache object allocation:
    fs/freevxfs/vxfs_super.c:
        vxfs_alloc_inode(...):
            ...
            vi = kmem_cache_alloc(vxfs_inode_cachep, GFP_KERNEL);
            ...
            return &vi->vfs_inode;

    fs/freevxfs/vxfs_inode.c:
        cxfs_iget(...):
            ...
            inode->i_link = vip->vii_immed.vi_immed;

example usage trace:
    readlink_copy+0x43/0x70
    vfs_readlink+0x62/0x110
    SyS_readlinkat+0x100/0x130

    fs/namei.c:
        readlink_copy(..., link):
            ...
            copy_to_user(..., link, len);

        (inlined in vfs_readlink)
        generic_readlink(dentry, ...):
            struct inode *inode = d_inode(dentry);
            const char *link = inode->i_link;
            ...
            readlink_copy(..., link);

In support of usercopy hardening, this patch defines a region in the
vxfs_inode slab cache in which userspace copy operations are allowed.

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, provide usage trace]
Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/freevxfs/vxfs_super.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/freevxfs/vxfs_super.c b/fs/freevxfs/vxfs_super.c
index 455ce5b77e9b..c143e18d5a65 100644
--- a/fs/freevxfs/vxfs_super.c
+++ b/fs/freevxfs/vxfs_super.c
@@ -332,9 +332,13 @@ vxfs_init(void)
 {
 	int rv;
 
-	vxfs_inode_cachep = kmem_cache_create("vxfs_inode",
+	vxfs_inode_cachep = kmem_cache_create_usercopy("vxfs_inode",
 			sizeof(struct vxfs_inode_info), 0,
-			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD, NULL);
+			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
+			offsetof(struct vxfs_inode_info, vii_immed.vi_immed),
+			sizeof_field(struct vxfs_inode_info,
+				vii_immed.vi_immed),
+			NULL);
 	if (!vxfs_inode_cachep)
 		return -ENOMEM;
 	rv = register_filesystem(&vxfs_fs_type);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
