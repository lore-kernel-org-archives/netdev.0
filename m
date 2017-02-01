From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 2/2] ixgbe: add af_packet direct copy support
Date: Tue, 31 Jan 2017 20:58:36 -0800
Message-ID: <58916AFC.8030901@gmail.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
 <20170127213411.14162.22553.stgit@john-Precision-Tower-5810>
 <588FFC11.9030403@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>, bjorn.topel@gmail.com,
        jasowang@redhat.com, alexander.duyck@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36214 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751086AbdBAE6y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 23:58:54 -0500
Received: by mail-pf0-f195.google.com with SMTP id 19so30829468pfo.3
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 20:58:53 -0800 (PST)
In-Reply-To: <588FFC11.9030403@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-30 06:53 PM, Alexei Starovoitov wrote:
> On 1/27/17 1:34 PM, John Fastabend wrote:
>> +    h2 = page_address(rx_buffer->page) + rx_buffer->page_offset - hdrlen;
>> +    eth = page_address(rx_buffer->page) + rx_buffer->page_offset,
> 
> I don't think it compiles ;)

Well that is what I get for doing some last minute checkpatch fixes
and not doing a build test before sending it out. Oh well just an RFC
to get some general feedback.

> 
>> +    /* This indicates a bug in ixgbe leaving for testing purposes */
>> +    WARN_ON(TP_STATUS_USER & h2->tp_status);
>> +    len = le16_to_cpu(rx_desc->wb.upper.length);
>> +    h2->tp_len = len;
>> +    h2->tp_snaplen = len;
>> +    h2->tp_mac = ALIGN(TPACKET_ALIGN(TPACKET2_HDRLEN), L1_CACHE_BYTES);
>> +    h2->tp_net = h2->tp_mac + ETH_HLEN;
>> +    h2->tp_sec = div_s64_rem(ns, NSEC_PER_SEC, &rem);
>> +    h2->tp_nsec = rem;
>> +
>> +    sll = (void *)h2 + TPACKET_ALIGN(sizeof(struct tpacket2_hdr));
>> +    sll->sll_halen = ETH_HLEN;
>> +    memcpy(sll->sll_addr, eth->h_source, ETH_ALEN);
>> +    sll->sll_family = AF_PACKET;
>> +    sll->sll_hatype = rx_ring->netdev->type;
>> +    sll->sll_protocol = eth->h_proto;
>> +    sll->sll_pkttype = PACKET_HOST;
>> +    sll->sll_ifindex = rx_ring->netdev->ifindex;
> 
> performance wise it looks very expensive to do all these header copies
> and integer divide for every packet.
> I think unless we move to new dumb and simple header format
> performance of this approach is not going to be satisfactory.
> 

Sure I'm not opposed to moving to a v4 in fact I think it would help
in a lot of ways. I'll try to fire off some benchmarks and then move
to a v4 to see how that works out.

.John
