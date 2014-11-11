From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Tue, 11 Nov 2014 14:33:21 -0800
Message-ID: <CAHA+R7O=_h4HEF01wFacteawVX-2uvMiPjUAExKV6GphSJySzg@mail.gmail.com>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
	<1415700789-9171-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:51104 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbaKKWdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:33:22 -0500
Received: by mail-qg0-f50.google.com with SMTP id a108so7916887qge.37
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 14:33:21 -0800 (PST)
In-Reply-To: <1415700789-9171-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 2:13 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> +static int tcf_vlan_init(struct net *net, struct nlattr *nla,
> +                        struct nlattr *est, struct tc_action *a,
> +                        int ovr, int bind)
> +{
> +       struct nlattr *tb[TCA_VLAN_MAX + 1];
> +       struct tc_vlan *parm;
> +       struct tcf_vlan *v;
> +       int action;
> +       __be16 push_vid = 0;
> +       __be16 push_proto = 0;
> +       int ret = 0;
> +       int err;
> +
> +       if (!nla)
> +               return -EINVAL;
> +
> +       err = nla_parse_nested(tb, TCA_VLAN_MAX, nla, vlan_policy);
> +       if (err < 0)
> +               return err;
> +
> +       if (!tb[TCA_VLAN_PARMS])
> +               return -EINVAL;
> +       parm = nla_data(tb[TCA_VLAN_PARMS]);
> +       switch (parm->v_action) {
> +       case TCA_VLAN_ACT_POP:
> +               break;
> +       case TCA_VLAN_ACT_PUSH:
> +               if (!tb[TCA_VLAN_PUSH_VLAN_ID])
> +                       return -EINVAL;
> +               push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);

nla_get_be16() ?


> +               if (push_vid >= VLAN_VID_MASK)
> +                       return -ERANGE;
> +

htons() ?

[...]

> +static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
> +                        int bind, int ref)
> +{
> +       unsigned char *b = skb_tail_pointer(skb);
> +       struct tcf_vlan *v = a->priv;
> +       struct tc_vlan opt = {
> +               .index    = v->tcf_index,
> +               .refcnt   = v->tcf_refcnt - ref,
> +               .bindcnt  = v->tcf_bindcnt - bind,
> +               .action   = v->tcf_action,
> +               .v_action = v->tcfv_action,
> +       };
> +       struct tcf_t t;
> +
> +       if (nla_put(skb, TCA_VLAN_PARMS, sizeof(opt), &opt))
> +               goto nla_put_failure;
> +
> +       if (v->tcfv_action == TCA_VLAN_ACT_PUSH &&
> +           nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, v->tcfv_push_vid) &&
> +           nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL, v->tcfv_push_proto))
> +               goto nla_put_failure;

nla_put_be16() ?
