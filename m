From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: [PATCH] net: tun: release the reference of tun device in tun_recvmsg
Date: Wed, 29 May 2013 00:29:34 +0200
Message-ID: <201305290029.35303.a.miskiewicz@gmail.com>
References: <201304250822.38944.a.miskiewicz@gmail.com> <517A0A84.40102@cn.fujitsu.com> <517A0BE2.9080503@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org,
	Balakumaran Kannan <kumaran.4353@gmail.com>,
	Maruthi Thotad <Maruthi.Thotad@ap.sony.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:46754 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756973Ab3E1W3k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 18:29:40 -0400
Received: by mail-bk0-f51.google.com with SMTP id ji1so2454507bkc.10
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 15:29:38 -0700 (PDT)
In-Reply-To: <517A0BE2.9080503@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 26 of April 2013, Jason Wang wrote:
> On 04/26/2013 01:03 PM, Gao feng wrote:
> > On 04/25/2013 11:04 PM, Arkadiusz Miskiewicz wrote:
> >> On Thursday 25 of April 2013, Gao feng wrote:
> >>> We forget to release the reference of tun device in tun_recvmsg.
> >>> bug introduced in commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
> >>> (tuntap: move socket to tun_file)
> >>=20
> >> Hm, still hitting the problem even with the patch - dmesg:
> > Ok, seams there are another problems we haven't discovered.
> > it's excellent if you can find out which commit introduces this
> > bug by git bisect.
> >=20
> > Thanks!
>=20
> Yes, bisect will be helpful. If you could not do it, please tell me t=
he
> steps to reproduce the issue and the tree you used. I just test with
> net.git and net-next.git with a tap device created by tunctl, didn't
> meet the issue.

Took a while. Suspected patch is below. I'm running fresh linus git
(3.10.0-rc3-00046-g58f8bbd) with the patch reverted and couldn't
reproduce problem anymore after several tries (will do more testing
in meantime).

My tap0 has ipv6 addresses (with link scope only). openvpn 2.3.1.

commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
Author: Balakumaran Kannan <kumaran.4353@gmail.com>
Date:   Tue Apr 2 16:15:05 2013 +0530

    net IPv6 : Fix broken IPv6 routing table after loopback down-up
   =20
    IPv6 Routing table becomes broken once we do ifdown, ifup of the lo=
opback(lo)
    interface. After down-up, routes of other interface's IPv6 addresse=
s through
    'lo' are lost.
   =20
    IPv6 addresses assigned to all interfaces are routed through 'lo' f=
or internal
    communication. Once 'lo' is down, those routing entries are removed=
 from routing
    table. But those removed entries are not being re-created properly =
when 'lo' is
    brought up. So IPv6 addresses of other interfaces becomes unreachab=
le from the
    same machine. Also this breaks communication with other machines be=
cause of
    NDISC packet processing failure.
   =20
    This patch fixes this issue by reading all interface's IPv6 address=
es and adding
    them to IPv6 routing table while bringing up 'lo'.
   =20
    =3D=3DTesting=3D=3D
    Before applying the patch:
    $ route -A inet6                                                   =
                                                                       =
              =20
    Kernel IPv6 routing table                                          =
                                                                       =
              =20
    Destination                    Next Hop                   Flag Met =
Ref Use If                                                             =
              =20
    2000::20/128                   ::                         U    256 =
0     0 eth0                                                           =
              =20
    fe80::/64                      ::                         U    256 =
0     0 eth0                                                           =
              =20
    ::/0                           ::                         !n   -1  =
1     1 lo                                                             =
              =20
    ::1/128                        ::                         Un   0   =
1     0 lo                                                             =
              =20
    2000::20/128                   ::                         Un   0   =
1     0 lo                                                             =
              =20
    fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   =
1     0 lo                                                             =
              =20
    ff00::/8                       ::                         U    256 =
0     0 eth0                                                           =
              =20
    ::/0                           ::                         !n   -1  =
1     1 lo                                                             =
              =20
    $ sudo ifdown lo
    $ sudo ifup lo
    $ route -A inet6
    Kernel IPv6 routing table
    Destination                    Next Hop                   Flag Met =
Ref Use If
    2000::20/128                   ::                         U    256 =
0     0 eth0
    fe80::/64                      ::                         U    256 =
0     0 eth0
    ::/0                           ::                         !n   -1  =
1     1 lo
    ::1/128                        ::                         Un   0   =
1     0 lo
    ff00::/8                       ::                         U    256 =
0     0 eth0
    ::/0                           ::                         !n   -1  =
1     1 lo
    $
   =20
    After applying the patch:
    $ route -A inet6
    Kernel IPv6 routing
    table
    Destination                    Next Hop                   Flag Met =
Ref Use If
    2000::20/128                   ::                         U    256 =
0     0 eth0
    fe80::/64                      ::                         U    256 =
0     0 eth0
    ::/0                           ::                         !n   -1  =
1     1 lo
    ::1/128                        ::                         Un   0   =
1     0 lo
    2000::20/128                   ::                         Un   0   =
1     0 lo
    fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   =
1     0 lo
    ff00::/8                       ::                         U    256 =
0     0 eth0
    ::/0                           ::                         !n   -1  =
1     1 lo
    $ sudo ifdown lo
    $ sudo ifup lo
    $ route -A inet6
    Kernel IPv6 routing table
    Destination                    Next Hop                   Flag Met =
Ref Use If
    2000::20/128                   ::                         U    256 =
0     0 eth0
    fe80::/64                      ::                         U    256 =
0     0 eth0
    ::/0                           ::                         !n   -1  =
1     1 lo
    ::1/128                        ::                         Un   0   =
1     0 lo
    2000::20/128                   ::                         Un   0   =
1     0 lo
    fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   =
1     0 lo
    ff00::/8                       ::                         U    256 =
0     0 eth0
    ::/0                           ::                         !n   -1  =
1     1 lo
    $
   =20
    Signed-off-by: Balakumaran Kannan <Balakumaran.Kannan@ap.sony.com>
    Signed-off-by: Maruthi Thotad <Maruthi.Thotad@ap.sony.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


git bisect start
# bad: [824282ca7d250bd7c301f221c3cd902ce906d731] Merge branch 'upstrea=
m' of git://git.linux-mips.org/pub/scm/ralf/upstream-linus
git bisect bad 824282ca7d250bd7c301f221c3cd902ce906d731
# good: [19f949f52599ba7c3f67a5897ac6be14bfcb1200] Linux 3.8
git bisect good 19f949f52599ba7c3f67a5897ac6be14bfcb1200
# good: [2ef14f465b9e096531343f5b734cffc5f759f4a6] Merge branch 'x86-mm=
-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 2ef14f465b9e096531343f5b734cffc5f759f4a6
# good: [21f3b24da9328415792efc780f50b9f434c12465] Merge tag 'scsi-misc=
' of git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi
git bisect good 21f3b24da9328415792efc780f50b9f434c12465
# skip: [b4811bacbc68f6e17d442df88f98afaa9394d4f5] ARM: fix CONFIG_VIRT=
_TO_BUS handling
git bisect skip b4811bacbc68f6e17d442df88f98afaa9394d4f5
# good: [cc9945bf9cac03860b2f7d59882263c965c6e3af] drm/radeon: don't se=
t hpd, afmt interrupts when interrupts are disabled
git bisect good cc9945bf9cac03860b2f7d59882263c965c6e3af
# good: [087aa036eb79f24b856893190359ba812b460f45] powerpc: make additi=
onal room in exception vector area
git bisect good 087aa036eb79f24b856893190359ba812b460f45
# bad: [8f09aacfa6cf64c469fe60c05dfc1bd75e8615ed] Merge tag 'sound-3.9'=
 of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect bad 8f09aacfa6cf64c469fe60c05dfc1bd75e8615ed
# good: [d299c29039aae518d0e70fc26fb158a80dfcd31a] Merge tag 'for-linus=
-20130331' of git://git.kernel.dk/linux-block
git bisect good d299c29039aae518d0e70fc26fb158a80dfcd31a
# good: [118c9a45fdacc6fe57910fa1d048e2d5bbc193f4] Merge tag 'fixes' of=
 git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect good 118c9a45fdacc6fe57910fa1d048e2d5bbc193f4
# bad: [66ade474237745a57b7e87da9a93c7ec69fd52bb] Merge branch 'fixes' =
of git://git.linaro.org/people/rmk/linux-arm
git bisect bad 66ade474237745a57b7e87da9a93c7ec69fd52bb
# good: [6e8517a90b41b57d66926286c0add31145c75eb6] Merge tag 'regmap-v3=
=2E9-rc4' of git://git.kernel.org/pub/scm/linux/kernel/git/broonie/regm=
ap
git bisect good 6e8517a90b41b57d66926286c0add31145c75eb6
# skip: [cd0e4a9dd432b2f0209d84b5b2420695c1fd3eb7] Merge branch 'for_li=
nus' of git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs
git bisect skip cd0e4a9dd432b2f0209d84b5b2420695c1fd3eb7
# good: [120ecfafabec382c4feb79ff159ef42a39b6d33b] ARM: 7678/1: Work ar=
ound faulty ISAR0 register in some Krait CPUs
git bisect good 120ecfafabec382c4feb79ff159ef42a39b6d33b
# bad: [17eb3d8fbe4c573426fc99946040305e79c07803] Merge branch 'for-lin=
us' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux
git bisect bad 17eb3d8fbe4c573426fc99946040305e79c07803
# skip: [765a0cac566c938821ae26efb4aa53b7502ee82c] s390/mm: provide emt=
py check_pgt_cache() function
git bisect skip 765a0cac566c938821ae26efb4aa53b7502ee82c
# good: [94f9852de86447088e8e3c12d8b5a8f996acee32] s390/scm_blk: fix er=
ror return code in scm_blk_init()
git bisect good 94f9852de86447088e8e3c12d8b5a8f996acee32
# skip: [990454b5a48babde44a23c0f22bae5523f4fdf13] VSOCK: Handle change=
s to the VMCI context ID.
git bisect skip 990454b5a48babde44a23c0f22bae5523f4fdf13
# good: [f0f6ee1f70c4eaab9d52cf7d255df4bd89f8d1c2] cbq: incorrect proce=
ssing of high limits
git bisect good f0f6ee1f70c4eaab9d52cf7d255df4bd89f8d1c2
# bad: [da241efcd9c3da2af6ba20055c7e158ec725005c] Merge git://git.kerne=
l.org/pub/scm/linux/kernel/git/davem/net
git bisect bad da241efcd9c3da2af6ba20055c7e158ec725005c
# skip: [25fb6ca4ed9cad72f14f61629b68dc03c0d9713f] net IPv6 : Fix broke=
n IPv6 routing table after loopback down-up
git bisect skip 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
# only skipped commits left to test
# possible first bad commit: [da241efcd9c3da2af6ba20055c7e158ec725005c]=
 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
# possible first bad commit: [990454b5a48babde44a23c0f22bae5523f4fdf13]=
 VSOCK: Handle changes to the VMCI context ID.
# possible first bad commit: [25fb6ca4ed9cad72f14f61629b68dc03c0d9713f]=
 net IPv6 : Fix broken IPv6 routing table after loopback down-up
# possible first bad commit: [94f9852de86447088e8e3c12d8b5a8f996acee32]=
 s390/scm_blk: fix error return code in scm_blk_init()
# possible first bad commit: [3bff6038f1938d2541943dfde604a9b92f347650]=
 s390/scm_block: fix printk format string
# possible first bad commit: [6c43a519610a5e11af5be707ad88391ce86129ba]=
 drivers/Kconfig: add several missing GENERIC_HARDIRQS dependencies


>=20
> >> http://pastebin.com/iSm0QJVY
> >>=20
> >>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >>> ---
> >>>=20
> >>>  drivers/net/tun.c | 7 +++++--
> >>>  1 file changed, 5 insertions(+), 2 deletions(-)
> >>>=20
> >>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> >>> index 0c9df2f..dcd0c19 100644
> >>> --- a/drivers/net/tun.c
> >>> +++ b/drivers/net/tun.c
> >>> @@ -1471,14 +1471,17 @@ static int tun_recvmsg(struct kiocb *iocb=
,
> >>> struct socket *sock, if (!tun)
> >>>=20
> >>>  		return -EBADFD;
> >>>=20
> >>> -	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
> >>> -		return -EINVAL;
> >>> +	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC)) {
> >>> +		ret =3D -EINVAL;
> >>> +		goto out;
> >>> +	}
> >>>=20
> >>>  	ret =3D tun_do_read(tun, tfile, iocb, m->msg_iov, total_len,
> >>>  =09
> >>>  			  flags & MSG_DONTWAIT);
> >>>  =09
> >>>  	if (ret > total_len) {
> >>>  =09
> >>>  		m->msg_flags |=3D MSG_TRUNC;
> >>>  		ret =3D flags & MSG_TRUNC ? ret : total_len;
> >>>  =09
> >>>  	}
> >>>=20
> >>> +out:
> >>>  	tun_put(tun);
> >>>  	return ret;
> >>> =20
> >>>  }


--=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / maven.pl
