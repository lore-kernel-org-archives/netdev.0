From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH v3 6/7] fs: struct file move from call_rcu() to SLAB_DESTROY_BY_RCU
Date: Tue, 24 Jul 2007 11:13:45 +1000
Message-ID: <200707241113.46834.nickpiggin@yahoo.com.au>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com> <494196DD.5070600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"kernel-testers@vger.kernel.org >> Kernel Testers List"
	<kernel-testers@vger.kernel.org>, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <494196DD.5070600@cosmosbay.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 12 December 2008 09:40, Eric Dumazet wrote:
> From: Christoph Lameter <cl@linux-foundation.org>
>
> [PATCH] fs: struct file move from call_rcu() to SLAB_DESTROY_BY_RCU
>
> Currently we schedule RCU frees for each file we free separately. That has
> several drawbacks against the earlier file handling (in 2.6.5 f.e.), which
> did not require RCU callbacks:
>
> 1. Excessive number of RCU callbacks can be generated causing long RCU
>   queues that in turn cause long latencies. We hit SLUB page allocation
>   more often than necessary.
>
> 2. The cache hot object is not preserved between free and realloc. A close
>   followed by another open is very fast with the RCUless approach because
>   the last freed object is returned by the slab allocator that is
>   still cache hot. RCU free means that the object is not immediately
>   available again. The new object is cache cold and therefore open/close
>   performance tests show a significant degradation with the RCU
>   implementation.
>
> One solution to this problem is to move the RCU freeing into the Slab
> allocator by specifying SLAB_DESTROY_BY_RCU as an option at slab creation
> time. The slab allocator will do RCU frees only when it is necessary
> to dispose of slabs of objects (rare). So with that approach we can cut
> out the RCU overhead significantly.
>
> However, the slab allocator may return the object for another use even
> before the RCU period has expired under SLAB_DESTROY_BY_RCU. This means
> there is the (unlikely) possibility that the object is going to be
> switched under us in sections protected by rcu_read_lock() and
> rcu_read_unlock(). So we need to verify that we have acquired the correct
> object after establishing a stable object reference (incrementing the
> refcounter does that).
>
>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
>  Documentation/filesystems/files.txt |   21 ++++++++++++++--
>  fs/file_table.c                     |   33 ++++++++++++++++++--------
>  include/linux/fs.h                  |    5 ---
>  3 files changed, 42 insertions(+), 17 deletions(-)
>
> diff --git a/Documentation/filesystems/files.txt
> b/Documentation/filesystems/files.txt index ac2facc..6916baa 100644
> --- a/Documentation/filesystems/files.txt
> +++ b/Documentation/filesystems/files.txt
> @@ -78,13 +78,28 @@ the fdtable structure -
>     that look-up may race with the last put() operation on the
>     file structure. This is avoided using atomic_long_inc_not_zero()
>     on ->f_count :
> +   As file structures are allocated with SLAB_DESTROY_BY_RCU,
> +   they can also be freed before a RCU grace period, and reused,
> +   but still as a struct file.
> +   It is necessary to check again after getting
> +   a stable reference (ie after atomic_long_inc_not_zero()),
> +   that fcheck_files(files, fd) points to the same file.
>
>  	rcu_read_lock();
>  	file = fcheck_files(files, fd);
>  	if (file) {
> -		if (atomic_long_inc_not_zero(&file->f_count))
> +		if (atomic_long_inc_not_zero(&file->f_count)) {
>  			*fput_needed = 1;
> -		else
> +			/*
> +			 * Now we have a stable reference to an object.
> +			 * Check if other threads freed file and reallocated it.
> +			 */
> +			if (file != fcheck_files(files, fd)) {
> +				*fput_needed = 0;
> +				put_filp(file);
> +				file = NULL;
> +			}
> +		} else
>  		/* Didn't get the reference, someone's freed */
>  			file = NULL;
>  	}
> @@ -95,6 +110,8 @@ the fdtable structure -
>     atomic_long_inc_not_zero() detects if refcounts is already zero or
>     goes to zero during increment. If it does, we fail
>     fget()/fget_light().
> +   The second call to fcheck_files(files, fd) checks that this filp
> +   was not freed, then reused by an other thread.
>
>  6. Since both fdtable and file structures can be looked up
>     lock-free, they must be installed using rcu_assign_pointer()
> diff --git a/fs/file_table.c b/fs/file_table.c
> index a46e880..3e9259d 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -37,17 +37,11 @@ static struct kmem_cache *filp_cachep __read_mostly;
>
>  static struct percpu_counter nr_files __cacheline_aligned_in_smp;
>
> -static inline void file_free_rcu(struct rcu_head *head)
> -{
> -	struct file *f =  container_of(head, struct file, f_u.fu_rcuhead);
> -	kmem_cache_free(filp_cachep, f);
> -}
> -
>  static inline void file_free(struct file *f)
>  {
>  	percpu_counter_dec(&nr_files);
>  	file_check_state(f);
> -	call_rcu(&f->f_u.fu_rcuhead, file_free_rcu);
> +	kmem_cache_free(filp_cachep, f);
>  }
>
>  /*
> @@ -306,6 +300,14 @@ struct file *fget(unsigned int fd)
>  			rcu_read_unlock();
>  			return NULL;
>  		}
> +		/*
> +		 * Now we have a stable reference to an object.
> +		 * Check if other threads freed file and re-allocated it.
> +		 */
> +		if (unlikely(file != fcheck_files(files, fd))) {
> +			put_filp(file);
> +			file = NULL;
> +		}

This is a non-trivial change, because that put_filp may drop the last
reference to the file. So now we have the case where we free the file
from a context in which it had never been allocated.

>From a quick glance though the callchains, I can't seen an obvious
problem. But it needs to have documentation in put_filp, or at least
a mention in the changelog, and also cc'ed to the security lists.

Also, it adds code and cost to the get/put path in return for
improvement in the free path. get/put is the more common path, but
it is a small loss for a big improvement. So it might be worth it. But
it is not justified by your microbenchmark. Do we have a more useful
case that it helps?
