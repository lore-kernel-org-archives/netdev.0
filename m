From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] decnet: remove macro-local declarations
Date: Fri, 06 Nov 2015 12:44:32 +0100
Message-ID: <563C92A0.3050309@bfs.de>
References: <1446718696-32505-1-git-send-email-Julia.Lawall@lip6.fr> <20151105.142619.983467860147585345.davem@davemloft.net> <alpine.DEB.2.02.1511052107501.2065@localhost6.localdomain6> <20151105.151320.1646543343654766675.davem@davemloft.net> <alpine.DEB.2.10.1511061142440.2378@hadrien>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lkp@intel.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1511061142440.2378@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+1

I like this more since it is much more obvious what is done.

more over we can remove a macro with only 2 users.

re,
 wh


Am 06.11.2015 11:57, schrieb Julia Lawall:
>>> Would it be preferable to remove the macro entirely and inline the for
>>> loop header?
>>
>> Could you show me an example of how this would look exactly?
> 
> One possible solution is below.  I moved the initialization of the nh
> pointer inside the loop to reduce the size of the loop header.  One could
> also inline fi->fib_nh[nhsel] where it occurs, but it seemed that that
> would make quite long expressions.
> 
> julia
> 
> diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
> index 1540b50..509ae82 100644
> --- a/net/decnet/dn_table.c
> +++ b/net/decnet/dn_table.c
> @@ -60,11 +60,6 @@ struct dn_hash
> 
>  #define dz_key_0(key)		((key).datum = 0)
> 
> -#define for_nexthops(fi) { int nhsel; const struct dn_fib_nh *nh;\
> -	for(nhsel = 0, nh = (fi)->fib_nh; nhsel < (fi)->fib_nhs; nh++, nhsel++)
> -
> -#define endfor_nexthops(fi) }
> -
>  #define DN_MAX_DIVISOR 1024
>  #define DN_S_ZOMBIE 1
>  #define DN_S_ACCESSED 2
> @@ -227,7 +222,7 @@ static struct dn_zone *dn_new_zone(struct dn_hash *table, int z)
>  static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct nlattr *attrs[], struct dn_fib_info *fi)
>  {
>  	struct rtnexthop *nhp;
> -	int nhlen;
> +	int nhlen, nhsel;
> 
>  	if (attrs[RTA_PRIORITY] &&
>  	    nla_get_u32(attrs[RTA_PRIORITY]) != fi->fib_priority)
> @@ -246,8 +241,9 @@ static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct nlattr
>  	nhp = nla_data(attrs[RTA_MULTIPATH]);
>  	nhlen = nla_len(attrs[RTA_MULTIPATH]);
> 
> -	for_nexthops(fi) {
> +	for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
>  		int attrlen = nhlen - sizeof(struct rtnexthop);
> +		const struct dn_fib_nh *nh = &fi->fib_nh[nhsel];
>  		__le16 gw;
> 
>  		if (attrlen < 0 || (nhlen -= nhp->rtnh_len) < 0)
> @@ -264,7 +260,7 @@ static int dn_fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct nlattr
>  				return 1;
>  		}
>  		nhp = RTNH_NEXT(nhp);
> -	} endfor_nexthops(fi);
> +	}
> 
>  	return 0;
>  }
> @@ -345,11 +341,13 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>  	if (fi->fib_nhs > 1) {
>  		struct rtnexthop *nhp;
>  		struct nlattr *mp_head;
> +		int nhsel;
> 
>  		if (!(mp_head = nla_nest_start(skb, RTA_MULTIPATH)))
>  			goto errout;
> 
> -		for_nexthops(fi) {
> +		for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
> +			const struct dn_fib_nh *nh = &fi->fib_nh[nhsel];
>  			if (!(nhp = nla_reserve_nohdr(skb, sizeof(*nhp))))
>  				goto errout;
> 
> @@ -362,7 +360,7 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>  				goto errout;
> 
>  			nhp->rtnh_len = skb_tail_pointer(skb) - (unsigned char *)nhp;
> -		} endfor_nexthops(fi);
> +		}
> 
>  		nla_nest_end(skb, mp_head);
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
