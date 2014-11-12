From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Wed, 12 Nov 2014 13:34:45 +0100
Message-ID: <20141112123445.GE1882@nanopsycho.orion>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us>
 <1415700789-9171-2-git-send-email-jiri@resnulli.us>
 <CAHA+R7O=_h4HEF01wFacteawVX-2uvMiPjUAExKV6GphSJySzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:53146 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbaKLMer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 07:34:47 -0500
Received: by mail-wi0-f181.google.com with SMTP id n3so4701132wiv.8
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 04:34:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHA+R7O=_h4HEF01wFacteawVX-2uvMiPjUAExKV6GphSJySzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 11, 2014 at 11:33:21PM CET, cwang@twopensource.com wrote:
>On Tue, Nov 11, 2014 at 2:13 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> +static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>> +                        struct nlattr *est, struct tc_action *a,
>> +                        int ovr, int bind)
>> +{
>> +       struct nlattr *tb[TCA_VLAN_MAX + 1];
>> +       struct tc_vlan *parm;
>> +       struct tcf_vlan *v;
>> +       int action;
>> +       __be16 push_vid = 0;
>> +       __be16 push_proto = 0;
>> +       int ret = 0;
>> +       int err;
>> +
>> +       if (!nla)
>> +               return -EINVAL;
>> +
>> +       err = nla_parse_nested(tb, TCA_VLAN_MAX, nla, vlan_policy);
>> +       if (err < 0)
>> +               return err;
>> +
>> +       if (!tb[TCA_VLAN_PARMS])
>> +               return -EINVAL;
>> +       parm = nla_data(tb[TCA_VLAN_PARMS]);
>> +       switch (parm->v_action) {
>> +       case TCA_VLAN_ACT_POP:
>> +               break;
>> +       case TCA_VLAN_ACT_PUSH:
>> +               if (!tb[TCA_VLAN_PUSH_VLAN_ID])
>> +                       return -EINVAL;
>> +               push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
>
>nla_get_be16() ?

No. I made this the same as it is done in net/8021q/vlan_netlink.c

>
>
>> +               if (push_vid >= VLAN_VID_MASK)
>> +                       return -ERANGE;
>> +
>
>htons() ?
>
>[...]
>
>> +static int tcf_vlan_dump(struct sk_buff *skb, struct tc_action *a,
>> +                        int bind, int ref)
>> +{
>> +       unsigned char *b = skb_tail_pointer(skb);
>> +       struct tcf_vlan *v = a->priv;
>> +       struct tc_vlan opt = {
>> +               .index    = v->tcf_index,
>> +               .refcnt   = v->tcf_refcnt - ref,
>> +               .bindcnt  = v->tcf_bindcnt - bind,
>> +               .action   = v->tcf_action,
>> +               .v_action = v->tcfv_action,
>> +       };
>> +       struct tcf_t t;
>> +
>> +       if (nla_put(skb, TCA_VLAN_PARMS, sizeof(opt), &opt))
>> +               goto nla_put_failure;
>> +
>> +       if (v->tcfv_action == TCA_VLAN_ACT_PUSH &&
>> +           nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_ID, v->tcfv_push_vid) &&
>> +           nla_put_u16(skb, TCA_VLAN_PUSH_VLAN_PROTOCOL, v->tcfv_push_proto))
>> +               goto nla_put_failure;
>
>nla_put_be16() ?
