From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 5/5] tun: vringfd xmit support.
Date: Sat, 19 Apr 2008 01:15:15 +1000
Message-ID: <200804190115.15983.rusty@rustcorp.com.au>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181443.24812.rusty@rustcorp.com.au>
	<20080418043120.ff78eab5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20080418043120.ff78eab5.akpm@linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Friday 18 April 2008 21:31:20 Andrew Morton wrote:
> On Fri, 18 Apr 2008 14:43:24 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
> > +		/* How many pages will this take? */
> > +		npages = 1 + (base + len - 1)/PAGE_SIZE - base/PAGE_SIZE;
>
> Brain hurts.  I hope you got that right.

I tested it when I wrote it, but just wrote a tester again:

base		len	npages
0               1       1
0xfff           1       1
0x1000          1       1
0               4096    1
0x1             4096    2
0xfff           4096    2
0x1000          4096    1
0xfffff000      4096    1
0xfffff000      4097    4293918722

> > +		if (unlikely(num_pg + npages > MAX_SKB_FRAGS)) {
> > +			err = -ENOSPC;
> > +			goto fail;
> > +		}
> > +		n = get_user_pages(current, current->mm, base, npages,
> > +				   0, 0, pages, NULL);
>
> What is the maximum numbet of pages which an unpriviliged user can
> concurrently pin with this code?

Since only root can open the tun device, it's currently OK.  The old code
kmalloced and copied: is there some mm-fu reason why pinning userspace memory
is worse?

But I actually think it's OK even for non-root, since these become skbs, which
means they either go into an outgoing device queue or a socket queue which is
accounted for exactly for this reason. 

> > +		if (unlikely(n < 0)) {
> > +			err = n;
> > +			goto fail;
> > +		}
> > +
> > +		/* Transfer pages to the frag array */
> > +		for (j = 0; j < n; j++) {
> > +			f[num_pg].page = pages[j];
> > +			if (j == 0) {
> > +				f[num_pg].page_offset = offset_in_page(base);
> > +				f[num_pg].size = min(len, PAGE_SIZE -
> > +						     f[num_pg].page_offset);
> > +			} else {
> > +				f[num_pg].page_offset = 0;
> > +				f[num_pg].size = min(len, PAGE_SIZE);
> > +			}
> > +			len -= f[num_pg].size;
> > +			base += f[num_pg].size;
> > +			num_pg++;
> > +		}
>
> This loop is a fancy way of doing
>
> 		num_pg = n;

Damn, you had me reworking this until I realized why.  It's not: we're
inside a loop, doing one iovec array element at a time.

> > +		if (unlikely(n != npages)) {
> > +			err = -EFAULT;
> > +			goto fail;
> > +		}
>
> why not do this immediately after running get_user_pages()?

To simplify the failure path.  Hmm, I would use release_pages here...

> > +fail:
> > +	for (i = 0; i < num_pg; i++)
> > +		put_page(f[i].page);
>
> release_pages() could be a tad more efficient, but it's only error-path.

... but I didn't know that existed.  Had to include pagemap.h, and it's not
exported.  It seems to be a useful interface; see patch.

Cheers,
Rusty.

Subject: Export release_pages; nice undo for get_user_pages.

Andrew Morton suggests tun/tap use release_pages, but it's not
exported.  It's not clear to me why this is in swap.c, but it exists
even without CONFIG_SWAP, so that's OK.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r abd2ad431e5c mm/swap.c
--- a/mm/swap.c	Sat Apr 19 00:34:54 2008 +1000
+++ b/mm/swap.c	Sat Apr 19 01:11:40 2008 +1000
@@ -346,6 +346,7 @@ void release_pages(struct page **pages, 
 
 	pagevec_free(&pages_to_free);
 }
+EXPORT_SYMBOL(release_pages);
 
 /*
  * The pages which we're about to release may be in the deferred lru-addition
