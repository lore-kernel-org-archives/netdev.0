From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v2 2/2] net_sched: fix all the madness of tc filter chain
Date: Mon, 11 Sep 2017 14:58:16 -0700
Message-ID: <CAM_iQpWT6sRWGTt+nPtj=dcfzeL6np6nOPOzrM7kdtGh5TL_gQ@mail.gmail.com>
References: <20170907042607.24413-1-xiyou.wangcong@gmail.com>
 <20170907042607.24413-2-xiyou.wangcong@gmail.com> <20170907063216.GB1967@nanopsycho>
 <CAM_iQpXsYc1cfZmuFKGH1O-FPJr9+NJqZTTB5z1oJVGYgvkV+Q@mail.gmail.com>
 <20170907205239.GF1967@nanopsycho> <CAM_iQpUJLfkq0ys3XNchPVXBpF4yoNaBG_L7UjiSMW7_9NyYaQ@mail.gmail.com>
 <20170910143300.GB1860@nanopsycho> <CAM_iQpV2p25iZg7sd7jpcN0nuAPmwVUa3-J8F_oGC26aTTPtWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:37019 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdIKV6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 17:58:37 -0400
Received: by mail-pg0-f52.google.com with SMTP id d8so17707404pgt.4
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 14:58:37 -0700 (PDT)
In-Reply-To: <CAM_iQpV2p25iZg7sd7jpcN0nuAPmwVUa3-J8F_oGC26aTTPtWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 11, 2017 at 2:14 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> Looks like all due to the lack of locking on block->chain_list.
> I thought the rcu_barrier() could properly handle this,
> but seems still not, probably I need to move it in the loop,
> I am still not 100% sure if it is totally safe with
> list_for_each_safe():
>
>
> -       list_for_each_entry(chain, &block->chain_list, list)
> +       list_for_each_entry_safe(chain, tmp, &block->chain_list, list) {
>                 tcf_chain_flush(chain);
> -       rcu_barrier();
> +               rcu_barrier(); // are we safe now???
> +       }
>

Answer myself: No, this is not safe either, because we may
list_del() the next node, and apparently _safe() can't guarantee
that...

So either we have to use locking or use the trick you suggested.
