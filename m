From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 2/2] net/sched: act_csum: compute crc32c on SCTP
 packets
Date: Fri, 6 Jan 2017 10:23:18 +0100
Message-ID: <b4e2b22a-5a06-3c31-a312-3c6de1ef14e5@6wind.com>
References: <cover.1483630849.git.dcaratti@redhat.com>
 <c9ee721fd7816b9d30939f23783f50f9aeb00d66.1483630849.git.dcaratti@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Davide Caratti <dcaratti@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37627 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162769AbdAFJXW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 04:23:22 -0500
Received: by mail-wm0-f47.google.com with SMTP id t79so20904771wmt.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 01:23:22 -0800 (PST)
In-Reply-To: <c9ee721fd7816b9d30939f23783f50f9aeb00d66.1483630849.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2017 à 17:59, Davide Caratti a écrit :
> modify act_csum to compute crc32c on IPv4/IPv6 packets having SCTP in
> their payload, and extend UAPI definitions accordingly.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> ---
>  include/uapi/linux/tc_act/tc_csum.h |  3 ++-
>  net/sched/act_csum.c                | 32 ++++++++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/tc_act/tc_csum.h b/include/uapi/linux/tc_act/tc_csum.h
> index 8ac8041..58d457f 100644
> --- a/include/uapi/linux/tc_act/tc_csum.h
> +++ b/include/uapi/linux/tc_act/tc_csum.h
> @@ -21,7 +21,8 @@ enum {
>  	TCA_CSUM_UPDATE_FLAG_IGMP    = 4,
>  	TCA_CSUM_UPDATE_FLAG_TCP     = 8,
>  	TCA_CSUM_UPDATE_FLAG_UDP     = 16,
> -	TCA_CSUM_UPDATE_FLAG_UDPLITE = 32
> +	TCA_CSUM_UPDATE_FLAG_UDPLITE = 32,
> +	TCA_CSUM_UPDATE_FLAG_SCTP    = 64
nit: please put a comma after the '64' so that the next person who adds a flag
will not have to touch that line.

>  };
>  
>  struct tc_csum {
> diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
> index a0edd80..620ac9b 100644
> --- a/net/sched/act_csum.c
> +++ b/net/sched/act_csum.c
[snip]
> @@ -365,6 +385,12 @@ static int tcf_csum_ipv4(struct sk_buff *skb, u32 update_flags)
>  					       ntohs(iph->tot_len), 1))
>  				goto fail;
>  		break;
> +	case IPPROTO_SCTP:
> +		if (update_flags & TCA_CSUM_UPDATE_FLAG_SCTP)
> +			if (!tcf_csum_sctp(skb, iph->ihl * 4,
> +					   ntohs(iph->tot_len)))
nit: one 'if' only?
		if (update_flags & TCA_CSUM_UPDATE_FLAG_SCTP &&
		    !tcf_csum_sctp(skb, iph->ihl * 4, ntohs(iph->tot_len))

> +				goto fail;
> +		break;
>  	}
>  
>  	if (update_flags & TCA_CSUM_UPDATE_FLAG_IPV4HDR) {
> @@ -481,6 +507,12 @@ static int tcf_csum_ipv6(struct sk_buff *skb, u32 update_flags)
>  						       pl + sizeof(*ip6h), 1))
>  					goto fail;
>  			goto done;
> +		case IPPROTO_SCTP:
> +			if (update_flags & TCA_CSUM_UPDATE_FLAG_SCTP)
> +				if (!tcf_csum_sctp(skb, hl,
> +						   pl + sizeof(*ip6h)))
Same here.


Regards,
Nicolas
