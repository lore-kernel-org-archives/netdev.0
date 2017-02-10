From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH RFC net] net/mlx5e: Add preemption enable/disable around
 TC statistics upcall
Date: Fri, 10 Feb 2017 10:14:16 -0800
Message-ID: <20170210101416.1c537cec@cakuba.netronome.com>
References: <1486654723-25777-1-git-send-email-ogerlitz@mellanox.com>
        <20170209173441.1f1eb96e@cakuba.netronome.com>
        <CAJ3xEMjuBqrJrQatVroLdF49rxzdF+9a1aP8b3mJSqUyS63-5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Amir Vadai <amir@vadai.me>, Ido Schimmel <idosch@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Roi Dayan <roid@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35586 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbdBJSPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:15:32 -0500
Received: by mail-pf0-f170.google.com with SMTP id 202so7818171pfx.2
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 10:14:21 -0800 (PST)
In-Reply-To: <CAJ3xEMjuBqrJrQatVroLdF49rxzdF+9a1aP8b3mJSqUyS63-5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Feb 2017 18:21:25 +0200, Or Gerlitz wrote:
> On Fri, Feb 10, 2017 at 3:34 AM, Jakub Kicinski wrote:
> > On Thu,  9 Feb 2017 17:38:43 +0200, Or Gerlitz wrote:  
> >> Running with CONFIG_PREEMPT set, I get a
> >>
> >> BUG: using smp_processor_id() in preemptible [00000000] code: tc/3793
> >>
> >> asserion from the TC action (mirred) stats_update callback, when the do
> >>
> >>       _bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets)
> >>
> >> As done by commit 66860be "nfp: bpf: allow offloaded filters to update stats",
> >> disabling/enabling preemption around the TC upcall solves that.
> >>
> >> Fixes: aad7e08d39bd ('net/mlx5e: Hardware offloaded flower filter statistics support')
> >> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> >> ---
> >>
> >> I marked it as RFC, since I wasn't fully sure on the nature of the
> >> problem, nor if this is the direction we should take to the fix.  
> 
> > I think it's the right fix  
> 
> Do you under the problem? what's wrong with the call done in the TC
> action code w.r.t preemption?
> 
> does it make sense to do this (say) 100K times/sec?

TC actions have pre-cpu stats, referencing them has to be done with
preemption disabled.  Let's CC Jamal and Cong - maybe there are some
more clever things we could do here?  The situation in a nutshell is
that the offload drivers read the stats from HW and want to write them
back to the TC action stats.  The writeback happens in process context
when user requests stats dump (potentially for multiple actions but we
currently would just iterate over all actions in driver code).
