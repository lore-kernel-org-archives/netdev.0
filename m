From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V6 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 8 Sep 2016 16:18:49 +0300
Message-ID: <CAJL1qvE8ij_63efQA-jdH_nfR1zWwYGVromGf72HW1MJYBmt4Q@mail.gmail.com>
References: <1473235686-18975-1-git-send-email-hadarh@mellanox.com>
 <1473235686-18975-5-git-send-email-hadarh@mellanox.com> <CAM_iQpUrLg=i7Zug5h2OxpKoBqO5OWYmBCaMm=wYAYC3XZ-4uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34766 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941037AbcIHNSu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 09:18:50 -0400
Received: by mail-oi0-f68.google.com with SMTP id x125so2550298oia.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 06:18:50 -0700 (PDT)
In-Reply-To: <CAM_iQpUrLg=i7Zug5h2OxpKoBqO5OWYmBCaMm=wYAYC3XZ-4uQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 7:27 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Sep 7, 2016 at 1:08 AM, Hadar Hen Zion <hadarh@mellanox.com> wrote:
>> +struct tcf_tunnel_key_params {
>> +       struct rcu_head         rcu;
>> +       int                     tcft_action;
>> +       int                     action;
>> +       struct metadata_dst     *tcft_enc_metadata;
>> +};
>> +
>> +struct tcf_tunnel_key {
>> +       struct tc_action              common;
>> +       struct tcf_tunnel_key_params __rcu *params;
>> +};
>> +
> ...
>
> This is unnecessary if we make the tc action API aware of RCU.
>
>> +
>> +static void tunnel_key_release(struct tc_action *a, int bind)
>> +{
>> +       struct tcf_tunnel_key *t = to_tunnel_key(a);
>> +       struct tcf_tunnel_key_params *params;
>> +
>> +       rcu_read_lock();
>> +       params = rcu_dereference(t->params);
>> +
>> +       if (params->tcft_action == TCA_TUNNEL_KEY_ACT_SET)
>> +               dst_release(&params->tcft_enc_metadata->dst);
>> +
>> +       rcu_read_unlock();
>> +
>
> So you allocate memory for t->params in ->init() but not
> release it here?

Right, I'll fix it in the next version.

>
> Also, ->cleanup() should be called with RTNL, no need to
> take read lock here.

RTNL lock isn't taken when cleanup is called.

>
> BTW, again you do NOT need to make it RCU, the whole
> tc action API should be, as my patchset does, I will take care
> of this as a part of my patchset. Eric is wasting your time on
> this, with no benefits, the code will be replaced soon.
