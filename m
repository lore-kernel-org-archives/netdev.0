From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
Date: Wed, 6 May 2015 13:41:02 -0700
Message-ID: <20150506134102.b01faad32e07ff3d308e1a09@linux-foundation.org>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
	<20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
	<20150506123840.312f41000e8d46f1ef9ce046@linux-foundation.org>
	<554A793F.3070001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:53899 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbbEFUlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 16:41:04 -0400
In-Reply-To: <554A793F.3070001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 May 2015 13:27:43 -0700 Alexander Duyck <alexander.h.duyck@redhat.com> wrote:

> >> +void skb_free_frag(void *head)
> >> +{
> >> +	struct page *page = virt_to_head_page(head);
> >> +
> >> +	if (unlikely(put_page_testzero(page))) {
> >> +		if (likely(PageHead(page)))
> >> +			__free_pages_ok(page, compound_order(page));
> >> +		else
> >> +			free_hot_cold_page(page, false);
> >> +	}
> >> +}
> > Why are we testing for PageHead in here?  If the code were to simply do
> >
> > 	if (unlikely(put_page_testzero(page)))
> > 		__free_pages_ok(page, compound_order(page));
> >
> > that would still work?
> 
> My assumption was that there was a performance difference between 
> __free_pages_ok and free_hot_cold_page for order 0 pages.  From what I 
> can tell free_hot_cold_page will do bulk cleanup via free_pcppages_bulk 
> while __free_pages_ok just calls free_one_page.

Could be.  Plus there's hopefully some performance advantage if the
page is genuinely cache-hot.  I don't think that anyone has verified
the benefits of the hot/cold optimisation in the last decade or two,
and it was always pretty marginal..

Is the PageHead thing really "likely"?  We're usually dealing with
order>0 pages here?
