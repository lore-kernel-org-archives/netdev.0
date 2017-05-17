From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Wed, 17 May 2017 15:00:04 +0100
Message-ID: <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:39118 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751566AbdEQOAV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 10:00:21 -0400
In-Reply-To: <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/05/17 23:53, Alexei Starovoitov wrote:
> following this line of thinking it feels that it should be possible
> to get rid of 'aux_off' and 'aux_off_align' and simplify the code.
> I mean we can always do
> dst_reg->min_align = min(dst_reg->min_align, src_reg->min_align);
>
> and don't use 'off' as part of alignment checks at all.
Problem with this approach, of course, is that (say) NET_IP_ALIGN +
 sizeof(ethhdr) = 16 is muchly aligned, whereas if you turn all
 constants into alignments you think you're only 2-byte aligned.
I think you have to track exact offsets when you can, and only turn
 into an alignment when you introduce a variable.
Of course it can still be fooled by e.g. 2 + (x << 2) + 14, which it
 will think is only 2-aligned when really it's 4-aligned, but unless
 you want to start tracking 'bits known to be 1' as well as 'bits
 known to be 0', I think you just accept that alignment tracking
 isn't commutative.  The obvious cases (ihl << 2 and so) will work
 when written the obvious way, unless the compiler does something
 perverse.
OTOH the 'track known 1s as well' might work in a nice generic way
 and cover all bases, I'll have to experiment a bit with that.

-Ed
