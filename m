From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount
 earlier
Date: Wed, 19 Apr 2017 07:32:38 -0400
Message-ID: <861dba23-1244-ee57-a980-a6dceffa2793@mojatatu.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com>
 <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
 <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com>
 <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
 <462700507.23.1492589388406@webmail.proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35730 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762654AbdDSLck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 07:32:40 -0400
Received: by mail-it0-f66.google.com with SMTP id e132so2039172ite.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 04:32:40 -0700 (PDT)
In-Reply-To: <462700507.23.1492589388406@webmail.proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 04:09 AM, Wolfgang Bumiller wrote:
>

> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 8cc883c063f0..c7e5e437b847 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -555,6 +555,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>  	struct nlattr *tb[TCA_ACT_MAX + 1];
>  	struct nlattr *kind;
>  	int err;
> +	bool created;
>
>  	if (name == NULL) {
>  		err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
> @@ -603,20 +604,19 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>  		err = a_o->init(net, nla, est, &a, ovr, bind);
>  	if (err < 0)
>  		goto err_mod;
> +	created = err == ACT_P_CREATED;
>
>  	if (name == NULL && tb[TCA_ACT_COOKIE]) {
>  		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
>
>  		if (cklen > TC_COOKIE_MAX_SIZE) {
>  			err = -EINVAL;
> -			tcf_hash_release(a, bind);
> -			goto err_mod;
> +			goto err_release;
>  		}
>
>  		if (nla_memdup_cookie(a, tb) < 0) {
>  			err = -ENOMEM;
> -			tcf_hash_release(a, bind);
> -			goto err_mod;
> +			goto err_release;
>  		}
>  	}
>
> @@ -624,11 +624,14 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>  	 * if it exists and is only bound to in a_o->init() then
>  	 * ACT_P_CREATED is not returned (a zero is).
>  	 */
> -	if (err != ACT_P_CREATED)
> +	if (!created)
>  		module_put(a_o->owner);
>
>  	return a;
>
> +err_release:
> +	if (created)
> +		tcf_hash_release(a, bind);
>  err_mod:
>  	module_put(a_o->owner);
>  err_out:
>

This solves one issue, but I am afraid the issue Cong mentioned is a
possibility still.
Lets say user did a replace and tried to also replace the cookie
in that transaction. The init() succeeds but the cookie allocation
fails. To be correct we'll have to undo the replace i.e something
like uninit() which will restore back the old values.
This is very complex and unnecessary.

My suggestion:
If we move the cookie allocation before init we can save it and
only when init succeeds do we attach it to the action, otherwise
we free it on error path.

cheers,
jamal
