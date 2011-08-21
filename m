From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/2] Improve sequence number generation.
Date: Sun, 21 Aug 2011 03:28:44 +0200
Message-ID: <20110821012844.GA15222@1wt.eu>
References: <20110816103028.1360.qmail@science.horizon.com> <20110820233951.6428.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mpm@selenic.com, dan@doxpara.com,
	gerrit@erg.abdn.ac.uk, herbert@gondor.hengli.com.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: George Spelvin <linux@horizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110820233951.6428.qmail@science.horizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi George,

On Sat, Aug 20, 2011 at 07:39:51PM -0400, George Spelvin wrote:
(...)
> A few questions, all related to performance requirements:
> * Should I worry about 32-bit x86 performance at all, since it's
>   pretty unlikely that a 32-bit machine will be running traffic levels
>   (1000+ connections/sec) where it matters?

1000 connections per second is a moderately low load even for a
32-bit machine. I'm used to play in the 10-100k/s range on 32-bit,
depending on the usage pattern, I even reached 300k/s on an anti-ddos
machine. So yes, performance matters a lot, especially when we risk
to slow down one small operation that is done many times a second.

> * Should I worry about 32-bit IPv6 performance, since that's even more
>   unlikely to be running heavy loads on 32-bit hardware?

On x86 you're probably right, but there are other very fast platforms
such as ARM, which are used to build routers or appliances, and which
are 32-bit and there it may matter.

> * If yes, is this fast enough to be acceptable, or do I need to work
>   harder to find more speed?

I'd suggest that the most important is no performance regression. Probably
that if you can bring something which brings back what we lost with MD5,
your work would gain interest.

> Willy, apparently you did some benchmarking of various hash functions.
> Is that data available somewhere?  Even if not, just a brief description
> of the methodology and assumptions would help to make sure I'm measuring
> in a reasonable way.

I'm copy-pasting here the memo I exchanged in private after my tests, there
is nothing secret in it, so better post the whole explanation :

-------------------------------------------------------------------------
I did an ugly patch which consists in replacing calls to md5_transform()
with sha_transform() in secure_ip_id(), secure_tcp_sequence_number(),
secure_ipv4_port_ephemeral() on top of David's patches. I kept the same
hashing method, without calling sha_init() and by filling the hash with
net_secret, eg :

@@ -104,28 +107,32 @@ __u32 secure_ipv6_id(const __be32 daddr[4])
 __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
                                 __be16 sport, __be16 dport)
 {
-       u32 hash[MD5_DIGEST_WORDS];
+       u32 hash[SHA_DIGEST_WORDS];
+       u32 workspace[SHA_WORKSPACE_WORDS];

        hash[0] = (__force u32)saddr;
        hash[1] = (__force u32)daddr;
        hash[2] = ((__force u16)sport << 16) + (__force u16)dport;
-       hash[3] = net_secret[15];
+       hash[3] = net_secret[14];
+       hash[4] = net_secret[15];

-       md5_transform(hash, net_secret);
+       sha_transform(hash, (const char *)net_secret, workspace);

        return seq_scale(hash[0]);
 }


With this I could run tests on mainline (called "MD4" below), David's code
("MD5") and the transform above ("SHA1"). The tests involved connecting
from the test machine to an external HTTP server and retrieving an empty
object. This test was followed by two other series, one on a server which
immediately resets upon accept (to reproduce the SYN, SYN/ACK, ACK, RST
sequence I'm used to encounter when setting up anti-DDoS filters), and
a SYN, RST sequence caused by sending the traffic to a closed port, in
order to more accurately observe the differences.

I switch the test machine to an Atom N450 running in 64-bit mode in order
to benefit from the SHA1 optimizations.

Numbers are in connections per second.

kernel   http   RST server   closed port
-------+------+------------+------------
 MD4     9610      7840       16950
 MD5     9340      7560       16360
 SHA1    9250      7280       15400

In HTTP, performance drops by 2.8% when switching to MD5, and by 3.75
when using SHA1 instead. With the reset server, MD5 takes a 3.6% hit
and SHA1 7.15%. On the closed port test, which sees only SYN and RST
packets, MD5 takes a 3.5% hit and SHA1 a 9.15% one.

Note that the biggest hit was still the 2.6.35.11 -> 3.0-git upgrade,
because HTTP gives me 10040 cps in 2.6.35.11. I think it's the compiler
and not the kernel : I used to build 2.6.35 with gcc-3.4 but had to
use a more recent toolchain (gcc 4.4) with 3.0 due to cmpxchg16b, and
my experience with gcc has always been a noticeable performance loss
with each new version, so that seems consistent...

All in all, while the SHA1 cost becomes concerning, it could be used
as an alternative to MD5 when we add a sysctl to select between
performance and security.
-------------------------------------------------------------------------

Note that this wasn't the best machine for the test, but it was available
and moreover it required little additional hardware to saturate it ;-)

Best regards,
Willy
