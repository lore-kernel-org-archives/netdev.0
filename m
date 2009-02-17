From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Tue, 17 Feb 2009 18:13:04 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0902171723330.27283@blackhole.kfki.hu>
References: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu>  <20090212001223.GA5757@movementarian.org>  <alpine.DEB.2.00.0902121006440.18739@blackhole.kfki.hu> <f73f7ab80902120546w2ac30501v10fc55b9c8270be9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <f73f7ab80902120546w2ac30501v10fc55b9c8270be9@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 12 Feb 2009, Kyle Moffett wrote:

> On Thu, Feb 12, 2009 at 4:11 AM, Jozsef Kadlecsik
> <kadlec@blackhole.kfki.hu> wrote:
> > The current jhash.h implements the lookup2() hash function by Bob Jenkins.
> > However, lookup2() is outdated as Bob wrote a new hash function called
> > lookup3(). The new hash function
> >
> > - mixes better than lookup2(): it passes the check that every input bit
> >  changes every output bit 50% of the time, while lookup2() failed it.
> > - performs better: compiled with -O2 on Core2 Duo, lookup3() 20-40% faster
> >  than lookup2() depending on the key length.
> 
> Well, there's another question which is not addressed by Bob Jenkins'
> design docs:
> 
> Kernel code usually runs cache-cold, whereas Bob Jenkins did most of
> his testing cache-hot in tight loops.  If you compile both lookup2 and
> lookup3 with -Os and run them in a loop with a cache flush, how well
> do they compare then?

In order to get as much data as possible, I dusted off the good old cttest 
program which was used long time ago to test and pick the currently used 
lookup2 function. I added lookup3 to cttest, converted the internals to 
follow the current netfilter/conntrack hash lookup usage and introduced a 
large enough input buffer to force cold cache. I also added the superfast 
hash by Paul Hsieh and murmur2 hash of Austin Appleby, to check those as 
well.

The test program and all the generated html pages and graphs are at
http://www.kfki.hu/~kadlec/sw/netfilter/ct3/. Here follows just a terse 
summary:

- Superfasthash is definitely not good enough as it can too easily 
  produce just too much clashes.
- The murmur2 hash is the fastest one and looks quite good, still it
  had got some trouble at specific hash table sizes.
- No weakness could be spotted with the lookup3 hash.
- When compiling with -Os, the hashes from fastest to slowest are:
  murmur2, lookup3, superfast, lookup2.
- When compiling with -O2, the hashes from fastest to slowest are:
  murmur2, superfast, lookup3 and lookup2.

On Thu, 12 Feb 2009, Rusty Russell wrote:

> My concern was that it's also bigger (and we inline it).  Performance is
> pretty much a wash since we so rarely hash more than a few words.

In netfilter/conntrack (;-) we call the hash function for every packet, so 
even if a small number of cycle can be gained at one lookup, I think it's 
worth. And in the IPv4/IPv6 neutral nf_conntrack we hash 9 words.

> Any stats on code size changes?

The minimal code here

#include <stdint.h>

typedef uint64_t u64;
typedef uint32_t u32;
typedef uint16_t u16;
typedef uint8_t u8;

#ifdef JHASH
#include "jhash.h"
#else
#include "jhash3.h"
#endif

u32 hash(const u32 *key, u32 len, u32 initval)
{
        return jhash2(key, len, initval);
}
/* eof */

compiled with -Os, then stripped, give:

-rw-r--r-- 1 kadlec kadlec 1080 2009-02-17 14:10 lookup2.o
-rw-r--r-- 1 kadlec kadlec 1024 2009-02-17 14:10 lookup3.o

So I think the currently used lookup2 can safely be replaced with lookup3.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
