From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v2 03/19] vbus: add connection-client helper
	infrastructure
Date: Thu, 4 Jun 2009 21:06:11 +0300
Message-ID: <20090604180611.GA16387@redhat.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163057.32740.27829.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46412 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751630AbZFDSIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2009 14:08:21 -0400
Content-Disposition: inline
In-Reply-To: <20090409163057.32740.27829.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 09, 2009 at 12:30:57PM -0400, Gregory Haskins wrote:
> +static unsigned long
> +task_memctx_copy_to(struct vbus_memctx *ctx, void *dst, const void *src,
> +		    unsigned long n)
> +{
> +	struct task_memctx *tm = to_task_memctx(ctx);
> +	struct task_struct *p = tm->task;
> +
> +	while (n) {
> +		unsigned long offset = ((unsigned long)dst)%PAGE_SIZE;
> +		unsigned long len = PAGE_SIZE - offset;
> +		int ret;
> +		struct page *pg;
> +		void *maddr;
> +
> +		if (len > n)
> +			len = n;
> +
> +		down_read(&p->mm->mmap_sem);
> +		ret = get_user_pages(p, p->mm,
> +				     (unsigned long)dst, 1, 1, 0, &pg, NULL);
> +
> +		if (ret != 1) {
> +			up_read(&p->mm->mmap_sem);
> +			break;
> +		}
> +
> +		maddr = kmap_atomic(pg, KM_USER0);
> +		memcpy(maddr + offset, src, len);
> +		kunmap_atomic(maddr, KM_USER0);
> +		set_page_dirty_lock(pg);
> +		put_page(pg);
> +		up_read(&p->mm->mmap_sem);
> +
> +		src += len;
> +		dst += len;
> +		n -= len;
> +	}
> +
> +	return n;
> +}

BTW, why did you decide to use get_user_pages?
Would switch_mm + copy_to_user work as well
avoiding page walk if all pages are present?

Also - if we just had vmexit because a process executed
io (or hypercall), can't we just do copy_to_user there?
Avi, I think at some point you said that we can?


-- 
MST
