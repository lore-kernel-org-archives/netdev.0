From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken.
 In 4.0.0-rc3
Date: Mon, 16 Mar 2015 09:21:38 +0000
Message-ID: <BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
References: <390621425930628@web28o.yandex.ru>
 <3625951426018334@web26j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?koi8-r?B?8MHOz9cg4c7E0sXK?= <rockford@yandex.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0137.outbound.protection.outlook.com ([207.46.100.137]:34963
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751445AbbCPJVl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 05:21:41 -0400
In-Reply-To: <3625951426018334@web26j.yandex.ru>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =F0=C1=CE=CF=D7 =E1=CE=C4=D2=C5=CA <rockford@yandex.ru> Sent: W=
ednesday, March 11, 2015 4:12 AM
> To: Duan Fugang-B38611; netdev@vger.kernel.org; linux-arm-kernel
> Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is
> broken. In 4.0.0-rc3
>=20
> Hello!
> Adding lakml to cc:
>=20
> > Commit 2b995f63987013bacde99168218f9c7b252bdcf1 in 4.0.0-rc3 introd=
uces
> a nasty bug in transmit, corrupting packets.
> >
> > To reproduce:
> >
> > $ dd if=3D/dev/zero of=3Dzeros bs=3D1M count=3D20 $ md5sum -b zeros
> > 8f4e33f3dc3e414ff94e5fb6905cba8c *zeros
> >
> > This checksum is correct.
> >
> > Copy file "zeros" to another host with NFS, and it gets corrupted,
> checksum is changed.
> > File should be big, small amounts of transmit isn't affected.
> >
> > I use an i.MX6 Quad board.
> >
> > If this commit is reverted, all works fine.
>=20
> 3.19 works fine too.
> And it is not random corruption, when copying all-zero file this is
> received on NFS host:
> $ hd zeros | head -16
> 00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00
> |................|
> *
> 0052c0f0  00 00 00 00 00 00 00 00  1c f0 9f e5 1c f0 9f e5
> |................|
> 0052c100  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 1c f0 9f e5
> |................|
> 0052c110  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 74 fb 00 00
> |............t...|
> 0052c120  bc ff 93 00 c0 ff 93 00  c4 ff 93 00 c8 ff 93 00
> |................|
> 0052c130  cc ff 93 00 d0 ff 93 00  d4 ff 93 00 d8 ff 93 00
> |................|
> 0052c140  13 00 00 00 28 63 29 20  43 6f 70 79 72 69 67 68  |....(c)
> Copyrigh|
> 0052c150  74 20 32 30 30 37 2d 32  30 31 32 2c 20 46 72 65  |t 2007-2=
012,
> Fre|
> 0052c160  65 73 63 61 6c 65 20 53  65 6d 69 63 6f 6e 64 75  |escale
> Semicondu|
> 0052c170  63 74 6f 72 2e 20 41 6c  6c 20 72 69 67 68 74 73  |ctor. Al=
l
> rights|
> 0052c180  20 72 65 73 65 72 76 65  64 2e 00 00 dd 00 2c 41  |
> reserved.....,A|
> 0052c190  11 73 00 00 d3 74 00 00  3d 75 00 00 a9 78 00 00
> |.s...t..=3Du...x..|
> 0052c1a0  4f 78 00 00 75 77 00 00  07 76 00 00 c3 79 00 00
> |Ox..uw...v...y..|
> 0052c1b0  09 7a 00 00 75 7a 00 00  97 22 00 00 49 1f 00 00
> |.z..uz..."..I...|
> 0052c1c0  b9 21 00 00 ff 70 00 00  90 21 90 00 23 4a 52 f8
> |.!...p...!..#JR.|
>=20
> Looks like zero page with vectors at beginning.
> Freescale i.MX6 Quad-based Embedsky E9 board.
>=20
Hi,=20

I try your case on i.MX6q sabresd board with net tree kernel.
root@freescale ~$ uname -r
4.0.0-rc3-11071-gf00bbd2

With below test steps for 10 time, the zero file size range from 20M to=
 300M bytes,=20
compare the md5sum checksum between i.MX6q and i.MX6q/PC host,  the che=
cksum is the same.

root@freescale ~$ rm zeros
root@freescale ~$ dd if=3D/dev/zero of=3Dzeros bs=3D1M count=3D300
300+0 records in
300+0 records out
314572800 bytes (300.0MB) copied, 1.811459 seconds, 165.6MB/s
root@freescale ~$ md5sum -b zeros
0d97a9cd8bbd7ce75a2a76bb06258915  zeros
root@freescale ~$ cp zeros /mnt/nfs/ -f
root@freescale ~$ rm zeros
root@freescale ~$ cp /mnt/nfs/zeros ./
root@freescale ~$ md5sum -b zeros
0d97a9cd8bbd7ce75a2a76bb06258915  zeros

Do you have any lost for reproduce the issue ?


Regards,
Andy
