From: David Miller <davem@davemloft.net>
Subject: Re: netfilter spurious ELOOP
Date: Tue, 24 Mar 2009 16:28:08 -0700 (PDT)
Message-ID: <20090324.162808.114465835.davem@davemloft.net>
References: <200903242302.n2ON25u4024288@givry.fdupont.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	Francis_Dupont@isc.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Francis.Dupont@fdupont.fr
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200903242302.n2ON25u4024288@givry.fdupont.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francis Dupont <Francis.Dupont@fdupont.fr>
Date: Wed, 25 Mar 2009 00:02:05 +0100

Adding correct CC:'s

> summary: iptables command gets spurious ELOOP errors
> 
> report: when a rule with a target like MARK --set-mark 0x80000001
> then adding new other rules can failed with "Too many levels of symbolic
> links" (aka ELOOP) error.
> The problem is in kernel net/ipv4/netfilter/ip_tables.c in the 
> mark_source_chains() routine which checks the verdict field of
> targets even for not standard targets.
> 
> keywords: netfilter target eloop
> 
> environment: recent gentoo and fedora. Problem not fixed in
> linux-2.6.29 (last stable version taken from kernel.org some minutes ago).
> 
> proposed fix (checked):
> diff --unified=10 net/ipv4/netfilter/ip_tables.c*
> at the end of the message.
> 
> request: can you send to me at both my personal and professional addresses
> a bug/ticket number as soon as possible?
> 
> Request
> 
> Francis.Dupont@fdupont.fr
> 
> PS: the patch:
> 
> --- net/ipv4/netfilter/ip_tables.c	2009-03-23 16:12:14.000000000 -0700
> +++ net/ipv4/netfilter/ip_tables.c+fix	2009-03-24 15:55:45.000000000 -0700
> @@ -489,21 +489,23 @@
>  			e->comefrom |= ((1 << hook) | (1 << NF_INET_NUMHOOKS));
>  
>  			/* Unconditional return/END. */
>  			if ((e->target_offset == sizeof(struct ipt_entry)
>  			    && (strcmp(t->target.u.user.name,
>  				       IPT_STANDARD_TARGET) == 0)
>  			    && t->verdict < 0
>  			    && unconditional(&e->ip)) || visited) {
>  				unsigned int oldpos, size;
>  
> -				if (t->verdict < -NF_MAX_VERDICT - 1) {
> +				if ((t->verdict < -NF_MAX_VERDICT - 1) &&
> +				    (strcmp(t->target.u.user.name,
> +					    IPT_STANDARD_TARGET) == 0)) {
>  					duprintf("mark_source_chains: bad "
>  						"negative verdict (%i)\n",
>  								t->verdict);
>  					return 0;
>  				}
>  
>  				/* Return: backtrack through the last
>  				   big jump. */
>  				do {
>  					e->comefrom ^= (1<<NF_INET_NUMHOOKS);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
