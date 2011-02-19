From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 19 Feb 2011 14:18:00 +0100
Message-ID: <4D5FC308.9020507@gmail.com>
References: <1298039252.6201.66.camel@edumazet-laptop> <4D5E8655.5070304@trash.net> <20110218145850.GF2939@psychotron.redhat.com> <20110218.120656.104048936.davem@davemloft.net> <20110218205832.GE2602@psychotron.redhat.com> <21593.1298070371@death> <20110219080523.GB2782@psychotron.redhat.com> <4D5FA1D7.4050801@gmail.com> <20110219110830.GD2782@psychotron.redhat.com> <20110219112842.GE2782@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f52.google.com ([209.85.214.52]:44633 "EHLO
	mail-bw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab1BSNXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Feb 2011 08:23:51 -0500
Received: by bwz4 with SMTP id 4so4302709bwz.11
        for <netdev@vger.kernel.org>; Sat, 19 Feb 2011 05:23:50 -0800 (PST)
In-Reply-To: <20110219112842.GE2782@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/02/2011 12:28, Jiri Pirko a =E9crit :
> Sat, Feb 19, 2011 at 12:08:31PM CET, jpirko@redhat.com wrote:
>> Sat, Feb 19, 2011 at 11:56:23AM CET, nicolas.2p.debian@gmail.com wro=
te:
>>> Le 19/02/2011 09:05, Jiri Pirko a =E9crit :
>>>> This patch converts bonding to use rx_handler. Results in cleaner
>>>> __netif_receive_skb() with much less exceptions needed. Also
>>>> bond-specific work is moved into bond code.
>>>>
>>>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>>>
>>>> v1->v2:
>>>>          using skb_iif instead of new input_dev to remember origin=
al
>>>> 	device
>>>> v2->v3:
>>>> 	set orig_dev =3D skb->dev if skb_iif is set
>>>>
>>>
>>> Why do we need to let the rx_handlers call netif_rx() or __netif_re=
ceive_skb()?
>>>
>>> Bonding used to be handled with very few overhead, simply replacing
>>> skb->dev with skb->dev->master. Time has passed and we eventually
>>> added many special processing for bonding into __netif_receive_skb(=
),
>>> but the overhead remained very light.
>>>
>>> Calling netif_rx() (or __netif_receive_skb()) to allow nesting woul=
d probably lead to some overhead.
>>>
>>> Can't we, instead, loop inside __netif_receive_skb(), and deliver
>>> whatever need to be delivered, to whoever need, inside the loop ?
>>>
>>> rx_handler =3D rcu_dereference(skb->dev->rx_handler);
>>> while (rx_handler) {
>>> 	/* ...  */
>>> 	orig_dev =3D skb->dev;
>>> 	skb =3D rx_handler(skb);
>>> 	/* ... */
>>> 	rx_handler =3D (skb->dev !=3D orig_dev) ? rcu_dereference(skb->dev=
->rx_handler) : NULL;
>>> }
>>>
>>> This would reduce the overhead, while still allowing nesting: vlan =
on
>>> top on bonding, bridge on top on bonding, ...
>>
>> I see your point. Makes sense to me. But the loop would have to incl=
ude
>> at least processing of ptype_all too. I'm going to cook a follow-up
>> patch.
>>
>
> DRAFT (doesn't modify rx_handlers):
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4ebf7fe..e5dba47 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3115,6 +3115,7 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>   {
>   	struct packet_type *ptype, *pt_prev;
>   	rx_handler_func_t *rx_handler;
> +	struct net_device *dev;
>   	struct net_device *orig_dev;
>   	struct net_device *null_or_dev;
>   	int ret =3D NET_RX_DROP;
> @@ -3129,7 +3130,9 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>   	if (netpoll_receive_skb(skb))
>   		return NET_RX_DROP;
>
> -	__this_cpu_inc(softnet_data.processed);
> +	skb->skb_iif =3D skb->dev->ifindex;
> +	orig_dev =3D skb->dev;

orig_dev should be set inside the loop, to reflect "previously crossed =
device", while following the=20
path:

eth0 -> bond0 -> br0.

=46irst step inside loop:

orig_dev =3D eth0
skb->dev =3D bond0 (at the end of the loop).

Second step inside loop:

orig_dev =3D bond0
skb->dev =3D br0 (et the end of the loop).

This would allow for exact match delivery to bond0 if someone bind ther=
e.

> +
>   	skb_reset_network_header(skb);
>   	skb_reset_transport_header(skb);
>   	skb->mac_len =3D skb->network_header - skb->mac_header;
> @@ -3138,12 +3141,9 @@ static int __netif_receive_skb(struct sk_buff =
*skb)
>
>   	rcu_read_lock();
>
> -	if (!skb->skb_iif) {
> -		skb->skb_iif =3D skb->dev->ifindex;
> -		orig_dev =3D skb->dev;
> -	} else {
> -		orig_dev =3D dev_get_by_index_rcu(dev_net(skb->dev), skb->skb_iif)=
;
> -	}

I like the fact that it removes the above part.

> +another_round:
> +	__this_cpu_inc(softnet_data.processed);
> +	dev =3D skb->dev;
>
>   #ifdef CONFIG_NET_CLS_ACT
>   	if (skb->tc_verd&  TC_NCLS) {
> @@ -3153,7 +3153,7 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>   #endif
>
>   	list_for_each_entry_rcu(ptype,&ptype_all, list) {
> -		if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
> +		if (!ptype->dev || ptype->dev =3D=3D dev) {
>   			if (pt_prev)
>   				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>   			pt_prev =3D ptype;

Inside the loop, we should only do exact match delivery, for &ptype_all=
 and for=20
&ptype_base[ntohs(type) & PTYPE_HASH_MASK]:

         list_for_each_entry_rcu(ptype, &ptype_all, list) {
-               if (!ptype->dev || ptype->dev =3D=3D dev) {
+               if (ptype->dev =3D=3D dev) {
                         if (pt_prev)
                                 ret =3D deliver_skb(skb, pt_prev, orig=
_dev);
                         pt_prev =3D ptype;
                 }
         }


         list_for_each_entry_rcu(ptype,
                         &ptype_base[ntohs(type) & PTYPE_HASH_MASK], li=
st) {
                 if (ptype->type =3D=3D type &&
-                   (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D=
 skb->dev)) {
+                   (ptype->dev =3D=3D skb->dev)) {
                         if (pt_prev)
                                 ret =3D deliver_skb(skb, pt_prev, orig=
_dev);
                         pt_prev =3D ptype;
                 }
         }

After leaving the loop, we can do wilcard delivery, if skb is not NULL.

         list_for_each_entry_rcu(ptype, &ptype_all, list) {
-               if (!ptype->dev || ptype->dev =3D=3D dev) {
+               if (!ptype->dev) {
                         if (pt_prev)
                                 ret =3D deliver_skb(skb, pt_prev, orig=
_dev);
                         pt_prev =3D ptype;
                }
         }


         list_for_each_entry_rcu(ptype,
                         &ptype_base[ntohs(type) & PTYPE_HASH_MASK], li=
st) {
-               if (ptype->type =3D=3D type &&
-                   (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D=
 skb->dev)) {
+		if (ptype->type =3D=3D type && !ptype->dev) {
                         if (pt_prev)
                                 ret =3D deliver_skb(skb, pt_prev, orig=
_dev);
                         pt_prev =3D ptype;
                 }
         }

This would reduce the number of tests inside the list_for_each_entry_rc=
u() loops. And because we=20
match only ptype->dev =3D=3D dev inside the loop and !ptype->dev outsid=
e the loop, this should avoid=20
duplicate delivery.

Also, for performance reason, exact match protocol handler lists might =
be moved from ptype_base or=20
ptype_all to a per net_device list. That way, the list_for_each_entry_r=
cu() inside the loop could be=20
empty if no protocol handler bind on the current dev.

inside loop:

         list_for_each_entry_rcu(ptype, dev->ptype_all, list) {
                 if (pt_prev)
			ret =3D deliver_skb(skb, pt_prev, orig_dev);
                 pt_prev =3D ptype;
         }

         list_for_each_entry_rcu(ptype,
                         dev->ptype_base[ntohs(type) & PTYPE_HASH_MASK]=
, list) {
                 if (ptype->type =3D=3D type) {
                         if (pt_prev)
                                 ret =3D deliver_skb(skb, pt_prev, orig=
_dev);
                         pt_prev =3D ptype;
                 }
         }

Outside loop :

         list_for_each_entry_rcu(ptype, &ptype_all, list) {
                 if (pt_prev)
                         ret =3D deliver_skb(skb, pt_prev, orig_dev);
                 pt_prev =3D ptype;
         }


         list_for_each_entry_rcu(ptype,
                         &ptype_base[ntohs(type) & PTYPE_HASH_MASK], li=
st) {
		if (ptype->type =3D=3D type) {
                         if (pt_prev)
                                 ret =3D deliver_skb(skb, pt_prev, orig=
_dev);
                         pt_prev =3D ptype;
                 }
         }

This would require several changes into ptype_all and ptype_base handli=
ng, but should be faster.

> @@ -3167,7 +3167,7 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>   ncls:
>   #endif
>
> -	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
> +	rx_handler =3D rcu_dereference(dev->rx_handler);
>   	if (rx_handler) {
>   		if (pt_prev) {
>   			ret =3D deliver_skb(skb, pt_prev, orig_dev);
> @@ -3176,6 +3176,8 @@ ncls:
>   		skb =3D rx_handler(skb);
>   		if (!skb)
>   			goto out;
> +		if (dev !=3D skb->dev)

I would use "if (skb->dev !=3D dev)" for clarity, because skb->dev is e=
xpected to have changed, not dev.

> +			goto another_round;
>   	}
>
>   	if (vlan_tx_tag_present(skb)) {
>

	Nicolas.
