From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: [2.6.33-rc5 regression] NULL pointer dereference in
 vlan_skb_recv - probably introduced by commit
 9793241fe92f7d9303fb221e43fc598eb065f267
Date: Sun, 24 Jan 2010 16:02:28 +0100
Message-ID: <20100124160228.366f4e72@neptune.home>
References: <20100123165657.187c11e4@neptune.home>
	<20100123223132.0e62d8cb@neptune.home>
	<4B5C4E5E.2010507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753682Ab0AXPLs@vger.kernel.org>
In-Reply-To: <4B5C4E5E.2010507@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 24 January 2010 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le 23/01/2010 22:31, Bruno Pr=C3=A9mont a =C3=A9crit :
> >> Above part of code did change between 2.6.32 and 2.6.33-rc5 with
> >> commit 9793241fe92f7d9303fb221e43fc598eb065f267 (vlan: Precise RX
> >> stats accounting)
> >> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommitdiff;h=3D9793241fe92f7d9303fb221e43fc598eb065f267
> >=20
> > Reverting just that commit gets the system running correctly.
> >=20
> > Bruno
>=20
> I have no idea how this patch can break vlan networking.
>=20
> Your disassembly and .config seems to show your machine is not SMP
>=20
> Maybe something is broken on UP and alloc_percpu() ?
>=20
> Could you add a debug in vlan_dev_init()
>=20
>=20
>  	vlan_dev_info(dev)->vlan_rx_stats =3D alloc_percpu(struct
> vlan_rx_stats); if (!vlan_dev_info(dev)->vlan_rx_stats)
>  	return -ENOMEM;
> +	pr_err("vlan_dev_init() rx_stats=3D%p\n",
> vlan_dev_info(dev)->vlan_rx_stats);
>=20
>=20
> This make sure vlan_dev_init() is called and percpu allocation is
> properly done.
>=20
> Thanks

Readding your "precise RX stats" commit with following additional chang=
es I get
(first hunk to avoid crash):

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b788978..9216a98 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -165,8 +165,11 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_=
device *dev,
=20
        rx_stats =3D per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats,
                               smp_processor_id());
-       rx_stats->rx_packets++;
-       rx_stats->rx_bytes +=3D skb->len;
+       if (rx_stats) {
+               rx_stats->rx_packets++;
+               rx_stats->rx_bytes +=3D skb->len;
+       } else
+               pr_err("vlan_skb_recv() rx_stats=3D%p -> %p\n",
  vlan_dev_info(dev)->vlan_rx_stats, rx_stats);=20
        skb_pull_rcsum(skb, VLAN_HLEN);
=20
@@ -738,6 +741,7 @@ static int vlan_dev_init(struct net_device *dev)
        vlan_dev_info(dev)->vlan_rx_stats =3D alloc_percpu(struct
  vlan_rx_stats); if (!vlan_dev_info(dev)->vlan_rx_stats)
                return -ENOMEM;
+       pr_err("vlan_dev_init() rx_stats=3D%p\n",
  vlan_dev_info(dev)->vlan_rx_stats);=20
        return 0;
 }


=2E..
[   13.877610] Ending clean XFS mount for filesystem: loop0
[   15.795601] Adding 1004020k swap on /dev/sda5.  Priority:-1 extents:=
1 across:1004020k=20
[   16.612143] ADDRCONF(NETDEV_UP): lan: link is not ready
[   16.851846] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech=
=2Ecom>
[   16.851856] All bugs added by David S. Miller <davem@redhat.com>
[   16.878049] vlan_dev_init() rx_stats=3Ddceae290
[   20.040395] b44: lan: Link is up at 100 Mbps, full duplex.
[   20.040404] b44: lan: Flow control is off for TX and off for RX.
[   20.040535] ADDRCONF(NETDEV_CHANGE): lan: link becomes ready
[   25.019941] RPC: Registered udp transport module.
[   25.019950] RPC: Registered tcp transport module.
[   25.019956] RPC: Registered tcp NFSv4.1 backchannel transport module=
=2E
[   25.382400] svc: failed to register lockdv1 RPC service (errno 97).
[   25.385278] mount.nfs used greatest stack depth: 1012 bytes left
[   25.872973] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[   26.740561] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   26.775071] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   27.050223] lan.658: no IPv6 routers present
[   58.357052] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   63.350334] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   91.767589] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   91.932344] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   91.933053] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   91.998628] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   92.002752] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   92.007918] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   92.009644] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   92.016789] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   92.018520] vlan_skb_recv() rx_stats=3D(null) -> (null)
[   92.041737] vlan_skb_recv() rx_stats=3D(null) -> (null)
=2E..

So during vlan_dev_init() rx_stats is properly initialized, but when
packets reach the vlan dev later on exactly that same pointer is NULL..=
=2E

So question is, who did reset vlan_dev_info(dev)->vlan_rx_stats to NULL=
?

Thanks,
Bruno
