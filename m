From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] bpf: devmap fix mutex in rcu critical
 section
Date: Mon, 07 Aug 2017 14:13:45 -0700 (PDT)
Message-ID: <20170807.141345.1869290095205202235.davem@davemloft.net>
References: <20170805050219.12333.47493.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, alexander.levin@verizon.com,
        netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36214 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751926AbdHGVNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:13:46 -0400
In-Reply-To: <20170805050219.12333.47493.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 04 Aug 2017 22:02:19 -0700

> Originally we used a mutex to protect concurrent devmap update
> and delete operations from racing with netdev unregister notifier
> callbacks.
> 
> The notifier hook is needed because we increment the netdev ref
> count when a dev is added to the devmap. This ensures the netdev
> reference is valid in the datapath. However, we don't want to block
> unregister events, hence the initial mutex and notifier handler.
> 
> The concern was in the notifier hook we search the map for dev
> entries that hold a refcnt on the net device being torn down. But,
> in order to do this we require two steps,
 ...
> Fortunately, by writing slightly better code we can avoid the
> mutex altogether. If CPU 1 in the above example uses a cmpxchg
> and _only_ replaces the dev reference in the map when it is in
> fact the expected dev the race is removed completely. The two
> cases being illustrated here, first the race condition,
 ...
> And viola the original race we tried to solve with a mutex is
> corrected and the trace noted by Sasha below is resolved due
> to removal of the mutex.
> 
> Note: When walking the devmap and removing dev references as needed
> we depend on the core to fail any calls to dev_get_by_index() using
> the ifindex of the device being removed. This way we do not race with
> the user while searching the devmap.
> 
> Additionally, the mutex was also protecting list add/del/read on
> the list of maps in-use. This patch converts this to an RCU list
> and spinlock implementation. This protects the list from concurrent
> alloc/free operations. The notifier hook walks this list so it uses
> RCU read semantics.
> 
> BUG: sleeping function called from invalid context at kernel/locking/mutex.c:747
> in_atomic(): 1, irqs_disabled(): 0, pid: 16315, name: syz-executor1
> 1 lock held by syz-executor1/16315:
>  #0:  (rcu_read_lock){......}, at: [<ffffffff8c363bc2>] map_delete_elem kernel/bpf/syscall.c:577 [inline]
>  #0:  (rcu_read_lock){......}, at: [<ffffffff8c363bc2>] SYSC_bpf kernel/bpf/syscall.c:1427 [inline]
>  #0:  (rcu_read_lock){......}, at: [<ffffffff8c363bc2>] SyS_bpf+0x1d32/0x4ba0 kernel/bpf/syscall.c:1388
> 
> Fixes: 2ddf71e23cc2 ("net: add notifier hooks for devmap bpf map")
> Reported-by: Sasha Levin <alexander.levin@verizon.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Applied, thanks John.
