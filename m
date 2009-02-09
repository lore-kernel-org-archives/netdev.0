From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 3/3] iptables: lock free counters
Date: Mon, 09 Feb 2009 16:58:16 +0100
Message-ID: <49905298.80601@trash.net>
References: <20090204001202.724266235@vyatta.com> <20090204001755.808036408@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58070 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbZBIP6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 10:58:19 -0500
In-Reply-To: <20090204001755.808036408@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> --- a/net/ipv4/netfilter/ip_tables.c	2009-01-29 11:09:20.720069979 -0800
> +++ b/net/ipv4/netfilter/ip_tables.c	2009-01-29 11:10:49.827070289 -0800
> @@ -347,9 +347,9 @@ ipt_do_table(struct sk_buff *skb,
>  	mtpar.family  = tgpar.family = NFPROTO_IPV4;
>  	tgpar.hooknum = hook;
>  
> -	read_lock_bh(&table->lock);
> +	rcu_read_lock_bh();
>  	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
> -	private = table->private;
> +	private = rcu_dereference(table->private);
>  	table_base = (void *)private->entries[smp_processor_id()];
>  	e = get_entry(table_base, private->hook_entry[hook]);

I think this doesn't actually need the _bh rcu_read_lock() variant
since updates are never done in softirq context.

