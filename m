From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [2.6.33-rc5 regression] NULL pointer dereference in
	vlan_skb_recv - probably introduced by commit
	9793241fe92f7d9303fb221e43fc598eb065f267
Date: Mon, 25 Jan 2010 00:25:23 +0800
Message-ID: <20100124162523.GC11037@hack>
References: <20100123165657.187c11e4@neptune.home> <20100123223132.0e62d8cb@neptune.home> <4B5C4E5E.2010507@gmail.com> <20100124160228.366f4e72@neptune.home> <20100124162549.2b39b222@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bruno =?utf-8?Q?Pr=C3=A9mont?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:39487 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505Ab0AXQXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 11:23:15 -0500
Content-Disposition: inline
In-Reply-To: <20100124162549.2b39b222@neptune.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 24, 2010 at 04:25:49PM +0100, Bruno Pr=C3=A9mont wrote:
>On Sun, 24 January 2010 Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Le 23/01/2010 22:31, Bruno Pr=C3=A9mont a =C3=A9crit :
>> >> Above part of code did change between 2.6.32 and 2.6.33-rc5 with
>> >> commit 9793241fe92f7d9303fb221e43fc598eb065f267 (vlan: Precise RX
>> >> stats accounting)
>> >> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommitdiff;h=3D9793241fe92f7d9303fb221e43fc598eb065f267
>> >=20
>> > Reverting just that commit gets the system running correctly.
>> >=20
>> > Bruno
>>=20
>> I have no idea how this patch can break vlan networking.
>>=20
>> Your disassembly and .config seems to show your machine is not SMP
>
>Exact
>
>> Maybe something is broken on UP and alloc_percpu() ?
>
>Apparently not, see below and previous mail
>
>> Could you add a debug in vlan_dev_init()
>
>In addition to previous mail, I'm also dumping the result of
>vlan_dev_info(dev) shows that the returned pointer is not the same
>during vlan_dev_init() and vlan_skb_recv() ...
>
>diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>index b788978..f370ce1 100644
>--- a/net/8021q/vlan_dev.c
>+++ b/net/8021q/vlan_dev.c
>@@ -165,8 +165,11 @@ int vlan_skb_recv(struct sk_buff *skb, struct net=
_device *dev,
>=20
>        rx_stats =3D per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
>                               smp_processor_id());


I am thinking if vlan_dev_info(dev) here should be
vlan_dev_info(skb->dev)...



>-       rx_stats->rx_packets++;
>-       rx_stats->rx_bytes +=3D skb->len;
>+       if (rx_stats) {
>+               rx_stats->rx_packets++;
>+               rx_stats->rx_bytes +=3D skb->len;
>+       } else
>+               pr_err("vlan_skb_recv() %p->rx_stats=3D%p -> %p\n", vl=
an_dev_info(dev), vlan_dev_info(dev)->vlan_rx_stats, rx_stats);
>=20
>        skb_pull_rcsum(skb, VLAN_HLEN);
>=20
>@@ -738,6 +741,7 @@ static int vlan_dev_init(struct net_device *dev)
>        vlan_dev_info(dev)->vlan_rx_stats =3D alloc_percpu(struct vlan=
_rx_stats);
>        if (!vlan_dev_info(dev)->vlan_rx_stats)
>                return -ENOMEM;
>+       pr_err("vlan_dev_init() %p->rx_stats=3D%p\n", vlan_dev_info(de=
v), vlan_dev_info(dev)->vlan_rx_stats);
>=20
>        return 0;
> }
>
>This slightly adjusted change produces the following output:
>...
>[ 1192.257978] ADDRCONF(NETDEV_UP): lan: link is not ready
>[ 1192.399059] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatec=
h.com>
>[ 1192.399063] All bugs added by David S. Miller <davem@redhat.com>
>[ 1192.404475] vlan_dev_init() da4ff360->rx_stats=3Ddbd5a340
>                               ^^^^^^^^
>[ 1196.000225] b44: lan: Link is up at 100 Mbps, full duplex.
>[ 1196.000234] b44: lan: Flow control is off for TX and off for RX.
>[ 1196.000379] ADDRCONF(NETDEV_CHANGE): lan: link becomes ready
>[ 1203.160226] lan.658: no IPv6 routers present
>[ 1212.760561] vlan_skb_recv() ddbb8b60->rx_stats=3D(null) -> (null)
>                               ^^^^^^^^
>[ 1212.794961] vlan_skb_recv() ddbb8b60->rx_stats=3D(null) -> (null)
>[ 1219.247018] svc: failed to register lockdv1 RPC service (errno 97).
>[ 1219.249919] mount.nfs used greatest stack depth: 1008 bytes left
>[ 1221.388602] vlan_skb_recv() ddbb8b60->rx_stats=3D(null) -> (null)
>[ 1221.388690] vlan_skb_recv() ddbb8b60->rx_stats=3D(null) -> (null)
>[ 1278.793350] vlan_skb_recv() ddbb8b60->rx_stats=3D(null) -> (null)
>[ 1283.750363] vlan_skb_recv() ddbb8b60->rx_stats=3D(null) -> (null)
>...
>
>This might explain the NULL rx_stats pointer, but why do there exist
>two distinct vlan_dev_info(dev)? (unless in one case dev would be
>the physical network device and in the other case it would be vlan dev=
ice?
>that is lan versus lan.658 in my case...)
>
>Thanks,
>Bruno
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel=
" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/

--=20
Live like a child, think like the god.
=20
