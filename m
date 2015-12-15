From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 5/6] bpf: hash: avoid to call kmalloc() in eBPF prog
Date: Wed, 16 Dec 2015 00:21:12 +0100
Message-ID: <5670A068.3040602@iogearbox.net>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com> <1450178464-27721-6-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39480 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933744AbbLOXVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 18:21:18 -0500
In-Reply-To: <1450178464-27721-6-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2015 12:21 PM, Ming Lei wrote:
...
> +/* Called from syscall, and the code is borrowed from blk_mq */
> +static int htab_pre_alloc_elems(struct bpf_htab *htab)
> +{
> +	const unsigned max_order = 4;
> +	unsigned elem_size = htab->elem_size, i;
> +	unsigned nr_entries = htab->map.max_entries;
> +	size_t left = nr_entries * elem_size;
> +
> +	htab->elems = kzalloc(nr_entries * sizeof(struct htab_elem *),
> +			      GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);

Should this use GFP_USER (same below)?

Also, when having a large number of elements e.g. > 1Mio, should we fall
back to vzalloc()?

> +	if (!htab->elems)
> +		goto fail;
> +
> +	INIT_LIST_HEAD(&htab->page_list);
> +
> +	for (i = 0; i < nr_entries; ) {
> +		int this_order = max_order;
> +		struct page *page;
> +		int j, to_do;
> +		void *p;
> +
> +		while (left < order_to_size(this_order - 1) && this_order)
> +			this_order--;
> +
> +		do {
> +			page = alloc_pages(GFP_KERNEL | __GFP_NOWARN |
> +					   __GFP_NORETRY | __GFP_ZERO,
> +					   this_order);
> +			if (page)
> +				break;
...
