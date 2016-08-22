From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Mon, 22 Aug 2016 21:15:41 +0300
Message-ID: <CAJ3xEMhTdNXXLQfvD097_7LEK8YRTXW_r+ArB-XksX6dRvUAjg@mail.gmail.com>
References: <20160822143834.32422-1-amir@vadai.me> <20160822143834.32422-4-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>, Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34544 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752929AbcHVSPm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 14:15:42 -0400
Received: by mail-oi0-f68.google.com with SMTP id t127so604637oie.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 11:15:42 -0700 (PDT)
In-Reply-To: <20160822143834.32422-4-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 5:38 PM, Amir Vadai <amir@vadai.me> wrote:
> This action could be used before redirecting packets to a shared tunnel
> device, or when redirecting packets arriving from a such a device

nit, add period


> The action will release the metadata created by the tunnel device
> (decap), or set the metadata with the specified values for encap
> operation.

Jiri B. -- SB pointer to the code


> +static int tcf_iptunnel(struct sk_buff *skb, const struct tc_action *a,
> +                       struct tcf_result *res)
> +{
> +       struct tcf_iptunnel *t = to_iptunnel(a);
> +       int action;
> +
> +       spin_lock(&t->tcf_lock);
> +       tcf_lastuse_update(&t->tcf_tm);
> +       bstats_update(&t->tcf_bstats, skb);
> +       action = t->tcf_action;
> +
> +       switch (t->tcft_action) {
> +       case TCA_IPTUNNEL_ACT_DECAP:
> +               skb_dst_set_noref(skb, NULL);
> +               break;
> +       case TCA_IPTUNNEL_ACT_ENCAP:
> +               skb_dst_set_noref(skb, &t->tcft_enc_metadata->dst);

Jiri B > I understand the motivation for the decap action. However, what would
Jiri B > happen if someone does not include it?

The MD set by the (say) vxlan device will not be "consumed" (cleared)
and would be keep travelling with the SKB

> +
> +               break;
> +       default:
> +               BUG();

no, please, scream if you want to go beyond warning but don't kill and don't die

> +       }
> +
> +       spin_unlock(&t->tcf_lock);
> +       return action;
> +}
