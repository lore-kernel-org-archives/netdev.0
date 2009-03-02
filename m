From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Mon, 02 Mar 2009 12:02:05 +0100
Message-ID: <49ABBCAD.9030203@trash.net>
References: <20090226175247.5e56910f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42049 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006AbZCBLCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:02:09 -0500
In-Reply-To: <20090226175247.5e56910f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> This is a simple little iptables match that can be used to create the Strong
> End System model, that router and other non-Linux customers expect. There
> are management and other applications that use ping and expect to only get
> a response when the interface with that address is up. Normally, a Linux
> system will respond to a packet that arrives for any of the system addresses
> independent of which link it arrives on.
> 
> The module can be used on the INPUT chain like:
> 
> # iptables -P INPUT DROP
> # iptables -A INPUT -m strict -j ACCEPT

The idea makes sense ..

> +static bool strict_mt(const struct sk_buff *skb, const struct xt_match_param *par)
> +{
> +	struct in_device *in_dev;
> +	bool ret;
> +
> +	rcu_read_lock();
> +	in_dev = __in_dev_get_rcu(skb->dev);
> +	ret = (in_dev && inet_addr_onlink(in_dev, ip_hdr(skb)->daddr, 0));
> +	rcu_read_unlock();
> +
> +	return ret;
> +}

I'm not sure this is correct, I think it will only allow communication
with truely on-link addresses, meaning it won't accept routed packets
going to the interface address. Generally I don't think this can be
fully done in iptables since you'd still have to deal with ARP etc.
An IPv4 sysctl might be more appropriate.

Just for the IPv4 packets, I'm wondering if the intended result could
be achieved using the addrtype match. Something like:

-m addrtype --limit-iface-in --dst-type LOCAL

should check whether the destination address is local to the receiving
interface.
