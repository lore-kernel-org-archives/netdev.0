From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 4/4] net/sched: cls_bpf: Use skip flags to
 reflect HW offload status
Date: Thu, 9 Feb 2017 17:22:23 -0800
Message-ID: <20170209172223.405b9e2f@cakuba.netronome.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
        <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:11865 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751389AbdBJB3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 20:29:25 -0500
In-Reply-To: <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Feb 2017 16:18:08 +0200, Or Gerlitz wrote:
> Currently there is no way of querying whether a filter is
> offloaded to HW or not when using both policy (no flag).
> 
> Reuse the skip flags to show the insertion status by setting
> the skip_hw flag in case the filter wasn't offloaded.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  net/sched/cls_bpf.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
> index d9c9701..91ba90d 100644
> --- a/net/sched/cls_bpf.c
> +++ b/net/sched/cls_bpf.c
> @@ -185,14 +185,23 @@ static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
>  			return -EINVAL;
>  		}
>  	} else {
> -		if (!tc_should_offload(dev, tp, prog->gen_flags))
> -			return skip_sw ? -EINVAL : 0;
> +		if (!tc_should_offload(dev, tp, prog->gen_flags)) {
> +			if (tc_skip_sw(prog->gen_flags))
> +				return -EINVAL;
> +			prog->gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
> +			return 0;
> +		}
>  		cmd = TC_CLSBPF_ADD;
>  	}
>  
>  	ret = cls_bpf_offload_cmd(tp, obj, cmd);
> -	if (ret)
> -		return skip_sw ? ret : 0;
> +
> +	if (ret) {
> +		if (skip_sw)
> +			return ret;
> +		prog->gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
> +		return 0;
> +	}
>  
>  	obj->offloaded = true;

In cls_bpf we do store information about whether program is offloaded or
not already (see the @offloaded member).  Could we simplify the code
thanks to this?

I'm obviously all for reporting whether tc objects are offloaded or not
but let me ask perhaps the silly question of why reuse the SKIP_HW flag?
We don't have to worry about flag bits running out, could it be clearer
to users to report whether object is present in HW using a new flag?  Or
even two flags for present/non-present so user doesn't have to ponder
what no flag means (old kernel or not offloaded?). I don't really mind
either way I'm just wondering what the motivation was and maybe how
others feel.
