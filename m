From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sun, 20 Feb 2011 16:07:14 +0100
Message-ID: <20110220150710.GB2750@psychotron.redhat.com>
References: <21593.1298070371@death>
 <20110219080523.GB2782@psychotron.redhat.com>
 <4D5FA1D7.4050801@gmail.com>
 <20110219110830.GD2782@psychotron.redhat.com>
 <20110219112842.GE2782@psychotron.redhat.com>
 <4D5FC308.9020507@gmail.com>
 <20110219134645.GF2782@psychotron.redhat.com>
 <4D6027B9.6050108@gmail.com>
 <20110220103609.GA2750@psychotron.redhat.com>
 <4D610511.4050902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	"Fischer, Anna" <anna.fischer@hp.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000Ab1BTPOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 10:14:07 -0500
Content-Disposition: inline
In-Reply-To: <4D610511.4050902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 20, 2011 at 01:12:01PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 20/02/2011 11:36, Jiri Pirko a =E9crit :
>>Sat, Feb 19, 2011 at 09:27:37PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>>>Le 19/02/2011 14:46, Jiri Pirko a =E9crit :
>>>>Sat, Feb 19, 2011 at 02:18:00PM CET, nicolas.2p.debian@gmail.com wr=
ote:
>>>>>Le 19/02/2011 12:28, Jiri Pirko a =E9crit :
>>>>>>Sat, Feb 19, 2011 at 12:08:31PM CET, jpirko@redhat.com wrote:
>>>>>>>Sat, Feb 19, 2011 at 11:56:23AM CET, nicolas.2p.debian@gmail.com=
 wrote:
>>>>>>>>Le 19/02/2011 09:05, Jiri Pirko a =E9crit :
>>>>>>>>>This patch converts bonding to use rx_handler. Results in clea=
ner
>>>>>>>>>__netif_receive_skb() with much less exceptions needed. Also
>>>>>>>>>bond-specific work is moved into bond code.
>>>>>>>>>
>>>>>>>>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>>>>>>>>
>>>>>>>>>v1->v2:
>>>>>>>>>         using skb_iif instead of new input_dev to remember or=
iginal
>>>>>>>>>	device
>>>>>>>>>v2->v3:
>>>>>>>>>	set orig_dev =3D skb->dev if skb_iif is set
>>>>>>>>>
>>>>>>>>
>>>>>>>>Why do we need to let the rx_handlers call netif_rx() or __neti=
f_receive_skb()?
>>>>>>>>
>>>>>>>>Bonding used to be handled with very few overhead, simply repla=
cing
>>>>>>>>skb->dev with skb->dev->master. Time has passed and we eventual=
ly
>>>>>>>>added many special processing for bonding into __netif_receive_=
skb(),
>>>>>>>>but the overhead remained very light.
>>>>>>>>
>>>>>>>>Calling netif_rx() (or __netif_receive_skb()) to allow nesting =
would probably lead to some overhead.
>>>>>>>>
>>>>>>>>Can't we, instead, loop inside __netif_receive_skb(), and deliv=
er
>>>>>>>>whatever need to be delivered, to whoever need, inside the loop=
 ?
>>>>>>>>
>>>>>>>>rx_handler =3D rcu_dereference(skb->dev->rx_handler);
>>>>>>>>while (rx_handler) {
>>>>>>>>	/* ...  */
>>>>>>>>	orig_dev =3D skb->dev;
>>>>>>>>	skb =3D rx_handler(skb);
>>>>>>>>	/* ... */
>>>>>>>>	rx_handler =3D (skb->dev !=3D orig_dev) ? rcu_dereference(skb-=
>dev->rx_handler) : NULL;
>>>>>>>>}
>>>>>>>>
>>>>>>>>This would reduce the overhead, while still allowing nesting: v=
lan on
>>>>>>>>top on bonding, bridge on top on bonding, ...
>>>>>>>
>>>>>>>I see your point. Makes sense to me. But the loop would have to =
include
>>>>>>>at least processing of ptype_all too. I'm going to cook a follow=
-up
>>>>>>>patch.
>>>>>>>
>>>>>>
>>>>>>DRAFT (doesn't modify rx_handlers):
>>>>>>
>>>>>>diff --git a/net/core/dev.c b/net/core/dev.c
>>>>>>index 4ebf7fe..e5dba47 100644
>>>>>>--- a/net/core/dev.c
>>>>>>+++ b/net/core/dev.c
>>>>>>@@ -3115,6 +3115,7 @@ static int __netif_receive_skb(struct sk_bu=
ff *skb)
>>>>>>  {
>>>>>>  	struct packet_type *ptype, *pt_prev;
>>>>>>  	rx_handler_func_t *rx_handler;
>>>>>>+	struct net_device *dev;
>>>>>>  	struct net_device *orig_dev;
>>>>>>  	struct net_device *null_or_dev;
>>>>>>  	int ret =3D NET_RX_DROP;
>>>>>>@@ -3129,7 +3130,9 @@ static int __netif_receive_skb(struct sk_bu=
ff *skb)
>>>>>>  	if (netpoll_receive_skb(skb))
>>>>>>  		return NET_RX_DROP;
>>>>>>
>>>>>>-	__this_cpu_inc(softnet_data.processed);
>>>>>>+	skb->skb_iif =3D skb->dev->ifindex;
>>>>>>+	orig_dev =3D skb->dev;
>>>>>
>>>>>orig_dev should be set inside the loop, to reflect "previously
>>>>>crossed device", while following the path:
>>>>>
>>>>>eth0 ->   bond0 ->   br0.
>>>>>
>>>>>First step inside loop:
>>>>>
>>>>>orig_dev =3D eth0
>>>>>skb->dev =3D bond0 (at the end of the loop).
>>>>>
>>>>>Second step inside loop:
>>>>>
>>>>>orig_dev =3D bond0
>>>>>skb->dev =3D br0 (et the end of the loop).
>>>>>
>>>>>This would allow for exact match delivery to bond0 if someone bind=
 there.
>>>>>
>>>>>>+
>>>>>>  	skb_reset_network_header(skb);
>>>>>>  	skb_reset_transport_header(skb);
>>>>>>  	skb->mac_len =3D skb->network_header - skb->mac_header;
>>>>>>@@ -3138,12 +3141,9 @@ static int __netif_receive_skb(struct sk_b=
uff *skb)
>>>>>>
>>>>>>  	rcu_read_lock();
>>>>>>
>>>>>>-	if (!skb->skb_iif) {
>>>>>>-		skb->skb_iif =3D skb->dev->ifindex;
>>>>>>-		orig_dev =3D skb->dev;
>>>>>>-	} else {
>>>>>>-		orig_dev =3D dev_get_by_index_rcu(dev_net(skb->dev), skb->skb_=
iif);
>>>>>>-	}
>>>>>
>>>>>I like the fact that it removes the above part.
>>>>>
>>>>>>+another_round:
>>>>>>+	__this_cpu_inc(softnet_data.processed);
>>>>>>+	dev =3D skb->dev;
>>>>>>
>>>>>>  #ifdef CONFIG_NET_CLS_ACT
>>>>>>  	if (skb->tc_verd&    TC_NCLS) {
>>>>>>@@ -3153,7 +3153,7 @@ static int __netif_receive_skb(struct sk_bu=
ff *skb)
>>>>>>  #endif
>>>>>>
>>>>>>  	list_for_each_entry_rcu(ptype,&ptype_all, list) {
>>>>>>-		if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
>>>>>>+		if (!ptype->dev || ptype->dev =3D=3D dev) {
>>>>>>  			if (pt_prev)
>>>>>>  				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>>>>>  			pt_prev =3D ptype;
>>>>>
>>>>>Inside the loop, we should only do exact match delivery, for
>>>>>&ptype_all and for&ptype_base[ntohs(type)&   PTYPE_HASH_MASK]:
>>>>>
>>>>>        list_for_each_entry_rcu(ptype,&ptype_all, list) {
>>>>>-               if (!ptype->dev || ptype->dev =3D=3D dev) {
>>>>>+               if (ptype->dev =3D=3D dev) {
>>>>>                        if (pt_prev)
>>>>>                                ret =3D deliver_skb(skb, pt_prev, =
orig_dev);
>>>>>                        pt_prev =3D ptype;
>>>>>                }
>>>>>        }
>>>>>
>>>>>
>>>>>        list_for_each_entry_rcu(ptype,
>>>>>                        &ptype_base[ntohs(type)&   PTYPE_HASH_MASK=
], list) {
>>>>>                if (ptype->type =3D=3D type&&
>>>>>-                   (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=
=3D skb->dev)) {
>>>>>+                   (ptype->dev =3D=3D skb->dev)) {
>>>>>                        if (pt_prev)
>>>>>                                ret =3D deliver_skb(skb, pt_prev, =
orig_dev);
>>>>>                        pt_prev =3D ptype;
>>>>>                }
>>>>>        }
>>>>>
>>>>>After leaving the loop, we can do wilcard delivery, if skb is not =
NULL.
>>>>>
>>>>>        list_for_each_entry_rcu(ptype,&ptype_all, list) {
>>>>>-               if (!ptype->dev || ptype->dev =3D=3D dev) {
>>>>>+               if (!ptype->dev) {
>>>>>                        if (pt_prev)
>>>>>                                ret =3D deliver_skb(skb, pt_prev, =
orig_dev);
>>>>>                        pt_prev =3D ptype;
>>>>>               }
>>>>>        }
>>>>>
>>>>>
>>>>>        list_for_each_entry_rcu(ptype,
>>>>>                        &ptype_base[ntohs(type)&   PTYPE_HASH_MASK=
], list) {
>>>>>-               if (ptype->type =3D=3D type&&
>>>>>-                   (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=
=3D skb->dev)) {
>>>>>+		if (ptype->type =3D=3D type&&   !ptype->dev) {
>>>>>                        if (pt_prev)
>>>>>                                ret =3D deliver_skb(skb, pt_prev, =
orig_dev);
>>>>>                        pt_prev =3D ptype;
>>>>>                }
>>>>>        }
>>>>>
>>>>>This would reduce the number of tests inside the
>>>>>list_for_each_entry_rcu() loops. And because we match only ptype->=
dev
>>>>>=3D=3D dev inside the loop and !ptype->dev outside the loop, this =
should
>>>>>avoid duplicate delivery.
>>>>
>>>>Would you care to put this into patch so I can see the whole pictur=
e?
>>>>Thanks.
>>>
>>>Here is what I have in mind. It is based on your previous DRAFT patc=
h, and don't modify rx_handlers yet.
>>>
>>>Only compile tested !!
>>>
>>>I don't know if every pieces are at the right place. I wonder what t=
o
>>>do with CONFIG_NET_CLS_ACT part, that currently is between ptype_all
>>>and ptype_base processing.
>>>
>>>Anyway, the general idea is there.
>>>
>>>	Nicolas.
>>>
>>>net/core/dev.c |   70 ++++++++++++++++++++++++++++++++++++++++++++++=
++--------
>>>1 files changed, 60 insertions(+), 10 deletions(-)
>>>
>>>diff --git a/net/core/dev.c b/net/core/dev.c
>>>index e5dba47..7e007a9 100644
>>>--- a/net/core/dev.c
>>>+++ b/net/core/dev.c
>>>@@ -3117,7 +3117,6 @@ static int __netif_receive_skb(struct sk_buff =
*skb)
>>>	rx_handler_func_t *rx_handler;
>>>	struct net_device *dev;
>>>	struct net_device *orig_dev;
>>>-	struct net_device *null_or_dev;
>>>	int ret =3D NET_RX_DROP;
>>>	__be16 type;
>>>
>>>@@ -3130,9 +3129,6 @@ static int __netif_receive_skb(struct sk_buff =
*skb)
>>>	if (netpoll_receive_skb(skb))
>>>		return NET_RX_DROP;
>>>
>>>-	skb->skb_iif =3D skb->dev->ifindex;
>>>-	orig_dev =3D skb->dev;
>>>-
>>>	skb_reset_network_header(skb);
>>>	skb_reset_transport_header(skb);
>>>	skb->mac_len =3D skb->network_header - skb->mac_header;
>>>@@ -3143,6 +3139,8 @@ static int __netif_receive_skb(struct sk_buff =
*skb)
>>>
>>>another_round:
>>>	__this_cpu_inc(softnet_data.processed);
>>>+	skb->skb_iif =3D skb->dev->ifindex;
>>>+	orig_dev =3D skb->dev;
>>orig_dev should be set at the end of the loop. Now you are going to h=
ave
>>it always the same as dev and skb->dev.
>>
>
>Yes, you are right.
>
>I thinking about all this, I wonder what the protocol handlers expect =
as the orig_dev value ?
>
>Lest imagine the following configuration: eth0 -> bond0 -> br0.
>
>What does a protocol handler listening on br0 expect for orig_dev ?
>bond0 or eth0 ? Current implementation give eth0, but I think bond0
>should be the right value, for proper nesting.

I agree with you.

>
>>>	dev =3D skb->dev;
>>>
>>>#ifdef CONFIG_NET_CLS_ACT
>>>@@ -3152,8 +3150,13 @@ another_round:
>>>	}
>>>#endif
>>>
>>>+	/*
>>>+	 * Deliver to ptype_all protocol handlers that match current dev.
>>>+	 * This happens before rx_handler is given a chance to change skb-=
>dev.
>>>+	 */
>>>+
>>>	list_for_each_entry_rcu(ptype,&ptype_all, list) {
>>>-		if (!ptype->dev || ptype->dev =3D=3D dev) {
>>>+		if (ptype->dev =3D=3D dev) {
>>>			if (pt_prev)
>>>				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>>			pt_prev =3D ptype;
>>>@@ -3167,6 +3170,31 @@ another_round:
>>>ncls:
>>>#endif
>>>
>>>+	/*
>>>+	 * Deliver to ptype_base protocol handlers that match current dev.
>>>+	 * This happens before rx_handler is given a chance to change skb-=
>dev.
>>>+	 */
>>>+
>>>+	type =3D skb->protocol;
>>>+	list_for_each_entry_rcu(ptype,
>>>+			&ptype_base[ntohs(type)&  PTYPE_HASH_MASK], list) {
>>>+		if (ptype->type =3D=3D type&&  ptype->dev =3D=3D skb->dev) {
>>>+			if (pt_prev)
>>>+				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>>+			pt_prev =3D ptype;
>>>+		}
>>>+	}
>>
>>I'm not sure it is ok to deliver ptype_base here. See comment above
>>ptype_head() (I'm not sure I understand that correctly)
>
>Anyway, all this is probably plain wrong: Delivering the skb to
>protocol handlers while still changing the skb is guaranteed to cause
>strange behaviors.
>
>If we want to be able to deliver the skb to different protocol
>handlers and give all of them the right values for dev->skb and
>orig_dev (or previous_dev), we might end up with copying the skb. I
>hate the idea, but currently can't find a cleaner way to do so.

That would be unfortunate :/
>
>We first need to clarify what orig_dev should be, as stated above.
>
>>>+
>>>+	/*
>>>+	 * Call rx_handler for current device.
>>>+	 * If rx_handler return NULL, skip wilcard protocol handler delive=
ry.
>>>+	 * Else, if skb->dev changed, restart the whole delivery process, =
to
>>>+	 * allow for device nesting.
>>>+	 *
>>>+	 * Warning:
>>>+	 * rx_handlers must kfree_skb(skb) if they return NULL.
>>Well this is not true. They can return NULL and call netif_rx as they
>>have before. No changes necessary I believe.
>
>I don't really know. This needs to be double checked, anyway.
>
>>>+	 */
>>>+
>>>	rx_handler =3D rcu_dereference(dev->rx_handler);
>>>	if (rx_handler) {
>>>		if (pt_prev) {
>>>@@ -3176,10 +3204,15 @@ ncls:
>>>		skb =3D rx_handler(skb);
>>>		if (!skb)
>>>			goto out;
>>>-		if (dev !=3D skb->dev)
>>>+		if (skb->dev !=3D dev)
>>>			goto another_round;
>>>	}
>>>
>>>+	/*
>>>+	 * FIXME: The part below should use rx_handler instead of being ha=
rd
>>>+	 * coded here.
>>I'm not sure it is doable atm. For bridge and bond it should not be a
>>problem, but for macvlan, there is possible to have macvlans and vlan=
s
>>on the same dev. This possibility should persist.
>>/me scratches head on the idea to have multiple rx_handlers although =
it
>>was his original idea....
>
>I think your original proposal of having several rx_handlers per devic=
e was right.
>
>At the time you introduced the rx_handler system, only bridge and
>macvlan used it. Even if using bridge and macvlan on the same base
>device might be useless, this is not true for every possible
>rx_handler configuration.
>
>Now that we want to move bonding and vlan to the rx_handler system,
>it becomes obvious that we need several rx_handlers per device. At
>least, vlan should properly mix with bridge. And who know what would
>be the fifth rx_handler...
>
>>>+	 */
>>>+
>>>	if (vlan_tx_tag_present(skb)) {
>>>		if (pt_prev) {
>>>			ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>>@@ -3192,16 +3225,33 @@ ncls:
>>>			goto out;
>>>	}
>>>
>>>+	/*
>>>+	 * FIXME: Can't this be moved into the rx_handler for bonding,
>>>+	 * or into a futur rx_handler for vlan?
>>This hook is something I do not like at all :/ But anyway if should b=
e in vlan
>>part I think.
>
>Yes, and in order for the future rx_handler for vlan to properly
>handle it, it needs to know the device just below it, not the pure
>original device. Hence, my question about the exact meaning of
>orig_dev...
>
>	Nicolas.
>
>>>+	 */
>>>+
>>>	vlan_on_bond_hook(skb);
>>>
>>>-	/* deliver only exact match when indicated */
>>>-	null_or_dev =3D skb->deliver_no_wcard ? skb->dev : NULL;
>>>+	/*
>>>+	 * Deliver to wildcard ptype_all protocol handlers.
>>>+	 */
>>>+
>>>+	list_for_each_entry_rcu(ptype,&ptype_all, list) {
>>>+		if (!ptype->dev) {
>>>+			if (pt_prev)
>>>+				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>>+			pt_prev =3D ptype;
>>>+		}
>>>+	}
>>>+
>>>+	/*
>>>+	 * Deliver to wildcard ptype_all protocol handlers.
>>>+	 */
>>>
>>>	type =3D skb->protocol;
>>>	list_for_each_entry_rcu(ptype,
>>>			&ptype_base[ntohs(type)&  PTYPE_HASH_MASK], list) {
>>>-		if (ptype->type =3D=3D type&&
>>>-		    (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D skb->dev)=
) {
>>>+		if (ptype->type =3D=3D type&&  !ptype->dev) {
>>>			if (pt_prev)
>>>				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>>			pt_prev =3D ptype;
>>>--
>>>1.7.2.3
>>>
>>>
>>>
