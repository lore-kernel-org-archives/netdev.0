From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Face some error after applying commit 7dfa4b414d4(net/mlx4_en:
 Code cleanups in tx path)
Date: Sun, 09 Nov 2014 18:46:14 -0800
Message-ID: <1415587574.13896.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141108025758.GA13875@richard>
	 <CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com>
	 <20141110015933.GB6294@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:40479 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbaKJCqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 21:46:16 -0500
Received: by mail-pd0-f173.google.com with SMTP id v10so6896126pde.32
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 18:46:16 -0800 (PST)
In-Reply-To: <20141110015933.GB6294@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-10 at 09:59 +0800, Wei Yang wrote:
> On Fri, Nov 07, 2014 at 07:38:15PM -0800, Eric Dumazet wrote:
> >On Fri, Nov 7, 2014 at 6:57 PM, Wei Yang <weiyang@linux.vnet.ibm.com=
> wrote:
> >> Eric and Amir
> >>
> >> I am testing the VF on PowerNV platform with 3.18-rc2.
> >> After applying this patch I face some errors.
> >>
> >> First is the compiling error.
> >>
> >>     drivers/net/ethernet/mellanox/mlx4//en_tx.c: In function =E2=80=
=98mlx4_en_xmit=E2=80=99:
> >>     drivers/net/ethernet/mellanox/mlx4//en_tx.c:802:8: error: =E2=80=
=98shinfo=E2=80=99 undeclared (first use in this function)
> >>             shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
> >>             ^
> >>     include/linux/compiler.h:160:42: note: in definition of macro =
=E2=80=98unlikely=E2=80=99
> >>      # define unlikely(x) __builtin_expect(!!(x), 0)
> >>                                               ^
> >>     drivers/net/ethernet/mellanox/mlx4//en_tx.c:802:8: note: each =
undeclared identifier is reported only once for each function it appear=
s in
> >>             shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
> >>             ^
> >>     include/linux/compiler.h:160:42: note: in definition of macro =
=E2=80=98unlikely=E2=80=99
> >>      # define unlikely(x) __builtin_expect(!!(x), 0)
> >>                                               ^
> >>     make[1]: *** [drivers/net/ethernet/mellanox/mlx4//en_tx.o] Err=
or 1
> >>     make: *** [_module_drivers/net/ethernet/mellanox/mlx4/] Error =
2
> >>
> >
> >
> >This compilation error seems strange.
> >
> >Are you sure your tree is pristine, not corrupted in any way ?
>=20
> I believe I did the revert one by one with git revert.
>=20
> >
> >
> >> I tried to fix this with following change:
> >>
> >>     [root@tian-lp1 3.18]# git diff
> >>     diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/driv=
ers/net/ethernet/m
> >>     index eaf23eb..d2f06a7 100644
> >>     --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> >>     +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> >>     @@ -799,8 +799,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *s=
kb, struct net_dev
> >>              * set flag for further reference
> >>              */
> >>             if (unlikely(ring->hwtstamp_tx_type =3D=3D HWTSTAMP_TX=
_ON &&
> >>     -                    shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
> >>     -               shinfo->tx_flags |=3D SKBTX_IN_PROGRESS;
> >>     +                    skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTA=
MP)) {
> >>     +               skb_shinfo(skb)->tx_flags |=3D SKBTX_IN_PROGRE=
SS;
> >>                     tx_info->ts_requested =3D 1;
> >>             }
> >>
> >> But seems to face another error.
> >>
> >
> >I suspect your tree is not the official tree, I do not see how you g=
ot
> >this compilation error.
>=20
>=20
> I checked the upstream git tree again, and find this commit:
>=20
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commi=
t/?id=3D7dfa4b414d4eec8da56e44fb2b4aea3e549b092f
>=20
>=20
> And I want to say the shinfo local variable is introduced in commit:
>=20
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commi=
t/?id=3Db9d8839a44092cb4268ef2813c34d5dbf3363603
>=20
> And in my log tree, also checked the upstream, this one is applyed af=
ter the
> first one. And the compiling error will disappear untill I apply this=
 one.
>=20
> So this compiling issue can't reproduced at your side? You have reset=
 --hard
> to the "Code cleanup" one, and can't see the error? That is strange.
>=20

Okay, your message was not clear : I thought you had a compilation erro=
r
on current tree.

The true story of these patches is that Mellanox split an initial big
chunk [1] I gave into multiple patches.

Maybe they missed that one patch did not actually compile.

[1] https://patchwork.ozlabs.org/patch/394256/

Now, it is done, there is nothing we can do.

I'll let Mellanox comment, but it looks like your hardware does not lik=
e
something.

Have you tried to disable Blue Frame ?
