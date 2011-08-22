From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 0/2] Improve sequence number generation.
Date: 21 Aug 2011 22:06:08 -0400
Message-ID: <20110822020608.11889.qmail@science.horizon.com>
References: <20110821032753.GA8992@thunk.org>
Cc: dan@doxpara.com, davem@davemloft.net, gerrit@erg.abdn.ac.uk,
	herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org,
	mpm@selenic.com, netdev@vger.kernel.org, w@1wt.eu
To: linux@horizon.com, tytso@mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:42433 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756589Ab1HVCGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 22:06:11 -0400
In-Reply-To: <20110821032753.GA8992@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Here's a random thought --- it won't help on anything other than
> modern x86's, but who's to say we have to use the same algorithm on
> all platforms?

We absolutely do not.  With 15 64-bit registers, there are a lot more
efficient algorithms available than x86-32.

Here are my current timing experiments trying to find an efficient
hash for that case.  Timings are for 100,000 iterations, so these are
generally in the 100-200 cycles range per operation.

This is 32-bit code, even though it's running on 64-bit machines.


The first 3 are various MD5 implementations (standard, with the k[]
constants in an external array, with the input and K values scheduled
separately so it's a 64-word linear fetch while running).

Then are three similar variants of two-at-a-time MD5 computation.
The lines reporting 0 time are the second outputs.

The last two MD5 timings (9 and 10) are the current half_md4_transform
and twothirdsMD4Transform.  Those are the timing figures to match,
or preferably beat.

ChaCha is 8 rounds, and simply not fast enough.

The Skein192 (to be renamed; it's NOT approved by the designers!) is a
36-round, 6x32-bit variant of the SHA-3 candidate Skein.  0 is C code,
1 and 2 are rolled up assembly variants, 3 and 4 are unrolled assembly,
and 5 is unrolled assembly that also drops the tweak words.  (Which is
hardly important if we're only hashing one block.)

That, as you can see, is about half the time of MD5 and competitive with
the 2/3 MD4.  And probably considerably more secure.  (It's basically a
secure 192-bit hash with zero margin; I could maybe shave another couple
of rounds and still have 128-bit security.)

Shabal is a supposedly-fast SHA-3 candidate that made it to round 2,
just to see what the timing is like.  The second line is a half-size
variant that works on 8 as opposed to 16 words at a time.

2.4 GHz Phenom, hot cache:
MD5 (& half MD4) implementations:
 0:  36912577 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 1:  36937728 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 2:  37354723 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 3:  58866027 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 4:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 5:  96074375 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 6:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 7: 101722571 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 8:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 9:  12321905 cycles  b4b721c6 5635b583 b06c6474 c9871bee
10:  18038018 cycles  336f8820 5565aa9b 0133a23a 0b62780f

ChaCha implementations:
 0:  37345090 cycles  751ddf6a 6977b031 60730a4f c1e2d89e
 1:  30782411 cycles  d5fec2fe a8937844 33da9645 cbff3484

Skein192 implementations:
 0:  30343213 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 1:  22137253 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 2:  22439643 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 3:  18189990 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 4:  19025781 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 5:  17335443 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7

Shabal implementations:
 0: 177585782 cycles  6c192c71 ed0912f7 ec4513bb c8f03710 8e4e71b2 5200adff f4f40b0c 81ab7e54
 1:  88048716 cycles  51e5dab0 ed0912f7 ec4513bb c8f03710 8e4e71b2 5200adff f4f40b0c 81ab7e54


2.4 GHz Phenom, "cool cache": Run each of the 20 code paths once, then repeat 100,000 times.
MD5 (& half MD4) implementations:
 0:  43746107 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 1:  43682485 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 2:  43554706 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 3:  65376283 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 4:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 5: 105050654 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 6:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 7: 109949761 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 8:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 9:  19284802 cycles  b4b721c6 5635b583 b06c6474 c9871bee
10:  24359312 cycles  336f8820 5565aa9b 0133a23a 0b62780f

ChaCha implementations:
 0:  46379423 cycles  751ddf6a 6977b031 60730a4f c1e2d89e
 1:  38641131 cycles  d5fec2fe a8937844 33da9645 cbff3484

Skein192 implementations:
 0:  38125833 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 1:  31800936 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 2:  29010869 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 3:  25627838 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 4:  25913924 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 5:  24318110 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7

Shabal implementations:
 0: 185723030 cycles  6c192c71 ed0912f7 ec4513bb c8f03710 8e4e71b2 5200adff f4f40b0c 81ab7e54
 1:  92834811 cycles  51e5dab0 ed0912f7 ec4513bb c8f03710 8e4e71b2 5200adff f4f40b0c 81ab7e54


2.67 GHz i7 (Xeon W3520), hot cache:
MD5 (& half MD4) implementations:
 0:  36919956 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 1:  37156578 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 2:  35044283 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 3:  61506553 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 4:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 5:  97228616 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 6:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 7: 102025434 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 8:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 9:  11890788 cycles  b4b721c6 5635b583 b06c6474 c9871bee
10:  19542853 cycles  336f8820 5565aa9b 0133a23a 0b62780f

ChaCha implementations:
 0:  32864931 cycles  751ddf6a 6977b031 60730a4f c1e2d89e
 1:  28502254 cycles  d5fec2fe a8937844 33da9645 cbff3484

Skein192 implementations:
 0:  28894544 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 1:  25963843 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 2:  26394942 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 3:  22960214 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 4:  22458045 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 5:  21020691 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7

Shabal implementations:
 0: 107339671 cycles  6c192c71 ed0912f7 ec4513bb c8f03710 8e4e71b2 5200adff f4f40b0c 81ab7e54
 1:  52250187 cycles  51e5dab0 ed0912f7 ec4513bb c8f03710 8e4e71b2 5200adff f4f40b0c 81ab7e54


2.67 GHz i7 (Xeon W3520), cool cache:
MD5 (& half MD4) implementations:
 0:  38680693 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 1:  37812504 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 2:  35577261 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 3:  60584516 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 4:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 5:  96525869 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 6:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 7:  98360974 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 8:         0 cycles  16d174cf 10a7082f e1a2b897 3faddc63
 9:  13622987 cycles  b4b721c6 5635b583 b06c6474 c9871bee
10:  20895171 cycles  336f8820 5565aa9b 0133a23a 0b62780f

ChaCha implementations:
 0:  34210571 cycles  751ddf6a 6977b031 60730a4f c1e2d89e
 1:  29135985 cycles  d5fec2fe a8937844 33da9645 cbff3484

Skein192 implementations:
 0:  29621108 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 1:  27885244 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 2:  26022084 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 3:  22360719 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 4:  24639107 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7
 5:  21072150 cycles  646ce01c 7f2228dd 229a336d 033748b5 0de3a665 c79cf4f7

Shabal implementations:
 0: 105186652 cycles  6c192c71 ed0912f7 ec4513bb c8f03710 8e4e71b2 5200adff f4f40b0c 81ab7e54
 1:  57009351 cycles  51e5dab0 ed0912f7 ec4513bb c8f03710 8e4e71b2 5200adff f4f40b0c 81ab7e54
