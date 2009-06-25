From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Thu, 25 Jun 2009 23:19:45 +0200
Message-ID: <4A43E9F1.90209@cosmosbay.com>
References: <4A439C6B.9090502@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49524 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZFYVTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 17:19:53 -0400
In-Reply-To: <4A439C6B.9090502@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=B3 Staszewski a =E9crit :
> Hello ALL
>=20
> Some time ago i report this:
> http://bugzilla.kernel.org/show_bug.cgi?id=3D6648
>=20
> and now with 2.6.29 / 2.6.29.1 / 2.6.29.3 and 2.6.30 it back
> dmesg output:
> oprofile: using NMI interrupt.
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits
> Fix inflate_threshold_root. Now=3D15 size=3D11 bits

Curious, you seem to hit an old alloc_pages limit()... (MAX_ORDER alloc=
ation)

Your root node has 2^18 =3D 262144 pointers of 8 bytes -> 2097152 bytes=
 (+ header -> 4194304 bytes)

But since following commit, we should use vmalloc() so this PAGE_SIZE<<=
10) limit
should not anymore be applied.

Could you do a "cat /proc/vmallocinfo" just to check your big tnodes ar=
e vmalloced() ?


commit 15be75cdb5db442d0e33d37b20832b88f3ccd383
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Thu Apr 10 02:56:38 2008 -0700

    IPV4: fib_trie use vmalloc for large tnodes

    Use vmalloc rather than alloc_pages to avoid wasting memory.
    The problem is that tnode structure has a power of 2 sized array,
    plus a header. So the current code wastes almost half the memory
    allocated because it always needs the next bigger size to hold
    that small header.

    This is similar to an earlier patch by Eric, but instead of a list
    and lock, I used a workqueue to handle the fact that vfree can't
    be done in interrupt context.

    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


>=20
> cat /proc/net/fib_triestat
> Basic info: size of leaf: 40 bytes, size of tnode: 56 bytes.
> Main:
>        Aver depth:     2.28
>        Max depth:      6
>        Leaves:         276539
>        Prefixes:       289922
>        Internal nodes: 66762
>          1: 35046  2: 13824  3: 9508  4: 4897  5: 2331  6: 1149  7: 5=
=20
> 9: 1  18: 1
>        Pointers: 691228
> Null ptrs: 347928
> Total size: 35709  kB
>=20
> Counters:
> ---------
> gets =3D 26276593
> backtracks =3D 547306
> semantic match passed =3D 26188746
> semantic match miss =3D 1117
> null node hit=3D 27285055
> skipped node resize =3D 0
>=20
> Local:
>        Aver depth:     3.33
>        Max depth:      4
>        Leaves:         9
>        Prefixes:       10
>        Internal nodes: 8
>          1: 8
>        Pointers: 16
> Null ptrs: 0
> Total size: 2  kB
>=20
> Counters:
> ---------
> gets =3D 26642350
> backtracks =3D 1282818
> semantic match passed =3D 18166
> semantic match miss =3D 0
> null node hit=3D 0
> skipped node resize =3D 0
>=20
>=20
>=20
> This machine is running bgpd with two bgp peers / full route table
>=20
> cat /proc/meminfo
> MemTotal:       12279032 kB
> MemFree:        11521920 kB
> Buffers:           80288 kB
> Cached:            34416 kB
> SwapCached:            0 kB
> Active:           286816 kB
> Inactive:          82024 kB
> Active(anon):     254296 kB
> Inactive(anon):        0 kB
> Active(file):      32520 kB
> Inactive(file):    82024 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> SwapTotal:        987988 kB
> SwapFree:         987988 kB
> Dirty:              1140 kB
> Writeback:             0 kB
> AnonPages:        254164 kB
> Mapped:             5440 kB
> Slab:             365084 kB
> SReclaimable:      28784 kB
> SUnreclaim:       336300 kB
> PageTables:         2104 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     7127504 kB
> Committed_AS:     267704 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:       11824 kB
> VmallocChunk:   34359707815 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:        3392 kB
> DirectMap2M:    12578816 kB
>=20
>=20
> Interfaces mtu is1500

