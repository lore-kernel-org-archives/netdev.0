From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v6 0/5] The SipHash Patchset
Date: Fri, 16 Dec 2016 04:03:23 +0100
Message-ID: <20161216030328.11602-1-Jason@zx2c4.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
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
        davem@davemloft.net, luto@amacapital.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161215203003.31989-1-Jason@zx2c4.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey again,

This keeps getting more ambitious, which is good I suppose. If the frequency
of new versioned patchsets is too high for LKML and not customary, please let
me know. Otherwise, read on to see what's new this time...

With Hannes' suggestion, there is now only one siphash() function, which will
use the faster aligned version by compile-time constant folding. Additionally,
I now use constant folding to optionally switch to the helper siphash_Nu64
functions that are a bit faster for data of length 8, 16, 24, and 32. So, the
result is that you use siphash(data, len, key) if you have a buffer of sorts,
and then everything is taken care of for you. Or, if you have a series of
integers, you can opt to use siphash_Nu{32,64} functions instead. The basic
API is now complete.

After replacing MD5 in secure sequence number generation and the RNG, it
turned out that md5_transform wasn't used any place else in the tree, so
finally -- this is something to rejoice over -- lib/md5.c has been deleted and
now that function lives as a static function in crypto/md5.c where it belongs.

Meanwhile, it seems that sha_transform is used in places where SipHash would
be more fitting, so the IPv4 and IPv6 syncookies implementation now uses
SipHash, which should speed up TCP performance. Some BSDs already do this.

I'd like to replace sha_transform in addrconf, but that code is a bit gnarley,
so I don't want to be too meddlesome. I'm not entirely convinced either that
SipHash is a good choice for it. But I'm open to discussion here, so if you
have an opinion, please speak up.

If you've been following the evolution of this patchset, and think that
certain patches in it are fine, please do lend me your Reviewed-by to carry
into any subsequent versions, so that in case you disappear your useful
reviews will still keep the ball moving.

Thanks for all the great feedback thus far.

Jason

Jason A. Donenfeld (5):
  siphash: add cryptographically secure PRF
  secure_seq: use SipHash in place of MD5
  random: use SipHash in place of MD5
  md5: remove from lib and only live in crypto
  syncookies: use SipHash in place of SHA1

 MAINTAINERS             |   7 ++
 crypto/md5.c            |  95 +++++++++++++++++++++-
 drivers/char/random.c   |  32 +++-----
 include/linux/siphash.h |  86 ++++++++++++++++++++
 lib/Kconfig.debug       |   6 +-
 lib/Makefile            |   7 +-
 lib/md5.c               |  95 ----------------------
 lib/siphash.c           | 210 ++++++++++++++++++++++++++++++++++++++++++++++++
 lib/test_siphash.c      | 101 +++++++++++++++++++++++
 net/core/secure_seq.c   | 133 ++++++++++++------------------
 net/ipv4/syncookies.c   |  20 +----
 net/ipv6/syncookies.c   |  37 ++++-----
 12 files changed, 590 insertions(+), 239 deletions(-)
 create mode 100644 include/linux/siphash.h
 delete mode 100644 lib/md5.c
 create mode 100644 lib/siphash.c
 create mode 100644 lib/test_siphash.c

-- 
2.11.0
