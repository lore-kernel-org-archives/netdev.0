From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: Implement fast csum_partial for x86_64
Date: Mon, 4 Jan 2016 23:17:37 +0100
Message-ID: <568AEF81.7070404@stressinduktion.org>
References: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41463 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752012AbcADWRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:17:42 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id D920F207BE
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 17:17:40 -0500 (EST)
In-Reply-To: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.01.2016 00:22, Tom Herbert wrote:
> Implement assembly routine for csum_partial for 64 bit x86. This
> primarily speeds up checksum calculation for smaller lengths such as
> those that are present when doing skb_postpull_rcsum when getting
> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
> conversion.
>
> This implementation is similar to csum_partial implemented in
> checksum_32.S, however since we are dealing with 8 bytes at a time
> there are more cases for alignment and small lengths-- for those we
> employ jump tables.
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
> Case                    nsecs    nsecs    Improvement
> ---------------------+--------+--------+-----------------------------
> 1400 bytes (0 align)    194.4    176.7      9%    (Big packet)
> 40 bytes (0 align)      10.5     5.7       45%    (Ipv6 hdr common case)
> 8 bytes (4 align)       8.6      7.4       15%    (UDP, VXLAN in IPv4)
> 14 bytes (0 align)      10.4     6.5       37%    (Eth hdr)
> 14 bytes (4 align)      10.8     7.8       27%    (Eth hdr in IPv4)
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>

I verified the implementation through tests and can also see a speed-up 
in almost all cases. Unfortunately _addcarry_u64 intrinsics and __int128 
for letting the compiler use adc instructions generated even worse code 
as the current implementation.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks Tom!
