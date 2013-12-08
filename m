From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] 6lowpan: Moving generic
 compression code into 6lowpan_iphc.c
Date: Sun, 8 Dec 2013 15:38:46 +0100
Message-ID: <20131208143846.GA25486@omega>
References: <1386439370-14549-1-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1386439370-14549-1-git-send-email-jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 07, 2013 at 08:02:50PM +0200, Jukka Rissanen wrote:
> Because the IEEE 802154 and Bluetooth share the IP header compression
> and uncompression code, the common code is moved to 6lowpan_iphc.c
> file.
> 
> Signed-off-by: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> ---
> Hi,
> 
> this is just refactoring code so that Bluetooth LE 6LoWPAN
> patches (sent to bluetooth mailing list) can use it.
> No functionality changes by this patch.
> 
> Cheers,
> Jukka
> 
>  net/ieee802154/6lowpan.c      | 753 ++-------------------------------------
>  net/ieee802154/6lowpan.h      |  32 ++
>  net/ieee802154/6lowpan_iphc.c | 807 ++++++++++++++++++++++++++++++++++++++++++
>  net/ieee802154/Makefile       |   2 +-
>  4 files changed, 875 insertions(+), 719 deletions(-)
>  create mode 100644 net/ieee802154/6lowpan_iphc.c
...
> @@ -485,181 +149,14 @@ static int lowpan_header_create(struct sk_buff *skb,
>  		return 0;
>  
>  	hdr = ipv6_hdr(skb);
> -	hc06_ptr = head + 2;
> -
> -	pr_debug("IPv6 header dump:\n\tversion = %d\n\tlength  = %d\n"
> -		 "\tnexthdr = 0x%02x\n\thop_lim = %d\n", hdr->version,
> -		 ntohs(hdr->payload_len), hdr->nexthdr, hdr->hop_limit);
> -
> -	lowpan_raw_dump_table(__func__, "raw skb network header dump",
> -		skb_network_header(skb), sizeof(struct ipv6hdr));
>  
>  	if (!saddr)
>  		saddr = dev->dev_addr;
>  
>  	lowpan_raw_dump_inline(__func__, "saddr", (unsigned char *)saddr, 8);
> -
> -	/*
> -	 * As we copy some bit-length fields, in the IPHC encoding bytes,
> -	 * we sometimes use |=
> -	 * If the field is 0, and the current bit value in memory is 1,
> -	 * this does not work. We therefore reset the IPHC encoding here
> -	 */
> -	iphc0 = LOWPAN_DISPATCH_IPHC;
> -	iphc1 = 0;
> -
> -	/* TODO: context lookup */
> -
>  	lowpan_raw_dump_inline(__func__, "daddr", (unsigned char *)daddr, 8);
>  
> -	/*
> -	 * Traffic class, flow label
> -	 * If flow label is 0, compress it. If traffic class is 0, compress it
> -	 * We have to process both in the same time as the offset of traffic
> -	 * class depends on the presence of version and flow label
> -	 */
> -
> -	/* hc06 format of TC is ECN | DSCP , original one is DSCP | ECN */
> -	tmp = (hdr->priority << 4) | (hdr->flow_lbl[0] >> 4);
> -	tmp = ((tmp & 0x03) << 6) | (tmp >> 2);
> -
> -	if (((hdr->flow_lbl[0] & 0x0F) == 0) &&
> -	     (hdr->flow_lbl[1] == 0) && (hdr->flow_lbl[2] == 0)) {
> -		/* flow label can be compressed */
> -		iphc0 |= LOWPAN_IPHC_FL_C;
> -		if ((hdr->priority == 0) &&
> -		   ((hdr->flow_lbl[0] & 0xF0) == 0)) {
> -			/* compress (elide) all */
> -			iphc0 |= LOWPAN_IPHC_TC_C;
> -		} else {
> -			/* compress only the flow label */
> -			*hc06_ptr = tmp;
> -			hc06_ptr += 1;
> -		}
> -	} else {
> -		/* Flow label cannot be compressed */
> -		if ((hdr->priority == 0) &&
> -		   ((hdr->flow_lbl[0] & 0xF0) == 0)) {
> -			/* compress only traffic class */
> -			iphc0 |= LOWPAN_IPHC_TC_C;
> -			*hc06_ptr = (tmp & 0xc0) | (hdr->flow_lbl[0] & 0x0F);
> -			memcpy(hc06_ptr + 1, &hdr->flow_lbl[1], 2);
> -			hc06_ptr += 3;
> -		} else {
> -			/* compress nothing */
> -			memcpy(hc06_ptr, &hdr, 4);
> -			/* replace the top byte with new ECN | DSCP format */
> -			*hc06_ptr = tmp;
> -			hc06_ptr += 4;
> -		}
> -	}
> -
> -	/* NOTE: payload length is always compressed */
> -
> -	/* Next Header is compress if UDP */
> -	if (hdr->nexthdr == UIP_PROTO_UDP)
> -		iphc0 |= LOWPAN_IPHC_NH_C;
> -
> -	if ((iphc0 & LOWPAN_IPHC_NH_C) == 0) {
> -		*hc06_ptr = hdr->nexthdr;
> -		hc06_ptr += 1;
> -	}
> -
> -	/*
> -	 * Hop limit
> -	 * if 1:   compress, encoding is 01
> -	 * if 64:  compress, encoding is 10
> -	 * if 255: compress, encoding is 11
> -	 * else do not compress
> -	 */
> -	switch (hdr->hop_limit) {
> -	case 1:
> -		iphc0 |= LOWPAN_IPHC_TTL_1;
> -		break;
> -	case 64:
> -		iphc0 |= LOWPAN_IPHC_TTL_64;
> -		break;
> -	case 255:
> -		iphc0 |= LOWPAN_IPHC_TTL_255;
> -		break;
> -	default:
> -		*hc06_ptr = hdr->hop_limit;
> -		hc06_ptr += 1;
> -		break;
> -	}
> -
> -	/* source address compression */
> -	if (is_addr_unspecified(&hdr->saddr)) {
> -		pr_debug("source address is unspecified, setting SAC\n");
> -		iphc1 |= LOWPAN_IPHC_SAC;
> -	/* TODO: context lookup */
> -	} else if (is_addr_link_local(&hdr->saddr)) {
> -		pr_debug("source address is link-local\n");
> -		iphc1 |= lowpan_compress_addr_64(&hc06_ptr,
> -				LOWPAN_IPHC_SAM_BIT, &hdr->saddr, saddr);
> -	} else {
> -		pr_debug("send the full source address\n");
> -		memcpy(hc06_ptr, &hdr->saddr.s6_addr16[0], 16);
> -		hc06_ptr += 16;
> -	}
> -
> -	/* destination address compression */
> -	if (is_addr_mcast(&hdr->daddr)) {
> -		pr_debug("destination address is multicast: ");
> -		iphc1 |= LOWPAN_IPHC_M;
> -		if (lowpan_is_mcast_addr_compressable8(&hdr->daddr)) {
> -			pr_debug("compressed to 1 octet\n");
> -			iphc1 |= LOWPAN_IPHC_DAM_11;
> -			/* use last byte */
> -			*hc06_ptr = hdr->daddr.s6_addr[15];
> -			hc06_ptr += 1;
> -		} else if (lowpan_is_mcast_addr_compressable32(&hdr->daddr)) {
> -			pr_debug("compressed to 4 octets\n");
> -			iphc1 |= LOWPAN_IPHC_DAM_10;
> -			/* second byte + the last three */
> -			*hc06_ptr = hdr->daddr.s6_addr[1];
> -			memcpy(hc06_ptr + 1, &hdr->daddr.s6_addr[13], 3);
> -			hc06_ptr += 4;
> -		} else if (lowpan_is_mcast_addr_compressable48(&hdr->daddr)) {
> -			pr_debug("compressed to 6 octets\n");
> -			iphc1 |= LOWPAN_IPHC_DAM_01;
> -			/* second byte + the last five */
> -			*hc06_ptr = hdr->daddr.s6_addr[1];
> -			memcpy(hc06_ptr + 1, &hdr->daddr.s6_addr[11], 5);
> -			hc06_ptr += 6;
> -		} else {
> -			pr_debug("using full address\n");
> -			iphc1 |= LOWPAN_IPHC_DAM_00;
> -			memcpy(hc06_ptr, &hdr->daddr.s6_addr[0], 16);
> -			hc06_ptr += 16;
> -		}
> -	} else {
> -		/* TODO: context lookup */
> -		if (is_addr_link_local(&hdr->daddr)) {
> -			pr_debug("dest address is unicast and link-local\n");
> -			iphc1 |= lowpan_compress_addr_64(&hc06_ptr,
> -				LOWPAN_IPHC_DAM_BIT, &hdr->daddr, daddr);
> -		} else {
> -			pr_debug("dest address is unicast: using full one\n");
> -			memcpy(hc06_ptr, &hdr->daddr.s6_addr16[0], 16);
> -			hc06_ptr += 16;
> -		}
> -	}
> -
> -	/* UDP header compression */
> -	if (hdr->nexthdr == UIP_PROTO_UDP)
> -		lowpan_compress_udp_header(&hc06_ptr, skb);
> -
> -	head[0] = iphc0;
> -	head[1] = iphc1;
> -
> -	skb_pull(skb, sizeof(struct ipv6hdr));
> -	skb_reset_transport_header(skb);
> -	memcpy(skb_push(skb, hc06_ptr - head), head, hc06_ptr - head);
> -	skb_reset_network_header(skb);
> -
> -	lowpan_raw_dump_table(__func__, "raw skb data dump", skb->data,
> -				skb->len);
> +	lowpan_header_compress(skb, dev, type, daddr, saddr, len);

okay, here we should check the return value for an error. Nevertheless,
the error handling is currently ignored in other functions like lowpan_rcv.
So I will prepare some patches to make a more functionality error handling.

- Alex

------------------------------------------------------------------------------
Sponsored by Intel(R) XDK 
Develop, test and display web and hybrid apps with a single code base.
Download it for free now!
http://pubads.g.doubleclick.net/gampad/clk?id=111408631&iu=/4140/ostg.clktrk
