From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v11 13/17] Add mp(mediate passthru) device.
Date: Tue, 28 Sep 2010 15:06:54 +0200
Message-ID: <20100928130654.GD14385@redhat.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
 <2c954a831e2d9a93437aaf06386cd3a5af6b73b9.1285385607.git.xiaohui.xin@intel.com>
 <1285622613.2263.550.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com, arnd@arndb.de
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753802Ab0I1NN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 09:13:29 -0400
Content-Disposition: inline
In-Reply-To: <1285622613.2263.550.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 27, 2010 at 10:23:33PM +0100, Ben Hutchings wrote:
> > +/* The main function to transform the guest user space address
> > + * to host kernel address via get_user_pages(). Thus the hardware
> > + * can do DMA directly to the external buffer address.
> > + */
> > +static struct page_info *alloc_page_info(struct page_ctor *ctor,
> > +		struct kiocb *iocb, struct iovec *iov,
> > +		int count, struct frag *frags,
> > +		int npages, int total)
> > +{
> > +	int rc;
> > +	int i, j, n = 0;
> > +	int len;
> > +	unsigned long base, lock_limit;
> > +	struct page_info *info = NULL;
> > +
> > +	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
> > +	lock_limit >>= PAGE_SHIFT;
> > +
> > +	if (ctor->lock_pages + count > lock_limit && npages) {
> > +		printk(KERN_INFO "exceed the locked memory rlimit.");
> > +		return NULL;
> > +	}
> 
> What if the process is locking pages with mlock() as well?  Doesn't this
> allow it to lock twice as many pages as it should be able to?

No, since locked_vm is incremented by both mp and mlock.
Or at least, that's the idea :)
In any case, twice as many would not be a big deal: admin can control
which processes can do this by controlling access to the device.

> > +	info = kmem_cache_alloc(ext_page_info_cache, GFP_KERNEL);
> > +	
> > +	if (!info)
> > +		return NULL;
> > +	info->skb = NULL;
> > +	info->next = info->prev = NULL;
> > +
> > +	for (i = j = 0; i < count; i++) {
> > +		base = (unsigned long)iov[i].iov_base;
> > +		len = iov[i].iov_len;
> > +
> > +		if (!len)
> > +			continue;
> > +		n = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
> > +
> > +		rc = get_user_pages_fast(base, n, npages ? 1 : 0,
> > +				&info->pages[j]);
> > +		if (rc != n)
> > +			goto failed;
> > +
> > +		while (n--) {
> > +			frags[j].offset = base & ~PAGE_MASK;
> > +			frags[j].size = min_t(int, len,
> > +					PAGE_SIZE - frags[j].offset);
> > +			len -= frags[j].size;
> > +			base += frags[j].size;
> > +			j++;
> > +		}
> > +	}
> > +
> > +#ifdef CONFIG_HIGHMEM
> > +	if (npages && !(dev->features & NETIF_F_HIGHDMA)) {
> > +		for (i = 0; i < j; i++) {
> > +			if (PageHighMem(info->pages[i]))
> > +				goto failed;
> > +		}
> > +	}
> > +#endif
> 
> Shouldn't you try to allocate lowmem pages explicitly, rather than
> failing at this point?

We don't allocate pages, we lock given pages. Once this is
integrated in macvtap presumably we'll fall back on data copy
for such devices.

...

> > +	skb_reserve(skb, NET_IP_ALIGN);
> > +	skb_put(skb, len);
> > +
> > +	if (skb_copy_datagram_from_iovec(skb, 0, iov, 0, len)) {
> > +		kfree_skb(skb);
> > +		return -EAGAIN;
> > +	}
> > +
> > +	skb->protocol = eth_type_trans(skb, mp->dev);
> 
> Why are you calling eth_type_trans() on transmit?

So that GSO can work.  BTW macvtap does:

        skb_set_network_header(skb, ETH_HLEN);
        skb_reset_mac_header(skb);
        skb->protocol = eth_hdr(skb)->h_proto;

and I think this is broken for vlans. Arnd?

-- 
MST
