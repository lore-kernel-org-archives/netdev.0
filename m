From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 04/16] dma-debug: add allocator code
Date: Sun, 11 Jan 2009 00:43:52 +0100
Message-ID: <20090110234352.GA20843@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-5-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:58765 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763AbZAJXob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:44:31 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-5-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +		printk(KERN_ERR "DMA-API: debugging out of memory "
> +				"- disabling\n");

btw., i'd suggest to not break kernel messages mid-string, but do 
something like this instead:

> +		printk(KERN_ERR
		 "DMA-API: debugging out of memory - disabling\n");

Also, i'd use WARN() - it might be useful to see what callsite depleted 
the pool.

> +	entry = list_entry(free_entries.next, struct dma_debug_entry, list);
> +	list_del(&entry->list);
> +	memset(entry, 0, sizeof(*entry));
> +
> +	num_free_entries -= 1;
> +	if (num_free_entries < min_free_entries)
> +		min_free_entries = num_free_entries;

unlikely() i guess.

Regarding the entry pool locking:

> +static void dma_entry_free(struct dma_debug_entry *entry)
> +{
> +	unsigned long flags;
> +
> +	/*
> +	 * add to beginning of the list - this way the entries are
> +	 * more likely cache hot when they are reallocated.
> +	 */
> +	spin_lock_irqsave(&free_entries_lock, flags);
> +	list_add(&entry->list, &free_entries);
> +	num_free_entries += 1;
> +	spin_unlock_irqrestore(&free_entries_lock, flags);

it might make sense to cache entries in the buckets - hence reuse the 
bucket spinlock. This means a somewhat higher effective pool size, but it 
also avoids a global lock.

	Ingo
