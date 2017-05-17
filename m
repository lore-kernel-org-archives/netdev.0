From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 06/10] net: sched: introduce helpers to work
 with filter chains
Date: Wed, 17 May 2017 07:50:11 +0200
Message-ID: <20170517055011.GC1832@nanopsycho>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172802.1317-7-jiri@resnulli.us>
 <CAM_iQpWDp3kFfCDL0JJ4c1_e9FZQ_-Wg+5HV0txz=KrTgWsq-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33547 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751305AbdEQFuO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 01:50:14 -0400
Received: by mail-wr0-f193.google.com with SMTP id w50so222677wrc.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 22:50:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpWDp3kFfCDL0JJ4c1_e9FZQ_-Wg+5HV0txz=KrTgWsq-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 17, 2017 at 12:17:11AM CEST, xiyou.wangcong@gmail.com wrote:
>On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> +static struct tcf_proto *tcf_chain_tp_prev(struct tcf_chain_info *chain_info)
>> +{
>> +       return rtnl_dereference(*chain_info->pprev);
>> +}
>> +
>> +static void tcf_chain_tp_insert(struct tcf_chain *chain,
>> +                               struct tcf_chain_info *chain_info,
>> +                               struct tcf_proto *tp)
>> +{
>> +       if (chain->p_filter_chain &&
>> +           *chain_info->pprev == chain->filter_chain)
>> +               *chain->p_filter_chain = tp;
>> +       RCU_INIT_POINTER(tp->next, rtnl_dereference(*chain_info->pprev));
>
>Use tcf_chain_tp_prev()?

Ok. Will do that.

>
>
>> +       rcu_assign_pointer(*chain_info->pprev, tp);
>> +}
>> +
>> +static void tcf_chain_tp_remove(struct tcf_chain *chain,
>> +                               struct tcf_chain_info *chain_info,
>> +                               struct tcf_proto *tp)
>> +{
>> +       struct tcf_proto *next = rtnl_dereference(chain_info->next);
>> +
>> +       if (chain->p_filter_chain && tp == chain->filter_chain)
>> +               *chain->p_filter_chain = next;
>> +       RCU_INIT_POINTER(*chain_info->pprev, next);
>> +}
>> +
>> +static struct tcf_proto *tcf_chain_tp_find(struct tcf_chain *chain,
>> +                                          struct tcf_chain_info *chain_info,
>> +                                          u32 protocol, u32 prio,
>> +                                          bool prio_allocate)
>> +{
>> +       struct tcf_proto **pprev;
>> +       struct tcf_proto *tp;
>> +
>> +       /* Check the chain for existence of proto-tcf with this priority */
>> +       for (pprev = &chain->filter_chain;
>> +            (tp = rtnl_dereference(*pprev)); pprev = &tp->next) {
>
>Use tcf_chain_tp_prev()?

Can't be done.
