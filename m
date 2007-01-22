From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Mon, 22 Jan 2007 15:25:39 -0500
Message-ID: <45B51DC3.1010303@hp.com>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net> <45B504DC.8030107@kolumbus.fi> <20070122194548.GE21059@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:58285 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbXAVUZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 15:25:42 -0500
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20070122194548.GE21059@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil

I don't this is still right...

> @@ -746,6 +772,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  	int dad = ipv6_addr_any(saddr);
>  	int inc;
>  	int is_router;
> +	int type;
>  
>  	if (ipv6_addr_is_multicast(&msg->target)) {
>  		ND_PRINTK2(KERN_WARNING 
> @@ -796,14 +823,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  	inc = ipv6_addr_is_multicast(daddr);
>  
>  	if ((ifp = ipv6_get_ifaddr(&msg->target, dev, 1)) != NULL) {
> -		if (ifp->flags & IFA_F_TENTATIVE) {
> -			/* Address is tentative. If the source
> -			   is unspecified address, it is someone
> -			   does DAD, otherwise we ignore solicitations
> -			   until DAD timer expires.
> -			 */
> -			if (!dad)
> -				goto out;
> +
> +		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>  			if (dev->type == ARPHRD_IEEE802_TR) {
>  				unsigned char *sadr = skb->mac.raw;
>  				if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
> @@ -816,8 +837,23 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  					goto out;
>  				}
>  			}

First, you do looped packet detection for all packets, not just DAD.

> -			addrconf_dad_failure(ifp); 
> -			return;
> +
> +			/* The one exception to the above rule about 
> +			   optimistic addresses is that we need to always 
> +			   respond to an NS from a unicast address if we are
> +			   optimistic. RFC 4429 Sec 3.3.  If (unicast
> +			   and optimistic) are false then we can just fail
> +			   dad now.
> +			*/
> +			if (ifp->flags & IFA_F_OPTIMISTIC) {
> +				type = ipv6_addr_type(saddr);			
> +				if (!(type & IPV6_ADDR_UNICAST)) {
> +					addrconf_dad_failure(ifp); 
> +					goto out;
> +				}
> +			} else
> +				if (!dad)
> +					goto out;


Second, you fail dad in the OPTIMISTIC case, but not the regular case, which should also fail
if this is a DAD packet.

I think the following is what you want (totally untested):

	if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {

		if (dad) {
			/* We are processing a DAD packet for a tentative address.
			 * Make sure that this was not one of our NSs looped back
			 * to us.
			 */
			if (dev->type== ARPHDR_IEEE802_TR) {
				..... blah ...
			}

			/* Fail DAD since we are colliding with someout out there*/
			addrconf_dad_failure(ifp);
		} else {
			/* This is not a DAD neighbor solicitation.  If we
			 * are OPTIMISTIC, we'll respond with a NA.  Otherwise
			 * we'll ignore the packet.
			 */
			if (!(ifp->flags & IFA_F_OPTIMISTIC))
				goto out
		}
	}
	idef = ifp->idev;

-vlad
