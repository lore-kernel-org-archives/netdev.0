From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v3 06/10] net: sched: introduce helpers to work
 with filter chains
Date: Tue, 16 May 2017 15:17:11 -0700
Message-ID: <CAM_iQpWDp3kFfCDL0JJ4c1_e9FZQ_-Wg+5HV0txz=KrTgWsq-w@mail.gmail.com>
References: <20170516172802.1317-1-jiri@resnulli.us> <20170516172802.1317-7-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34076 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdEPWRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 18:17:32 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so40976378wmf.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 15:17:32 -0700 (PDT)
In-Reply-To: <20170516172802.1317-7-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> +static struct tcf_proto *tcf_chain_tp_prev(struct tcf_chain_info *chain_info)
> +{
> +       return rtnl_dereference(*chain_info->pprev);
> +}
> +
> +static void tcf_chain_tp_insert(struct tcf_chain *chain,
> +                               struct tcf_chain_info *chain_info,
> +                               struct tcf_proto *tp)
> +{
> +       if (chain->p_filter_chain &&
> +           *chain_info->pprev == chain->filter_chain)
> +               *chain->p_filter_chain = tp;
> +       RCU_INIT_POINTER(tp->next, rtnl_dereference(*chain_info->pprev));

Use tcf_chain_tp_prev()?


> +       rcu_assign_pointer(*chain_info->pprev, tp);
> +}
> +
> +static void tcf_chain_tp_remove(struct tcf_chain *chain,
> +                               struct tcf_chain_info *chain_info,
> +                               struct tcf_proto *tp)
> +{
> +       struct tcf_proto *next = rtnl_dereference(chain_info->next);
> +
> +       if (chain->p_filter_chain && tp == chain->filter_chain)
> +               *chain->p_filter_chain = next;
> +       RCU_INIT_POINTER(*chain_info->pprev, next);
> +}
> +
> +static struct tcf_proto *tcf_chain_tp_find(struct tcf_chain *chain,
> +                                          struct tcf_chain_info *chain_info,
> +                                          u32 protocol, u32 prio,
> +                                          bool prio_allocate)
> +{
> +       struct tcf_proto **pprev;
> +       struct tcf_proto *tp;
> +
> +       /* Check the chain for existence of proto-tcf with this priority */
> +       for (pprev = &chain->filter_chain;
> +            (tp = rtnl_dereference(*pprev)); pprev = &tp->next) {

Use tcf_chain_tp_prev()?
