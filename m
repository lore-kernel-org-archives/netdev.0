From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Tue, 22 Apr 2008 23:02:26 +0400
Message-ID: <20080422190225.GA4756@martell.zuzino.mipt.ru>
References: <Pine.LNX.4.64.0804141301580.7803@schroedinger.engr.sgi.com> <20080419111719.GA6724@martell.zuzino.mipt.ru> <20080419144535.GA4814@martell.zuzino.mipt.ru> <20080419215444.2d4623f5@osprey.hogchain.net> <20080420111453.GA4902@martell.zuzino.mipt.ru> <20080420060607.2b1be48b@osprey.hogchain.net> <20080420122631.GA4761@martell.zuzino.mipt.ru> <20080420133704.63f5cc10@osprey.hogchain.net> <20080420205500.GA4762@martell.zuzino.mipt.ru> <20080421210821.28053a92@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:39169 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758180AbYDVSHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 14:07:09 -0400
Received: by nf-out-0910.google.com with SMTP id g13so842671nfb.21
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 11:07:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080421210821.28053a92@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2008 at 09:08:21PM -0500, Jay Cliburn wrote:
> On Mon, 21 Apr 2008 00:55:00 +0400
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
>=20
> > Aha, ifconfig down is enough. Here is how reproducer looks like now=
:
> >=20
> > 	./sync-linux-linus && ssh core2 "sudo /sbin/ifconfig eth0
> > down"
> >=20
> > where first script is basically scp(1).
> >=20
> > Also, booting with 1G or 2G of RAM (mem=3D1024m) makes issue go awa=
y.
> >=20
> > printk at dev_close() time shows that NETIF_F_HIGHDMA was not someh=
ow
> > enabled.
> >=20
>=20
> Alexey, can you please try this (very minimally tested) patch?
>=20
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index 5586fc6..07fe5c0 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -1115,9 +1115,6 @@ static void atl1_free_ring_resources(struct atl=
1_adapter *adapter)
>  	struct atl1_rrd_ring *rrd_ring =3D &adapter->rrd_ring;
>  	struct atl1_ring_header *ring_header =3D &adapter->ring_header;
> =20
> -	atl1_clean_tx_ring(adapter);
> -	atl1_clean_rx_ring(adapter);
> -
>  	kfree(tpd_ring->buffer_info);
>  	pci_free_consistent(pdev, ring_header->size, ring_header->desc,
>  		ring_header->dma);
> @@ -3423,6 +3420,8 @@ static int atl1_set_ringparam(struct net_device=
 *netdev,
>  		adapter->rrd_ring =3D rrd_old;
>  		adapter->tpd_ring =3D tpd_old;
>  		adapter->ring_header =3D rhdr_old;
> +		atl1_clean_tx_ring(adapter);
> +		atl1_clean_rx_ring(adapter);
>  		atl1_free_ring_resources(adapter);

Patch doesn't help unfortunately.

BTW, below is clean corruption trace:


atl1 0000:03:00.0: eth0 link is up 1000 Mbps full duplex
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
BUG kmalloc-2048: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xffff81017ed7a97a-0xffff81017ed7af71. First byte 0x0 instead of =
0x6b
INFO: Allocated in dev_alloc_skb+0x18/0x30 age=3D23894 cpu=3D1 pid=3D30=
255
INFO: Freed in skb_release_data+0x7a/0xc0 age=3D20700 cpu=3D0 pid=3D0
INFO: Slab 0xffffe200053bf240 used=3D12 fp=3D0xffff81017ed7a968 flags=3D=
0x17c000000040c3
INFO: Object 0xffff81017ed7a968 @offset=3D10600 fp=3D0xffff81017ed7ca88

Bytes b4 0xffff81017ed7a958:  14 09 a7 01 01 00 00 00 5a 5a 5a 5a 5a 5a=
 5a 5a ..=C2=A7.....ZZZZZZZZ
  Object 0xffff81017ed7a968:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xffff81017ed7a978:  6b 6b 00 18 f3 a2 9f 90 00 1b 38 af 22 49=
 08 00 kk..=C3=B3=C2=A2....8=C2=AF"I..
  Object 0xffff81017ed7a988:  45 10 00 4c a4 9f 40 00 40 11 d2 fe c0 a8=
 00 2a E..L=C2=A4.@.@.=C3=92=C3=BE=C3=80=C2=A8.*
  Object 0xffff81017ed7a998:  59 6f a8 b1 9d e9 00 7b 00 38 58 29 23 00=
 00 00 Yo=C2=A8=C2=B1.=C3=A9.{.8X)#...
  Object 0xffff81017ed7a9a8:  00 00 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00 ................
  Object 0xffff81017ed7a9b8:  00 00 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00 ................
  Object 0xffff81017ed7a9c8:  00 00 00 00 1e 31 61 fa 08 5e 9a 73 de cf=
 ce 94 .....1a=C3=BA.^.s=C3=9E=C3=8F=C3=8E.
  Object 0xffff81017ed7a9d8:  63 64 65 66 67 68 6a 69 6b 6c 6d 6e 6f 70=
 71 72 cdefghjiklmnopqr
 Redzone 0xffff81017ed7b168:  bb bb bb bb bb bb bb bb                  =
       =C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB=C2=BB       =20
 Padding 0xffff81017ed7b1a8:  5a 5a 5a 5a 5a 5a 5a 5a                  =
       ZZZZZZZZ       =20
Pid: 31677, comm: ifconfig Not tainted 2.6.25-3925e6fc1f774048404fdd910=
b0345b06c699eb4 #5

Call Trace:
 [<ffffffff80288277>] print_trailer+0xe7/0x170
 [<ffffffff802883a5>] check_bytes_and_report+0xa5/0xd0
 [<ffffffff80288678>] check_object+0xa8/0x250
 [<ffffffff80289975>] __slab_alloc+0x535/0x690
 [<ffffffff80253f3e>] ? mark_held_locks+0x3e/0x80
 [<ffffffff803f2fd8>] ? dev_alloc_skb+0x18/0x30
 [<ffffffff8028aff6>] __kmalloc_track_caller+0xe6/0x100
 [<ffffffff803f2fd8>] ? dev_alloc_skb+0x18/0x30
 [<ffffffff803f2b8f>] __alloc_skb+0x6f/0x160
 [<ffffffff803f2fd8>] dev_alloc_skb+0x18/0x30
 [<ffffffff8036512a>] atl1_alloc_rx_buffers+0x11a/0x260
 [<ffffffff80366dc7>] atl1_up+0x77/0x750
 [<ffffffff80367a0b>] atl1_open+0x3b/0x50
 [<ffffffff803fa3fa>] dev_open+0x5a/0x90
 [<ffffffff803f8ca9>] dev_change_flags+0x99/0x1b0
 [<ffffffff8043d1d2>] devinet_ioctl+0x592/0x740
 [<ffffffff803fa229>] ? dev_ioctl+0x479/0x550
 [<ffffffff8043d891>] inet_ioctl+0x61/0x80
 [<ffffffff803eaa16>] sock_ioctl+0x56/0x240
 [<ffffffff8029b271>] vfs_ioctl+0x31/0x90
 [<ffffffff8029b343>] do_vfs_ioctl+0x73/0x2d0
 [<ffffffff8029b5ea>] sys_ioctl+0x4a/0x80
 [<ffffffff8020b54b>] system_call_after_swapgs+0x7b/0x80

=46IX kmalloc-2048: Restoring 0xffff81017ed7a97a-0xffff81017ed7af71=3D0=
x6b

=46IX kmalloc-2048: Marking all objects used
atl1 0000:03:00.0: eth0 link is up 1000 Mbps full duplex

