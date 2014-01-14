From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 4/4] dma debug: introduce debug_dma_assert_idle()
Date: Mon, 13 Jan 2014 17:14:12 -0800
Message-ID: <20140113171412.dd90c020b103f4a686f8dc34@linux-foundation.org>
References: <20140114004509.27138.50345.stgit@viggo.jf.intel.com>
	<20140114004804.27138.18469.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dmaengine@vger.kernel.org, Vinod Koul <vinod.koul@intel.com>,
	netdev@vger.kernel.org, Joerg Roedel <joro@8bytes.org>,
	linux-kernel@vger.kernel.org,
	James Bottomley <JBottomley@Parallels.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140114004804.27138.18469.stgit@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Jan 2014 16:48:47 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> Record actively mapped pages and provide an api for asserting a given
> page is dma inactive before execution proceeds.  Placing
> debug_dma_assert_idle() in cow_user_page() flagged the violation of the
> dma-api in the NET_DMA implementation (see commit 77873803363c "net_dma:
> mark broken").

Some discussion of the overlap counter thing would be useful.

> --- a/include/linux/dma-debug.h
> +++ b/include/linux/dma-debug.h
>
> ...
>
> +static void __active_pfn_inc_overlap(struct dma_debug_entry *entry)
> +{
> +	unsigned long pfn = entry->pfn;
> +	int i;
> +
> +	for (i = 0; i < RADIX_TREE_MAX_TAGS; i++)
> +		if (radix_tree_tag_get(&dma_active_pfn, pfn, i) == 0) {
> +			radix_tree_tag_set(&dma_active_pfn, pfn, i);
> +			return;
> +		}
> +	pr_debug("DMA-API: max overlap count (%d) reached for pfn 0x%lx\n",
> +		 RADIX_TREE_MAX_TAGS, pfn);
> +}
> +
> +static void __active_pfn_dec_overlap(struct dma_debug_entry *entry)
> +{
> +	unsigned long pfn = entry->pfn;
> +	int i;
> +
> +	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
> +		if (radix_tree_tag_get(&dma_active_pfn, pfn, i)) {
> +			radix_tree_tag_clear(&dma_active_pfn, pfn, i);
> +			return;
> +		}
> +	radix_tree_delete(&dma_active_pfn, pfn);
> +}
> +
> +static int active_pfn_insert(struct dma_debug_entry *entry)
> +{
> +	unsigned long flags;
> +	int rc;
> +
> +	spin_lock_irqsave(&radix_lock, flags);
> +	rc = radix_tree_insert(&dma_active_pfn, entry->pfn, entry);
> +	if (rc == -EEXIST)
> +		__active_pfn_inc_overlap(entry);
> +	spin_unlock_irqrestore(&radix_lock, flags);
> +
> +	return rc;
> +}
> +
> +static void active_pfn_remove(struct dma_debug_entry *entry)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&radix_lock, flags);
> +	__active_pfn_dec_overlap(entry);
> +	spin_unlock_irqrestore(&radix_lock, flags);
> +}

OK, I think I see what's happening.  The tags thing acts as a crude
counter and if the map/unmap count ends up imbalanced, we deliberately
leak an entry in the radix-tree so it can later be reported via undescribed
means.  Thoughts:

- RADIX_TREE_MAX_TAGS=3 so the code could count to 7, with a bit of
  futzing around.

- from a style/readability point of view it is unexpected that
  __active_pfn_dec_overlap() actually removes radix-tree items.  It
  would be better to do:

	spin_lock_irqsave(&radix_lock, flags);
	if (__active_pfn_dec_overlap(entry) == something) {
		/*
		 * Nice comment goes here
		 */
		radix_tree_delete(...);
	}
	spin_unlock_irqrestore(&radix_lock, flags);
