From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 19 Feb 2011 12:28:43 +0100
Message-ID: <20110219112842.GE2782@psychotron.redhat.com>
References: <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
 <20110218145850.GF2939@psychotron.redhat.com>
 <20110218.120656.104048936.davem@davemloft.net>
 <20110218205832.GE2602@psychotron.redhat.com>
 <21593.1298070371@death>
 <20110219080523.GB2782@psychotron.redhat.com>
 <4D5FA1D7.4050801@gmail.com>
 <20110219110830.GD2782@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686Ab1BSL2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Feb 2011 06:28:54 -0500
Content-Disposition: inline
In-Reply-To: <20110219110830.GD2782@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 19, 2011 at 12:08:31PM CET, jpirko@redhat.com wrote:
>Sat, Feb 19, 2011 at 11:56:23AM CET, nicolas.2p.debian@gmail.com wrote=
:
>>Le 19/02/2011 09:05, Jiri Pirko a =E9crit :
>>>This patch converts bonding to use rx_handler. Results in cleaner
>>>__netif_receive_skb() with much less exceptions needed. Also
>>>bond-specific work is moved into bond code.
>>>
>>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>>
>>>v1->v2:
>>>         using skb_iif instead of new input_dev to remember original
>>>	device
>>>v2->v3:
>>>	set orig_dev =3D skb->dev if skb_iif is set
>>>
>>
>>Why do we need to let the rx_handlers call netif_rx() or __netif_rece=
ive_skb()?
>>
>>Bonding used to be handled with very few overhead, simply replacing
>>skb->dev with skb->dev->master. Time has passed and we eventually
>>added many special processing for bonding into __netif_receive_skb(),
>>but the overhead remained very light.
>>
>>Calling netif_rx() (or __netif_receive_skb()) to allow nesting would =
probably lead to some overhead.
>>
>>Can't we, instead, loop inside __netif_receive_skb(), and deliver
>>whatever need to be delivered, to whoever need, inside the loop ?
>>
>>rx_handler =3D rcu_dereference(skb->dev->rx_handler);
>>while (rx_handler) {
>>	/* ...  */
>>	orig_dev =3D skb->dev;
>>	skb =3D rx_handler(skb);
>>	/* ... */
>>	rx_handler =3D (skb->dev !=3D orig_dev) ? rcu_dereference(skb->dev->=
rx_handler) : NULL;
>>}
>>
>>This would reduce the overhead, while still allowing nesting: vlan on
>>top on bonding, bridge on top on bonding, ...
>
>I see your point. Makes sense to me. But the loop would have to includ=
e
>at least processing of ptype_all too. I'm going to cook a follow-up
>patch.
>

DRAFT (doesn't modify rx_handlers):

diff --git a/net/core/dev.c b/net/core/dev.c
index 4ebf7fe..e5dba47 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3115,6 +3115,7 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 {
 	struct packet_type *ptype, *pt_prev;
 	rx_handler_func_t *rx_handler;
+	struct net_device *dev;
 	struct net_device *orig_dev;
 	struct net_device *null_or_dev;
 	int ret =3D NET_RX_DROP;
@@ -3129,7 +3130,9 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 	if (netpoll_receive_skb(skb))
 		return NET_RX_DROP;
=20
-	__this_cpu_inc(softnet_data.processed);
+	skb->skb_iif =3D skb->dev->ifindex;
+	orig_dev =3D skb->dev;
+
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 	skb->mac_len =3D skb->network_header - skb->mac_header;
@@ -3138,12 +3141,9 @@ static int __netif_receive_skb(struct sk_buff *s=
kb)
=20
 	rcu_read_lock();
=20
-	if (!skb->skb_iif) {
-		skb->skb_iif =3D skb->dev->ifindex;
-		orig_dev =3D skb->dev;
-	} else {
-		orig_dev =3D dev_get_by_index_rcu(dev_net(skb->dev), skb->skb_iif);
-	}
+another_round:
+	__this_cpu_inc(softnet_data.processed);
+	dev =3D skb->dev;
=20
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
@@ -3153,7 +3153,7 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 #endif
=20
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
+		if (!ptype->dev || ptype->dev =3D=3D dev) {
 			if (pt_prev)
 				ret =3D deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev =3D ptype;
@@ -3167,7 +3167,7 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 ncls:
 #endif
=20
-	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
+	rx_handler =3D rcu_dereference(dev->rx_handler);
 	if (rx_handler) {
 		if (pt_prev) {
 			ret =3D deliver_skb(skb, pt_prev, orig_dev);
@@ -3176,6 +3176,8 @@ ncls:
 		skb =3D rx_handler(skb);
 		if (!skb)
 			goto out;
+		if (dev !=3D skb->dev)
+			goto another_round;
 	}
=20
 	if (vlan_tx_tag_present(skb)) {
