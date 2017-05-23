From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next] net: sched: cls_api: make reclassify return all
 the way back to the original tp
Date: Tue, 23 May 2017 13:50:39 +0200
Message-ID: <20170523115037.GB25668@vergenet.net>
References: <20170523071159.1951-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37064 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933847AbdEWLuo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 07:50:44 -0400
Received: by mail-wm0-f46.google.com with SMTP id d127so22740154wmf.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 04:50:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170523071159.1951-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 09:11:59AM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> With the introduction of chain goto action, the reclassification would
> cause the re-iteration of the actual chain. It makes more sense to restart
> the whole thing and re-iterate starting from the original tp - start
> of chain 0.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>

> ---
>  net/sched/cls_api.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 01a8b8b..89fbb35 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -300,7 +300,8 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  	__be16 protocol = tc_skb_protocol(skb);
>  #ifdef CONFIG_NET_CLS_ACT
>  	const int max_reclassify_loop = 4;
> -	const struct tcf_proto *old_tp = tp;
> +	const struct tcf_proto *orig_tp = tp;
> +	const struct tcf_proto *first_tp;
>  	int limit = 0;
>  
>  reclassify:
> @@ -315,9 +316,10 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  		err = tp->classify(skb, tp, res);
>  #ifdef CONFIG_NET_CLS_ACT
>  		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode)) {
> +			first_tp = orig_tp;
>  			goto reset;
>  		} else if (unlikely(TC_ACT_EXT_CMP(err, TC_ACT_GOTO_CHAIN))) {
> -			old_tp = res->goto_tp;
> +			first_tp = res->goto_tp;
>  			goto reset;
>  		}
>  #endif
> @@ -335,7 +337,7 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  		return TC_ACT_SHOT;
>  	}
>  
> -	tp = old_tp;
> +	tp = first_tp;
>  	protocol = tc_skb_protocol(skb);
>  	goto reclassify;
>  #endif
> -- 
> 2.9.3
> 
