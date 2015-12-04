From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/4] qed: fix handling of concurrent ramrods
Date: Fri, 04 Dec 2015 14:34:15 -0500 (EST)
Message-ID: <20151204.143415.1088078490863415742.davem@davemloft.net>
References: <1449140356-17419-1-git-send-email-manish.chopra@qlogic.com>
	<1449140356-17419-3-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com, Tomer.Tayar@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbbLDTeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 14:34:17 -0500
In-Reply-To: <1449140356-17419-3-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Thu, 3 Dec 2015 05:59:14 -0500

> @@ -124,8 +124,19 @@ struct qed_spq {
>  	dma_addr_t		p_phys;
>  	struct qed_spq_entry	*p_virt;
>  
> -	/* Used as index for completions (returns on EQ by FW) */
> -	u16			echo_idx;
> +	/* Bitmap for handling out-of-order completions */
> +#define SPQ_RING_SIZE \
> +	(CORE_SPQE_PAGE_SIZE_BYTES / sizeof(struct slow_path_element))
> +#define SPQ_COMP_BMAP_SIZE	(SPQ_RING_SIZE / BITS_PER_LONG)
> +	unsigned long		p_comp_bitmap[SPQ_COMP_BMAP_SIZE];
> +	u8			comp_bitmap_idx;
> +
> +#define SPQ_COMP_BMAP_SET_BIT(p_spq, idx)	\
> +	__set_bit((idx) % SPQ_RING_SIZE, (p_spq)->p_comp_bitmap)
> +#define SPQ_COMP_BMAP_CLEAR_BIT(p_spq, idx)	\
> +	__clear_bit((idx) % SPQ_RING_SIZE, (p_spq)->p_comp_bitmap)
> +#define SPQ_COMP_BMAP_TEST_BIT(p_spq, idx)	\
> +	test_bit((idx) % SPQ_RING_SIZE, (p_spq)->p_comp_bitmap)
>  

Don't invent stuff we already have ifrastructure for.

Use DECLARE_BITMAP(), and the helpers, as necessary, in linux/bitmap.h
