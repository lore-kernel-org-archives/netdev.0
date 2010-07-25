From: Ofer Heifetz <oferh@marvell.com>
Subject: RE: Splice status
Date: Sun, 25 Jul 2010 17:47:56 +0300
Message-ID: <EE71107DF0D1F24FA2D95041E64AB9E80114797BC8AB@IL-MB01.marvell.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	 <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	 <1278334254.2877.158.camel@edumazet-laptop>
	 <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
	 <1278388580.2466.305.camel@edumazet-laptop>
	 <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED254E7B66@IL-MB01.marvell.com>
 <1279030308.2634.349.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:53520 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab0GYOte convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 10:49:34 -0400
In-Reply-To: <1279030308.2634.349.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Still trying to get better performance with splice, I noticed that when=
 using splice there are twice the file size memcpy (placed a counter in=
 memcpy), I verified it via samba file transfer and splice-fromnet/out.

I also used the splice-fromnet/out and using ftrace I did notice that d=
ata is copied twice using these routines: skb_splice_bits, pipe_to_file=
=2E

I thought that the main goal of splice is to refrain from one copy when=
 moving data from network to file descriptor.

If there are the same number of memcpy and context switches and in samb=
a copy additional vfs overhead it makes sense that splice deteriates th=
e samba overall write performance.

-Ofer

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Tuesday, July 13, 2010 5:12 PM
To: Ofer Heifetz
Cc: Changli Gao; Jens Axboe; netdev@vger.kernel.org
Subject: RE: Splice status

Le mardi 13 juillet 2010 =E0 14:41 +0300, Ofer Heifetz a =E9crit :
> Hi,
>=20
> I wanted to let you know that I have been testing Samba splice on Mar=
vell 6282 SoC on 2.6.35_rc3 and noticed that it gave worst performance =
than not using it and also noticed that on re-writing file the iowait i=
s high.
>=20
> iometer using 2G file (file is created before test)
>=20
> Splice  write cpu% iow%
> -----------------------
>  No     58    98    0
> Yes     14   100   48
>=20
> iozone using 2G file (file created during test)
>=20
> Splice  write cpu% iow%  re-write cpu% iow% =20
> -------------------------------------------
>  No     35    85    4    58.2     70    0
> Yes     33    85    4    15.7    100   58
>=20
> Any clue why splice introduces a high iowait?
> I noticed samba uses up to 16K per splice syscall, changing the samba=
 to try more did not help, so I guess it is a kernel limitation.
>=20

splice(socket -> pipe) provides partial buffers (depending on the MTU)

With typical MTU=3D1500 and tcp timestamps, each network frame contains
1448 bytes of payload, partially filling one page (of 4096 bytes)

When doing the splice(pipe -> file), kernel has to coalesce partial
data, but amount of written data per syscall() is small (about 20
Kbytes)

Without splice(), the write() syscall provides more data, and vfs
overhead is smaller as buffer size is a power of two.

Samba uses a 128 KBytes TRANSFER_BUF_SIZE in its default_sys_recvfile()
implementation, it easily outperforms splice() implementation.

You could try extending pipe size (fcntl(fd, F_SETPIPE_SZ, 256)), maybe
it will be a bit better. (and ask 256*4096 bytes to splice())

I tried this and got about 256Kbytes per splice() call...

# perf report
# Events: 13K
#
# Overhead         Command      Shared Object  Symbol
# ........  ..............  .................  ......
#
     8.69%  splice-fromnet  [kernel.kallsyms]  [k] memcpy
     3.82%  splice-fromnet  [kernel.kallsyms]  [k] kunmap_atomic
     3.51%  splice-fromnet  [kernel.kallsyms]  [k] __block_prepare_writ=
e
     2.79%  splice-fromnet  [kernel.kallsyms]  [k] __skb_splice_bits
     2.58%  splice-fromnet  [kernel.kallsyms]  [k] ext3_mark_iloc_dirty
     2.45%  splice-fromnet  [kernel.kallsyms]  [k] do_get_write_access
     2.04%  splice-fromnet  [kernel.kallsyms]  [k] __find_get_block
     1.89%  splice-fromnet  [kernel.kallsyms]  [k] _raw_spin_lock
     1.83%  splice-fromnet  [kernel.kallsyms]  [k] journal_add_journal_=
head
     1.46%  splice-fromnet  [bnx2x]            [k] bnx2x_rx_int
     1.46%  splice-fromnet  [kernel.kallsyms]  [k] kfree
     1.42%  splice-fromnet  [kernel.kallsyms]  [k] journal_put_journal_=
head
     1.29%  splice-fromnet  [kernel.kallsyms]  [k] __ext3_get_inode_loc
     1.26%  splice-fromnet  [kernel.kallsyms]  [k] journal_dirty_metada=
ta
     1.25%  splice-fromnet  [kernel.kallsyms]  [k] page_address
     1.20%  splice-fromnet  [kernel.kallsyms]  [k] journal_cancel_revok=
e
     1.15%  splice-fromnet  [kernel.kallsyms]  [k] tcp_read_sock
     1.09%  splice-fromnet  [kernel.kallsyms]  [k] unlock_buffer
     1.09%  splice-fromnet  [kernel.kallsyms]  [k] pipe_to_file
     1.05%  splice-fromnet  [kernel.kallsyms]  [k] radix_tree_lookup_el=
ement
     1.04%  splice-fromnet  [kernel.kallsyms]  [k] kmap_atomic_prot
     1.04%  splice-fromnet  [kernel.kallsyms]  [k] kmem_cache_free
     1.03%  splice-fromnet  [kernel.kallsyms]  [k] kmem_cache_alloc
     1.01%  splice-fromnet  [bnx2x]            [k] bnx2x_poll


