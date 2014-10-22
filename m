From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 17:35:12 -0400
Message-ID: <54482310.5090406@cumulusnetworks.com>
References: <5447FDB2.2010906@gmail.com> <1414005158.9031.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Crestez Dan Leonard <cdleonard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:42460 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933443AbaJVVfP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 17:35:15 -0400
In-Reply-To: <1414005158.9031.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/14, 3:12 PM, Eric Dumazet wrote:
> On Wed, 2014-10-22 at 21:55 +0300, Crestez Dan Leonard wrote:
>> Hello,
>>
>> It seems that the TCP MD5 feature allocates a percpu struct
>> tcp_md5sig_pool and uses part of that memory for a scratch buffer to
>> do crypto on. Here is the relevant code:
>>
>> static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
>>                                         __be32 daddr, __be32 saddr,
>> int nbytes)
>> {
>>         struct tcp4_pseudohdr *bp;
>>         struct scatterlist sg;
>>
>>         bp = &hp->md5_blk.ip4;
>>
>>         /*
>>          * 1. the TCP pseudo-header (in the order: source IP address,
>>          * destination IP address, zero-padded protocol number, and
>>          * segment length)
>>          */
>>         bp->saddr = saddr;
>>         bp->daddr = daddr;
>>         bp->pad = 0;
>>         bp->protocol = IPPROTO_TCP;
>>         bp->len = cpu_to_be16(nbytes);
>>
>>         sg_init_one(&sg, bp, sizeof(*bp));
>>         return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
>> }
>>
>> sg_init_one does virt_addr on the pointer which assumes it is directly
>> accessible. But the tcp_md5sig_pool pointer comes from alloc_percpu
>> which can return memory from the vmalloc area after the
>> pcpu_first_chunk is exhausted. This looks wrong to me. I'm am getting
>> crashes on mips and I believe this to be the cause.

I can confirm this created an issue on our powerpc based switches. My
solution in our 3.2 kernel was to allocate the buffer on the stack. I
like this solution better.
