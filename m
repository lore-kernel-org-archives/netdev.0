From: Jeffrey Walton <noloader@gmail.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Sat, 17 Dec 2016 09:55:31 -0500
Message-ID: <CAH8yC8nE5CLfbv8gCRCeiNW3JLCAB3062-6pNO8mEXJYcsFUsw@mail.gmail.com>
References: <20161215203003.31989-1-Jason@zx2c4.com> <20161215203003.31989-2-Jason@zx2c4.com>
Reply-To: noloader@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        linux-crypto@vger.kernel.org,
        David Laight <David.Laight@aculab.com>,
        Ted Tso <tytso@mit.edu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Vegard Nossum <vegard.nossum@gmail.com>, ak@linux.intel.com,
        davem@davemloft.net, luto@amacapital.net,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215203003.31989-2-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/lib/test_siphash.c b/lib/test_siphash.c
> new file mode 100644
> index 000000000000..93549e4e22c5
> --- /dev/null
> +++ b/lib/test_siphash.c
> @@ -0,0 +1,83 @@
> +/* Test cases for siphash.c
> + *
> + * Copyright (C) 2016 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
> + *
> + * This file is provided under a dual BSD/GPLv2 license.
> + *
> + * SipHash: a fast short-input PRF
> + * https://131002.net/siphash/
> + *
> + * This implementation is specifically for SipHash2-4.
> + */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
> +#include <linux/siphash.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/module.h>
> +
> +/* Test vectors taken from official reference source available at:
> + *     https://131002.net/siphash/siphash24.c
> + */
> +static const u64 test_vectors[64] = {
> +       0x726fdb47dd0e0e31ULL, 0x74f839c593dc67fdULL, 0x0d6c8009d9a94f5aULL,
> +       0x85676696d7fb7e2dULL, 0xcf2794e0277187b7ULL, 0x18765564cd99a68dULL,
> +       0xcbc9466e58fee3ceULL, 0xab0200f58b01d137ULL, 0x93f5f5799a932462ULL,
> +       0x9e0082df0ba9e4b0ULL, 0x7a5dbbc594ddb9f3ULL, 0xf4b32f46226bada7ULL,
> +       0x751e8fbc860ee5fbULL, 0x14ea5627c0843d90ULL, 0xf723ca908e7af2eeULL,
> +       0xa129ca6149be45e5ULL, 0x3f2acc7f57c29bdbULL, 0x699ae9f52cbe4794ULL,
> +       0x4bc1b3f0968dd39cULL, 0xbb6dc91da77961bdULL, 0xbed65cf21aa2ee98ULL,
> +       0xd0f2cbb02e3b67c7ULL, 0x93536795e3a33e88ULL, 0xa80c038ccd5ccec8ULL,
> +       0xb8ad50c6f649af94ULL, 0xbce192de8a85b8eaULL, 0x17d835b85bbb15f3ULL,
> +       0x2f2e6163076bcfadULL, 0xde4daaaca71dc9a5ULL, 0xa6a2506687956571ULL,
> +       0xad87a3535c49ef28ULL, 0x32d892fad841c342ULL, 0x7127512f72f27cceULL,
> +       0xa7f32346f95978e3ULL, 0x12e0b01abb051238ULL, 0x15e034d40fa197aeULL,
> +       0x314dffbe0815a3b4ULL, 0x027990f029623981ULL, 0xcadcd4e59ef40c4dULL,
> +       0x9abfd8766a33735cULL, 0x0e3ea96b5304a7d0ULL, 0xad0c42d6fc585992ULL,
> +       0x187306c89bc215a9ULL, 0xd4a60abcf3792b95ULL, 0xf935451de4f21df2ULL,
> +       0xa9538f0419755787ULL, 0xdb9acddff56ca510ULL, 0xd06c98cd5c0975ebULL,
> +       0xe612a3cb9ecba951ULL, 0xc766e62cfcadaf96ULL, 0xee64435a9752fe72ULL,
> +       0xa192d576b245165aULL, 0x0a8787bf8ecb74b2ULL, 0x81b3e73d20b49b6fULL,
> +       0x7fa8220ba3b2eceaULL, 0x245731c13ca42499ULL, 0xb78dbfaf3a8d83bdULL,
> +       0xea1ad565322a1a0bULL, 0x60e61c23a3795013ULL, 0x6606d7e446282b93ULL,
> +       0x6ca4ecb15c5f91e1ULL, 0x9f626da15c9625f3ULL, 0xe51b38608ef25f57ULL,
> +       0x958a324ceb064572ULL
> +};
> +static const siphash_key_t test_key =
> +       { 0x0706050403020100ULL , 0x0f0e0d0c0b0a0908ULL };
> +
> +static int __init siphash_test_init(void)
> +{
> +       u8 in[64] __aligned(SIPHASH_ALIGNMENT);
> +       u8 in_unaligned[65];
> +       u8 i;
> +       int ret = 0;
> +
> +       for (i = 0; i < 64; ++i) {
> +               in[i] = i;
> +               in_unaligned[i + 1] = i;
> +               if (siphash(in, i, test_key) != test_vectors[i]) {
> +                       pr_info("self-test aligned %u: FAIL\n", i + 1);
> +                       ret = -EINVAL;
> +               }
> +               if (siphash_unaligned(in_unaligned + 1, i, test_key) != test_vectors[i]) {
> +                       pr_info("self-test unaligned %u: FAIL\n", i + 1);
> +                       ret = -EINVAL;
> +               }
> +       }
> +       if (!ret)
> +               pr_info("self-tests: pass\n");
> +       return ret;
> +}
> +
> +static void __exit siphash_test_exit(void)
> +{
> +}
> +
> +module_init(siphash_test_init);
> +module_exit(siphash_test_exit);
> +
> +MODULE_AUTHOR("Jason A. Donenfeld <Jason@zx2c4.com>");
> +MODULE_LICENSE("Dual BSD/GPL");
> --
> 2.11.0
>

I believe the output of SipHash depends upon endianness. Folks who
request a digest through the af_alg interface will likely expect a
byte array.

I think that means on little endian machines, values like element 0
must be reversed byte reversed:

    0x726fdb47dd0e0e31ULL => 31,0e,0e,dd,47,db,6f,72

If I am not mistaken, that value (and other tv's) are returned here:

    return (v0 ^ v1) ^ (v2 ^ v3);

It may be prudent to include the endian reversal in the test to ensure
big endian machines produce expected results. Some closely related
testing on an old Apple PowerMac G5 revealed that result needed to be
reversed before returning it to a caller.

Jeff
