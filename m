From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2 of 2] IPv6: do not create temporary adresses with too
 short preferred lifetime
Date: Wed, 02 Apr 2008 08:50:11 +0900 (JST)
Message-ID: <20080402.085011.124380410.yoshfuji@linux-ipv6.org>
References: <patchbomb.1207091339@pirzuine>
	<00affc24c178e6da3a3b.1207091341@pirzuine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: benoit.boissinot@ens-lyon.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59681 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756180AbYDAXsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 19:48:35 -0400
In-Reply-To: <00affc24c178e6da3a3b.1207091341@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <00affc24c178e6da3a3b.1207091341@pirzuine> (at Wed, 02 Apr 2008 01:09:01 +0200), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> IPv6: do not create temporary adresses with too short preferred lifetime
> 
> >From RFC341:
> A temporary address is created only if this calculated Preferred
> Lifetime is greater than REGEN_ADVANCE time units.  In particular,
> an implementation must not create a temporary address with a zero
> Preferred Lifetime.
> 
> Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

> 
> diff -r 0c33481968e0 -r 00affc24c178 net/ipv6/addrconf.c
> --- a/net/ipv6/addrconf.c	Sat Mar 22 00:41:39 2008 +0100
> +++ b/net/ipv6/addrconf.c	Sat Mar 22 00:39:16 2008 +0100
> @@ -776,6 +776,7 @@
>  	struct inet6_dev *idev = ifp->idev;
>  	struct in6_addr addr, *tmpaddr;
>  	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
> +	unsigned long regen_advance;
>  	int tmp_plen;
>  	int ret = 0;
>  	int max_addresses;
> @@ -836,7 +837,22 @@
>  	tmp_tstamp = ifp->tstamp;
>  	spin_unlock_bh(&ifp->lock);
>  
> +	regen_advance = idev->cnf.regen_max_retry *
> +	                idev->cnf.dad_transmits *
> +	                idev->nd_parms->retrans_time / HZ;
>  	write_unlock(&idev->lock);
> +
> +	/* A temporary address is created only if this calculated Preferred
> +	 * Lifetime is greater than REGEN_ADVANCE time units.  In particular,
> +	 * an implementation must not create a temporary address with a zero
> +	 * Preferred Lifetime.
> +	 */
> +	if (tmp_prefered_lft <= regen_advance) {
> +		in6_ifa_put(ifp);
> +		in6_dev_put(idev);
> +		ret = -1;
> +		goto out;
> +	}
>  
>  	addr_flags = IFA_F_TEMPORARY;
>  	/* set in addrconf_prefix_rcv() */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
