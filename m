From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: segfault after VLAN change
Date: Wed, 02 Jul 2014 01:23:43 -0700
Message-ID: <1404289423.23797.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <42408b4f154d434d9838b83ae2dc15db@BL2PR03MB545.namprd03.prod.outlook.com>
	 <87simk1bhu.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	Li RongQing <roy.qing.li@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:49221 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbaGBIXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 04:23:47 -0400
Received: by mail-wi0-f181.google.com with SMTP id n3so10219wiv.2
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 01:23:46 -0700 (PDT)
In-Reply-To: <87simk1bhu.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-02 at 09:11 +0200, Bj=C3=B8rn Mork wrote:
> Madalin-Cristian Bucur <madalin.bucur@freescale.com> writes:
>=20
> > Hello,
> >
> > I've discovered that the commit:
> >
> >     commit 5a4ae5f6e7d4b2b5a9b8981d513345053e40b6ac
> >     Author: Li RongQing <roy.qing.li@gmail.com>
> >     Date:   Mon Apr 21 19:49:08 2014 +0800
> >
> >     vlan: unnecessary to check if vlan_pcpu_stats is NULL
> >
> >     if allocating memory for vlan_pcpu_stats failed, the device can=
 not be operated
> >
> >     Signed-off-by:=20
> >     Cc: Eric Dumazet <edumazet@google.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > is causing a segfault when removing vlan on a e1000 device (reprodu=
ces with other devices as well).
> > Re-adding the check or reverting the patch removes the issue (log b=
elow).
>=20
>=20
> Yes, that commit should be reverted.

Maybe not.

>=20
> The commit message makes it clear that only allocation failures were
> considered, while a simple grep reveals that there at least one site
> where that field is explicitly NULLed:
>=20
> bjorn@nemi:/usr/local/src/git/linux$ git grep vlan_pcpu_stats net/802=
1q/
> net/8021q/vlan_core.c:  struct vlan_pcpu_stats *rx_stats;
> net/8021q/vlan_core.c:  rx_stats =3D this_cpu_ptr(vlan_dev_priv(vlan_=
dev)->vlan_pcpu_stats);
> net/8021q/vlan_dev.c:           struct vlan_pcpu_stats *stats;
> net/8021q/vlan_dev.c:           stats =3D this_cpu_ptr(vlan->vlan_pcp=
u_stats);
> net/8021q/vlan_dev.c:           this_cpu_inc(vlan->vlan_pcpu_stats->t=
x_dropped);
> net/8021q/vlan_dev.c:   vlan_dev_priv(dev)->vlan_pcpu_stats =3D netde=
v_alloc_pcpu_stats(struct vlan_pcpu_stats);
> net/8021q/vlan_dev.c:   if (!vlan_dev_priv(dev)->vlan_pcpu_stats)
> net/8021q/vlan_dev.c:   free_percpu(vlan->vlan_pcpu_stats);
> net/8021q/vlan_dev.c:   vlan->vlan_pcpu_stats =3D NULL;
> net/8021q/vlan_dev.c:   struct vlan_pcpu_stats *p;
> net/8021q/vlan_dev.c:           p =3D per_cpu_ptr(vlan_dev_priv(dev)-=
>vlan_pcpu_stats, i);
>=20
>=20
> Without looking further it seems likely that this is done during
> teardown, making the original NULL check necessary.

Then the teardown is not properly done.

Sure a 'revert' helps, but the real bug should be fixed.

The freeing of the percpu structure should happen from
dev->destructor(), not from ndo_uninit
