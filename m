From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v9 12/16] Add mp(mediate passthru) device.
Date: Fri, 10 Sep 2010 21:40:51 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D79280489A9C9@shsmsx502.ccr.corp.intel.com>
References: <1281086624-5765-5-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-6-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-7-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-8-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-9-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-10-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-11-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-12-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-13-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-14-git-send-email-xiaohui.xin@intel.com>
 <20100906111126.GA15608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.hengli.com.au" <herbert@gondor.hengli.com.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39498 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068Ab0IJNk6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 09:40:58 -0400
In-Reply-To: <20100906111126.GA15608@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael,
Sorry to reply the mail late.

>So - does this driver help reduce service demand signifiantly?

I'm looking at the performance now.

>Some comments from looking at the code:
>
>On Fri, Aug 06, 2010 at 05:23:41PM +0800, xiaohui.xin@intel.com wrote:
>> +static struct page_info *alloc_page_info(struct page_ctor *ctor,
>> +		struct kiocb *iocb, struct iovec *iov,
>> +		int count, struct frag *frags,
>> +		int npages, int total)
>> +{
>> +	int rc;
>> +	int i, j, n = 0;
>> +	int len;
>> +	unsigned long base, lock_limit;
>> +	struct page_info *info = NULL;
>> +
>> +	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
>> +	lock_limit >>= PAGE_SHIFT;
>
>Playing with rlimit on data path, transparently to the application in this way
>looks strange to me, I suspect this has unexpected security implications.
>Further, applications may have other uses for locked memory
>besides mpassthru - you should not just take it because it's there.
>
>Can we have an ioctl that lets userspace configure how much
>memory to lock? This ioctl will decrement the rlimit and store
>the data in the device structure so we can do accounting
>internally. Put it back on close or on another ioctl.

Yes, we can decrement the rlimit in ioctl in one time to avoid
data path.

>Need to be careful for when this operation gets called
>again with 0 or another small value while we have locked memory -
>maybe just fail with EBUSY?  or wait until it gets unlocked?
>Maybe 0 can be special-cased and deactivate zero-copy?.
>
In fact, if we choose RLIMIT_MEMLOCK to limit the lock memory,
the default value is only 16 pages. It's too small to make the device to 
work. So we always to configure it with a large value. 
I think, if rlimit value after decrement is < 0, then deactivate zero-copy 
is better. 0 maybe ok.

>> +
>> +	if (ctor->lock_pages + count > lock_limit && npages) {
>> +		printk(KERN_INFO "exceed the locked memory rlimit.");
>> +		return NULL;
>> +	}
>> +
>> +	info = kmem_cache_zalloc(ext_page_info_cache, GFP_KERNEL);
>
>You seem to fill in all memory, why zalloc? this is data path ...

Ok, Let me check this.

>
>> +
>> +	if (!info)
>> +		return NULL;
>> +
>> +	for (i = j = 0; i < count; i++) {
>> +		base = (unsigned long)iov[i].iov_base;
>> +		len = iov[i].iov_len;
>> +
>> +		if (!len)
>> +			continue;
>> +		n = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
>> +
>> +		rc = get_user_pages_fast(base, n, npages ? 1 : 0,
>
>npages controls whether this is a write? Why?

We use npages as a flag here. In mp_sendmsg(), we called alloc_page_info() with npages = 0.

>
>> +				&info->pages[j]);
>> +		if (rc != n)
>> +			goto failed;
>> +
>> +		while (n--) {
>> +			frags[j].offset = base & ~PAGE_MASK;
>> +			frags[j].size = min_t(int, len,
>> +					PAGE_SIZE - frags[j].offset);
>> +			len -= frags[j].size;
>> +			base += frags[j].size;
>> +			j++;
>> +		}
>> +	}
>> +
>> +#ifdef CONFIG_HIGHMEM
>> +	if (npages && !(dev->features & NETIF_F_HIGHDMA)) {
>> +		for (i = 0; i < j; i++) {
>> +			if (PageHighMem(info->pages[i]))
>> +				goto failed;
>> +		}
>> +	}
>> +#endif
>
>Are non-highdma devices worth bothering with? If yes -
>are there other limitations devices might have that we need to handle?
>E.g. what about non-s/g devices or no checksum offloading?.

Basically I think there is no limitations for both, but let me have a check.

>
>> +		skb_push(skb, ETH_HLEN);
>> +
>> +		if (skb_is_gso(skb)) {
>> +			hdr.hdr.hdr_len = skb_headlen(skb);
>> +			hdr.hdr.gso_size = shinfo->gso_size;
>> +			if (shinfo->gso_type & SKB_GSO_TCPV4)
>> +				hdr.hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>> +			else if (shinfo->gso_type & SKB_GSO_TCPV6)
>> +				hdr.hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
>> +			else if (shinfo->gso_type & SKB_GSO_UDP)
>> +				hdr.hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
>> +			else
>> +				BUG();
>> +			if (shinfo->gso_type & SKB_GSO_TCP_ECN)
>> +				hdr.hdr.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
>> +
>> +		} else
>> +			hdr.hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
>> +
>> +		if (skb->ip_summed == CHECKSUM_PARTIAL) {
>> +			hdr.hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
>> +			hdr.hdr.csum_start =
>> +				skb->csum_start - skb_headroom(skb);
>> +			hdr.hdr.csum_offset = skb->csum_offset;
>> +		}
>
>We have this code in tun, macvtap and packet socket already.
>Could this be a good time to move these into networking core?
>I'm not asking you to do this right now, but could this generic
>virtio-net to skb stuff be encapsulated in functions?

It seems reasonable.

>
>--
>MST
