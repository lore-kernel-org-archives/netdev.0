From: Dave Kleikamp <dave.kleikamp@oracle.com>
Subject: Re: [PATCH v3 09/31] jfs: Define usercopy region in jfs_ip slab cache
Date: Thu, 21 Sep 2017 21:54:55 -0500
Message-ID: <0132ff58-f18b-6d67-8edd-fa6bd1f6927b@oracle.com>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
 <1505940337-79069-10-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Windsor <dave@nullcore.net>, jfs-discussion@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        linux-mm@kvack.org, kernel-hardening@lists.openwall.com
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1505940337-79069-10-git-send-email-keescook@chromium.org>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Acked-by: Dave Kleikamp <dave.kleikamp@oracle.com>

On 09/20/2017 03:45 PM, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
> 
> The jfs symlink pathnames, stored in struct jfs_inode_info.i_inline and
> therefore contained in the jfs_ip slab cache, need to be copied to/from
> userspace.
> 
> cache object allocation:
>     fs/jfs/super.c:
>         jfs_alloc_inode(...):
>             ...
>             jfs_inode = kmem_cache_alloc(jfs_inode_cachep, GFP_NOFS);
>             ...
>             return &jfs_inode->vfs_inode;
> 
>     fs/jfs/jfs_incore.h:
>         JFS_IP(struct inode *inode):
>             return container_of(inode, struct jfs_inode_info, vfs_inode);
> 
>     fs/jfs/inode.c:
>         jfs_iget(...):
>             ...
>             inode->i_link = JFS_IP(inode)->i_inline;
> 
> example usage trace:
>     readlink_copy+0x43/0x70
>     vfs_readlink+0x62/0x110
>     SyS_readlinkat+0x100/0x130
> 
>     fs/namei.c:
>         readlink_copy(..., link):
>             ...
>             copy_to_user(..., link, len);
> 
>         (inlined in vfs_readlink)
>         generic_readlink(dentry, ...):
>             struct inode *inode = d_inode(dentry);
>             const char *link = inode->i_link;
>             ...
>             readlink_copy(..., link);
> 
> In support of usercopy hardening, this patch defines a region in the
> jfs_ip slab cache in which userspace copy operations are allowed.
> 
> This region is known as the slab cache's usercopy region. Slab caches can
> now check that each copy operation involving cache-managed memory falls
> entirely within the slab's usercopy region.
> 
> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
> whitelisting code in the last public patch of grsecurity/PaX based on my
> understanding of the code. Changes or omissions from the original code are
> mine and don't reflect the original grsecurity/PaX code.
> 
> Signed-off-by: David Windsor <dave@nullcore.net>
> [kees: adjust commit log, provide usage trace]
> Cc: Dave Kleikamp <shaggy@kernel.org>
> Cc: jfs-discussion@lists.sourceforge.net
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  fs/jfs/super.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/jfs/super.c b/fs/jfs/super.c
> index 2f14677169c3..e018412608d4 100644
> --- a/fs/jfs/super.c
> +++ b/fs/jfs/super.c
> @@ -966,9 +966,11 @@ static int __init init_jfs_fs(void)
>  	int rc;
>  
>  	jfs_inode_cachep =
> -	    kmem_cache_create("jfs_ip", sizeof(struct jfs_inode_info), 0,
> -			    SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
> -			    init_once);
> +	    kmem_cache_create_usercopy("jfs_ip", sizeof(struct jfs_inode_info),
> +			0, SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
> +			offsetof(struct jfs_inode_info, i_inline),
> +			sizeof_field(struct jfs_inode_info, i_inline),
> +			init_once);
>  	if (jfs_inode_cachep == NULL)
>  		return -ENOMEM;
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
