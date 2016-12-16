From: "George Spelvin" <linux@sciencehorizons.net>
Subject: RE: [PATCH v5 2/4] siphash: add Nu{32,64} helpers
Date: 16 Dec 2016 10:44:33 -0500
Message-ID: <20161216154433.19337.qmail@ns.sciencehorizons.net>
References: <063D6719AE5E284EB5DD2968C1650D6DB0240EFA@AcuExch.aculab.com>
To: ak@linux.intel.com, davem@davemloft.net, David.Laight@ACULAB.COM,
        ebiggers3@gmail.com, hannes@stressinduktion.org, Jason@zx2c4.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.sciencehorizons.net ([71.41.210.147]:31297 "HELO
        ns.sciencehorizons.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1761877AbcLPPof (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 10:44:35 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0240EFA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason A. Donenfeld wrote:
> Isn't that equivalent to:
>	v0 = key[0];
>	v1 = key[1];
>	v2 = key[0] ^ (0x736f6d6570736575ULL ^ 0x646f72616e646f6dULL);
>	v3 = key[1] ^ (0x646f72616e646f6dULL ^ 0x7465646279746573ULL);

(Pre-XORing key[] with the first two constants which, if the constants
are random in the first place, can be a no-op.)  Other than the typo
in the v2 line, yes.  If they key is non-public, then you can xor an
arbitrary constant in to both halves to slightly speed up the startup.

(Nits: There's a typo in the v2 line, you don't need to parenthesize
associative operators like xor, and the "ull" suffix is redundant here.)

> Those constants also look like ASCII strings.

They are.  The ASCII is "somepseudorandomlygeneratedbytes".

> What cryptographic analysis has been done on the values?

They're "nothing up my sleeve numbers".

They're arbitrary numbers, and almost any other values would do exactly
as well.  The main properties are:

1) They're different (particulatly v0 != v2 and v1 != v3), and
2) Neither they, nor their xor, is rotationally symmetric like 0x55555555.
   (Because SipHash is mostly rotationally symmetric, broken only by the
   interruption of the carry chain at the msbit, it helps slightly
   to break this up at the beginning.)

Those exact values only matter for portability.  If you don't need anyone
else to be able to compute matching outputs, then you could use any other
convenient constants (like the MD5 round constants).
