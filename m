From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: Thu, 22 Dec 2016 22:38:09 +0100
Message-ID: <30d9513a-129b-d246-1461-2326130e118f@stressinduktion.org>
References: <20161222211140.2816.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
        Jason@zx2c4.com, jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        tom@herbertland.com, torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: George Spelvin <linux@sciencehorizons.net>, luto@kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161222211140.2816.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.12.2016 22:11, George Spelvin wrote:
>> I do tend to like Ted's version in which we use batched
>> get_random_bytes() output.  If it's fast enough, it's simpler and lets
>> us get the full strength of a CSPRNG.
> 
> With the ChaCha20 generator, that's fine, although note that this abandons
> anti-backtracking entirely.
> 
> It also takes locks, something the previous get_random_int code
> path avoided.  Do we need to audit the call sites to ensure that's safe?

We have spin_lock_irq* locks on the way. Of course they can hurt in when
contended. The situation should be the same as with get_random_bytes,
callable from every possible situation in the kernel without fear, so
this should also work for get_random_int. A lockdep test should still be
done. ;)

> And there is the issue that the existing callers assume that there's a
> fixed cost per word.  A good half of get_random_long calls are followed by
> "& ~PAGE_MASK" to extract the low 12 bits.  Or "& ((1ul << mmap_rnd_bits)
> - 1)" to extract the low 28.  If we have a buffer we're going to have to
> pay to refill, it would be nice to use less than 8 bytes to satisfy those.
> 
> But that can be a followup patch.  I'm thinking
> 
> unsigned long get_random_bits(unsigned bits)
> 	E.g. get_random_bits(PAGE_SHIFT),
> 	     get_random_bits(mmap_rnd_bits),
> 	u32 imm_rnd = get_random_bits(32)
> 
> unsigned get_random_mod(unsigned modulus)
> 	E.g. get_random_mod(hole) & ~(alignment - 1);
> 	     get_random_mod(port_scan_backoff)
> 	(Althogh probably drivers/s390/scsi/zfcp_fc.c should be changed
> 	to prandom.)
> 
> with, until the audit is completed:
> #define get_random_int() get_random_bits(32)
> #define get_random_long() get_random_bits(BITS_PER_LONG)

Yes, that does look nice indeed. Accounting for bits instead of bytes
shouldn't be a huge problem either. Maybe it gets a bit more verbose in
case you can't satisfy a request with one batched entropy block and have
to consume randomness from two.

>> It could only mix the output back in every two calls, in which case
>> you can backtrack up to one call but you need to do 2^128 work to
>> backtrack farther.  But yes, this is getting excessively complicated.
> 
> No, if you're willing to accept limited backtrack, this is a perfectly
> acceptable solution, and not too complicated.  You could do it phase-less
> if you like; store the previous output, then after generating the new
> one, mix in both.  Then overwrite the previous output.  (But doing two
> rounds of a crypto primtive to avoid one conditional jump is stupid,
> so forget that.)

Can you quickly explain why we lose the backtracking capability?

ChaCha as a block cipher gives a "perfect" permutation from the output
of either the CRNG or the CPRNG, which actually itself has backtracking
protection.

Thanks for explaining,
Hannes
