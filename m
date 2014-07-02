From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: segfault after VLAN change
Date: Wed, 02 Jul 2014 09:11:09 +0200
Message-ID: <87simk1bhu.fsf@nemi.mork.no>
References: <42408b4f154d434d9838b83ae2dc15db@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li RongQing <roy.qing.li@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35183 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902AbaGBHL3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 03:11:29 -0400
In-Reply-To: <42408b4f154d434d9838b83ae2dc15db@BL2PR03MB545.namprd03.prod.outlook.com>
	(Madalin-Cristian Bucur's message of "Tue, 1 Jul 2014 16:55:13 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Madalin-Cristian Bucur <madalin.bucur@freescale.com> writes:

> Hello,
>
> I've discovered that the commit:
>
>     commit 5a4ae5f6e7d4b2b5a9b8981d513345053e40b6ac
>     Author: Li RongQing <roy.qing.li@gmail.com>
>     Date:   Mon Apr 21 19:49:08 2014 +0800
>
>     vlan: unnecessary to check if vlan_pcpu_stats is NULL
>
>     if allocating memory for vlan_pcpu_stats failed, the device can n=
ot be operated
>
>     Signed-off-by:=20
>     Cc: Eric Dumazet <edumazet@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> is causing a segfault when removing vlan on a e1000 device (reproduce=
s with other devices as well).
> Re-adding the check or reverting the patch removes the issue (log bel=
ow).


Yes, that commit should be reverted.

The commit message makes it clear that only allocation failures were
considered, while a simple grep reveals that there at least one site
where that field is explicitly NULLed:

bjorn@nemi:/usr/local/src/git/linux$ git grep vlan_pcpu_stats net/8021q=
/
net/8021q/vlan_core.c:  struct vlan_pcpu_stats *rx_stats;
net/8021q/vlan_core.c:  rx_stats =3D this_cpu_ptr(vlan_dev_priv(vlan_de=
v)->vlan_pcpu_stats);
net/8021q/vlan_dev.c:           struct vlan_pcpu_stats *stats;
net/8021q/vlan_dev.c:           stats =3D this_cpu_ptr(vlan->vlan_pcpu_=
stats);
net/8021q/vlan_dev.c:           this_cpu_inc(vlan->vlan_pcpu_stats->tx_=
dropped);
net/8021q/vlan_dev.c:   vlan_dev_priv(dev)->vlan_pcpu_stats =3D netdev_=
alloc_pcpu_stats(struct vlan_pcpu_stats);
net/8021q/vlan_dev.c:   if (!vlan_dev_priv(dev)->vlan_pcpu_stats)
net/8021q/vlan_dev.c:   free_percpu(vlan->vlan_pcpu_stats);
net/8021q/vlan_dev.c:   vlan->vlan_pcpu_stats =3D NULL;
net/8021q/vlan_dev.c:   struct vlan_pcpu_stats *p;
net/8021q/vlan_dev.c:           p =3D per_cpu_ptr(vlan_dev_priv(dev)->v=
lan_pcpu_stats, i);


Without looking further it seems likely that this is done during
teardown, making the original NULL check necessary.



Bj=C3=B8rn
