From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 6 Jan 2016 00:35:18 +0100
Message-ID: <568C5336.9090907@stressinduktion.org>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, x86@kernel.org
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:42599 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750822AbcAEXfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 18:35:22 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 6A7B4204A9
	for <netdev@vger.kernel.org>; Tue,  5 Jan 2016 18:35:21 -0500 (EST)
In-Reply-To: <1452019261-449449-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 05.01.2016 19:41, Tom Herbert wrote:
> Implement assembly routine for csum_partial for 64 bit x86. This
> primarily speeds up checksum calculation for smaller lengths such as
> those that are present when doing skb_postpull_rcsum when getting
> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
> conversion.
>
> This implementation is similar to csum_partial implemented in
> checksum_32.S, however since we are dealing with 8 bytes at a time
> there are more cases for small lengths-- for that we employ a jump
> table. Also, we don't do anything special for alignment, unaligned
> accesses on x86 do not appear to be a performance issue.
>
> Testing:
>
> Verified correctness by testing arbitrary length buffer filled with
> random data. For each buffer I compared the computed checksum
> using the original algorithm for each possible alignment (0-7 bytes).
>
> Checksum performance:
>
> Isolating old and new implementation for some common cases:
>
>                          Old      New
> Case                    nsecs    nsecs     Improvement
> ---------------------+--------+--------+-----------------------------
> 1400 bytes (0 align)    194.5    174.3     10%    (Big packet)
> 40 bytes (0 align)      13.8     5.8       57%    (Ipv6 hdr common case)
> 8 bytes (4 align)       8.4      2.9       65%    (UDP, VXLAN in IPv4)
> 14 bytes (0 align)      10.6     5.8       45%    (Eth hdr)
> 14 bytes (4 align)      10.8     5.8       46%    (Eth hdr in IPv4)
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Also,

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Tested with the same test cases as the old patch and showed no problems 
and same improvements.

Tom, did you have a look if it makes sense to add a second carry 
addition train with the adcx instruction, which does not signal carry 
via the carry flag but with the overflow flag? This instruction should 
not have any dependencies with the adc instructions and could help the 
CPU to parallelize the code even more (increased instructions per cycle).

Thanks,
Hannes
