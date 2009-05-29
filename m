From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 09:46:36 -0400
Message-ID: <1243604796.3966.21.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Jarek Poplawski <jarkao2@gmail.com>
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f190.google.com ([209.85.221.190]:44786 "EHLO
	mail-qy0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758231AbZE2Nrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 09:47:33 -0400
Received: by qyk28 with SMTP id 28so6508824qyk.33
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 06:47:34 -0700 (PDT)
In-Reply-To: <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

Sorry - cant help you on earlier question in the thread on
syntax of cls_group config (but we can revisit after resolving
this). You should always copy the maintainer if you want quick
answers (for cls_group case Thomas Graf).

On your patch:
I think you have found a real issue (I have a strong feeling
it has everything to do with your config process)

Comments below:

On Fri, 2009-05-29 at 14:18 +0900, Minoru Usui wrote:
> Hi, 


> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 0759f32..756148b 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -266,11 +266,6 @@ replay:
>  			goto errout;
>  		}
>  
> -		spin_lock_bh(root_lock);
> -		tp->next = *back;
> -		*back = tp;
> -		spin_unlock_bh(root_lock);
> -
>  	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
>  		goto errout;
>  
> @@ -314,8 +309,17 @@ replay:
>  	}
>  
>  	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
> -	if (err == 0)
> -		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
> +	if (err) {
> +		tcf_destroy(tp);
> +		goto errout;
> +	}
> +
> +	spin_lock_bh(root_lock);
> +	tp->next = *back;
> +	*back = tp;
> +	spin_unlock_bh(root_lock);
> +
> +	tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);

This is incorrect. tp may already exist and you dont want to destroy
for failure to change its parameters. You also dont want to reattach
an existing tp because it succeeded in parameter change. 
So the soln is to check if this is a new tp and then do what you did
above...
Did that make sense?

cheers,
jamal

