From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 5/6] bpf: Add BPF_MAP_TYPE_LRU_PERCPU_HASH
Date: Mon, 14 Nov 2016 17:34:38 -0800
Message-ID: <20161115013436.GA8080@ast-mbp.thefacebook.com>
References: <1478890511-1346984-1-git-send-email-kafai@fb.com>
 <1478890511-1346984-6-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36253 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938882AbcKOBeo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 20:34:44 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so10314148pgx.3
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 17:34:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1478890511-1346984-6-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 10:55:10AM -0800, Martin KaFai Lau wrote:
> Provide a LRU version of the existing BPF_MAP_TYPE_PERCPU_HASH
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
...
> +	/* For LRU, we need to alloc before taking bucket's
> +	 * spinlock because LRU's elem alloc may need
> +	 * to remove older elem from htab and this removal
> +	 * operation will need a bucket lock.
> +	 */
> +	if (map_flags != BPF_EXIST) {
> +		l_new = prealloc_lru_pop(htab, key, hash);
> +		if (!l_new)
> +			return -ENOMEM;
> +	}
> +
> +	/* bpf_map_update_elem() can be called in_irq() */
> +	raw_spin_lock_irqsave(&b->lock, flags);
> +
> +	l_old = lookup_elem_raw(head, hash, key, key_size);
> +
> +	ret = check_flags(htab, l_old, map_flags);
> +	if (ret)
> +		goto err;
> +
> +	if (l_old) {
> +		bpf_lru_node_set_ref(&l_old->lru_node);
> +
> +		/* per-cpu hash map can update value in-place */
> +		pcpu_copy_value(htab, htab_elem_get_ptr(l_old, key_size),
> +				value, onallcpus);
> +	} else {
> +		pcpu_copy_value(htab, htab_elem_get_ptr(l_new, key_size),
> +				value, onallcpus);
> +		hlist_add_head_rcu(&l_new->hash_node, head);
> +		l_new = NULL;
> +	}
> +	ret = 0;
> +err:
> +	raw_spin_unlock_irqrestore(&b->lock, flags);
> +	if (l_new)
> +		bpf_lru_push_free(&htab->lru, &l_new->lru_node);
> +	return ret;
> +}

definitely tricky code, but all looks correct.
Acked-by: Alexei Starovoitov <ast@kernel.org>
