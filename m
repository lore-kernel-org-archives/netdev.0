From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sched: fix refcount imbalance in actions
Date: Thu, 30 Jul 2015 14:21:16 -0700 (PDT)
Message-ID: <20150730.142116.2111905680725756228.davem@davemloft.net>
References: <00f17fd2908b742c7e450bb76a1d487c0b32304f.1438205044.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, ast@plumgrid.com, jhs@mojatatu.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbbG3VVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 17:21:18 -0400
In-Reply-To: <00f17fd2908b742c7e450bb76a1d487c0b32304f.1438205044.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 29 Jul 2015 23:35:25 +0200

> Since commit 55334a5db5cd ("net_sched: act: refuse to remove bound action
> outside"), we end up with a wrong reference count for a tc action.
 ...
> What happens is that in tcf_hash_check(), we check tcf_common for a given
> index and increase tcfc_refcnt and conditionally tcfc_bindcnt when we've
> found an existing action. Now there are the following cases:
> 
>   1) We do a late binding of an action. In that case, we leave the
>      tcfc_refcnt/tcfc_bindcnt increased and are done with the ->init()
>      handler. This is correctly handeled.
> 
>   2) We replace the given action, or we try to add one without replacing
>      and find out that the action at a specific index already exists
>      (thus, we go out with error in that case).
> 
> In case of 2), we have to undo the reference count increase from
> tcf_hash_check() in the tcf_hash_check() function. Currently, we fail to
> do so because of the 'tcfc_bindcnt > 0' check which bails out early with
> an -EPERM error.
> 
> Now, while commit 55334a5db5cd prevents 'tc actions del action ...' on an
> already classifier-bound action to drop the reference count (which could
> then become negative, wrap around etc), this restriction only accounts for
> invocations outside a specific action's ->init() handler.
> 
> One possible solution would be to add a flag thus we possibly trigger
> the -EPERM ony in situations where it is indeed relevant.
> 
> After the patch, above test cases have correct reference count again.
> 
> Fixes: 55334a5db5cd ("net_sched: act: refuse to remove bound action outside")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
