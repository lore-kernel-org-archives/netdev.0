From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 13:54:48 -0800
Message-ID: <1383861288.9412.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
	 <20131107.161755.355597965034457889.davem@davemloft.net>
	 <20131107213111.GA6885@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:40418 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab3KGVyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 16:54:52 -0500
Received: by mail-pd0-f181.google.com with SMTP id x10so1205197pdj.12
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 13:54:51 -0800 (PST)
In-Reply-To: <20131107213111.GA6885@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 05:31 +0800, Herbert Xu wrote:

> Sorry David, I just realised that this patch doesn't address
> this problem fully.  While we can stop the generation of these
> packets in our own stack, if they're coming from the virt host
> or another guest, there is nothing we can do to stop them.
> 
> So given virtio_net is now generating such packets, our choices
> are either to linearise them or deal with them properly in skb_segment.

Hi Herbert

I believe I did this on my patch.

Note that there is absolutely no requirement on how are the skb found in
frag_list (their length is not a multiple of MSS)

For the ease of discussion, once patched skb_segment() looks like :

/**
 *	skb_segment - Perform protocol segmentation on skb.
 *	@skb: buffer to segment
 *	@features: features for the output path (see dev->features)
 *
 *	This function performs segmentation on the given skb.  It returns
 *	a pointer to the first in a list of new skbs for the segments.
 *	In case of error it returns ERR_PTR(err).
 */
struct sk_buff *skb_segment(struct sk_buff *head_skb, netdev_features_t features)
{
	struct sk_buff *segs = NULL;
	struct sk_buff *tail = NULL;
	struct sk_buff *cskb = head_skb;
	unsigned int mss = skb_shinfo(head_skb)->gso_size;
	unsigned int doffset = head_skb->data - skb_mac_header(head_skb);
	unsigned int tot_len; /* should reach head_skb->len at the end */
	unsigned int offset = doffset; /* offset in cskb->data */
	unsigned int tnl_hlen = skb_tnl_header_len(head_skb);
	unsigned int headroom;
	unsigned int len;
	__be16 proto;
	bool csum;
	int sg = !!(features & NETIF_F_SG);
	int cur_frag = 0, nfrags = skb_shinfo(cskb)->nr_frags;
	unsigned int data_len, cur_frag_offset = 0;
	int err = -ENOMEM;

	proto = skb_network_protocol(head_skb);
	if (unlikely(!proto))
		return ERR_PTR(-EINVAL);

	csum = !!can_checksum_protocol(features, proto);
	__skb_push(head_skb, doffset);
	headroom = skb_headroom(head_skb);

	for (tot_len = doffset; tot_len < head_skb->len; tot_len += len) {
		struct sk_buff *nskb;
		skb_frag_t *frag;
		int hsize, size, remain;

		len = head_skb->len - tot_len;
		if (len > mss)
			len = mss;

		hsize = skb_headlen(cskb) - offset;
		if (hsize < 0)
			hsize = 0;
		if (hsize > len || !sg)
			hsize = len;

		nskb = __alloc_skb(hsize + doffset + headroom,
				   GFP_ATOMIC, skb_alloc_rx_flag(head_skb),
				   NUMA_NO_NODE);

		if (unlikely(!nskb))
			goto err;

		skb_reserve(nskb, headroom);
		__skb_put(nskb, doffset);

		if (segs)
			tail->next = nskb;
		else
			segs = nskb;
		tail = nskb;

		__copy_skb_header(nskb, head_skb);
		nskb->mac_len = head_skb->mac_len;

		skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);

		skb_copy_from_linear_data_offset(head_skb, -tnl_hlen,
						 nskb->data - tnl_hlen,
						 doffset + tnl_hlen);

		if (!sg) {
			nskb->ip_summed = CHECKSUM_NONE;
			nskb->csum = skb_copy_and_csum_bits(head_skb, tot_len,
							    skb_put(nskb, len),
							    len, 0);
			offset += len;
			continue;
		}

		frag = skb_shinfo(nskb)->frags;

		skb_copy_from_linear_data_offset(cskb, offset,
						 skb_put(nskb, hsize), hsize);
		offset += hsize;

		nskb->data_len = len - hsize;
		nskb->len += nskb->data_len;
		nskb->truesize += nskb->data_len;

		skb_shinfo(nskb)->tx_flags = skb_shinfo(head_skb)->tx_flags & SKBTX_SHARED_FRAG;

		for (data_len = 0; data_len < nskb->data_len; data_len += remain) {
			remain = nskb->data_len - data_len;
			if (unlikely(cur_frag >= nfrags)) {
				if (cskb == head_skb)
					cskb = skb_shinfo(head_skb)->frag_list;
				else
					cskb = cskb->next;
				if (!cskb) {
					WARN_ON_ONCE(1);
					goto err;
				}
				cur_frag = 0;
				cur_frag_offset = 0;
				nfrags = skb_shinfo(cskb)->nr_frags;
				offset = 0;
				if (skb_headlen(cskb)) {
					char *data;
					struct page *page;

					remain = min_t(int, remain, skb_headlen(cskb));
					pr_err_once("remain %d\n", remain);
					if (likely(cskb->head_frag)) {
						data = cskb->data;
						page = virt_to_head_page(data);
						get_page(page);
					} else {
						data = __netdev_alloc_frag(SKB_DATA_ALIGN(remain),
									   GFP_ATOMIC);
						/* Really this should not happen, fix the caller ! */
						WARN_ON_ONCE(1);
						if (!data)
							goto err;
						memcpy(data, cskb->data, remain);
						page = virt_to_head_page(data);
					}
					frag->page.p = page;
					frag->page_offset = data - (char *)page_address(page);
					skb_frag_size_set(frag, remain);
					frag++;
					offset = remain;
					continue;
				}
			}
			*frag = skb_shinfo(cskb)->frags[cur_frag];
			__skb_frag_ref(frag);

			frag->page_offset += cur_frag_offset;
			skb_frag_size_sub(frag, cur_frag_offset);
			size = skb_frag_size(frag);

			if (size <= remain) {
				cur_frag++;
				cur_frag_offset = 0;
				remain = size;
			} else {
				skb_frag_size_set(frag, remain);
				cur_frag_offset += remain;
			}

			frag++;
		}

		skb_shinfo(nskb)->nr_frags = frag - skb_shinfo(nskb)->frags;

		if (!csum) {
			nskb->csum = skb_checksum(nskb, doffset,
						  nskb->len - doffset, 0);
			nskb->ip_summed = CHECKSUM_NONE;
		}
	}

	return segs;

err:
	while ((cskb = segs)) {
		segs = cskb->next;
		kfree_skb(cskb);
	}
	return ERR_PTR(err);
}
EXPORT_SYMBOL_GPL(skb_segment);
