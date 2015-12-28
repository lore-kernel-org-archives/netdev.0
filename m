From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v1 3/3] bpf: hash: use per-bucket spinlock
Date: Mon, 28 Dec 2015 15:43:29 +0100
Message-ID: <56814A91.5000208@iogearbox.net>
References: <1451307326-12807-1-git-send-email-tom.leiming@gmail.com> <1451307326-12807-4-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33240 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbbL1Onn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 09:43:43 -0500
In-Reply-To: <1451307326-12807-4-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/28/2015 01:55 PM, Ming Lei wrote:
> Both htab_map_update_elem() and htab_map_delete_elem() can be
> called from eBPF program, and they may be in kernel hot path,
> so it isn't efficient to use a per-hashtable lock in this two
> helpers.
>
> The per-hashtable spinlock is used for protecting bucket's
> hlist, and per-bucket lock is just enough. This patch converts
> the per-hashtable lock into per-bucket spinlock, so that
> contention can be decreased a lot.
>
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
> ---
>   kernel/bpf/hashtab.c | 46 ++++++++++++++++++++++++++++++----------------
>   1 file changed, 30 insertions(+), 16 deletions(-)
>
> diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
> index d857fcb..67222a9 100644
> --- a/kernel/bpf/hashtab.c
> +++ b/kernel/bpf/hashtab.c
> @@ -14,10 +14,14 @@
>   #include <linux/filter.h>
>   #include <linux/vmalloc.h>
>
> +struct bucket {
> +	struct hlist_head head;
> +	raw_spinlock_t lock;
> +};
> +
>   struct bpf_htab {
>   	struct bpf_map map;
> -	struct hlist_head *buckets;
> -	raw_spinlock_t lock;
> +	struct bucket *buckets;
>   	atomic_t count;	/* number of elements in this hashtable */
>   	u32 n_buckets;	/* number of hash buckets */
>   	u32 elem_size;	/* size of each element in bytes */
> @@ -88,24 +92,25 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
>   		/* make sure page count doesn't overflow */
>   		goto free_htab;

When adapting memory accounting and allocation sizes below where you replace
sizeof(struct hlist_head) with sizeof(struct bucket), is there a reason why
you don't update the overflow checks along with it?

[...]
         /* prevent zero size kmalloc and check for u32 overflow */
         if (htab->n_buckets == 0 ||
             htab->n_buckets > U32_MAX / sizeof(struct hlist_head))
                 goto free_htab;

         if ((u64) htab->n_buckets * sizeof(struct hlist_head) +
             (u64) htab->elem_size * htab->map.max_entries >=
             U32_MAX - PAGE_SIZE)
                 /* make sure page count doesn't overflow */
                 goto free_htab;
[...]

> -	htab->map.pages = round_up(htab->n_buckets * sizeof(struct hlist_head) +
> +	htab->map.pages = round_up(htab->n_buckets * sizeof(struct bucket) +
>   				   htab->elem_size * htab->map.max_entries,
>   				   PAGE_SIZE) >> PAGE_SHIFT;
>
>   	err = -ENOMEM;
> -	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct hlist_head),
> +	htab->buckets = kmalloc_array(htab->n_buckets, sizeof(struct bucket),
>   				      GFP_USER | __GFP_NOWARN);
>
>   	if (!htab->buckets) {
> -		htab->buckets = vmalloc(htab->n_buckets * sizeof(struct hlist_head));
> +		htab->buckets = vmalloc(htab->n_buckets * sizeof(struct bucket));
>   		if (!htab->buckets)
>   			goto free_htab;
>   	}

[...]

Thanks,
Daniel
