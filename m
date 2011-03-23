From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39-rc: WARNING: at __ip_select_ident+0xd3/0xf0()
Date: Wed, 23 Mar 2011 10:49:39 +0100
Message-ID: <1300873779.3063.39.camel@edumazet-laptop>
References: <AANLkTinacRCOx+z02n1OwBjGfVL5itzZs7Jqv_4PRXZK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinacRCOx+z02n1OwBjGfVL5itzZs7Jqv_4PRXZK@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 23 mars 2011 =C3=A0 10:14 +0300, Alexander Beregalov a =C3=A9=
crit :
> Hi
>=20
> I do not know how to reproduce it.
>=20
> WARNING: at include/net/inetpeer.h:102 __ip_select_ident+0xd3/0xf0()
> Hardware name:
> Modules linked in: hwmon_vid sata_sil i2c_nforce2
> Pid: 0, comm: swapper Not tainted 2.6.38-07035-g6447f55d #1
> Call Trace:
>  [<c102ad5d>] warn_slowpath_common+0x6d/0xa0
>  [<c13070c3>] ? __ip_select_ident+0xd3/0xf0
>  [<c13070c3>] ? __ip_select_ident+0xd3/0xf0
>  [<c102adad>] warn_slowpath_null+0x1d/0x20
>  [<c13070c3>] __ip_select_ident+0xd3/0xf0
>  [<c130df4c>] __ip_make_skb+0x25c/0x360
>  [<c130d807>] ? ip_append_data+0x67/0xa0
>  [<c132f980>] ? icmp_glue_bits+0x0/0x60
>  [<c130e0b4>] ip_push_pending_frames+0x14/0x30
>  [<c132f95c>] icmp_push_reply+0xdc/0x100
>  [<c13306a8>] icmp_send+0x408/0x4a0
>  [<c132ca61>] ? __udp4_lib_lookup.clone.49+0x171/0x2d0
>  [<c132d877>] __udp4_lib_rcv+0x487/0x6a0
>  [<c13058c0>] ? ip_route_input_common+0x0/0xa00
>  [<c132daa2>] udp_rcv+0x12/0x20
>  [<c13084bc>] ip_local_deliver+0x9c/0x140
>  [<c130846d>] ? ip_local_deliver+0x4d/0x140
>  [<c13087c6>] ip_rcv+0x266/0x560
>  [<c12e92b3>] __netif_receive_skb+0x393/0x400
>  [<c12e8fe4>] ? __netif_receive_skb+0xc4/0x400
>  [<c12e9472>] netif_receive_skb+0x42/0x50
>  [<c12e94b7>] napi_skb_finish+0x37/0x50
>  [<c12eadf3>] napi_gro_receive+0xb3/0xc0
>  [<c128d76f>] e1000_receive_skb.clone.34+0x3f/0x60
>  [<c128dfcf>] e1000_clean_rx_irq+0x27f/0x4b0
>  [<c1055be1>] ? __lock_acquire+0x441/0x19a0
>  [<c128d249>] e1000_clean+0x1e9/0x570
>  [<c13697fc>] ? _raw_spin_lock+0x5c/0x70
>  [<c12e9778>] net_rx_action+0xe8/0x170
>  [<c102ffe7>] __do_softirq+0x77/0x110
>  [<c102ff70>] ? __do_softirq+0x0/0x110
>  <IRQ>  [<c1030246>] ? irq_exit+0x76/0x90
>  [<c1003823>] ? do_IRQ+0x43/0xb0
>  [<c136f5ee>] ? common_interrupt+0x2e/0x34
>  [<c100755f>] ? default_idle+0x2f/0x60
>  [<c10015d6>] ? cpu_idle+0x36/0x60
>  [<c135f2e5>] ? rest_init+0xa5/0xb0
>  [<c135f240>] ? rest_init+0x0/0xb0
>  [<c163c663>] ? start_kernel+0x277/0x27e
>  [<c163c174>] ? unknown_bootoption+0x0/0x19f
>  [<c163c071>] ? i386_start_kernel+0x71/0x77
> --

Thanks Alexander for this bug report.

Here is a patch to fix this issue (and other crash you mentioned in nex=
t
mail)


[PATCH] ipv4: fix ip_rt_update_pmtu()

commit 2c8cec5c10bc (Cache learned PMTU information in inetpeer) added
an extra inet_putpeer() call in ip_rt_update_pmtu().

This results in various problems, since we can free one inetpeer, while
it is still in use.

Ref: http://www.spinics.net/lists/netdev/msg159121.html

Reported-by: Alexander Beregalov <a.beregalov@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 870b518..34921b0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1593,8 +1593,6 @@ static void ip_rt_update_pmtu(struct dst_entry *d=
st, u32 mtu)
 			rt->rt_peer_genid =3D rt_peer_genid();
 		}
 		check_peer_pmtu(dst, peer);
-
-		inet_putpeer(peer);
 	}
 }
=20
