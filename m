From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [patch net-next RFC 1/9] net_sch: red: Add offload ability to RED qdisc
Date: Mon, 30 Oct 2017 08:47:04 -0400
Message-ID: <85wp3col9z.fsf@mojatatu.com>
References: <20171030085613.8697-1-jiri@resnulli.us>
        <20171030085613.8697-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, mlxsw@mellanox.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, michael.chan@broadcom.com,
        ganeshgr@chelsio.com, saeedm@mellanox.com, matanb@mellanox.com,
        leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, ogerlitz@mellanox.com,
        john.fastabend@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:55952 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752503AbdJ3MrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 08:47:07 -0400
Received: by mail-io0-f171.google.com with SMTP id p186so26793324ioe.12
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 05:47:07 -0700 (PDT)
In-Reply-To: <20171030085613.8697-2-jiri@resnulli.us> (Jiri Pirko's message of
        "Mon, 30 Oct 2017 09:56:05 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:


[...]

> +static void red_unoffload(struct Qdisc *sch)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct tc_red_qopt_offload opt = {
> +		.handle = sch->handle,
> +		.command = TC_RED_DESTROY,
> +		.parent = sch->parent,
> +	};
> +
> +	if (!tc_can_offload(dev) || !dev->netdev_ops->ndo_setup_tc)
> +		return;
> +
> +	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_QDISC_RED,  &opt);
> +}
> +

> @@ -162,6 +179,28 @@ static const struct nla_policy red_policy[TCA_RED_MAX + 1] = {
>  	[TCA_RED_MAX_P] = { .type = NLA_U32 },
>  };
>  
> +static int red_offload(struct Qdisc *sch)
> +{
> +	struct red_sched_data *q = qdisc_priv(sch);
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct tc_red_qopt_offload opt = {
> +		.handle = sch->handle,
> +		.command = TC_RED_REPLACE,
> +		.parent = sch->parent,
> +		.set = {
> +			.min = q->parms.qth_min >> q->parms.Wlog,
> +			.max = q->parms.qth_max >> q->parms.Wlog,
> +			.probability = q->parms.max_P,
> +			.is_ecn = red_use_ecn(q),
> +		},
> +	};
> +
> +	if (!tc_can_offload(dev) || !dev->netdev_ops->ndo_setup_tc)
> +		return -EOPNOTSUPP;
> +
> +	return dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_QDISC_RED, &opt);
> +}
> +

[...]

Can't red_unoffload() and red_offload() be unified in a single API? For
example, red_offload(struct Qdisc *sch, bool enable) ?
