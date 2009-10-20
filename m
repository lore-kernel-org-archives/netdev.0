From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 23:57:39 +0200
Message-ID: <4ADE3253.10302@gmail.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com> <4ADE2A24.6080300@gmail.com> <4ADE2C00.8030900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60091 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbZJTV5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 17:57:40 -0400
In-Reply-To: <4ADE2C00.8030900@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear a =E9crit :
> That's definitely a nasty little issue.  Using skb_set_queue_mapping
> in pktgen makes it run for me, but may just be getting lucky with the
> mac-vlan interfaces which will do the dev_queue_xmit (but, I don't so=
 much
> care exactly what queue is used as long as things don't crash and the
> link doesn't reset).
>=20
> Don't worry about a quick patch on my account.  I seem to have it wor=
king
> to at least some degree (no funny crashes, no link watchdog timeouts)=
=2E
>=20

Could you try following patch ?

This makes queue_mapping invariant if set in range [0 ... real_num_tx_q=
ueues-1]

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index df7b23a..3ef2429 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2023,17 +2023,17 @@ static inline void skb_copy_queue_mapping(struc=
t sk_buff *to, const struct sk_bu
=20
 static inline void skb_record_rx_queue(struct sk_buff *skb, u16 rx_que=
ue)
 {
-	skb->queue_mapping =3D rx_queue + 1;
+	skb->queue_mapping =3D rx_queue;
 }
=20
 static inline u16 skb_get_rx_queue(const struct sk_buff *skb)
 {
-	return skb->queue_mapping - 1;
+	return skb->queue_mapping;
 }
=20
 static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 {
-	return (skb->queue_mapping !=3D 0);
+	return (skb->queue_mapping !=3D 0xffff);
 }
=20
 extern u16 skb_tx_hash(const struct net_device *dev,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 80a9616..5f04f00 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -198,6 +198,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_=
t gfp_mask,
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize =3D size + sizeof(struct sk_buff);
 	atomic_set(&skb->users, 1);
+	skb->queue_mapping =3D 0xffff;
 	skb->head =3D data;
 	skb->data =3D data;
 	skb_reset_tail_pointer(skb);


