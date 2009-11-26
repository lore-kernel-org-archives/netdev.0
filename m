From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/4] veth: move loopback logic to common location
Date: Thu, 26 Nov 2009 22:14:25 +0100
Message-ID: <4B0EEFB1.3080403@trash.net>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <200911261621.28298.arnd@arndb.de> <4B0E9FD0.4040107@trash.net> <200911261844.59912.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	virtualization@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62981 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbZKZVOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 16:14:20 -0500
In-Reply-To: <200911261844.59912.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Thursday 26 November 2009, Patrick McHardy wrote:
>> In addition to those already handled, I'd say
>>
>> - priority: affects qdisc classification, may refer to classes of the
>>   old namespace
>> - ipvs_property: might cause packets to incorrectly skip netfilter hooks
>> - nf_trace: might trigger packet tracing
>> - nf_bridge: contains references to network devices in the old NS,
>>   also indicates packet was bridged
>> - iif: index is only valid in the originating namespace
>> - probably secmark.
> 
> ok
> 
>> - tc_index: classification result, should only be set in the namespace
>>   of the classifier
>> - tc_verd: RTTL etc. should begin at zero again
> 
> Wouldn't that defeat the purpose of RTTL? If you create a loop
> across two devices in different namespaces, it may no longer get
> detected. Or is that a different problem again?

Mhh good point, that would indeed be possible. OTOH using ingress
filtering in one namespace currently might cause the packet to get
dropped in a different namespace because the ttl runs out. For now
I'd suggest to go the safe route and keep the TTL intact until we
can come up with something better.

> +void skb_set_dev(struct sk_buff *skb, struct net_device *dev)
> +{
> +	if (skb->dev && !net_eq(dev_net(skb->dev), dev_net(dev))) {
> +		secpath_reset(skb);
> +		skb_dst_drop(skb);
> +		nf_reset(skb);
> +		skb_init_secmark(skb);
> +		skb->mark = 0;
> +		skb->priority = 0;
> +		skb->nf_trace = 0;
> +		skb->ipvs_property = 0;
> +#ifdef CONFIG_NET_SCHED
> +		skb->tc_index = 0;
> +#ifdef CONFIG_NET_CLS_ACT
> +		skb->tc_verd = SET_TC_VERD(skb->tc_verd, 0);
> +		skb->tc_verd = SET_TC_RTTL(skb->tc_verd, 0);
> +#endif
> +#endif

This makes we wonder which ones we actually should keep. Most of the
others get reinitialized anyways, so maybe its better to simply clear
the entire area up until ->tail like f.i. skb_recycle_check().

> +	}
> +	skb->dev = dev;
> +	skb->skb_iif = skb->dev->ifindex;

This doesn't seem necessary, if the packet goes through
netif_receive_skb, it will be set anyways.

> +}
> +EXPORT_SYMBOL(skb_set_dev);
