From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 4 of 5] IPv6: fix lifetime calculation on temporary
 address creation
Date: Fri, 28 Mar 2008 12:04:01 +0900 (JST)
Message-ID: <20080328.120401.89511262.yoshfuji@linux-ipv6.org>
References: <patchbomb.1206305168@pirzuine>
	<ec551b4a5bb25cda00ff.1206305172@pirzuine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55380 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755276AbYC1DCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 23:02:32 -0400
In-Reply-To: <ec551b4a5bb25cda00ff.1206305172@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <ec551b4a5bb25cda00ff.1206305172@pirzuine> (at Sun, 23 Mar 2008 21:46:12 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> IPv6: fix lifetime calculation on temporary address creation
> 
> The lifetime calculation was buggy since it copied the tstamp
> from the associated public address.
> If (now - ifp->prefered_lft)/HZ (ie the elapsed time since the
> timestamp was set in the public address) was greater than
> temp_prefered_lft, you would always get deprecated addresses.
> 
> This patch corrects the lifetime calculation by setting the tstamp
> to "now" and calculating the remaining time from the public address.
> 
> Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
:
>  	memcpy(&addr.s6_addr[8], idev->rndid, 8);
> -	tmp_valid_lft = min_t(__u32,
> -			      ifp->valid_lft,
> -			      idev->cnf.temp_valid_lft);
> -	tmp_prefered_lft = min_t(__u32,
> -				 ifp->prefered_lft,
> -				 idev->cnf.temp_prefered_lft - desync_factor / HZ);
> +	now = jiffies;
> +	elapsed = (now - ifp->tstamp) / HZ;
> +	if (elapsed >= ifp->valid_lft)
> +		tmp_valid_lft = 0;
> +	else
> +		tmp_valid_lft = min_t(__u32,
> +				      ifp->valid_lft - elapsed,
> +				      idev->cnf.temp_valid_lft);
> +	if (elapsed >= ifp->prefered_lft)
> +		tmp_prefered_lft = 0;
> +	else
> +		tmp_prefered_lft = min_t(__u32,
> +					 ifp->prefered_lft - elapsed,
> +					 idev->cnf.temp_prefered_lft - desync_factor / HZ);

Basically I agree, but it is possible to expire the temporary
address AFTER public address, which is not good.  Please fix this.

--yoshfuji
