From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
Date: Wed, 6 May 2015 12:38:40 -0700
Message-ID: <20150506123840.312f41000e8d46f1ef9ce046@linux-foundation.org>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
	<20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:52929 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbbEFTil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 15:38:41 -0400
In-Reply-To: <20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 May 2015 16:14:48 -0700 Alexander Duyck <alexander.h.duyck@redhat.com> wrote:

> +/**
> + * skb_free_frag - free a page fragment
> + * @head: virtual address of page fragment
> + *
> + * Frees a page fragment allocated out of either a compound or order 0 page.
> + * The function itself is a hybrid between free_pages and free_compound_page
> + * which can be found in mm/page_alloc.c
> + */
> +void skb_free_frag(void *head)
> +{
> +	struct page *page = virt_to_head_page(head);
> +
> +	if (unlikely(put_page_testzero(page))) {
> +		if (likely(PageHead(page)))
> +			__free_pages_ok(page, compound_order(page));
> +		else
> +			free_hot_cold_page(page, false);
> +	}
> +}

Why are we testing for PageHead in here?  If the code were to simply do

	if (unlikely(put_page_testzero(page)))
		__free_pages_ok(page, compound_order(page));

that would still work?


There's nothing networking-specific in here.  I suggest the function be
renamed and moved to page_alloc.c.  Add an inlined skb_free_frag() in a
net header which calls it.  This way the mm developers know about it
and will hopefully maintain it.  It would need a comment explaining
when and why people should and shouldn't use it.

The term "page fragment" is a net thing and isn't something we know
about.  What is it?  From context I'm thinking a definition would look
something like

  An arbitrary-length arbitrary-offset area of memory which resides
  within a 0 or higher order page.  Multiple fragments within that page
  are individually refcounted, in the page's reference counter.

Is that correct and complete?
