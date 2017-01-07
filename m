From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH net-next 1/4] siphash: add cryptographically secure PRF
Date: Sat, 7 Jan 2017 14:11:23 +0100
Message-ID: <CAHmME9rfpA_yZ6Es--O04jbzANbGvUP21xH6pux+dWA5tv1QnA@mail.gmail.com>
References: <20170106.145737.1436197697379516563.davem@davemloft.net>
 <20170106201055.13765-1-Jason@zx2c4.com> <20170106201055.13765-2-Jason@zx2c4.com>
 <20170107040459.GA575@zzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        David Laight <David.Laight@aculab.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:40286 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937916AbdAGNL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 7 Jan 2017 08:11:29 -0500
In-Reply-To: <20170107040459.GA575@zzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for the review. I wish we had gotten to this much earlier
before the merge, when there were quite a few revisions and
refinements, but better late than never, and I'm quite pleased to have
your feedback for making this patchset perfect. Comments are inline
below.

On Sat, Jan 7, 2017 at 5:04 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
> I was confused by all the functions passing siphash_key_t "by value" until I saw
> that it's actually typedefed to u64[2].  Have you considered making it a struct
> instead, something like this?
>
> typedef struct {
>         u64 v[2];
> } siphash_key_t;

That's a good idea. I'll make this change.

>
>> +static inline u64 ___siphash_aligned(const __le64 *data, size_t len, const siphash_key_t key)
>> +{
>> +     if (__builtin_constant_p(len) && len == 4)
>> +             return siphash_1u32(le32_to_cpu(data[0]), key);
>
> Small bug here: data[0] is not valid if len is 4.  This can be fixed by casting
> to a le32 pointer:
>
>                 return siphash_1u32(le32_to_cpup((const __le32 *)data), key);

Since data[0] is then passed to a function that takes a u32, gcc
actually does the right thing here and doesn't generate an out of
bounds read. But of course this isn't good behavior to rely on. I'll
fix this up. Thanks for catching it.

>
>> +static int __init siphash_test_init(void)
>> +{
>> +     u8 in[64] __aligned(SIPHASH_ALIGNMENT);
>> +     u8 in_unaligned[65];
>
> It seems that in_unaligned+1 is meant to be misaligned, but that's not
> guaranteed because in_unaligned has no alignment restriction, so it could
> theoretically be misaligned in a way that makes in_unaligned+1 aligned.  So it
> should be 'in_unaligned[65] __aligned(SIPHASH_ALIGNMENT)'.

Thanks, will do.

>
> There are also a lot of checkpatch warnings produced by this patch.  It looks
> like many of them can be ignored, but there may be some that should be
> addressed.

Will have a look and address for v2.

Thanks again for your review!

Regards,
Jason
