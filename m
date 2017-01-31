From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [RFC PATCH 2/2] ixgbe: add af_packet direct copy support
Date: Mon, 30 Jan 2017 18:53:05 -0800
Message-ID: <588FFC11.9030403@fb.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
 <20170127213411.14162.22553.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <john.r.fastabend@intel.com>, <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>, <bjorn.topel@gmail.com>,
        <jasowang@redhat.com>, <alexander.duyck@gmail.com>,
        <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37817 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750929AbdAaEMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 23:12:20 -0500
In-Reply-To: <20170127213411.14162.22553.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/27/17 1:34 PM, John Fastabend wrote:
> +	h2 = page_address(rx_buffer->page) + rx_buffer->page_offset - hdrlen;
> +	eth = page_address(rx_buffer->page) + rx_buffer->page_offset,

I don't think it compiles ;)

> +	/* This indicates a bug in ixgbe leaving for testing purposes */
> +	WARN_ON(TP_STATUS_USER & h2->tp_status);
> +	len = le16_to_cpu(rx_desc->wb.upper.length);
> +	h2->tp_len = len;
> +	h2->tp_snaplen = len;
> +	h2->tp_mac = ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN), L1_CACHE_BYTES);
> +	h2->tp_net = h2->tp_mac + ETH_HLEN;
> +	h2->tp_sec = div_s64_rem(ns, NSEC_PER_SEC, &rem);
> +	h2->tp_nsec = rem;
> +
> +	sll = (void *)h2 + TPACKET_ALIGN(sizeof(struct tpacket2_hdr));
> +	sll->sll_halen = ETH_HLEN;
> +	memcpy(sll->sll_addr, eth->h_source, ETH_ALEN);
> +	sll->sll_family = AF_PACKET;
> +	sll->sll_hatype = rx_ring->netdev->type;
> +	sll->sll_protocol = eth->h_proto;
> +	sll->sll_pkttype = PACKET_HOST;
> +	sll->sll_ifindex = rx_ring->netdev->ifindex;

performance wise it looks very expensive to do all these header copies
and integer divide for every packet.
I think unless we move to new dumb and simple header format
performance of this approach is not going to be satisfactory.
