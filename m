From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] net: implement dma cache skb allocator
Date: Wed, 11 Mar 2015 06:55:58 -0700
Message-ID: <5500496E.1060701@gmail.com>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com> <1426009384-11544-2-git-send-email-_govind@gmx.com> <54FF5521.5000007@redhat.com> <alpine.LNX.2.03.1503111359280.3394@ws.cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41394 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbCKN4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 09:56:01 -0400
Received: by pdjy10 with SMTP id y10so11402544pdj.8
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 06:56:00 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.03.1503111359280.3394@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2015 01:57 AM, Govindarajulu Varadarajan wrote:
> On Tue, 10 Mar 2015, Alexander Duyck wrote:
>
>>
>> On 03/10/2015 10:43 AM, Govindarajulu Varadarajan wrote:
>>> This patch implements dma cache skb allocator. This is based on
>>> __alloc_page_frag & __page_frag_refill implementation in
>>> net/core/skbuff.c
>>>
>>> In addition to frag allocation from order(3) page in __alloc_page_frag,
>>> we also maintain dma address of the page. While allocating a frag
>>> for skb
>>> we use va + offset for virtual address of the frag, and pa + offset for
>>> dma address of the frag. This reduces the number of calls to
>>> dma_map() by 1/3
>>> for 9000 bytes and by 1/20 for 1500 bytes.
>>>
>>> __alloc_page_frag is limited to max buffer size of PAGE_SIZE, i.e
>>> 4096 in most
>>> of the cases. So 9k buffer allocation goes through kmalloc which return
>>> page of order 2, 16k. We waste 7k bytes for every 9k buffer.
>>
>> The question I would have is do you actually need to have the 9k
>> buffer? Does the hardware support any sort of scatter-gather
>> receive?  If so that would be preferable as the 9k allocation per skb
>> will have significant overhead when you start receiving small packets.
>>
>
> enic hw has limited desc per rq (4096), and we can have only one dma
> block per
> desc. Having sg/header-split will reduce the effective rq ring size for
> large packets.

Yes, so?  In the case of the Intel driver they default to only 512
descriptors per ring with a size of 2K per descriptor.  Are you saying
the latency for your interrupt processing is so high that you need to
buffer 9k per descriptor in order to achieve line rate?

>
>> A classic example is a TCP flow where you are only receiving a few
>> hundred bytes per frame.  You will take a huge truesize penalty for
>> allocating a 9k skb for a frame of only a few hundred bytes, though
>> it sounds like you are taking that hit already.
>>
>
> For this we have rx copybreak for pkts < 256 bytes.

That definitely helps but still leaves you open since a 257 byte packet
would be consuming 9K in that case.  Also standard flows with frames of
1514 still take a hard hit with a receive buffer size of 9K.

- Alex
