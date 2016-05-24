From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RESEND 7/8] pipe: account to kmemcg
Date: Tue, 24 May 2016 05:59:02 -0700
Message-ID: <1464094742.5939.46.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
	 <2c2545563b6201f118946f96dd8cfc90e564aff6.1464079538.git.vdavydov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro
 <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal
 Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org,  netdev@vger.kernel.org, x86@kernel.org,
 linux-kernel@vger.kernel.org
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <2c2545563b6201f118946f96dd8cfc90e564aff6.1464079538.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-24 at 11:49 +0300, Vladimir Davydov wrote:
> Pipes can consume a significant amount of system memory, hence they
> should be accounted to kmemcg.
> 
> This patch marks pipe_inode_info and anonymous pipe buffer page
> allocations as __GFP_ACCOUNT so that they would be charged to kmemcg.
> Note, since a pipe buffer page can be "stolen" and get reused for other
> purposes, including mapping to userspace, we clear PageKmemcg thus
> resetting page->_mapcount and uncharge it in anon_pipe_buf_steal, which
> is introduced by this patch.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> ---
>  fs/pipe.c | 32 ++++++++++++++++++++++++++------
>  1 file changed, 26 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/pipe.c b/fs/pipe.c
> index 0d3f5165cb0b..4b32928f5426 100644
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -21,6 +21,7 @@
>  #include <linux/audit.h>
>  #include <linux/syscalls.h>
>  #include <linux/fcntl.h>
> +#include <linux/memcontrol.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/ioctls.h>
> @@ -137,6 +138,22 @@ static void anon_pipe_buf_release(struct pipe_inode_info *pipe,
>  		put_page(page);
>  }
>  
> +static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
> +			       struct pipe_buffer *buf)
> +{
> +	struct page *page = buf->page;
> +
> +	if (page_count(page) == 1) {

This looks racy : some cpu could have temporarily elevated page count.

> +		if (memcg_kmem_enabled()) {
> +			memcg_kmem_uncharge(page, 0);
> +			__ClearPageKmemcg(page);
> +		}
> +		__SetPageLocked(page);
> +		return 0;
> +	}
> +	return 1;
> +}
> +




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
