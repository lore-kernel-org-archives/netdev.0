From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 12:03:25 -0800
Message-ID: <CAKgT0Ucw9ryw5PNe1Wh+cDhrQPtEsn_4h-X2YzVo2og52gVSRw@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<CAKgT0Ufe6iS5dLLUG4XfLxVVidH4oVo=9jp5VWsWDvRu5xLuCQ@mail.gmail.com>
	<CALx6S37Krix0afu_GKbxA9Dqi9W-_50V_bDL6DLZf4uRXtWaQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33189 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227AbcBDUDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 15:03:25 -0500
Received: by mail-io0-f178.google.com with SMTP id f81so105250324iof.0
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 12:03:25 -0800 (PST)
In-Reply-To: <CALx6S37Krix0afu_GKbxA9Dqi9W-_50V_bDL6DLZf4uRXtWaQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 11:44 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Feb 4, 2016 at 11:22 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Wed, Feb 3, 2016 at 11:18 AM, Tom Herbert <tom@herbertland.com> wrote:
>>> Implement assembly routine for csum_partial for 64 bit x86. This
>>> primarily speeds up checksum calculation for smaller lengths such as
>>> those that are present when doing skb_postpull_rcsum when getting
>>> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
>>> conversion.
>>>
>>> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is checked to determine whether
>>> we need to avoid unaligned accesses. Efficient unaligned accesses
>>> offer a nice additional speedup as demonstrated in the results
>>> provided below.
>>>
>>> This implementation is similar to csum_partial implemented in
>>> checksum_32.S, however since we are dealing with 8 bytes at a time
>>> there are more cases for small lengths (and alignments)-- for that
>>> we employ a jump table.
>>>
>>> Testing:
>>>
>>> Correctness:
>>>
>>> Verified correctness by testing arbitrary length buffer filled with
>>> random data. For each buffer I compared the computed checksum
>>> using the original algorithm for each possible alignment (0-7 bytes).
>>>
>>> Checksum performance:
>>>
>>> Isolating old and new implementation for some common cases:
>>>
>>>          Old      NewA     NewA %   NewNoA   NewNoA %
>>> Len/Aln  nsec     nsec     Improv   nsecs    Improve
>>> --------+-------+--------+-------+-------+---------------------
>>> 1400/0    192.9    175.1   10%     174.9     10%   (Big packet)
>>> 40/0      13.8     7.7     44%     5.7       58%   (Ipv6 hdr cmn case)
>>> 8/4       8.4      6.9     18%     2.8       67%   (UDP, VXLAN in IPv4)
>>> 14/0      10.5     7.3     30%     5.4       48%   (Eth hdr)
>>> 14/4      10.8     8.7     19%     5.4       50%   (Eth hdr in IPv4)
>>> 14/3      11.0     9.8     11%     5.6       49%   (Eth with odd align)
>>> 7/1       10.0     5.8     42%     4.8       52%   (buffer in one quad)
>>>
>>> NewA=>CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS not set
>>> NewNoA=>CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set
>>>
>>> Results from: Intel(R) Xeon(R) CPU X5650 @ 2.67GHz
>>>
>>> Also test on these with similar results:
>>>
>>> Intel(R) Xeon(R) CPU E5-2660 v2 @ 2.20GHz
>>> Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz
>>>
>>> Branch prediction:
>>>
>>> To test the effects of poor branch prediction in the jump tables I
>>> tested checksum performance with runs for two combinations of length
>>> and alignment. As the baseline I performed the test by doing half of
>>> calls with the first combination, followed by using the second
>>> combination for the second half. In the test case, I interleave the
>>> two combinations so that in every call the length and alignment are
>>> different to defeat the effects of branch prediction. Running several
>>> cases, I did not see any material performance difference between
>>> the baseline and the interleaving test case.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>
>> So a couple of general questions about all this.
>>
>> First why do you break the alignment part out over so many reads?  It
>> seems like you could just get the offset, subtract that from your
>> starting buffer, read the aligned long, and then mask off the bits you
>> don't want.  That should take maybe 4 or 5 instructions which would
>> save you a bunch of jumping around since most of it is just
>> arithmetic.
>>
> This would require reading bytes before the buffer pointer back to an
> 8 byte offset. Is this *always* guaranteed to be safe? Similar
> question on reading bytes past the length.

I would think we should be fine as long as we are only confining
ourselves to the nearest long.  I would assume page and segmentation
boundaries are at least aligned by the size of a long.  As such I
don't see how reading a few extra bytes to mask off later should cause
any issue.

- Alex
