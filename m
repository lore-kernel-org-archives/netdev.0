From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] tun: vringfd xmit support.
Date: Fri, 18 Apr 2008 04:31:20 -0700
Message-ID: <20080418043120.ff78eab5.akpm@linux-foundation.org>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181441.10499.rusty@rustcorp.com.au>
	<200804181442.17251.rusty@rustcorp.com.au>
	<200804181443.24812.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200804181443.24812.rusty@rustcorp.com.au>
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

On Fri, 18 Apr 2008 14:43:24 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:

> This patch modifies tun to allow a vringfd to specify the send
> buffer.  The user does a write to push out packets from the buffer.
> 
> Again we use the 'struct virtio_net_hdr' to allow userspace to send
> GSO packets.  In this case, it can hint how much to copy, and the
> other pages will be made into skb fragments.
> 
> 
> ...
>
> +/* We don't consolidate consecutive iovecs, so huge iovecs can break here.
> + * Users will learn not to do that. */
> +static int get_user_skb_frags(const struct iovec *iv, size_t len,
> +			      struct skb_frag_struct *f)
> +{
> +	unsigned int i, j, num_pg = 0;
> +	int err;
> +	struct page *pages[MAX_SKB_FRAGS];
> +
> +	down_read(&current->mm->mmap_sem);
> +	while (len) {
> +		int n, npages;
> +		unsigned long base, len;
> +		base = (unsigned long)iv->iov_base;
> +		len = (unsigned long)iv->iov_len;
> +
> +		if (len == 0) {
> +			iv++;
> +			continue;
> +		}
> +
> +		/* How many pages will this take? */
> +		npages = 1 + (base + len - 1)/PAGE_SIZE - base/PAGE_SIZE;

Brain hurts.  I hope you got that right.

> +		if (unlikely(num_pg + npages > MAX_SKB_FRAGS)) {
> +			err = -ENOSPC;
> +			goto fail;
> +		}
> +		n = get_user_pages(current, current->mm, base, npages,
> +				   0, 0, pages, NULL);

What is the maximum numbet of pages which an unpriviliged user can
concurrently pin with this code?

> +		if (unlikely(n < 0)) {
> +			err = n;
> +			goto fail;
> +		}
> +
> +		/* Transfer pages to the frag array */
> +		for (j = 0; j < n; j++) {
> +			f[num_pg].page = pages[j];
> +			if (j == 0) {
> +				f[num_pg].page_offset = offset_in_page(base);
> +				f[num_pg].size = min(len, PAGE_SIZE -
> +						     f[num_pg].page_offset);
> +			} else {
> +				f[num_pg].page_offset = 0;
> +				f[num_pg].size = min(len, PAGE_SIZE);
> +			}
> +			len -= f[num_pg].size;
> +			base += f[num_pg].size;
> +			num_pg++;
> +		}

This loop is a fancy way of doing

		num_pg = n;

> +		if (unlikely(n != npages)) {
> +			err = -EFAULT;
> +			goto fail;
> +		}

why not do this immediately after running get_user_pages()?

> +	}
> +	up_read(&current->mm->mmap_sem);
> +	return num_pg;
> +
> +fail:
> +	for (i = 0; i < num_pg; i++)
> +		put_page(f[i].page);

release_pages() could be a tad more efficient, but it's only error-path.

> +	up_read(&current->mm->mmap_sem);
> +	return err;
> +}
> +
>  
