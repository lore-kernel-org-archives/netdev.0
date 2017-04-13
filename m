From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH linux 2/2] net sched actions: fix refcount decrement on error
Date: Thu, 13 Apr 2017 09:39:43 -0400
Message-ID: <85inm8pgtc.fsf@mojatatu.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
        <20170412142140.26649-3-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32834 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753420AbdDMNjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 09:39:51 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so13012705ioi.0
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 06:39:50 -0700 (PDT)
In-Reply-To: <20170412142140.26649-3-w.bumiller@proxmox.com> (Wolfgang
        Bumiller's message of "Wed, 12 Apr 2017 16:21:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Bumiller <w.bumiller@proxmox.com> writes:

> If memory allocation for nla_memdup_cookie() fails
> module_put has to be guarded by the same condition as it was
> before the TCA_ACT_COOKIE has been added as stated in the
> comment afterwards:
>

What if a new entry has been created, and a_o->init returns
ACT_P_CREATED, but cookie allocation fails, do we not remove module
reference count?

[...]

>  		if (cklen > TC_COOKIE_MAX_SIZE) {
> -			err = -EINVAL;
>  			tcf_hash_release(a, bind);
> -			goto err_mod;
> +			if (err != ACT_P_CREATED)
> +				module_put(a_o->owner);
> +			err = -EINVAL;
> +			goto err_out;
>  		}
>  
>  		if (nla_memdup_cookie(a, tb) < 0) {
> -			err = -ENOMEM;
>  			tcf_hash_release(a, bind);
> -			goto err_mod;
> +			if (err != ACT_P_CREATED)
> +				module_put(a_o->owner);
> +			err = -ENOMEM;
> +			goto err_out;
>  		}
>  	}
