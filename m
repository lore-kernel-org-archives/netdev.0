From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH 0/2] New jhash function
Date: Fri,  3 Dec 2010 13:38:59 +0100
Message-ID: <1291379941-31565-1-git-send-email-kadlec@blackhole.kfki.hu>
References: <201011271401.22773.rusty@rustcorp.com.au>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201011271401.22773.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The current jhash.h implements the lookup2() hash function by Bob Jenkins. 
However, lookup2() is outdated as Bob wrote a new hash function called 
lookup3(). There is a longer comparison of those two and other hash
functions at http://burtleburtle.net/bob/hash/doobs.html.

Please consider applying the following patches.

Speed

I wrote a small benchmark program to compare jhash2 and jhash3 (you can
download it from http://www.kfki.hu/~kadlec/sw/netfilter/jhash23.tgz).
On a machine with Core2 Duo and compiled with -O2, the ratio of the execution
time for the byte variants of the hash functions were (in parens the different
key sizes):

jhash2/jhash3 (4 bytes): 1.587518
jhash2/jhash3 (8 bytes): 1.282824
jhash2/jhash3 (12 bytes): 2.349628
jhash2/jhash3 (16 bytes): 1.466988
jhash2/jhash3 (32 bytes): 1.501063
jhash2/jhash3 (64 bytes): 1.587527
jhash2/jhash3 (128 bytes): 1.628037
jhash2/jhash3 (256 bytes): 1.648318

Similarly, for the word variants

jhash2/jhash3 (1 words): 1.300904
jhash2/jhash3 (2 words): 1.316108
jhash2/jhash3 (3 words): 2.249708
jhash2/jhash3 (4 words): 1.460192
jhash2/jhash3 (8 words): 1.501438
jhash2/jhash3 (16 words): 1.558039
jhash2/jhash3 (32 words): 1.520082
jhash2/jhash3 (64 words): 1.528347

Sizes

When compiling just the byte variants the sizes are

   text    data     bss     dec     hex filename
    661       0       0     661     295 jhashb2.o
    441       0       0     441     1b9 jhashb3.o

and for the word variants

   text    data     bss     dec     hex filename
    354       0       0     354     162 jhashw2.o
    248       0       0     248      f8 jhashw3.o

I compiled the kernel with "allyesconfig", in three variants: jhash2, jhash3 and
jhash3 un-inlined

   text    data     bss     dec     hex filename
69297477        11282083        35904032        116483592       6f16608 vmlinux.jhash2
69293829        11282083        35903728        116479640       6f15698 vmlinux.jhash3
69288578        11282083        35902336        116472997       6f13ca5 vmlinux.jhash3-uninlined

With jhash3 we can gain 3.6k and un-inlining shrinks the code with an additional
5.2k. In the patch I left jhash(3) inlined.

Uniformity

According to Bob Jenkins, lookup3() mixes better than lookup2(): it passes
the check that every input bit changes every output bit 50% of the time, while
lookup2() failed it. In order to verify it I added jhash3 to the cttest program,
which tests hash functions with (artifical, worst case) netfilter conntrack data
and calculates the statistics (chi-square, probability of longest bucket, etc).
You can find the program and the results here:
http://www.kfki.hu/~kadlec/sw/netfilter/ct3/ - to sum up, lookup3() produces
uniform key values and no weakness could be spotted.

Many thanks to Eric Dumazet for his thorough reviewing.

Dave applied the first patch to net-next-2.6.

Jozsef Kadlecsik (2):
  Remove calls to jhash internals
  The new jhash implementation

 include/linux/jhash.h            |  183 ++++++++++++++++++++++----------------
 net/ipv6/inet6_connection_sock.c |   18 ++--
 net/ipv6/reassembly.c            |   36 ++++----
 3 files changed, 129 insertions(+), 108 deletions(-)
