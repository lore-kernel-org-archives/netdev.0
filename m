From: David Miller <davem@davemloft.net>
Subject: Re: [BUG 2.6.18] unaligned access in ipvv6_rcv, nf_ip6_checksum,
 tcp_error, __ipv6_addr_type, fib6_lookup_1
Date: Mon, 09 Oct 2006 18:47:43 -0700 (PDT)
Message-ID: <20061009.184743.112621206.davem@davemloft.net>
References: <20060930202040.GF1083@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
To: laforge@gnumonks.org
In-Reply-To: <20060930202040.GF1083@sunbeam.de.gnumonks.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harald Welte <laforge@gnumonks.org>
Date: Sat, 30 Sep 2006 22:20:40 +0200

> Kernel unaligned access at TPC[10022cf0] ipv6_rcv+0xb8/0x320 [ipv6]
> Kernel unaligned access at TPC[10023800] __ipv6_addr_type+0x8/0x140 [ipv6]
> Kernel unaligned access at TPC[1002fd64] fib6_lookup_1+0x2c/0x120 [ipv6]
> Kernel unaligned access at TPC[10093878] tcp_error+0x40/0x2c0 [nf_conntrack]
> Kernel unaligned access at TPC[1004ce54] nf_ip6_checksum+0x13c/0x1c0 [ipv6]
> Kernel unaligned access at TPC[1004ce58] nf_ip6_checksum+0x140/0x1c0 [ipv6]
> Kernel unaligned access at TPC[1004ce60] nf_ip6_checksum+0x148/0x1c0 [ipv6]

I think for all of these cases the IPv6 header is not 4-byte
aligned in the SKB.  The first case is simply ipv6_hdr->version
which GCC turns into a load of the first 4 byte word of the
headers, then a mask+compare.  And this is fine becasue due
to the "struct in6_addr", gcc may assume that the ipv6 header
struct is at least 4 bytes aligned since in6_addr contains
an array of u32[]'s.

What kind of input path is this packet coming from?  Is it
using some kind of encapsulation?  It's odd for it to not
be 4 byte aligned, you would get the same kind of unaligned
accesses for an ipv4 header if it were misaligned like this.
