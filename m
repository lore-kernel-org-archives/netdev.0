From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] net: sched: don't use GFP_KERNEL under spin lock
Date: Tue, 05 Sep 2017 10:17:49 -0700
Message-ID: <1504631869.15310.46.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170905153123.13209-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
        Chris Mi <chrism@mellanox.com>, xiyou.wangcong@gmail.com,
        jhs@mojatatu.com, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33420 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751959AbdIERRw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 13:17:52 -0400
Received: by mail-pg0-f65.google.com with SMTP id m9so2279463pgd.0
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 10:17:51 -0700 (PDT)
In-Reply-To: <20170905153123.13209-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-05 at 08:31 -0700, Jakub Kicinski wrote:
> The new TC IDR code uses GFP_KERNEL under spin lock.  Which leads
> to:
> 
> [  582.621091] BUG: sleeping function called from invalid context at ../mm/slab.h:416
> [  582.629721] in_atomic(): 1, irqs_disabled(): 0, pid: 3379, name: tc
> [  582.636939] 2 locks held by tc/3379:
> [  582.641049]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff910354ce>] rtnetlink_rcv_msg+0x92e/0x1400
> [  582.650958]  #1:  (&(&tn->idrinfo->lock)->rlock){+.-.+.}, at: [<ffffffff9110a5e0>] tcf_idr_create+0x2f0/0x8e0
> [  582.662217] Preemption disabled at:
> [  582.662222] [<ffffffff9110a5e0>] tcf_idr_create+0x2f0/0x8e0
> [  582.672592] CPU: 9 PID: 3379 Comm: tc Tainted: G        W       4.13.0-rc7-debug-00648-g43503a79b9f0 #287
> [  582.683432] Hardware name: Dell Inc. PowerEdge R730/072T6D, BIOS 2.3.4 11/08/2016
> [  582.691937] Call Trace:
> ...
> [  582.742460]  kmem_cache_alloc+0x286/0x540
> [  582.747055]  radix_tree_node_alloc.constprop.6+0x4a/0x450
> [  582.753209]  idr_get_free_cmn+0x627/0xf80
> ...
> [  582.815525]  idr_alloc_cmn+0x1a8/0x270
> ...
> [  582.833804]  tcf_idr_create+0x31b/0x8e0
> ...
> 
> Try to preallocate the memory with idr_prealloc(GFP_KERNEL)
> (as suggested by Eric Dumazet), and change the allocation 
> flags under spin lock.
> 
> Fixes: 65a206c01e8e ("net/sched: Change act_api and act_xxx modules to use IDR")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---


Acked-by: Eric Dumazet <edumazet@google.com>

Not related to your patch, but it looks like idr_preload() has a bug
added in 4.11.  I will send a fix to lkml.
