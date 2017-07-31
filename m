From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 11/12] net: add notifier hooks for devmap bpf
 map
Date: Mon, 31 Jul 2017 10:55:03 +0200
Message-ID: <597EF067.1090605@iogearbox.net>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810> <20170717163002.24315.38734.stgit@john-Precision-Tower-5810> <20170730132931.gmzb6r4qaxxpsuir@sasha-lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "ast@fb.com" <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "brouer@redhat.com" <brouer@redhat.com>,
        "andy@greyhouse.net" <andy@greyhouse.net>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34723 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbdGaIzJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 04:55:09 -0400
In-Reply-To: <20170730132931.gmzb6r4qaxxpsuir@sasha-lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2017 03:28 PM, Levin, Alexander (Sasha Levin) wrote:
> On Mon, Jul 17, 2017 at 09:30:02AM -0700, John Fastabend wrote:
>> @@ -341,9 +368,11 @@ static int dev_map_update_elem(struct bpf_map *map, void *key, void *value,
>> 	 * Remembering the driver side flush operation will happen before the
>> 	 * net device is removed.
>> 	 */
>> +	mutex_lock(&dev_map_list_mutex);
>> 	old_dev = xchg(&dtab->netdev_map[i], dev);
>> 	if (old_dev)
>> 		call_rcu(&old_dev->rcu, __dev_map_entry_free);
>> +	mutex_unlock(&dev_map_list_mutex);
>>
>> 	return 0;
>> }
>
> This function gets called under rcu critical section, where we can't grab mutexes:

Agree, same goes for the delete callback that mutex is not allowed
in this context. If I recall, this was for the devmap netdev notifier
in order to check whether we need to purge dev entries from the map,
so that the device can be unregistered gracefully. Given that devmap
ops like update/delete are only allowed from user space, we could
look into whether this map type actually needs to hold RCU at all
here, or other option is to try and get rid of the mutex altogether.
John, could you take a look for a fix?

Thanks a lot,
Daniel

> BUG: sleeping function called from invalid context at kernel/locking/mutex.c:747
> in_atomic(): 1, irqs_disabled(): 0, pid: 16315, name: syz-executor1
> 1 lock held by syz-executor1/16315:
>   #0:  (rcu_read_lock){......}, at: [<ffffffff8c363bc2>] map_delete_elem kernel/bpf/syscall.c:577 [inline]
>   #0:  (rcu_read_lock){......}, at: [<ffffffff8c363bc2>] SYSC_bpf kernel/bpf/syscall.c:1427 [inline]
>   #0:  (rcu_read_lock){......}, at: [<ffffffff8c363bc2>] SyS_bpf+0x1d32/0x4ba0 kernel/bpf/syscall.c:1388
> Preemption disabled at:
> [<ffffffff8c363bd1>] map_delete_elem kernel/bpf/syscall.c:582 [inline]
> [<ffffffff8c363bd1>] SYSC_bpf kernel/bpf/syscall.c:1427 [inline]
> [<ffffffff8c363bd1>] SyS_bpf+0x1d41/0x4ba0 kernel/bpf/syscall.c:1388
> CPU: 2 PID: 16315 Comm: syz-executor1 Not tainted 4.13.0-rc2-next-20170727 #235
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1 04/01/2014
> Call Trace:
>   __dump_stack lib/dump_stack.c:16 [inline]
>   dump_stack+0x11d/0x1e5 lib/dump_stack.c:52
>   ___might_sleep+0x3cc/0x520 kernel/sched/core.c:6001
>   __might_sleep+0x95/0x190 kernel/sched/core.c:5954
>   __mutex_lock_common kernel/locking/mutex.c:747 [inline]
>   __mutex_lock+0x146/0x19b0 kernel/locking/mutex.c:893
>   mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
>   dev_map_delete_elem+0x82/0x110 kernel/bpf/devmap.c:325
>   map_delete_elem kernel/bpf/syscall.c:585 [inline]
>   SYSC_bpf kernel/bpf/syscall.c:1427 [inline]
>   SyS_bpf+0x1deb/0x4ba0 kernel/bpf/syscall.c:1388
>   do_syscall_64+0x26a/0x800 arch/x86/entry/common.c:287
>   entry_SYSCALL64_slow_path+0x25/0x25
> RIP: 0033:0x452309
> RSP: 002b:00007f8d83d66c08 EFLAGS: 00000216 ORIG_RAX: 0000000000000141
> RAX: ffffffffffffffda RBX: 0000000000718000 RCX: 0000000000452309
> RDX: 0000000000000010 RSI: 0000000020007000 RDI: 0000000000000003
> RBP: 0000000000000270 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000216 R12: 00000000004b85e4
> R13: 00000000ffffffff R14: 0000000000000003 R15: 0000000020007000
>
