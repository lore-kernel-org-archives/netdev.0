From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 3/3] mlxsw: spectrum_router: Return extack
 message on abort due to fib rules
Date: Thu, 26 Oct 2017 09:38:46 +0300
Message-ID: <20171026063846.GA19803@shredder.mtl.com>
References: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
 <1508994485-24533-4-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        johannes.berg@intel.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33851 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750884AbdJZGit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 02:38:49 -0400
Content-Disposition: inline
In-Reply-To: <1508994485-24533-4-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Oct 25, 2017 at 10:08:05PM -0700, David Ahern wrote:
> Adding a FIB rule on a spectrum platform silently aborts FIB offload:
>     $ ip ru add pref 99 from all to 192.168.1.1 table 10
>     $ dmesg -c
>     [  623.144736] mlxsw_spectrum 0000:03:00.0: FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.
> 
> This patch reworks FIB rule handling to return a message to the user:
>     $ ip ru add pref 99 from all to 8.8.8.8 table 11
>     Error: spectrum: FIB rules not supported. Aborting offload.
> 
> spectrum currently only checks whether the fib rule is a default rule or
> an l3mdev rule, both of which it knows how to handle. Any other it aborts
> FIB offload. Since the processing is fairly quick, move the code to inline
> with the user request rather than a work queue to allow a message to be
> returned if the offload is aborted. Change the delete handling to just return
> since it does nothing at the moment.

Nice idea, but one problem is that the FIB notifier is atomic and thus
when you trigger abort you end up sleeping in an atomic context:

[  178.933902] mlxsw_spectrum 0000:01:00.0: FIB abort triggered. Note that FIB entries are no longer being offloaded to this device.
[  178.946983] BUG: sleeping function called from invalid context at mm/slab.h:420
[  178.955199] in_atomic(): 0, irqs_disabled(): 0, pid: 3215, name: ip
[  178.962244] INFO: lockdep is turned off.
[  178.966666] Preemption disabled at:
[  178.966685] [<ffffffff811bb603>] wake_up_klogd+0x13/0xc0
[  178.976594] CPU: 0 PID: 3215 Comm: ip Not tainted 4.14.0-rc5-rules-extack-custom #688
[  178.985353] Hardware name: Mellanox Technologies Ltd. MSN2100-CB2FO/SA001017, BIOS 5.6.5 06/07/2016
[  178.995469] Call Trace:
[  178.998214]  dump_stack+0xb1/0x10c
[  179.002026]  ? _atomic_dec_and_lock+0x124/0x124
[  179.007102]  ? debug_show_held_locks+0x14/0x40
[  179.012083]  ___might_sleep+0x32d/0x420
[  179.016383]  __might_sleep+0x4c/0x1a0
[  179.020508]  ? mlxsw_core_reg_access_emad+0xcf/0x1490 [mlxsw_core]
[  179.027449]  ? mlxsw_core_reg_access_emad+0xcf/0x1490 [mlxsw_core]
[  179.034369]  kmem_cache_alloc_trace+0x50/0x4d0
[  179.039344]  ? _raw_spin_unlock_irqrestore+0x3d/0x60
[  179.044931]  mlxsw_core_reg_access_emad+0xcf/0x1490 [mlxsw_core]
[  179.051654]  ? up+0x14/0x80
[  179.054807]  ? mlxsw_core_schedule_dw+0x20/0x20 [mlxsw_core]
[  179.061171]  ? mlxsw_emad_pack_op_tlv+0x1080/0x1080 [mlxsw_core]
[  179.067897]  ? preempt_count_sub+0x13/0xd0
[  179.072476]  ? irq_work_queue+0x141/0x1d0
[  179.076990]  mlxsw_core_reg_access+0xf0/0x8f0 [mlxsw_core]
[  179.083135]  ? console_unlock+0x697/0x7d0
[  179.087650]  ? mlxsw_reg_trans_write+0x20/0x20 [mlxsw_core]
[  179.093890]  ? vprintk_emit+0x208/0x380
[  179.098252]  ? __mlxsw_item_set32.constprop.48+0xf3/0x240 [mlxsw_spectrum]
[  179.105973]  mlxsw_reg_write+0xe/0x10 [mlxsw_core]
[  179.111400]  __mlxsw_sp_fib_entry_op+0x1ad/0x540 [mlxsw_spectrum]
[  179.118288]  ? mlxsw_sp_fib_entry_ralue_pack+0x2b0/0x2b0 [mlxsw_spectrum]
[  179.125893]  ? note_gp_changes+0x210/0x210
[  179.130482]  ? fib_trie_get_first+0x170/0x170
[  179.135420]  mlxsw_sp_fib_node_entry_del+0x97/0xe0 [mlxsw_spectrum]
[  179.142501]  mlxsw_sp_fib4_node_entry_unlink+0x6a/0x230 [mlxsw_spectrum]
[  179.150066]  ? mlxsw_sp_fib_node_entry_del+0xe0/0xe0 [mlxsw_spectrum]
[  179.157277]  ? __lock_acquire+0xf0/0x2700
[  179.161840]  mlxsw_sp_vr_fib_flush+0x30e/0x4e0 [mlxsw_spectrum]
[  179.168537]  ? mlxsw_sp_fib6_entry_destroy+0x4c0/0x4c0 [mlxsw_spectrum]
[  179.176026]  mlxsw_sp_router_fib_flush+0x9e/0x1c0 [mlxsw_spectrum]
[  179.183026]  mlxsw_sp_router_fib_abort+0x9b/0x1b0 [mlxsw_spectrum]
[  179.190015]  mlxsw_sp_router_fib_event+0x25c/0x790 [mlxsw_spectrum]
...

How about we keep the checking and error reporting inline, but do the
actual abort in a workqueue?

Thanks
