From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v2 2/4] net/sched: Introduce sample tc action
Date: Wed, 25 Jan 2017 15:29:47 -0800
Message-ID: <CAM_iQpUHrhkVtgrA37btQ9sn0UPeYgkqnRx=3HZoLan-soT8hg@mail.gmail.com>
References: <1485166031-4773-1-git-send-email-jiri@resnulli.us> <1485166031-4773-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
        nogahf@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>, geert+renesas@glider.be,
        Stephen Hemminger <stephen@networkplumber.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Simon Horman <simon.horman@netronome.com>,
        Roman Mashak <mrv@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35764 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752268AbdAYXaJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 18:30:09 -0500
Received: by mail-wm0-f66.google.com with SMTP id d140so46359850wmd.2
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 15:30:09 -0800 (PST)
In-Reply-To: <1485166031-4773-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 2:07 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> +
> +static int tcf_sample_init(struct net *net, struct nlattr *nla,
> +                          struct nlattr *est, struct tc_action **a, int ovr,
> +                          int bind)
> +{
> +       struct tc_action_net *tn = net_generic(net, sample_net_id);
> +       struct nlattr *tb[TCA_SAMPLE_MAX + 1];
> +       struct psample_group *psample_group;
> +       struct tc_sample *parm;
> +       struct tcf_sample *s;
> +       bool exists = false;
> +       int ret;
> +
> +       if (!nla)
> +               return -EINVAL;
> +       ret = nla_parse_nested(tb, TCA_SAMPLE_MAX, nla, sample_policy);
> +       if (ret < 0)
> +               return ret;
> +       if (!tb[TCA_SAMPLE_PARMS] || !tb[TCA_SAMPLE_RATE] ||
> +           !tb[TCA_SAMPLE_PSAMPLE_GROUP])
> +               return -EINVAL;
> +
> +       parm = nla_data(tb[TCA_SAMPLE_PARMS]);
> +
> +       exists = tcf_hash_check(tn, parm->index, a, bind);
> +       if (exists && bind)
> +               return 0;
> +
> +       if (!exists) {
> +               ret = tcf_hash_create(tn, parm->index, est, a,
> +                                     &act_sample_ops, bind, false);
> +               if (ret)
> +                       return ret;
> +               ret = ACT_P_CREATED;
> +       } else {
> +               tcf_hash_release(*a, bind);
> +               if (!ovr)
> +                       return -EEXIST;
> +       }
> +       s = to_sample(*a);
> +
> +       ASSERT_RTNL();

Copy-n-paste from mirred aciton? This is not needed for you, mirred
needs it because of target netdevice.


> +       s->tcf_action = parm->action;
> +       s->rate = nla_get_u32(tb[TCA_SAMPLE_RATE]);
> +       s->psample_group_num = nla_get_u32(tb[TCA_SAMPLE_PSAMPLE_GROUP]);
> +       psample_group = psample_group_get(net, s->psample_group_num);
> +       if (!psample_group)
> +               return -ENOMEM;

I don't think you can just return here, needs tcf_hash_cleanup() for create
case, right?


> +       RCU_INIT_POINTER(s->psample_group, psample_group);
> +
> +       if (tb[TCA_SAMPLE_TRUNC_SIZE]) {
> +               s->truncate = true;
> +               s->trunc_size = nla_get_u32(tb[TCA_SAMPLE_TRUNC_SIZE]);
> +       }


Do you need tcf_lock here if RCU only protects ->psample_group??


> +
> +       if (ret == ACT_P_CREATED)
> +               tcf_hash_insert(tn, *a);
> +       return ret;
> +}
> +


Thanks.
