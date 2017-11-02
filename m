From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 3/3] act_vlan: VLAN action rewrite to use
 RCU lock/unlock and update
Date: Thu, 02 Nov 2017 17:00:05 +0900 (KST)
Message-ID: <20171102.170005.1755683020318904615.davem@davemloft.net>
References: <1509572781-17370-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        aring@mojatatu.com, mrv@mojatatu.com, manish.kurup@verizon.com
To: kurup.manish@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755480AbdKBIAL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:00:11 -0400
In-Reply-To: <1509572781-17370-1-git-send-email-manish.kurup@verizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Kurup <kurup.manish@gmail.com>
Date: Wed,  1 Nov 2017 17:46:21 -0400

> -	v->tcfv_push_proto = push_proto;
> +	ASSERT_RTNL();
> +	p = kzalloc(sizeof(*p), GFP_KERNEL);
> +	if (!p) {
> +		if (ovr)
> +			tcf_idr_release(*a, bind);
> +		return -ENOMEM;
> +	}
>  
>  	v->tcf_action = parm->action;
>  
> -	spin_unlock_bh(&v->tcf_lock);
> +	p_old = rtnl_dereference(v->vlan_p);
> +
> +	p->tcfv_action = action;
> +	p->tcfv_push_vid = push_vid;
> +	p->tcfv_push_prio = push_prio;
> +	p->tcfv_push_proto = push_proto;
> +
> +	rcu_assign_pointer(v->vlan_p, p);
> +
> +	if (p_old)
> +		kfree_rcu(p_old, rcu);

What frees this RCU memory when the VLAN action is destroyed?
