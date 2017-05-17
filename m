From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Wed, 17 May 2017 16:33:27 +0100
Message-ID: <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:37313 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750969AbdEQPdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:33:41 -0400
In-Reply-To: <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/05/17 15:00, Edward Cree wrote:
> OTOH the 'track known 1s as well' might work in a nice generic way
>  and cover all bases, I'll have to experiment a bit with that.
> 
> -Ed

So I did some experiments (in Python, script follows) and found that
 indeed this does appear to work, at least for addition and shifts.
The idea is that we have a 0s mask and a 1s mask; for bits that are
 unknown, the 0s mask is set and the 1s mask is cleared.  So a
 completely unknown variable has masks (~0, 0), then if you shift it
 left 2 you get (~3, 0) - just shift both masks.  A constant x has
 masks (x, x) - all the 0s are known 0s and all the 1s are known 1s.
Addition is a bit more complicated: we compute the 'unknown bits'
 mask, by XORing the 0s and 1s masks together, of each addend.  Then
 we add the corresponding masks from each addend together, and force
 the 'unknown' bits to the appropriate values in each mask.
So given (a1, b1) and (a2, b2), we compute m1 = a1 ^ b1,
 m2 = a2 ^ b2, and m = m1 | m2.  Then a = (a1 + a2) | m, and
 b = (b1 + b2) & ~m.
As a worked example, 2 + (x << 2) + 14:
 2 => (2, 2) constant
 x => (~0, 0) unknown
 x << 2 => (~3, 0)
 2 + (x << 2): add (2, 2) with (~3, 0)
    m1 = 0, m2 = ~3, m = ~3
    a = (2 + ~3) | ~3 = ~1 | ~3 = ~1
    b = (2 + 0) & ~~3 = 2 & 3 = 2
    so (~1, 2), which means "...xx10"
now add 14: add (~1, 2) with (14, 14)
    m1 = ~3, m2 = 0, m = ~3
    a = (~1 + 14) | ~3 = 12 | ~3 = ~3
    b = (2 + 14) & ~~3 = 16 & 3 = 0
    so (~3, 0), which means "...xx00"
and the result is 4-byte aligned.

-Ed

PS. Beware of bugs in the following code; I have only tested it, not
 proved it correct.

--8<--

#!/usr/bin/python2

def cpl(x):
    return (~x)&0xff

class AlignedNumber(object):
    def __init__(self, mask0=0xff, mask1=0):
        """mask0 has 0s for bits known to be 0, 1s otherwise.
        mask1 has 1s for bits known to be 1, 0s otherwise.
        Thus a bit which is set in mask0 and cleared in mask1 is an 'unknown'
        bit, while a bit which is cleared in mask0 and set in mask1 is a bug.
        """
        self.masks = (mask0 & 0xff, mask1 & 0xff)
        self.validate()
    @classmethod
    def const(cls, value):
        """All bits are known, so both masks equal value."""
        return cls(value, value)
    def validate(self):
        # Check for bits 'known' to be both 0 and 1
        assert not (cpl(self.masks[0]) & self.masks[1]), self.masks
        # Check unknown bits don't follow known bits
        assert self.mx | ((self.mx - 1) & 0xff) == 0xff, self.masks
    def __str__(self):
        return ':'.join(map(bin, self.masks))
    def __lshift__(self, sh):
        """Shift both masks left, low bits become 'known 0'"""
        return self.__class__(self.masks[0] << sh, self.masks[1] << sh)
    def __rshift__(self, sh):
        """Shift 1s into mask0; high bits become 'unknown'.
        While strictly speaking they may be known 0 if we're tracking the full
        word and doing unsigned shifts, having known bits before unknown bits
        breaks the addition code."""
        return self.__class__(cpl(cpl(self.masks[0]) >> sh), self.masks[1] >> sh)
    @property
    def mx(self):
        """Mask of unknown bits"""
        return self.masks[0] ^ self.masks[1]
    def __add__(self, other):
        """OR the mx values together.  Unknown bits could cause carries, so we
        just assume that they can carry all the way to the left (thus we keep
        our mx masks in the form 1...10...0.
        Then, add our 0- and 1-masks, and force the bits of the combined mx
        mask to the unknown state."""
        if isinstance(other, int):
            return self + AlignedNumber.const(other)
        assert isinstance(other, AlignedNumber), other
        m = self.mx | other.mx
        return self.__class__((self.masks[0] + other.masks[0]) | m,
                              (self.masks[1] + other.masks[1]) & cpl(m))
    def is_aligned(self, bits):
        """We are 2^n-aligned iff the bottom n bits are known-0."""
        mask = (1 << bits) - 1
        return not (self.masks[0] & mask)

if __name__ == '__main__':
    a = AlignedNumber.const(2)
    b = AlignedNumber() << 2
    c = AlignedNumber.const(14)
    print a, b, c
    print a + b, a + b + c
    assert (a + b + c).is_aligned(2)
    d = (AlignedNumber() << 4) >> 2
    print d
    assert d.is_aligned(2)
