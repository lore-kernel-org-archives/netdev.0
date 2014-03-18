From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH VXLAN] fix nonfunctional neigh_reduce
Date: Mon, 17 Mar 2014 22:16:55 -0400 (EDT)
Message-ID: <20140317.221655.411577389962355189.davem@davemloft.net>
References: <201403141749.s2EHnvgc030976@lab1.dls>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbaCRCQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 22:16:57 -0400
In-Reply-To: <201403141749.s2EHnvgc030976@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Fri, 14 Mar 2014 13:49:57 -0400

> @@ -1366,33 +1460,35 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
>  	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
>  		goto out;
>  
> -	n = neigh_lookup(ipv6_stub->nd_tbl, daddr, dev);
> +	n = neigh_lookup(ipv6_stub->nd_tbl, &msg->target, dev);
>  
> -	if (n) {
 ...
> +	if (!n) {
 ...
> +		if (vxlan->flags & VXLAN_F_L3MISS) {

Please don't change the top-level conditional logic, this creates
two problems:

1) It makes the patch harder to review and audit, you're really not
   changing as much in these code blocks as the patch makes it look.

2) It makes it harder to compare with arp_reduce().

Do we have an equivalent in ipv6 of arp_create()?  If so we should
try to use it instead of having yet another copy of code putting
together ndisc messages and sending them.

Thanks.
