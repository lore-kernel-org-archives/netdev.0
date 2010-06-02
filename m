From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: replace hooks in __netif_receive_skb (v4)
Date: Wed, 2 Jun 2010 08:50:31 +0200
Message-ID: <20100602065030.GA2603@psychotron.redhat.com>
References: <20100527180813.GA3714@psychotron.redhat.com>
 <20100527130822.02cb1661@nehalam>
 <20100528055154.GB2823@psychotron.redhat.com>
 <20100528061241.GC2823@psychotron.redhat.com>
 <1275030163.2650.3.camel@edumazet-laptop>
 <20100528073345.GD2823@psychotron.redhat.com>
 <20100601082805.1c84b16d@nehalam>
 <0199E0D51A61344794750DC57738F58E70B17D377A@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752056Ab0FBG4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 02:56:13 -0400
Content-Disposition: inline
In-Reply-To: <0199E0D51A61344794750DC57738F58E70B17D377A@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 01, 2010 at 06:13:51PM CEST, anna.fischer@hp.com wrote:
>> Subject: net: replace hooks in __netif_receive_skb (v4)
>> 
>> 
>> From: Jiri Pirko <jpirko@redhat.com>
>> 
>> What this patch does is it removes two receive frame hooks (for bridge
>> and for
>> macvlan) from __netif_receive_skb. These are replaced them with a
>> single
>> hook for both. It only supports one hook per device because it makes no
>> sense to do bridging and macvlan on the same device.
>> 
>> Then a network driver (of virtual netdev like macvlan or bridge) can
>> register
>> an rx_handler for needed net device.
>
>
>I think the idea of this is really good, and it has been long required to get rid of the bridging hook and the "hack" for macvlan to get into the network stack. 
>
>However, I wonder, if this is to be used as a generic interface, then why the restriction of only having a single hook per device? Yes, it makes sense to do this for the bridge/macvlan combination, but in general there could be other cases where you would want to allow multiple receivers per device. 

Right, I agree.

>
>
>> @@ -2792,6 +2778,7 @@ EXPORT_SYMBOL(__skb_bond_should_drop);
>>  static int __netif_receive_skb(struct sk_buff *skb)
>>  {
>>  	struct packet_type *ptype, *pt_prev;
>> +	rx_callback_func_t *rh;
>>  	struct net_device *orig_dev;
>>  	struct net_device *master;
>>  	struct net_device *null_or_orig;
>> @@ -2855,12 +2842,16 @@ static int __netif_receive_skb(struct sk
>>  ncls:
>>  #endif
>> 
>> -	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
>> -	if (!skb)
>> -		goto out;
>> -	skb = handle_macvlan(skb, &pt_prev, &ret, orig_dev);
>> -	if (!skb)
>> -		goto out;
>> +	/* Handle special case of bridge or macvlan */
>> +	if ((rh = rcu_dereference(skb->dev->rx_handler)) != NULL) {
>> +		if (pt_prev) {
>> +			ret = deliver_skb(skb, pt_prev, orig_dev);
>
>What happens with 'ret' here? It is completely ignored, isn't it? Because you assume that there is only a single receiver per device? I think it would be much better to have return codes that indicate whether a packet has been consumed by a receive handler, or whether it is supposed to be processed further. The same actually applies for the packet handlers that are processed a bit further down in netif_receive_skb() - the return code is ignored and so a handler has no control over further processing of the packet.

It's not ignored. it's returned at the end of the function __netif_receive_skb.
