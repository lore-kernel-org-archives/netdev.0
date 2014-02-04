From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
Date: Tue, 4 Feb 2014 10:25:33 -0800
Message-ID: <CAHA+R7OLnrujsinNhwVvZyJDz+BrTxYmw0gWeSSyq+dJ2LF9qg@mail.gmail.com>
References: <87r47jsb2p.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <87r47jsb2p.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 3, 2014 at 9:26 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> diff --git a/fs/file.c b/fs/file.c
> index 771578b33fb6..db25c2bdfe46 100644
> --- a/fs/file.c
> +++ b/fs/file.c
> @@ -34,7 +34,7 @@ static void *alloc_fdmem(size_t size)
>          * vmalloc() if the allocation size will be considered "large" by the VM.
>          */
>         if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> -               void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
> +               void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY);
>                 if (data != NULL)
>                         return data;
>         }

Or try again without __GFP_NORETRY like we do in nelink mmap?

diff --git a/fs/file.c b/fs/file.c
index 771578b..5c7a7b5 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -29,16 +29,20 @@ int sysctl_nr_open_max = 1024 * 1024; /* raised later */

 static void *alloc_fdmem(size_t size)
 {
+       void *data;
        /*
         * Very large allocations can stress page reclaim, so fall back to
         * vmalloc() if the allocation size will be considered "large"
by the VM.
         */
        if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
-               void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
+               data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY);
                if (data != NULL)
                        return data;
        }
-       return vmalloc(size);
+       data = vmalloc(size);
+       if (data != NULL)
+               return data;
+       return kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
 }

 static void free_fdmem(void *ptr)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
