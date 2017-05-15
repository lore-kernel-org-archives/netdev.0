From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch net-next v2 10/10] net: sched: add termination action
 to allow goto chain
Date: Mon, 15 May 2017 22:02:08 +0200
Message-ID: <591A0940.2070801@iogearbox.net>
References: <20170515083857.3615-1-jiri@resnulli.us> <20170515083857.3615-11-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com,
        alexei.starovoitov@gmail.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48141 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751970AbdEOUC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 16:02:28 -0400
In-Reply-To: <20170515083857.3615-11-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2017 10:38 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Introduce new type of termination action called "goto_chain". This allows
> user to specify a chain to be processed. This action type is
> then processed as a return value in tcf_classify loop in similar
> way as "reclassify" is, only it does not reset to the first filter
> in chain but rather reset to the first filter of the desired chain.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
[...]
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 1112a2b..98cc689 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -304,10 +304,14 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>   			continue;
>
>   		err = tp->classify(skb, tp, res);
> -		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode))
> +		if (err == TC_ACT_RECLASSIFY && !compat_mode) {
>   			goto reset;
> -		if (err >= 0)
> +		} else if (TC_ACT_EXT_CMP(err, TC_ACT_GOTO_CHAIN)) {
> +			old_tp = res->goto_tp;
> +			goto reset;
> +		} else if (err >= 0) {
>   			return err;
> +		}

Given this goto chain feature is pretty much only interesting for hw
offloads, can we move this further away from the sw fast path to not
add up to the cost per packet? (I doubt anyone is using TC_ACT_RECLASSIFY
in sw as well ...)

>   	}
>
>   	return TC_ACT_UNSPEC; /* signal: continue lookup */
>
