From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Elide fib_validate_source() completely when
 possible.
Date: Sat, 30 Jun 2012 13:45:52 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1206301300530.1593@ja.ssi.bg>
References: <20120629.020552.2190372012516348013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35937 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091Ab2F3Kjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2012 06:39:52 -0400
In-Reply-To: <20120629.020552.2190372012516348013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 29 Jun 2012, David Miller wrote:

> If rpfilter is off (or the SKB has an IPSEC path) and there are not
> tclassid users, we don't have to do anything at all when
> fib_validate_source() is invoked besides setting the itag to zero.
> 
> We monitor tclassid uses with a counter (modified only under RTNL and
> marked __read_mostly) and we protect the fib_validate_source() real
> work with a test against this counter and whether rpfilter is to be
> done.
> 
> Having a way to know whether we need no tclassid processing or not
> also opens the door for future optimized rpfilter algorithms that do
> not perform full FIB lookups.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

> +/* Ignore rp_filter for packets protected by IPsec. */
> +int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
> +			u8 tos, int oif, struct net_device *dev,
> +			struct in_device *idev, u32 *itag)
> +{
> +	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
> +

	It seems now we change the IN_DEV_ACCEPT_LOCAL policy
to depend on IN_DEV_RPFILTER. Isn't that dangerous for
home routers that disable rp_filter when using 2 or more
uplinks? I know that now rp_filter can be enabled for such
setups but sometimes users just update the kernel and can
miss such change.

	If we need the old behavior we should also check
IN_DEV_ACCEPT_LOCAL here. Then servers protected by firewall
can avoid this check by enabling accept_local. Established
stream sockets are anyways optimized by the new demux code.

	Not sure how fatal is the case of forwarding with
saddr=local_address. May be the risks for loops are same.

	If we really want a change in behavior we should
at least update the accept_local info in
Documentation/networking/ip-sysctl.txt ?

> +	if (!r && !fib_num_tclassid_users) {
> +		*itag = 0;
> +		return 0;
> +	}
> +	return __fib_validate_source(skb, src, dst, tos, oif, dev, r, idev, itag);
> +}
> +

Regards

--
Julian Anastasov <ja@ssi.bg>
