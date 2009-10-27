From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan: allow VLAN ID 0 to be used
Date: Tue, 27 Oct 2009 02:34:57 +0100
Message-ID: <4AE64E41.5030607@gmail.com>
References: <m34opmr2fz.fsf@ursa.amorsen.dk>	<4AE563C7.5070702@gmail.com>	<4AE5CAC6.4000604@gmail.com> <20091026.173232.33817336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: benny+usenet@amorsen.dk, gertjan_hofman@yahoo.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45225 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916AbZJ0BfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 21:35:05 -0400
In-Reply-To: <20091026.173232.33817336.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 26 Oct 2009 17:13:58 +0100
>=20
>> [PATCH] vlan: allow VLAN ID 0 to be used
>>
>> We currently use a 16 bit field (vlan_tci) to store VLAN ID on a skb=
=2E
>>
>> 0 value is used a special value, meaning VLAN ID not set.
>> This forbids use of VLAN ID 0
>>
>> As VLAN ID is 12 bits, we can use high order bit as a flag, and
>> allow VLAN ID 0
>>
>> Reported-by: Gertjan Hofman <gertjan_hofman@yahoo.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> This is going to need some more work.
>=20
> IXGBE is already using the higher bits of ->vlan_tci internally,
> your change breaks that.
>=20
> QLGE explicitly initializes skb->vlan_tci to zero, you'll need to mak=
e
> sure that's OK.
>=20
> There is an explicit "if (skb->vlan_tci" (ie. zero vs. non-zero) test
> in net/core/dev.c:netif_receive_skb()
>=20
> net/core/skbuff.c:__copy_skb_header() does a straight copy, you'll
> need to make sure that's still OK.
>=20
> net/packet/af_packet.c:tpacket_rcv() and packet_recvmsg() report the
> skb->vlan_tci value to userspace, that's broken now as userspace
> doesn't expect that new bit to be there.

Thanks a lot David for this extended review and guidelines

I hope I did not miss another important thing in this second version.

Again, tested on tg3 only, and on net-next-2.6 tree

[PATCH] vlan: allow null VLAN ID to be used

We currently use a 16 bit field (vlan_tci) to store VLAN ID/PRIO on a s=
kb.

Null value is used as a special value, meaning vlan tagging not enabled=
=2E
This forbids use of null vlan ID.

As pointed by David, some drivers use the 3 high order bits (PRIO)

As VLAN ID is 12 bits, we can use the remaining bit (CFI) as a flag, an=
d
allow null VLAN ID.

In case future code really wants to use VLAN_CFI_MASK, we'll have to us=
e
a bit outside of vlan_tci.

#define VLAN_PRIO_MASK         0xe000 /* Priority Code Point */
#define VLAN_PRIO_SHIFT        13
#define VLAN_CFI_MASK          0x1000 /* Canonical Format Indicator */
#define VLAN_TAG_PRESENT       VLAN_CFI_MASK
#define VLAN_VID_MASK          0x0fff /* VLAN Identifier */

Reported-by: Gertjan Hofman <gertjan_hofman@yahoo.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/if_vlan.h |   14 +++++++++-----
 net/8021q/vlan.h        |    2 +-
 net/8021q/vlan_dev.c    |    2 +-
 net/core/dev.c          |    2 +-
 net/packet/af_packet.c  |    5 +++--
 5 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 7ff9af1..8898cbe 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -63,7 +63,11 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const=
 struct sk_buff *skb)
 	return (struct vlan_ethhdr *)skb_mac_header(skb);
 }
=20
-#define VLAN_VID_MASK	0xfff
+#define VLAN_PRIO_MASK		0xe000 /* Priority Code Point */
+#define VLAN_PRIO_SHIFT		13
+#define VLAN_CFI_MASK		0x1000 /* Canonical Format Indicator */
+#define VLAN_TAG_PRESENT	VLAN_CFI_MASK
+#define VLAN_VID_MASK		0x0fff /* VLAN Identifier */
=20
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
@@ -105,8 +109,8 @@ static inline void vlan_group_set_device(struct vla=
n_group *vg,
 	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] =3D dev;
 }
=20
-#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci)
-#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci)
+#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESE=
NT)
+#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT=
)
=20
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 extern struct net_device *vlan_dev_real_dev(const struct net_device *d=
ev);
@@ -231,7 +235,7 @@ static inline struct sk_buff *__vlan_put_tag(struct=
 sk_buff *skb, u16 vlan_tci)
 static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *s=
kb,
 						     u16 vlan_tci)
 {
-	skb->vlan_tci =3D vlan_tci;
+	skb->vlan_tci =3D VLAN_TAG_PRESENT | vlan_tci;
 	return skb;
 }
=20
@@ -284,7 +288,7 @@ static inline int __vlan_hwaccel_get_tag(const stru=
ct sk_buff *skb,
 					 u16 *vlan_tci)
 {
 	if (vlan_tx_tag_present(skb)) {
-		*vlan_tci =3D skb->vlan_tci;
+		*vlan_tci =3D vlan_tx_tag_get(skb);
 		return 0;
 	} else {
 		*vlan_tci =3D 0;
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 82570bc..4ade5ed 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -89,7 +89,7 @@ static inline u32 vlan_get_ingress_priority(struct ne=
t_device *dev,
 {
 	struct vlan_dev_info *vip =3D vlan_dev_info(dev);
=20
-	return vip->ingress_priority_map[(vlan_tci >> 13) & 0x7];
+	return vip->ingress_priority_map[(vlan_tci >> VLAN_PRIO_SHIFT) & 0x7]=
;
 }
=20
 #ifdef CONFIG_VLAN_8021Q_GVRP
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4198ec5..e370197 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -393,7 +393,7 @@ int vlan_dev_set_egress_priority(const struct net_d=
evice *dev,
 	struct vlan_dev_info *vlan =3D vlan_dev_info(dev);
 	struct vlan_priority_tci_mapping *mp =3D NULL;
 	struct vlan_priority_tci_mapping *np;
-	u32 vlan_qos =3D (vlan_prio << 13) & 0xE000;
+	u32 vlan_qos =3D (vlan_prio << VLAN_PRIO_SHIFT) & VLAN_PRIO_MASK;
=20
 	/* See if a priority mapping exists.. */
 	mp =3D vlan->egress_priority_map[skb_prio & 0xF];
diff --git a/net/core/dev.c b/net/core/dev.c
index fa88dcd..5ab8668 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2303,7 +2303,7 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
=20
-	if (skb->vlan_tci && vlan_hwaccel_do_receive(skb))
+	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
 		return NET_RX_SUCCESS;
=20
 	/* if we've gotten here through NAPI, check netpoll */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ff752c6..33e68f2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -79,6 +79,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/mutex.h>
+#include <linux/if_vlan.h>
=20
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -766,7 +767,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct =
net_device *dev,
 			getnstimeofday(&ts);
 		h.h2->tp_sec =3D ts.tv_sec;
 		h.h2->tp_nsec =3D ts.tv_nsec;
-		h.h2->tp_vlan_tci =3D skb->vlan_tci;
+		h.h2->tp_vlan_tci =3D vlan_tx_tag_get(skb);
 		hdrlen =3D sizeof(*h.h2);
 		break;
 	default:
@@ -1493,7 +1494,7 @@ static int packet_recvmsg(struct kiocb *iocb, str=
uct socket *sock,
 		aux.tp_snaplen =3D skb->len;
 		aux.tp_mac =3D 0;
 		aux.tp_net =3D skb_network_offset(skb);
-		aux.tp_vlan_tci =3D skb->vlan_tci;
+		aux.tp_vlan_tci =3D vlan_tx_tag_get(skb);
=20
 		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
 	}
