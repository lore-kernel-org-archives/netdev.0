From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate
 alignment in verifier.
Date: Wed, 17 May 2017 20:16:33 -0400 (EDT)
Message-ID: <20170517.201633.1413407173876329751.davem@davemloft.net>
References: <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
        <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
        <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753107AbdERAQh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 20:16:37 -0400
In-Reply-To: <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 17 May 2017 16:33:27 +0100

> So I did some experiments (in Python, script follows) and found that
>  indeed this does appear to work, at least for addition and shifts.
> The idea is that we have a 0s mask and a 1s mask; for bits that are
>  unknown, the 0s mask is set and the 1s mask is cleared.  So a
>  completely unknown variable has masks (~0, 0), then if you shift it
>  left 2 you get (~3, 0) - just shift both masks.  A constant x has
>  masks (x, x) - all the 0s are known 0s and all the 1s are known 1s.
> Addition is a bit more complicated: we compute the 'unknown bits'
>  mask, by XORing the 0s and 1s masks together, of each addend.  Then
>  we add the corresponding masks from each addend together, and force
>  the 'unknown' bits to the appropriate values in each mask.
> So given (a1, b1) and (a2, b2), we compute m1 = a1 ^ b1,
>  m2 = a2 ^ b2, and m = m1 | m2.  Then a = (a1 + a2) | m, and
>  b = (b1 + b2) & ~m.
> As a worked example, 2 + (x << 2) + 14:
>  2 => (2, 2) constant
>  x => (~0, 0) unknown
>  x << 2 => (~3, 0)
>  2 + (x << 2): add (2, 2) with (~3, 0)
>     m1 = 0, m2 = ~3, m = ~3
>     a = (2 + ~3) | ~3 = ~1 | ~3 = ~1
>     b = (2 + 0) & ~~3 = 2 & 3 = 2
>     so (~1, 2), which means "...xx10"
> now add 14: add (~1, 2) with (14, 14)
>     m1 = ~3, m2 = 0, m = ~3
>     a = (~1 + 14) | ~3 = 12 | ~3 = ~3
>     b = (2 + 14) & ~~3 = 16 & 3 = 0
>     so (~3, 0), which means "...xx00"
> and the result is 4-byte aligned.

Ok, I'm starting to digest this.  If it works it's a nice universal
way to handle alignment tracking, that's for sure.

So, in C, addition (a += b) is something like:

struct bpf_reg_bits {
        u64 zero_bits;
        u64 one_bits;
};

static void add_update_bits(struct bpf_reg_bits *a, struct bpf_reg_bits *b)
{
        u64 m_zeros, m_ones, m_all;

        m_zeros = a->zero_bits ^ b->zero_bits;
        m_ones = a->one_bits ^ b->one_bits;
        m_all = m_zeros | m_ones;

        a->zero_bits = (a->zero_bits + b->zero_bits) | m_all;
        a->one_bits = (a->one_bits + b->zero_bits) & ~m_all;
}

Then, is subtraction merely:

static void sub_update_bits(struct bpf_reg_bits *a, struct bpf_reg_bits *b)
{
        u64 m_zeros, m_ones, m_all;

        m_zeros = a->zero_bits ^ b->zero_bits;
        m_ones = a->one_bits ^ b->one_bits;
        m_all = m_zeros | m_ones;

        a->zero_bits = (a->zero_bits - b->zero_bits) | m_all;
        a->one_bits = (a->one_bits - b->zero_bits) & ~m_all;
}

Or is something different needed?

What about multiplication?  AND should be easy too.

BTW, we track something similar already in reg->imm which tracks how
many high order bits are known to be cleared in the register.  It is
used to avoid potential overflow for packet pointer accesses.  I bet
we can subsume that into this facility as well.

Thanks for all of your suggestions so far.
