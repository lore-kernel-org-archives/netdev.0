From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bnx2x: dont dereference tcp header on non tcp frames
Date: Wed, 20 Apr 2011 09:31:53 +0200
Message-ID: <1303284713.3186.13.camel@edumazet-laptop>
References: <1303229503.3480.386.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eilon Greenstein <eilong@broadcom.com>,
	netdev <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48597 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab1DTHb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 03:31:58 -0400
Received: by wya21 with SMTP id 21so358931wya.19
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 00:31:57 -0700 (PDT)
In-Reply-To: <1303229503.3480.386.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 18:11 +0200, Eric Dumazet a =C3=A9crit :
> Hi guys
>=20
> bnx2x_set_pbd_csum() / bnx2x_set_pbd_csum_e2() seem to read
> tcp_hdrlen(skb) even for non TCP frames ?
>=20
> Also, (skb_network_header(skb) - skb->data) is signed, so=20
> 	(skb_network_header(skb) - skb->data) / 2 is a bit expensive...
>=20

I managed to trigger a kmemcheck fault using netperf -t UDP_RR

02:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM57711=
E 10Gigabit PCIe

[  341.246514] WARNING: kmemcheck: Caught 8-bit read from uninitialized=
 memory (ffff88011800ec30)
[  341.247155] c0a8146ea907c4550009aa456ed20000080004000400000014000300=
00000000
[  341.249789]  i i i i i i i i i i i i i u u u u u u u u u u u u u u u=
 u u u u
[  341.252425]                                  ^
[  341.252773]=20
[  341.252937] Pid: 4122, comm: netperf Not tainted 2.6.39-rc4-00237-ge=
3de956-dirty #549 HP ProLiant BL460c G6
[  341.253768] RIP: 0010:[<ffffffff812f5224>]  [<ffffffff812f5224>] bnx=
2x_start_xmit+0xce4/0x13f0
[  341.254476] RSP: 0018:ffff8801158b38b8  EFLAGS: 00010286
[  341.254879] RAX: ffff88011800ec24 RBX: ffff880118e44820 RCX: 0000000=
000000007
[  341.255400] RDX: 000000000000000a RSI: ffff880118e44820 RDI: ffff880=
11800ec40
[  341.255918] RBP: ffff8801158b39b8 R08: ffff88011800ec40 R09: ffff880=
11800ec00
[  341.256439] R10: 0000000000000000 R11: 000000006e14a8c0 R12: ffff880=
118f4db00
[  341.256958] R13: 0000000000000481 R14: 0000000000000040 R15: ffff880=
118ff18e0
[  341.257479] FS:  0000000000000000(0000) GS:ffff88011fc00000(0063) kn=
lGS:00000000f77e16c0
[  341.258081] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  341.258511] CR2: ffff880119856058 CR3: 0000000115879000 CR4: 0000000=
0000006f0
[  341.259033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[  341.259551] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000=
000000400
[  341.260072]  [<ffffffff8137fac5>] dev_hard_start_xmit+0x365/0x690
[  341.260593]  [<ffffffff81398bf7>] sch_direct_xmit+0xb7/0x1c0
[  341.261091]  [<ffffffff81383da8>] dev_queue_xmit+0x1a8/0x5d0
[  341.261583]  [<ffffffff813c2842>] ip_finish_output+0x122/0x2f0
[  341.262122]  [<ffffffff813c163e>] ip_output+0x7e/0xc0
[  341.262609]  [<ffffffff813c1194>] ip_local_out+0x24/0x30
[  341.263114]  [<ffffffff813c11b6>] ip_send_skb+0x16/0x70
[  341.263611]  [<ffffffff813e1326>] udp_send_skb+0x126/0x380
[  341.264129]  [<ffffffff813e300c>] udp_sendmsg+0x2cc/0x790
[  341.264637]  [<ffffffff813eaf44>] inet_sendmsg+0x84/0xc0
[  341.265143]  [<ffffffff8136d98b>] sock_sendmsg+0xbb/0xf0
[  341.265646]  [<ffffffff8136e1e5>] sys_sendto+0x105/0x140
[  341.266151]  [<ffffffff8136e22f>] sys_send+0xf/0x20
[  341.266625]  [<ffffffff813969fd>] compat_sys_socketcall+0xfd/0x1f0
[  341.267186]  [<ffffffff8146b8e9>] sysenter_dispatch+0x7/0x27

[PATCH] bnx2x: dont dereference tcp header on non tcp frames

bnx2x_set_pbd_csum() & bnx2x_set_pbd_csum_e2() use=20
tcp_hdrlen(skb) even for non TCP frames

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Dmitry Kravkov <dmitry@broadcom.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cm=
n.c
index e83ac6d..a16a638 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2019,7 +2019,9 @@ static inline void bnx2x_set_pbd_gso(struct sk_bu=
ff *skb,
 static inline  u8 bnx2x_set_pbd_csum_e2(struct bnx2x *bp, struct sk_bu=
ff *skb,
 	u32 *parsing_data, u32 xmit_type)
 {
-	*parsing_data |=3D ((tcp_hdrlen(skb)/4) <<
+	u8 tcphlen =3D (xmit_type & XMIT_CSUM_TCP) ? tcp_hdrlen(skb) : 0;
+
+	*parsing_data |=3D ((tcphlen/4) <<
 		ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW_SHIFT) &
 		ETH_TX_PARSE_BD_E2_TCP_HDR_LENGTH_DW;
=20
@@ -2027,7 +2029,7 @@ static inline  u8 bnx2x_set_pbd_csum_e2(struct bn=
x2x *bp, struct sk_buff *skb,
 		ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W_SHIFT) &
 		ETH_TX_PARSE_BD_E2_TCP_HDR_START_OFFSET_W;
=20
-	return skb_transport_header(skb) + tcp_hdrlen(skb) - skb->data;
+	return skb_transport_header(skb) + tcphlen - skb->data;
 }
=20
 /**
@@ -2044,6 +2046,7 @@ static inline u8 bnx2x_set_pbd_csum(struct bnx2x =
*bp, struct sk_buff *skb,
 	u32 xmit_type)
 {
 	u8 hlen =3D (skb_network_header(skb) - skb->data) / 2;
+	u8 tcphlen =3D (xmit_type & XMIT_CSUM_TCP) ? tcp_hdrlen(skb) : 0;
=20
 	/* for now NS flag is not used in Linux */
 	pbd->global_data =3D
@@ -2053,7 +2056,7 @@ static inline u8 bnx2x_set_pbd_csum(struct bnx2x =
*bp, struct sk_buff *skb,
 	pbd->ip_hlen_w =3D (skb_transport_header(skb) -
 			skb_network_header(skb)) / 2;
=20
-	hlen +=3D pbd->ip_hlen_w + tcp_hdrlen(skb) / 2;
+	hlen +=3D pbd->ip_hlen_w + tcphlen / 2;
=20
 	pbd->total_hlen_w =3D cpu_to_le16(hlen);
 	hlen =3D hlen*2;


