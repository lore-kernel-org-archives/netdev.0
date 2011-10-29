From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Sat, 29 Oct 2011 12:22:26 +0200
Message-ID: <1319883746.2586.33.camel@edumazet-laptop>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>
	  <4E972301.4030004@intel.com>
	  <CAEP_g=9dk_ERdnw4Hw_8RO8Z23E1g2Q9G=AxPkiaVhwbHvo47A@mail.gmail.com>
	  <20111018.234723.1235424375699917420.davem@davemloft.net>
	  <1319796053.23112.92.camel@edumazet-laptop>
	 <1319799986.23112.101.camel@edumazet-laptop> <4EAB62F0.2040101@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"hans.schillstrom@ericsson.com" <hans.schillstrom@ericsson.com>,
	"jpirko@redhat.com" <jpirko@redhat.com>,
	"mbizon@freebox.fr" <mbizon@freebox.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42440 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245Ab1J2KWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 06:22:42 -0400
Received: by wwe6 with SMTP id 6so6890794wwe.1
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2011 03:22:41 -0700 (PDT)
In-Reply-To: <4EAB62F0.2040101@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 28 octobre 2011 =C3=A0 19:20 -0700, John Fastabend a =C3=A9=
crit :

> Thanks Eric! Thought about this some and I haven't come up
> with anything better yet. Even though this might be a slight
> hack I would prefer this to reverting the patch.
>=20
> I'll think about this more tomorrow. Would you be against
> submitting this patch?

I cant submit this patch, because its a hack and partial fix.

=46or Unicast packets, we still do the wrong thing : setting their
pkt_type to PACKET_OTHERHOST before the call to rx_handler :

In this case, bond_handle_frame() wont handle this packet correctly in
some cases (BOND_MODE_ALB ...). I suppose bridge might be confused as
well. So other problems remain.

We should delay the PACKET_OTHERHOST setting to the last moment, that i=
s
the last time vlan_do_receive() is called.

What about following patch instead ?

[PATCH] vlan: allow nested vlan_do_receive()

commit 2425717b27eb (net: allow vlan traffic to be received under bond)
broke ARP processing on vlan on top of bonding.

       +-------+
eth0 --| bond0 |---bond0.103
eth1 --|       |
       +-------+

52870.115435: skb_gro_reset_offset <-napi_gro_receive
52870.115435: dev_gro_receive <-napi_gro_receive
52870.115435: napi_skb_finish <-napi_gro_receive
52870.115435: netif_receive_skb <-napi_skb_finish
52870.115435: get_rps_cpu <-netif_receive_skb
52870.115435: __netif_receive_skb <-netif_receive_skb
52870.115436: vlan_do_receive <-__netif_receive_skb
52870.115436: bond_handle_frame <-__netif_receive_skb
52870.115436: vlan_do_receive <-__netif_receive_skb
52870.115436: arp_rcv <-__netif_receive_skb
52870.115436: kfree_skb <-arp_rcv

Packet is dropped in arp_rcv() because its pkt_type was set to
PACKET_OTHERHOST in the first vlan_do_receive() call, since no eth0.103
exists.

We really need to change pkt_type only if no more rx_handler is about t=
o
be called for the packet.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/if_vlan.h |    8 +++++---
 net/8021q/vlan_core.c   |    7 +++++--
 net/core/dev.c          |    4 ++--
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 44da482..95874ff 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -106,7 +106,8 @@ extern struct net_device *__vlan_find_dev_deep(stru=
ct net_device *real_dev,
 extern struct net_device *vlan_dev_real_dev(const struct net_device *d=
ev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
=20
-extern bool vlan_do_receive(struct sk_buff **skb);
+extern bool vlan_do_receive(struct sk_buff **skb,
+			    rx_handler_func_t *rx_handler);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
=20
 #else
@@ -128,9 +129,10 @@ static inline u16 vlan_dev_vlan_id(const struct ne=
t_device *dev)
 	return 0;
 }
=20
-static inline bool vlan_do_receive(struct sk_buff **skb)
+static inline bool vlan_do_receive(struct sk_buff **skb,
+				   rx_handler_func_t *rx_handler)
 {
-	if ((*skb)->vlan_tci & VLAN_VID_MASK)
+	if (((*skb)->vlan_tci & VLAN_VID_MASK) && !rx_handler)
 		(*skb)->pkt_type =3D PACKET_OTHERHOST;
 	return false;
 }
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index f1f2f7b..3ec1ada 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -4,7 +4,7 @@
 #include <linux/netpoll.h>
 #include "vlan.h"
=20
-bool vlan_do_receive(struct sk_buff **skbp)
+bool vlan_do_receive(struct sk_buff **skbp, rx_handler_func_t *rx_hand=
ler)
 {
 	struct sk_buff *skb =3D *skbp;
 	u16 vlan_id =3D skb->vlan_tci & VLAN_VID_MASK;
@@ -13,7 +13,10 @@ bool vlan_do_receive(struct sk_buff **skbp)
=20
 	vlan_dev =3D vlan_find_dev(skb->dev, vlan_id);
 	if (!vlan_dev) {
-		if (vlan_id)
+		/* Only the last call to vlan_do_receive() should change
+		 * pkt_type to PACKET_OTHERHOST
+		 */
+		if (vlan_id && !rx_handler)
 			skb->pkt_type =3D PACKET_OTHERHOST;
 		return false;
 	}
diff --git a/net/core/dev.c b/net/core/dev.c
index edcf019..40976b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3283,18 +3283,18 @@ another_round:
 ncls:
 #endif
=20
+	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
 	if (vlan_tx_tag_present(skb)) {
 		if (pt_prev) {
 			ret =3D deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev =3D NULL;
 		}
-		if (vlan_do_receive(&skb))
+		if (vlan_do_receive(&skb, rx_handler))
 			goto another_round;
 		else if (unlikely(!skb))
 			goto out;
 	}
=20
-	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
 		if (pt_prev) {
 			ret =3D deliver_skb(skb, pt_prev, orig_dev);
