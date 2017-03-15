From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 1/9] net: fib_rules: Check if selector matches
 all packets
Date: Wed, 15 Mar 2017 09:15:43 -0600
Message-ID: <27c557ac-5905-5004-8264-1ceba0ad76c6@cumulusnetworks.com>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
 <1489575912-6469-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33615 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751848AbdCOPPq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:15:46 -0400
Received: by mail-pg0-f49.google.com with SMTP id n190so10563872pga.0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 08:15:46 -0700 (PDT)
In-Reply-To: <1489575912-6469-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/17 5:05 AM, Jiri Pirko wrote:
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index b6791d9..4ed475d 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -23,6 +23,20 @@ static const struct fib_kuid_range fib_kuid_range_unset = {
>  	KUIDT_INIT(~0),
>  };
>  
> +bool fib_rule_matchall(const struct fib_rule *rule)
> +{
> +	if (rule->iifindex || rule->oifindex || rule->mark || rule->l3mdev ||

l3mdev should not be in that list. Setting l3mdev is functionally
equivalent to setting rule->table. The difference is that l3mdev means
go get the table from the device. It has no bearing on a 'matchall' intent.


> +	    rule->tun_id || rule->flags)
> +		return false;
> +	if (rule->suppress_ifgroup != -1 || rule->suppress_prefixlen != -1)
> +		return false;
> +	if (!uid_eq(rule->uid_range.start, fib_kuid_range_unset.start) ||
> +	    !uid_eq(rule->uid_range.end, fib_kuid_range_unset.end))
> +		return false;
> +	return true;
> +}
> +EXPORT_SYMBOL_GPL(fib_rule_matchall);
> +
>  int fib_default_rule_add(struct fib_rules_ops *ops,
>  			 u32 pref, u32 table, u32 flags)
>  {
> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> index 2892109..7a941a5 100644
> --- a/net/ipv4/fib_rules.c
> +++ b/net/ipv4/fib_rules.c
> @@ -47,6 +47,16 @@ struct fib4_rule {
>  #endif
>  };
>  
> +bool fib4_rule_matchall(const struct fib_rule *rule)
> +{
> +	struct fib4_rule *r = (struct fib4_rule *) rule;

Use container_of instead of typecast.
