From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] net: fix /proc/net/ip_mr_cache display
Date: Mon, 01 Dec 2008 17:49:56 +0100
Message-ID: <493415B4.7020600@bull.net>
References: <20081201160214.965805516@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev hem <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:35981 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbYLAQuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 11:50:01 -0500
In-Reply-To: <20081201160214.965805516@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Argh, my patch breaks iproute2 command: ip mroute show

iproute2 uses sscanf() to read /proc/net/ip_mr_cache and expects 6
fields to be read. For the unresolved entries my patch only displays
the first three fields. As a consequence, 'ip mroute show' skips the
unresolved entries. :(

So we can
- either forget this patch and keep displaying garbage information
   in /proc/net/ip[6]_mr_cache for the unresolved entries. (No one
   complained before)
- or may be we can just print '-' or 0 for the fields that have no
   data associated in the unresolved case.

Tell me what you prefer.

Benjamin

Benjamin Thery wrote:
> /proc/net/ip6_mr_cache seems to display garbage when showing  unresolved
> mfc6_cache entries.
> 
> $ cat /proc/net/ip6_mr_cache
> Group        Origin    Iif    Pkts  Bytes     Wrong  Oifs
> ff05::1     2003::1      1        4   4132        2  2:1    3:1  
> ff05::3     2003::1  65535      514      2 -559067475
> (addresses modified to increase  readability)
> 
> The first line is correct. It is a resolved cache entry, 4 packets used it, etc
> The second line represents an unresolved entry, and the columns Pkts(4th),
> Bytes(5th) and Wrong(6th) just show garbage.
> 
> In struct mfc6_cache, there's an union to store data for resolved and
> unresolved cases. And what ipmr_mfc_seq_show() is printing in these 
> columns for the unresolved entries is some bytes from mfc6_cache.mfc_un.res.
> Bad.
> (eg. In our case -559067475 is in fact 0xdead4ead which is the spinlock
> magic from mfc6_cache.mfc_un.unres.unresolved.lock.magic).
> 
> This patch only prints pkt, bytes and wrong_if when its relevant, ie. 
> when showing a resolved cache entry.
> 
> Also, mfc->mfc_un.res.pkt, mfc->mfc_un.res.bytes, mfc->mfc_un.res.wrong_if
> are unsigned.
> 
> The patch also modifies IPv4 ipmr.c that contains similar code.
> 
> This patch applies on top of net-next-2.6.
> 
> The patch for net-2.6 is slightly different because of the NIP6_FMT to
> %pI6 conversion that was made in the seq_printf.
> 
> Regards,
> Benjamin
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> ---
>  net/ipv4/ipmr.c  |   11 ++++++-----
>  net/ipv6/ip6mr.c |   11 ++++++-----
>  2 files changed, 12 insertions(+), 10 deletions(-)
> 
> Index: net-next-2.6/net/ipv4/ipmr.c
> ===================================================================
> --- net-next-2.6.orig/net/ipv4/ipmr.c
> +++ net-next-2.6/net/ipv4/ipmr.c
> @@ -1879,15 +1879,16 @@ static int ipmr_mfc_seq_show(struct seq_
>  		const struct mfc_cache *mfc = v;
>  		const struct ipmr_mfc_iter *it = seq->private;
>  
> -		seq_printf(seq, "%08lX %08lX %-3d %8ld %8ld %8ld",
> +		seq_printf(seq, "%08lX %08lX %-3d",
>  			   (unsigned long) mfc->mfc_mcastgrp,
>  			   (unsigned long) mfc->mfc_origin,
> -			   mfc->mfc_parent,
> -			   mfc->mfc_un.res.pkt,
> -			   mfc->mfc_un.res.bytes,
> -			   mfc->mfc_un.res.wrong_if);
> +			   mfc->mfc_parent);
>  
>  		if (it->cache != &mfc_unres_queue) {
> +			seq_printf(seq, " %8lu %8lu %8lu",
> +				   mfc->mfc_un.res.pkt,
> +				   mfc->mfc_un.res.bytes,
> +				   mfc->mfc_un.res.wrong_if);
>  			for (n = mfc->mfc_un.res.minvif;
>  			     n < mfc->mfc_un.res.maxvif; n++ ) {
>  				if (VIF_EXISTS(n)
> Index: net-next-2.6/net/ipv6/ip6mr.c
> ===================================================================
> --- net-next-2.6.orig/net/ipv6/ip6mr.c
> +++ net-next-2.6/net/ipv6/ip6mr.c
> @@ -297,14 +297,15 @@ static int ipmr_mfc_seq_show(struct seq_
>  		const struct mfc6_cache *mfc = v;
>  		const struct ipmr_mfc_iter *it = seq->private;
>  
> -		seq_printf(seq, "%pI6 %pI6 %-3d %8ld %8ld %8ld",
> +		seq_printf(seq, "%pI6 %pI6 %-3d",
>  			   &mfc->mf6c_mcastgrp, &mfc->mf6c_origin,
> -			   mfc->mf6c_parent,
> -			   mfc->mfc_un.res.pkt,
> -			   mfc->mfc_un.res.bytes,
> -			   mfc->mfc_un.res.wrong_if);
> +			   mfc->mf6c_parent);
>  
>  		if (it->cache != &mfc_unres_queue) {
> +			seq_printf(seq, " %8lu %8lu %8lu",
> +				   mfc->mfc_un.res.pkt,
> +				   mfc->mfc_un.res.bytes,
> +				   mfc->mfc_un.res.wrong_if);
>  			for (n = mfc->mfc_un.res.minvif;
>  			     n < mfc->mfc_un.res.maxvif; n++) {
>  				if (MIF_EXISTS(n) &&
> 
> 
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
