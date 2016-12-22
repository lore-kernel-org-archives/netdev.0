From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [kernel-hardening] Re: HalfSipHash Acceptable Usage
Date: 21 Dec 2016 22:55:49 -0500
Message-ID: <20161222035549.10827.qmail@ns.sciencehorizons.net>
References: <CAHmME9pww5Q0Wy9MtkO7PAx2Tstfp=6Og3qZLZ=Rh8NaFo0Gog@mail.gmail.com>
To: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
        hannes@stressinduktion.org, Jason@zx2c4.com,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pww5Q0Wy9MtkO7PAx2Tstfp=6Og3qZLZ=Rh8NaFo0Gog@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Plus the benchmark was bogus anyway, and when I built a more specific
> harness -- actually comparing the TCP sequence number functions --
> SipHash was faster than MD5, even on register starved x86. So I think
> we're fine and this chapter of the discussion can come to a close, in
> order to move on to more interesting things.

Do we have to go through this?  No, the benchmark was *not* bogus.

Here's myresults from *your* benchmark.  I can't reboot some of my test
machines, so I took net/core/secure_seq.c, lib/siphash.c, lib/md5.c and
include/linux/siphash.h straight out of your test tree.

Then I replaced the kernel #includes with the necessary typedefs
and #defines to make it compile in user-space.  (Voluminous but
straightforward.)  E.g.

#define __aligned(x) __attribute__((__aligned__(x)))
#define ____cacheline_aligned __aligned(64)
#define CONFIG_INET 1
#define IS_ENABLED(x) 1
#define ktime_get_real_ns() 0
#define sysctl_tcp_timestamps 0

... etc.

Then I modified your benchmark code into the appended code.  The
differences are:
* I didn't iterate 100K times, I timed the functions *once*.
* I saved the times in a buffer and printed them all at the end
  so printf() wouldn't pollute the caches.
* Before every even-numbered iteration, I flushed the I-cache
  of everything from _init to _fini (i.e. all the non-library code).
  This cold-cache case is what is going to happen in the kernel.

In the results below, note that I did *not* re-flush between phases
of the test.  The effects of cacheing is clearly apparent in the tcpv4
results, where the tcpv6 code loaded the cache.

You can also see that the SipHash code benefits more from cacheing when
entered with a cold cache, as it iterates over the input words, while
the MD5 code is one big unrolled blob.

Order of computation is down the columns first, across second.

The P4 results were:
tcpv6 md5 cold:		4084	3488	3584	3584	3568
tcpv4 md5 cold:		1052	 996	 996	1060	 996
tcpv6 siphash cold:	4080	3296	3312	3296	3312
tcpv4 siphash cold:	2968	2748	2972	2716	2716
tcpv6 md5 hot:		 900	 712	 712	712	 712
tcpv4 md5 hot:		 632	 672	 672	672	 672
tcpv6 siphash hot:	2484	2292	2340	2340	2340
tcpv4 siphash hot:	1660	1560	1564	2340	1564

SipHash actually wins slightly in the cold-cache case, because
it iterates more.  In the hot-cache case, it loses horribly.

Core 2 duo:
tcpv6 md5 cold:		3396	2868	2964	3012	2832
tcpv4 md5 cold:		1368	1044	1320	1332	1308
tcpv6 siphash cold:	2940	2952	2916	2448	2604
tcpv4 siphash cold:	3192	2988	3576	3504	3624
tcpv6 md5 hot:		1116	1032	 996	1008	1008
tcpv4 md5 hot:		 936	 936	 936	 936	 936
tcpv6 siphash hot:	1200	1236	1236	1188	1188
tcpv4 siphash hot:	 936	 804	 804	 804	 804

Pretty much a tie, honestly.

Ivy Bridge:
tcpv6 md5 cold:		6086	6136	6962	6358	6060
tcpv4 md5 cold:		 816	 732	1046	1054	1012
tcpv6 siphash cold:	3756	1886	2152	2390	2566
tcpv4 siphash cold:	3264	2108	3026	3120	3526
tcpv6 md5 hot:		1062	 808	 824	 824	 832
tcpv4 md5 hot:		 730	 730	 740	 748	 748
tcpv6 siphash hot:	 960	 952	 936	1112	 926
tcpv4 siphash hot:	 638	 544	 562	 552	 560

Modern processors *hate* cold caches.  But notice how md5 is *faster*
than SipHash on hot-cache IPv6.

Ivy Bridge, -m64:
tcpv6 md5 cold:		4680	3672	3956	3616	3525
tcpv4 md5 cold:		1066	1416	1179	1179	1134
tcpv6 siphash cold:	 940	1258	1995	1609	2255
tcpv4 siphash cold:	1440	1269	1292	1870	1621
tcpv6 md5 hot:		1372	1111	1122	1088	1088
tcpv4 md5 hot:		 997	 997	 997	 997	 998
tcpv6 siphash hot:	 340	 340	 340	 352	 340
tcpv4 siphash hot:	 227	 238	 238	 238	 238

Of course, when you compile -m64, SipHash is unbeatable.


Here's the modified benchmark() code.  The entire package is
a bit voluminous for the mailing list, but anyone is welcome to it.

static void clflush(void)
{
	extern char const _init, _fini;
	char const *p = &_init;

	while (p < &_fini) {
		asm("clflush %0" : : "m" (*p));
		p += 64;
	}
}

typedef uint32_t cycles_t;
static cycles_t get_cycles(void)
{
	uint32_t eax, edx;
	asm volatile("rdtsc" : "=a" (eax), "=d" (edx));
	return eax;
}

static int benchmark(void)
{
	cycles_t start, finish;
	int i;
	u32 seq_number = 0;
	__be32 saddr6[4] = { 1, 4, 182, 393 }, daddr6[4] = { 9192, 18288, 2222222, 0xffffff10 };
	__be32 saddr4 = 28888, daddr4 = 182112;
	__be16 sport = 22, dport = 41992;
	u32 tsoff;
	cycles_t result[4];

	printf("seq num benchmark\n");

	for (i = 0; i < 10; i++) {
		if ((i & 1) == 0)
			clflush();

		start = get_cycles();
		seq_number += secure_tcpv6_sequence_number_md5(saddr6, daddr6, sport, dport, &tsoff);
		finish = get_cycles();
		result[0] = finish - start;

		start = get_cycles();
		seq_number += secure_tcp_sequence_number_md5(saddr4, daddr4, sport, dport, &tsoff);
		finish = get_cycles();
		result[1] = finish - start;

		start = get_cycles();
		seq_number += secure_tcpv6_sequence_number(saddr6, daddr6, sport, dport, &tsoff);
		finish = get_cycles();
		result[2] = finish - start;

		start = get_cycles();
		seq_number += secure_tcp_sequence_number(saddr4, daddr4, sport, dport, &tsoff);
		finish = get_cycles();
		result[3] = finish - start;

		printf("* Iteration %d results:\n", i);
		printf("secure_tcpv6_sequence_number_md5# cycles: %u\n", result[0]);
		printf("secure_tcp_sequence_number_md5# cycles: %u\n", result[1]);
		printf("secure_tcpv6_sequence_number_siphash# cycles: %u\n", result[2]);
		printf("secure_tcp_sequence_number_siphash# cycles: %u\n", result[3]);
		printf("benchmark result: %u\n", seq_number);
	}

	printf("benchmark result: %u\n", seq_number);
	return 0;
}
//device_initcall(benchmark);

int
main(void)
{
	memset(net_secret, 0xff, sizeof net_secret);
	memset(net_secret_md5, 0xff, sizeof net_secret_md5);
	return benchmark();
}
