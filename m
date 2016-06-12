From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] fib_rules: don't break ECN with TOS rules
Date: Sun, 12 Jun 2016 03:09:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1606120230560.2087@ja.home.ssi.bg>
References: <1465679423-27414-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56426 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751553AbcFLAJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jun 2016 20:09:55 -0400
In-Reply-To: <1465679423-27414-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 11 Jun 2016, Hannes Frederic Sowa wrote:

> Users of ToS rules could accidentally break ECN, this patch tries to
> fix this in a way so we don't break shell scripts depending on the old
> behavior while still being transparent to ECN. This quietly fixes ECN
> behavior for old setups.
> 
> For IPv6 we have no check if we check for ECN bits, in IPv4 we only
> check for the last bit, which is specified to be '0' from pre-DSCP times
> (because of implementation confusion).
> 
> This patch changes fib rules in a way that matches only for ecn bits
> will never match from now on (I consider them illegal), as we simply
> ignore those rules (it was easier to explain in a pr_warn). Opinions?

	Well, may be the confusion comes from commit 89aef8921bfb
("ipv4: Delete routing cache.") where the 'tos &= IPTOS_RT_MASK;'
line is lost from ip_route_input_common. I think, we should
add it back, so that we can properly match input routes with rules
that specify tos value. Old kernels didn't stored ECN bits in
flowi4_tos in the input path, so we should do the same.

> Cc: Florian Westphal <fw@strlen.de>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/inet_ecn.h | 5 +++++
>  net/ipv4/fib_rules.c   | 6 +++++-
>  net/ipv6/fib6_rules.c  | 7 ++++++-
>  3 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
> index 0dc0a51da38faa..be65d94c05ee01 100644
> --- a/include/net/inet_ecn.h
> +++ b/include/net/inet_ecn.h
> @@ -17,6 +17,11 @@ enum {
>  
>  extern int sysctl_tunnel_ecn_log;
>  
> +static inline __u8 INET_ECN_ignore(__u8 dsfield)
> +{
> +	return dsfield & ~INET_ECN_MASK;
> +}
> +
>  static inline int INET_ECN_is_ce(__u8 dsfield)
>  {
>  	return (dsfield & INET_ECN_MASK) == INET_ECN_CE;
> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> index 6e9ea69e5f751b..87efbc38589c76 100644
> --- a/net/ipv4/fib_rules.c
> +++ b/net/ipv4/fib_rules.c
> @@ -145,7 +145,8 @@ static int fib4_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
>  	    ((daddr ^ r->dst) & r->dstmask))
>  		return 0;
>  
> -	if (r->tos && (r->tos != fl4->flowi4_tos))
> +	if (!INET_ECN_ignore(r->tos) ||

	Above check will succeed for any rule that does not use
tos (r->tos = 0). So, rules without tos will return 0 (no match).

> +	    INET_ECN_ignore(r->tos) != INET_ECN_ignore(fl4->flowi4_tos))
>  		return 0;

	fib4_rule_configure already rejects ECN bits in r->tos,
so no need to filter them again in fast path.

>  	return 1;
> @@ -215,6 +216,9 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
>  	rule4->dst_len = frh->dst_len;
>  	rule4->dstmask = inet_make_mask(rule4->dst_len);
>  	rule4->tos = frh->tos;
> +	if (!INET_ECN_ignore(rule4->tos))
> +		pr_warn("ipv4: never matching ipv4 rule with match for %x added\n",
> +			rule4->tos);

	You should see this warning for non-tos rules...

Regards
