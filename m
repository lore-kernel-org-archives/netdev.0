From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: 23 Dec 2016 20:17:54 -0500
Message-ID: <20161224011754.14207.qmail@ns.sciencehorizons.net>
References: <254f8cd7-d045-172d-8692-6052d9da287e@stressinduktion.org>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        ebiggers3@gmail.com, eric.dumazet@gmail.com, Jason@zx2c4.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@kernel.org,
        netdev@vger.kernel.org, tom@herbertland.com, tytso@mit.edu,
        vegard.nossum@gmail.com
To: daniel@iogearbox.net, hannes@stressinduktion.org,
        linux@sciencehorizons.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <254f8cd7-d045-172d-8692-6052d9da287e@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa wrote:
> On 24.12.2016 00:39, George Spelvin wrote:
>> We just finished discussing why 8 bytes isn't enough.  If you only
>> feed back 8 bytes, an attacker who can do 2^64 computation can find it
>> (by guessing and computing forward to verify the guess) and recover the
>> previous state.  You need to feed back at least as much output as your
>> security targete.  For /dev/urandom's ChaCha20, that's 256 bits.

> I followed the discussion but it appeared to me that this has the
> additional constraint of time until the next reseeding event happenes,
> which is 300s (under the assumption that calls to get_random_int happen
> regularly, which I expect right now). After that the existing reseeding
> mechansim will ensure enough backtracking protection. The number of
> bytes can easily be increased here, given that reseeding was shown to be
> quite fast already and we produce enough output. But I am not sure if
> this is a bit overengineered in the end?

I'm not following your description of how the time-based and call-based
mechanisms interact, but for any mix-back, you should either do enough
or none at all.  (Also called "catastrophic reseeding".)

For example, two mix-backs of 64 bits gives you 65 bit security, not 128.
(Because each mixback can be guessed and verified separately.)

> Also agreed. Given your solution below to prandom_u32, I do think it
> might also work without the seqlock now.

It's not technically a seqlock; in particular the reader doesn't
spin.  But the write side, and general logic is so similar it's
a good mental model.

Basically, assume a 64-byte buffer.  The reader has gone through
32 bytes of it, and has 32 left, and when he reads another 8 bytes,
has to distinguish three cases:

1) No update; we read the old bytes and there are now 32 - 24 bytes left.
2) Update completed while we weren't looking.  There are now new
   bytes in the buffer, and we took 8 leaving 64 - 8 = 56.
3) Update in progress at the time of the read.  We don't know if we
   are seeing old bytes or new bytes, so we have to assume the worst
   and not proceeed unless 32 >= 8, but assume at the end there are
   64 - 8 = 56 new bytes left.

> I wouldn't have added a disable irqs, but given that I really like your
> proposal, I would take it in my todo branch and submit it when net-next
> window opens.

If you want that, I have a pile of patches to prandom I really
should push upstream.  Shall I refresh them and send them to you?


commit 4cf1b3d9f4fbccc29ffc2fe4ca4ff52ea77253f1
Author: George Spelvin <linux@horizon.com>
Date:   Mon Aug 31 00:05:00 2015 -0400

    net: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    The net/802 code was already efficient, but prandom_u32_max() is simpler.
    
    In net/batman-adv/bat_iv_ogm.c, batadv_iv_ogm_fwd_send_time() got changed
    from picking a random number of milliseconds and converting to jiffies to
    picking a random number of jiffies, since the number of milliseconds (and
    thus the conversion to jiffies) is a compile-time constant.  The equivalent
    code in batadv_iv_ogm_emit_send_time was not changed, because the number
    of milliseconds is variable.
    
    In net/ipv6/ip6_flowlabel.c, ip6_flowlabel had htonl(prandom_u32()),
    which is silly.  Just cast to __be32 without permuting the bits.
    
    net/sched/sch_netem.c got adjusted to only need one call to prandom_u32
    instead of 2.  (Assuming skb_headlen can't exceed 512 MiB, which is
    hopefully safe for some time yet.)
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 9c8fb80e1fd2be42c35cab1af27187d600fd85e3
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 15:20:47 2014 -0400

    mm/swapfile.c: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 2743eb01e5c5958fd88ae78d19c5fea772d4b117
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 15:19:53 2014 -0400

    lib: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 6a5e91bf395060a3351bfe5efc40ac20ffba2c1b
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 15:18:50 2014 -0400

    fs/xfs: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range".
    
    Also changed the last argument of xfs_error_test() from "unsigned long"
    to "unsigned", since the code never did support values > 2^32, and
    the largest value ever passed is 100.
    
    The code could be improved even further by passing in 2^32/rf rather
    than rf, but I'll leave that to some XFS developers.
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 6f6d485d9179ca6ec4e30caa06ade0e0c6931810
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 15:00:17 2014 -0400

    fs/ubifs: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range".
    
    In fs/ubifs/debug.c, the chance() function got rewritten entirely
    to take advantage of the fact its arguments are always constant.
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 0b6bf2c874bbbcfa74f6be0413c772b3ac134d12
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 14:52:17 2014 -0400

    fs/extX: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range".
    
    In ext4/ialloc.c:436, there's one more chance to do that, but
    the modulo is required to keep the deterministic option consistent,
    so I left it alone.
    
    Switching to "parent_group = ((u64)grp * ngroups) >> 32;" would be more
    efficient, but would change user-visible behavior.
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit e79e0e8b491bc976c0b4e1b2070eccdf55b34f43
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 14:47:15 2014 -0400

    fs/ceph: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit fc628326d8cf4abe364ea01259bc392c0bbaf5a0
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 14:46:29 2014 -0400

    drivers/scsi/fcoe/fcoe_ctlr.c: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 4810d67dd2edf08e7801ef47550d46b7397fe2dc
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 14:45:55 2014 -0400

    drivers/ntb/ntb_hw.c: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit f4a806abbc0785e8f0363e02fac613246eed9e34
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 14:45:27 2014 -0400

    drivers/net: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    In some cases (like ethernet/broadcom/cnic.c and drivers/net/hamradio),
    the range is a compile-time constant power of 2, so the code doesn't
    get any better, but I'm trying to do a full sweep.
    
    In drivers/net/wireless/brcm80211/brcmfmac/p2p.c, a timeout is selected from
    100, 200 or 300 ms.  It would be easy enough to make the granularity finer,
    but I assume the existing code is that way for a reason.
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 603e0c311fac09d633ff6c0fd9242108f1c52ead
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 13:55:09 2014 -0400

    drivers/mtd: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range".
    
    And rewrote the 1-in-N code in drivers/mtd/ubi/debug.h to avoid
    even more arithmetic.
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit e0657cc865e8e02768906935b8e8bf63af58aa46
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 13:52:13 2014 -0400

    drivers/mmc/core: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 017ee6841ec8d416093fc1f18bdd3df0dfc6aacc
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 13:51:33 2014 -0400

    drivers/lguest/page_tables.c: Use prandom_u32_max()
    
    This doesn't actually change the code because the array size is
    a power of 2 (it's a 4-element array).  But I'm on a roll.
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 87556165f46eb42c756bcb94e062c3fbd272a4bf
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 13:49:41 2014 -0400

    drivers/infiniband: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 1eafe1d429f442218810e8c604d4e7c466414cf3
Author: George Spelvin <linux@horizon.com>
Date:   Sun Aug 30 23:42:41 2015 -0400

    block/blk-mq-tag.c: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit f03ee59a63098d244d5b8932fc68c9fc3e2bb222
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 13:46:52 2014 -0400

    arch/x86: Use prandom_u32_max()
    
    It's slightly more efficient than "prandom_u32() % range"
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit feafd3a3fb09924ea633d677a7ab8a25a817f39d
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 13:44:49 2014 -0400

    lib/random32.c: Remove redundant U suffixes on integers
    
    Get rid of a few of the extraneous U suffixes on ordinary integers.
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit f14328d248e59c862478633479528c9cb8554d7a
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 12:40:19 2014 -0400

    lib/random32.c: Randomize timeout to the millisecond, not the second.
    
    If you're going to bother randomizing it, do it right.
    And use prandom_u32_max(), which is designed for the job, rather
    than "% 40".
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 143342006adfff718afedf58f639b72337d7c816
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 12:51:26 2014 -0400

    lib/random32.c: Make prandom_u32_max efficient for powers of 2
    
    The multiply-and-shift is efficient in the general case, but slower
    than a simple bitwise AND if the range is a power of 2.  Make the function
    handle this case so callers don't have to worry about micro-optimizing it.
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 99864db5cb023e6b09d71cde4997a5f6cafb5cca
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 12:02:17 2014 -0400

    lib/random32.c: Use <asm/unaligned.h> instead of hand-rolling it
    
    The functions exist for a reason; the manual byte-at-a-time code
    is unnecessarily slow (and bloated).
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 4ecd45f6eadd4d171782dc6b451ed1040e47d419
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 11:55:59 2014 -0400

    lib/random32.c: Debloat non-speed-critical code
    
    Unrolling code in rarely-used code paths is just silly.  There are
    two places that static calls to prandom_u32_state() can be removed:
    
    1) prandom_warmup() calls prandom_u32_state 10 times.
    2) prandom_state_selftest() can avoid one call and simplify the
       loop logic by repeating an assignment to a local variable
       (which probably adds zero code anyway).
    
    Signed-off-by: George Spelvin <linux@horizon.com>

commit 8765cff45da1d96e4310d50dd49231790c49b612
Author: George Spelvin <linux@horizon.com>
Date:   Sat May 24 11:52:34 2014 -0400

    lib/random32.c: Mark self-test data as __initconst
    
    So it can be thrown away along with the code that uses it.
    
    Signed-off-by: George Spelvin <linux@horizon.com>
