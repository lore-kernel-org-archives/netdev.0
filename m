From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 26 Feb 2011 08:14:34 +0100
Message-ID: <20110226071433.GA2783@psychotron.redhat.com>
References: <1298039252.6201.66.camel@edumazet-laptop>
 <4D5E8655.5070304@trash.net>
 <20110218145850.GF2939@psychotron.redhat.com>
 <20110218.120656.104048936.davem@davemloft.net>
 <20110218205832.GE2602@psychotron.redhat.com>
 <20110223190541.GB2783@psychotron.redhat.com>
 <4D683F6D.1030208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab1BZHPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Feb 2011 02:15:16 -0500
Content-Disposition: inline
In-Reply-To: <4D683F6D.1030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Feb 26, 2011 at 12:46:53AM CET, nicolas.2p.debian@gmail.com wrote:
>Le 23/02/2011 20:05, Jiri Pirko a =E9crit :
>>This patch converts bonding to use rx_handler. Results in cleaner
>>__netif_receive_skb() with much less exceptions needed. Also
>>bond-specific work is moved into bond code.
>>
>>Did performance test using pktgen and counting incoming packets by
>>iptables. No regression noted.
>>
>>Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>>
>>v1->v2:
>>         using skb_iif instead of new input_dev to remember original
>>	device
>>
>>v2->v3:
>>	do another loop in case skb->dev is changed. That way orig_dev
>>	core can be left untouched.
>
>Hi Jiri,
>
>Eventually taking enough time for a review.
>
>I think we should split this change :
>
>1/ Change __netif_receive_skb() to call rx_handler for diverted net_de=
vice, until rx_handler is NULL.
>
>2/ Convert currently existing rx_handlers (bridge and macvlan) to use
>this new "loop" feature, removing the need to call netif_rx() inside
>their respective rx_handler and also removing the associated
>overhead.

This might not be possible. Macvlan uses result of called netif_rx for
counting, bridge calls netdev_receive_skb via NF_HOOK. Nevertheless,
this can be eventually handled later, not as a part of this patch.
>
>3/ Convert bonding to use rx_handlers.
>
>Also, on step 1, we definitely need to clarify what orig_dev should be=
=2E
>
>I now think that orig_dev should be "the device one level below the
>current one" or NULL if current device was not diverted from another
>one. It means that we should keep an array of crossed (diverted)
>devices and the associated orig_dev. This array would be used to pass
>the right orig_dev to protocol handlers, depending on the device they
>register on :

I constructed the patch in the way origdev is the same in all situation=
s
as before the patch. I think that this decision can be ommitted at the
moment.

>
>eth0 -> bond0 -> br0
>
>A protocol handler registered on bond0 would receive eth0 as orig_dev.
>A protocol handler registered on br0 would receive bond0 as orig_dev.
>
>[snip]
>
>>@@ -3167,32 +3135,8 @@ static int __netif_receive_skb(struct sk_buff =
*skb)
>
>[snip]
>
>>+another_round:
>>+
>>+	__this_cpu_inc(softnet_data.processed);
>>+
>>  #ifdef CONFIG_NET_CLS_ACT
>>  	if (skb->tc_verd&  TC_NCLS) {
>>  		skb->tc_verd =3D CLR_TC_NCLS(skb->tc_verd);
>>@@ -3209,8 +3157,7 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>>  #endif
>>
>>  	list_for_each_entry_rcu(ptype,&ptype_all, list) {
>>-		if (ptype->dev =3D=3D null_or_orig || ptype->dev =3D=3D skb->dev |=
|
>>-		    ptype->dev =3D=3D orig_dev) {
>>+		if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
>>  			if (pt_prev)
>>  				ret =3D deliver_skb(skb, pt_prev, orig_dev);
>>  			pt_prev =3D ptype;
>>@@ -3224,16 +3171,20 @@ static int __netif_receive_skb(struct sk_buff=
 *skb)
>>  ncls:
>>  #endif
>>
>
>Why do you loop to ptype_all before calling rx_handler ?
>
>I don't understand why ptype_all and ptype_base are not handled at
>the same place in current __netif_receive_skb() but I think we should
>take the opportunity to change that, unless someone know of a good
>reason not to do so.

Again, the patch tries to do as little changes as it can. So this stays
the same as before. In case you want to change it, feel free to submit
patch doing that as follow-on.

>
>>-	/* Handle special case of bridge or macvlan */
>>  	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
>>  	if (rx_handler) {
>
>	Nicolas.
