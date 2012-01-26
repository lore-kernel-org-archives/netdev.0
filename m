From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH rhel6] Allow ipv6 proxies and arp proxies be shown with
 iproute2
Date: Thu, 26 Jan 2012 14:16:55 -0500
Message-ID: <20120126191655.GA8376@canuck.infradead.org>
References: <1327589392-10852-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul@parallels.com, devel@openvz.org, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: Tony Zelenoff <antonz@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:54252 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab2AZTRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 14:17:03 -0500
Content-Disposition: inline
In-Reply-To: <1327589392-10852-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2012 at 06:49:52PM +0400, Tony Zelenoff wrote:
> +	/* check for full ndmsg structure presence, family member is
> +	 * the same for both structures */
> +	if (nlmsg_len(cb->nlh) == sizeof(struct ndmsg) &&
> +	    ((struct ndmsg *) nlmsg_data(cb->nlh))->ndm_flags == NTF_PROXY)
> +		proxy = 1;
> +

Please change this check to nlmsg_len(cb->nlh) >= sizeof(struct ndmsg) so
we have the possibility to extend the request message in the future
without breaking backwards compatibility.

>  	s_t = cb->args[0];
>  
> -	for (tbl = neigh_tables, t = 0; tbl; tbl = tbl->next, t++) {
> +	for (tbl = neigh_tables, t = 0; tbl && (err >= 0);
> +	     tbl = tbl->next, t++) {
>  		if (t < s_t || (family && tbl->family != family))
>  			continue;
>  		if (t > s_t)
>  			memset(&cb->args[1], 0, sizeof(cb->args) -
>  						sizeof(cb->args[0]));
> -		if (neigh_dump_table(tbl, skb, cb) < 0)
> -			break;
> +		if (proxy) {
> +			err = pneigh_dump_table(tbl, skb, cb);
> +			continue;
> +		}
> +		err = neigh_dump_table(tbl, skb, cb);

Personally I would call neigh_dump_table() in the else branch and avoid
the continue statement.
