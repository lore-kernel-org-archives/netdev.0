From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Thu, 18 May 2017 15:10:03 +0100
Message-ID: <d348799b-4404-b408-9c36-59885c811eed@solarflare.com>
References: <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
 <20170517.201633.1413407173876329751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>,
        <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:37516 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932153AbdEROKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:10:19 -0400
In-Reply-To: <20170517.201633.1413407173876329751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/05/17 01:16, David Miller wrote:
> So, in C, addition (a += b) is something like:
>
> struct bpf_reg_bits {
>         u64 zero_bits;
>         u64 one_bits;
> };
>
> static void add_update_bits(struct bpf_reg_bits *a, struct bpf_reg_bits *b)
> {
>         u64 m_zeros, m_ones, m_all;
>
>         m_zeros = a->zero_bits ^ b->zero_bits;
>         m_ones = a->one_bits ^ b->one_bits;
>         m_all = m_zeros | m_ones;
No, this should be
    u64 m_a, m_b, m_all;

    m_a = a->zero_bits ^ a->one_bits; /* unknown bits in a */
    m_b = b->zero_bits ^ b->one_bits; /* unknown bits in b */
    m_all = m_a | m_b; /* unknown bits in result */
>         a->zero_bits = (a->zero_bits + b->zero_bits) | m_all;
>         a->one_bits = (a->one_bits + b->zero_bits) & ~m_all;
> }
>
> Then, is subtraction merely:
>
> static void sub_update_bits(struct bpf_reg_bits *a, struct bpf_reg_bits *b)
> {
>         u64 m_zeros, m_ones, m_all;
>
>         m_zeros = a->zero_bits ^ b->zero_bits;
>         m_ones = a->one_bits ^ b->one_bits;
>         m_all = m_zeros | m_ones;
>
>         a->zero_bits = (a->zero_bits - b->zero_bits) | m_all;
>         a->one_bits = (a->one_bits - b->zero_bits) & ~m_all;
> }
>
> Or is something different needed?
I suspect it's something different, just because I worry about what
 carries will do.

But I think Alexei's idea (mask and value) is better anyway; at the
 least it's easier to think about.

-Ed
