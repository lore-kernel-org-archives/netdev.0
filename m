From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] rhashtable: Per bucket locks & expansion/shrinking
 in work queue
Date: Mon, 15 Sep 2014 08:23:00 -0700
Message-ID: <1410794580.7106.168.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1410782841.git.tgraf@suug.ch>
	 <fe862eb8add076215918a0def9c3bd4fe8a104c7.1410782841.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, paulmck@linux.vnet.ibm.com,
	john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fe862eb8add076215918a0def9c3bd4fe8a104c7.1410782841.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-09-15 at 14:18 +0200, Thomas Graf wrote:

> +static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl)
> +{
> +	unsigned int i, size;
> +#if defined(CONFIG_PROVE_LOCKING)
> +	unsigned int nr_pcpus = 2;
> +#else
> +	unsigned int nr_pcpus = num_possible_cpus();
> +#endif
> +
> +	nr_pcpus = min_t(unsigned int, nr_pcpus, 32UL);
> +	size = nr_pcpus * ht->p.locks_mul;
> +

You need to roundup to next power of two.

> +	if (sizeof(spinlock_t) != 0) {
> +#ifdef CONFIG_NUMA
> +		if (size * sizeof(spinlock_t) > PAGE_SIZE)
> +			tbl->locks = vmalloc(size * sizeof(spinlock_t));
> +		else
> +#endif
> +		tbl->locks = kmalloc_array(size, sizeof(spinlock_t),
> +					   GFP_KERNEL);
> +		if (!tbl->locks)
> +			return -ENOMEM;
> +		for (i = 0; i < size; i++)
> +			spin_lock_init(&tbl->locks[i]);
> +	}
> +	tbl->locks_mask = size - 1;
> +
> +	return 0;
> +}
