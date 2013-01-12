From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH 6/6] ipv6: IPv6 over IEEE1394 (RFC3146) support.
Date: Sun, 13 Jan 2013 01:39:43 +0900
Message-ID: <50F191CF.3060803@linux-ipv6.org>
References: <50F17178.3090705@linux-ipv6.org> <20130112164741.1a0ab7bb@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephan Gatzka <stephan.gatzka@gmail.com>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36843 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753719Ab3ALQjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 11:39:45 -0500
In-Reply-To: <20130112164741.1a0ab7bb@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter wrote:
> On Jan 12 YOSHIFUJI Hideaki wrote:

>>  static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
>> @@ -366,6 +395,19 @@ static void pndisc_destructor(struct pneigh_entry *n)
>>  	ipv6_dev_mc_dec(dev, &maddr);
>>  }
>>  
>> +void ndisc_update_peerinfo(struct net_device *dev, void *lladdr)
>> +{
>> +#if defined(CONFIG_FIREWIRE_NET)
>> +	switch (dev->type) {
>> +	case ARPHRD_IEEE1394:
>> +		fwnet_update_peerinfo(dev, lladdr, (struct fwnet_peerinfo *)((__u64 *)lladdr + 1));
>> +		break;
>> +	default:
>> +		break;
>> +	}
>> +#endif
> [...]
> 
> Dito, please do not solve this with an EXPORT from drivers/firewire/net.c.
> 
> Either a new driver callback is required, and the function pointer to this
> callback needs to be reachable indirectly via the skb pointer.
> 
> Or drivers/firewire/net.c needs to be aware that it just received an NDP
> packet, and then call a parser function in net/ipv6/ndisc.c which returns
> the data that drivers/firewire/net.c wants to know.

How about putting EUI64, maxrec, sspd and fifo in dev->dev_addr?
This enable us to send NDISC/ARP packet easily (based on neighbor
cache entry), and driver can be notified for new neighbors (thus
new peers). Driver can manage peer information based on this
notification.

Note that notification mechanism is used in Chelsio cxgbe4
driver, for example.

It requires some further modification to driver itself, but I
guess we do not need any exports with this, and I guess most
of most of arp related code can be removed from the driver.

--yoshfuji
