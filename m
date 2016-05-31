From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] fib_rules: Added NLM_F_EXCL support to fib_nl_newrule
Date: Mon, 30 May 2016 20:21:29 -0600
Message-ID: <7ef40a87-2b63-dfee-e019-4a2f0aec5507@cumulusnetworks.com>
References: <574C051B.90706@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mateusz Bajorski <mateusz.bajorski@nokia.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37978 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162202AbcEaCVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 22:21:36 -0400
Received: by mail-it0-f42.google.com with SMTP id i127so19134226ita.1
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 19:21:35 -0700 (PDT)
In-Reply-To: <574C051B.90706@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/30/16 3:17 AM, Mateusz Bajorski wrote:
> When adding rule with NLM_F_EXCL flag then check if the same rule exist.
> If yes then exit with -EEXIST.
>
> This is already implemented in iproute2:
> 	if (cmd == RTM_NEWRULE) {
> 		req.n.nlmsg_flags |= NLM_F_CREATE|NLM_F_EXCL;
> 		req.r.rtm_type = RTN_UNICAST;
> 	}
>
> Tested ipv4 and ipv6 with net-next linux on qemu x86
>
> expected behavior after patch:
> localhost ~ # ip rule
> 0:    from all lookup local
> 32766:    from all lookup main
> 32767:    from all lookup default
> localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
> localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
> RTNETLINK answers: File exists
> localhost ~ # ip rule
> 0:    from all lookup local
> 1005:    from 10.46.177.97 lookup 104
> 32766:    from all lookup main
> 32767:    from all lookup default
>
> There was already topic regarding this but I don't see any changes
> merged and problem still occurs.
> https://lkml.kernel.org/r/1135778809.5944.7.camel+%28%29+localhost+%21+localdomain
>
> Signed-off-by: Mateusz Bajorski <mateusz.bajorski@nokia.com>
> ---
> Changes in v2: section moved to new place where new rule is already built
>
>  net/core/fib_rules.c | 34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index 840aceb..5bc1d27 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -371,6 +371,40 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
>  	} else if (rule->action == FR_ACT_GOTO)
>  		goto errout_free;
>
> +	if (nlh->nlmsg_flags & NLM_F_EXCL) {
> +		list_for_each_entry(r, &ops->rules_list, list) {

missing a namespace (fr_net) compare. Everything else is relative to it.

I suggest making the rule compare a helper function.

Also, this is going to be one of those pain points as new rule 
attributes are added - new attributes are not added to the compare. 
Perhaps a note above the fib_rule definition in net/fib_rules.h to add 
new attributes to the fib_rule compare function?


> +			if (r->action != rule->action)
> +				continue;
> +
> +			if (r->table != rule->table)
> +				continue;
> +
> +			if (r->pref != rule->pref)
> +				continue;
> +
> +			if (memcmp(r->iifname, rule->iifname, IFNAMSIZ))
> +				continue;
> +
> +			if (memcmp(r->oifname, rule->oifname, IFNAMSIZ))
> +				continue;
> +
> +			if (r->mark != rule->mark)
> +				continue;
> +
> +			if (r->mark_mask != rule->mark_mask)
> +				continue;
> +
> +			if (r->tun_id != rule->tun_id)
> +				continue;
> +
> +			if (!ops->compare(r, frh, tb))
> +				continue;
> +
> +			err = -EEXIST;
> +			goto errout_free;
> +		}
> +	}
> +
>  	err = ops->configure(rule, skb, frh, tb);
>  	if (err < 0)
>  		goto errout_free;
>
