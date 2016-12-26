From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Mon, 26 Dec 2016 11:24:35 -0500 (EST)
Message-ID: <20161226.112435.1546744617856168761.davem@davemloft.net>
References: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahark@mellanox.com, xiyou.wangcong@gmail.com,
        gerlitz.or@gmail.com, roid@mellanox.com, jiri@mellanox.com,
        john.fastabend@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbcLZQYj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 11:24:39 -0500
In-Reply-To: <1954223e8b7aa90ff835357e8a3ef7537be33e43.1482337600.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 21 Dec 2016 18:04:11 +0100

> Shahar reported a soft lockup in tc_classify(), where we run into an
> endless loop when walking the classifier chain due to tp->next == tp
> which is a state we should never run into. The issue only seems to
> trigger under load in the tc control path.
> 
> What happens is that in tc_ctl_tfilter(), thread A allocates a new
> tp, initializes it, sets tp_created to 1, and calls into tp->ops->change()
> with it. In that classifier callback we had to unlock/lock the rtnl
> mutex and returned with -EAGAIN. One reason why we need to drop there
> is, for example, that we need to request an action module to be loaded.
> 
> This happens via tcf_exts_validate() -> tcf_action_init/_1() meaning
> after we loaded and found the requested action, we need to redo the
> whole request so we don't race against others. While we had to unlock
> rtnl in that time, thread B's request was processed next on that CPU.
> Thread B added a new tp instance successfully to the classifier chain.
> When thread A returned grabbing the rtnl mutex again, propagating -EAGAIN
> and destroying its tp instance which never got linked, we goto replay
> and redo A's request.
> 
> This time when walking the classifier chain in tc_ctl_tfilter() for
> checking for existing tp instances we had a priority match and found
> the tp instance that was created and linked by thread B. Now calling
> again into tp->ops->change() with that tp was successful and returned
> without error.
> 
> tp_created was never cleared in the second round, thus kernel thinks
> that we need to link it into the classifier chain (once again). tp and
> *back point to the same object due to the match we had earlier on. Thus
> for thread B's already public tp, we reset tp->next to tp itself and
> link it into the chain, which eventually causes the mentioned endless
> loop in tc_classify() once a packet hits the data path.
> 
> Fix is to clear tp_created at the beginning of each request, also when
> we replay it. On the paths that can cause -EAGAIN we already destroy
> the original tp instance we had and on replay we really need to start
> from scratch. It seems that this issue was first introduced in commit
> 12186be7d2e1 ("net_cls: fix unconfigured struct tcf_proto keeps chaining
> and avoid kernel panic when we use cls_cgroup").
> 
> Fixes: 12186be7d2e1 ("net_cls: fix unconfigured struct tcf_proto keeps chaining and avoid kernel panic when we use cls_cgroup")
> Reported-by: Shahar Klein <shahark@mellanox.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
