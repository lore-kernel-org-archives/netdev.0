From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Fri, 9 May 2008 14:38:54 -0500
Message-ID: <20080509143854.7bc39ab7@osprey.hogchain.net>
References: <20080420060607.2b1be48b@osprey.hogchain.net>
	<20080420122631.GA4761@martell.zuzino.mipt.ru>
	<20080420133704.63f5cc10@osprey.hogchain.net>
	<20080420205500.GA4762@martell.zuzino.mipt.ru>
	<20080421210821.28053a92@osprey.hogchain.net>
	<20080425195743.2bfe66ee@osprey.hogchain.net>
	<20080504211507.GC1040@martell.zuzino.mipt.ru>
	<20080506110225.31fd61a4@osprey.hogchain.net>
	<20080509195149.GA4985@martell.zuzino.mipt.ru>
	<48249E55.1020300@redhat.com>
	<20080509200715.GA5040@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Snook <csnook@redhat.com>,
	Luca Tettamanti <kronos.it@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([204.127.217.104]:49704 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752125AbYEITi6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 15:38:58 -0400
In-Reply-To: <20080509200715.GA5040@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[trimmed cc list slightly]

On Sat, 10 May 2008 00:07:15 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Fri, May 09, 2008 at 02:56:21PM -0400, Chris Snook wrote:
> > Alexey Dobriyan wrote:
> >> Hmmm, there was a wonderful oops on interface stop here when the
> >> other end of atl1 cable was physically unplugged (but there was
> >> traffic before): atl1_down
> >> 	atl1_clean_rx_ring
> >> 	swiotlb_unmap_single
> >> 	swiotlb_unmap_single_attrs
> >> 	memcpy_c
> >
> > Intel chip, or AMD?
>=20
> Intel(R) Core(TM)2 CPU          6400  @ 2.13GHz
> Asus P5B-E motherboard.
>=20

I see the same thing with a Socked AM2-based board (Asus M2V) with 4GB
RAM installed. The problem occurs only when SWIOTLB is active, which
happens automatically at boot (in arch/x86/kernel/pci-swiotlb.c) when
the page frame number exceeds 1048576 (corresponding to 2^32 bytes).

I thought for awhile that the problem went away with iommu=3Dallowed, b=
ut
I was wrong.

The bug appears to be a "simple" skb write-after-free that happens only
when bounce buffers are in use, but I'll be damned if I can find the
cause of it.

<continues looking>

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
BUG kmalloc-2048: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xffff81010004297a-0xffff810100042f71. First byte 0x0 instead of =
0x6b
INFO: Allocated in dev_alloc_skb+0x16/0x2c age=3D5813 cpu=3D0 pid=3D302=
9
INFO: Freed in skb_release_data+0xa8/0xad age=3D201 cpu=3D0 pid=3D0
INFO: Slab 0xffffe20005801600 objects=3D15 used=3D0 fp=3D0xffff81010004=
5b18 flags=3D0x8000000000002082
INFO: Object 0xffff810100042968 @offset=3D10600 fp=3D0xffff8101000418d8

Bytes b4 0xffff810100042958:  aa 91 fd ff 00 00 00 00 5a 5a 5a 5a 5a 5a=
 5a 5a =EF=BF=BD.=EF=BF=BD=EF=BF=BD....ZZZZZZZZ
  Object 0xffff810100042968:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xffff810100042978:  6b 6b 00 17 31 4e 9d 41 00 0f db bc af 14=
 08 00 kk..1N.A..=DB=BC=EF=BF=BD...
  Object 0xffff810100042988:  45 00 00 4e 87 5e 00 00 40 11 6e 82 c0 a8=
 01 fe E..N.^..@.n.=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD.=EF=BF=BD
  Object 0xffff810100042998:  c0 a8 01 70 00 89 00 89 00 3a 3b 67 00 09=
 00 00 =EF=BF=BD=EF=BF=BD.p.....:;g....
  Object 0xffff8101000429a8:  00 01 00 00 00 00 00 00 20 43 4b 41 41 41=
 41 41 .........CKAAAAA
  Object 0xffff8101000429b8:  41 41 41 41 41 41 41 41 41 41 41 41 41 41=
 41 41 AAAAAAAAAAAAAAAA
  Object 0xffff8101000429c8:  41 41 41 41 41 41 41 41 41 00 00 21 00 01=
 f0 53 AAAAAAAAA..!..
  Object 0xffff8101000429d8:  56 17 df 3e 3b 9f b7 1f 2d 29 f0 68 cf 4d=
 61 97 V.=EF=BF=BD>;.=EF=BF=BD.-)=EF=BF=BDh=EF=BF=BDMa.
 Redzone 0xffff810100043168:  bb bb bb bb bb bb bb bb                  =
       =EF=BF=BD=F0=B0=BB=BB=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD       =20
 Padding 0xffff8101000431a8:  5a 5a 5a 5a 5a 5a 5a 5a                  =
       ZZZZZZZZ       =20
Pid: 3030, comm: ifconfig Not tainted 2.6.26-rc1 #3

Call Trace:
 [<ffffffff8108cf62>] print_trailer+0x123/0x12c
 [<ffffffff8108d00f>] check_bytes_and_report+0xa4/0xcb
 [<ffffffff8108d33e>] check_object+0xca/0x212
 [<ffffffff8108d6cd>] __free_slab+0x85/0xfd
 [<ffffffff811e5dd3>] ? skb_release_data+0xa8/0xad
 [<ffffffff8108d77d>] discard_slab+0x38/0x3a
 [<ffffffff8108e172>] __slab_free+0xdb/0x2ac
 [<ffffffff8108e47a>] kfree+0xbc/0xcb
 [<ffffffff811e5dd3>] ? skb_release_data+0xa8/0xad
 [<ffffffff811e5dd3>] skb_release_data+0xa8/0xad
 [<ffffffff811e6494>] skb_release_all+0xc9/0xce
 [<ffffffff811e5c2e>] __kfree_skb+0x11/0x78
 [<ffffffff811e5cbc>] kfree_skb+0x27/0x29
 [<ffffffffa00cc3aa>] :atl1:atl1_clean_rx_ring+0x7e/0xe2
 [<ffffffffa00cc4d7>] :atl1:atl1_down+0xc9/0xce
 [<ffffffffa00cedcd>] :atl1:atl1_close+0x18/0x27
 [<ffffffff811ebe2d>] dev_close+0x57/0x72
 [<ffffffff811ebb31>] dev_change_flags+0xa8/0x164
 [<ffffffff8122f44c>] devinet_ioctl+0x26a/0x5f6
 [<ffffffff8122fc79>] inet_ioctl+0x92/0xaa
 [<ffffffff811df6d4>] sock_ioctl+0x1da/0x202
 [<ffffffff8109f252>] vfs_ioctl+0x2a/0x77
 [<ffffffff8109f501>] do_vfs_ioctl+0x262/0x27f
 [<ffffffff8109f575>] sys_ioctl+0x57/0x7a
 [<ffffffff8100bff7>] tracesys+0xd5/0xda

=46IX kmalloc-2048: Restoring 0xffff81010004297a-0xffff810100042f71=3D0=
x6b
