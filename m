From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v7 13/16] lockd: use new hashtable implementation
Date: Mon, 29 Oct 2012 09:23:23 -0400
Message-ID: <20121029132323.GA16391@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-13-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1351450948-15618-13-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> Switch lockd to use the new hashtable implementation. This reduces the amount of
> generic unrelated code in lockd.
> 
> Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  fs/lockd/svcsubs.c | 66 +++++++++++++++++++++++++++++-------------------------
>  1 file changed, 36 insertions(+), 30 deletions(-)
> 
> diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> index 0deb5f6..d223a1f 100644
> --- a/fs/lockd/svcsubs.c
> +++ b/fs/lockd/svcsubs.c
> @@ -20,6 +20,7 @@
>  #include <linux/lockd/share.h>
>  #include <linux/module.h>
>  #include <linux/mount.h>
> +#include <linux/hashtable.h>
>  
>  #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
>  
> @@ -28,8 +29,7 @@
>   * Global file hash table
>   */
>  #define FILE_HASH_BITS		7
> -#define FILE_NRHASH		(1<<FILE_HASH_BITS)
> -static struct hlist_head	nlm_files[FILE_NRHASH];
> +static DEFINE_HASHTABLE(nlm_files, FILE_HASH_BITS);
>  static DEFINE_MUTEX(nlm_file_mutex);
>  
>  #ifdef NFSD_DEBUG
> @@ -68,7 +68,7 @@ static inline unsigned int file_hash(struct nfs_fh *f)
>  	int i;
>  	for (i=0; i<NFS2_FHSIZE;i++)
>  		tmp += f->data[i];
> -	return tmp & (FILE_NRHASH - 1);
> +	return tmp;
>  }
>  
>  /*
> @@ -86,17 +86,17 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
>  {
>  	struct hlist_node *pos;
>  	struct nlm_file	*file;
> -	unsigned int	hash;
> +	unsigned int	key;
>  	__be32		nfserr;
>  
>  	nlm_debug_print_fh("nlm_lookup_file", f);
>  
> -	hash = file_hash(f);
> +	key = file_hash(f);
>  
>  	/* Lock file table */
>  	mutex_lock(&nlm_file_mutex);
>  
> -	hlist_for_each_entry(file, pos, &nlm_files[hash], f_list)
> +	hash_for_each_possible(nlm_files, file, pos, f_list, file_hash(f))

we have a nice example of weirdness about key vs hash here:

1) "key" is computed from file_hash(f)
2) file_hash(f) is computed again and again in hash_for_each_possible()

>  		if (!nfs_compare_fh(&file->f_handle, f))
>  			goto found;
>  
> @@ -123,7 +123,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
>  		goto out_free;
>  	}
>  
> -	hlist_add_head(&file->f_list, &nlm_files[hash]);
> +	hash_add(nlm_files, &file->f_list, key);

3) then we use "key" as parameter to hash_add.

Moreover, we're adding dispersion to the file_hash() with the hash_32()
called under the hook within hashtable.h. Is it an intended behavior ?
This should at the very least be documented in the changelog.

[...]

> +static int __init nlm_init(void)
> +{
> +	hash_init(nlm_files);

Useless.

Thanks,

Mathieu

> +	return 0;
> +}
> +
> +module_init(nlm_init);
> -- 
> 1.7.12.4
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
