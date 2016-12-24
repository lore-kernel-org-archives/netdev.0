From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: Sat, 24 Dec 2016 01:12:09 +0100
Message-ID: <254f8cd7-d045-172d-8692-6052d9da287e@stressinduktion.org>
References: <20161223233904.11739.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        ebiggers3@gmail.com, eric.dumazet@gmail.com, Jason@zx2c4.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@kernel.org,
        netdev@vger.kernel.org, tom@herbertland.com, tytso@mit.edu,
        vegard.nossum@gmail.com
To: George Spelvin <linux@sciencehorizons.net>, daniel@iogearbox.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161223233904.11739.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 24.12.2016 00:39, George Spelvin wrote:
> Hannes Frederic Sowa wrote:
>> In general this looks good, but bitbuffer needs to be protected from
>> concurrent access, thus needing at least some atomic instruction and
>> disabling of interrupts for the locking if done outside of
>> get_random_long. Thus I liked your previous approach more where you
>> simply embed this in the already necessary get_random_long and aliased
>> get_random_long as get_random_bits(BITS_PER_LONG) accordingly, IMHO.
> 
> It's meant to be part of the same approach, and I didn't include locking
> because that's a requirement for *any* solution, and isn't specific
> to the part I was trying to illustrate.
> 
> (As for re-using the name "get_random_long", that was just so
> I didn't have to explain it.  Call it "get_random_long_internal"
> if you like.)
> 
> Possible locking implementations include:
> 1) Use the same locking as applies to get_random_long_internal(), or
> 2) Make bitbuffer a per-CPU variable (note that we currently have 128
>    bits of per-CPU state in get_random_int_hash[]), and this is all a
>    fast-path to bypass heavier locking in get_random_long_internal().

I understood that this is definitely a solvable problem.

>>> But, I just realized I've been overlooking something glaringly obvious...
>>> there's no reason you can't compute multple blocks in advance.
>>
>> In the current code on the cost of per cpu allocations thus memory.
> 
> Yes, but on 4-core machines it's still not much, and 4096-core
> behemoths have RAM to burn.
> 
>> In the extract_crng case, couldn't we simply use 8 bytes of the 64 byte
>> return block to feed it directly back into the state chacha? So we pass
>> on 56 bytes into the pcpu buffer, and consume 8 bytes for the next
>> state. This would make the window max shorter than the anti
>> backtracking protection right now from 300s to 14 get_random_int calls.
>> Not sure if this is worth it.
> 
> We just finished discussing why 8 bytes isn't enough.  If you only
> feed back 8 bytes, an attacker who can do 2^64 computation can find it
> (by guessing and computing forward to verify the guess) and recover the
> previous state.  You need to feed back at least as much output as your
> security targete.  For /dev/urandom's ChaCha20, that's 256 bits.

I followed the discussion but it appeared to me that this has the
additional constraint of time until the next reseeding event happenes,
which is 300s (under the assumption that calls to get_random_int happen
regularly, which I expect right now). After that the existing reseeding
mechansim will ensure enough backtracking protection. The number of
bytes can easily be increased here, given that reseeding was shown to be
quite fast already and we produce enough output. But I am not sure if
this is a bit overengineered in the end?

>>> For example, suppose we gave each CPU a small pool to minimize locking.
>>> When one runs out and calls the global refill, it could refill *all*
>>> of the CPU pools.  (You don't even need locking; there may be a race to
>>> determine *which* random numbers the reader sees, but they're equally
>>> good either way.)
> 
>> Yes, but still disabled interrupts, otherwise the same state could be
>> used twice on the same CPU. Uff, I think we have this problem in
>> prandom_u32.
> 
> There are some locking gotchas, but it is doable lock-free.
> 
> Basically, it's a seqlock.  The writer increments it once (to an odd
> number) before starting to overwrite the buffer, and a second time (to
> an even number) after.  "Before" and "after" mean smp_wmb().
> 
> The reader can use this to figure out how much of the data in the buffer
> is safely fresh.  The full sequence of checks is a bit intricate,
> but straightforward.
> 
> I didn't discuss the locking because I'm confident it's solvable,
> not because I wasn't aware it has to be solved.

Also agreed. Given your solution below to prandom_u32, I do think it
might also work without the seqlock now.

> As for prandom_u32(), what's the problem?  Are you worried that
> get_cpu_var disables preemption but not interrupts, and so an
> ISR might return the same value as process-level code?

Yes, exactly those were my thoughts.

> First of all, that's not a problem because prandom_u32() doesn't
> have security guarantees.  Occasionally returning a dupicate number
> is okay.
>
> Second, if you do care, that could be trivially fixed by throwing
> a barrier() in the middle of the code.  (Patch appended; S-o-B
> if anyone wants it.)

I wouldn't have added a disable irqs, but given that I really like your
proposal, I would take it in my todo branch and submit it when net-next
window opens.

> diff --git a/lib/random32.c b/lib/random32.c
> index c750216d..6bee4a36 100644
> --- a/lib/random32.c
> +++ b/lib/random32.c
> [...]

Thanks,
Hannes
