From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 2/4] net: vrf: call netdev_lockdep_set_classes()
Date: Wed, 8 Jun 2016 18:43:48 -0700
Message-ID: <CANn89iLr_H+hdti2wHzjP3P64oRiATTRe-usNkKjTu6XizNBHw@mail.gmail.com>
References: <1465430127-22993-1-git-send-email-edumazet@google.com>
 <1465430127-22993-2-git-send-email-edumazet@google.com> <31939b76-efa5-f1dd-3a8b-92d9343df7ee@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:35662 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933838AbcFIBnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 21:43:50 -0400
Received: by mail-yw0-f171.google.com with SMTP id z186so6415488ywd.2
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 18:43:50 -0700 (PDT)
In-Reply-To: <31939b76-efa5-f1dd-3a8b-92d9343df7ee@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2016 at 6:26 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 6/8/16 5:55 PM, Eric Dumazet wrote:
>>
>> In case a qdisc is used on a vrf device, we need to use different
>> lockdep classes to avoid false positives.
>>
>> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a
>> seqcount")
>> Reported-by: David Ahern <dsa@cumulusnetworks.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>>  drivers/net/vrf.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
>> index 1b214ea4619a..ee6bc1c5c1ce 100644
>> --- a/drivers/net/vrf.c
>> +++ b/drivers/net/vrf.c
>> @@ -657,7 +657,7 @@ static int vrf_dev_init(struct net_device *dev)
>>
>>         /* similarly, oper state is irrelevant; set to up to avoid
>> confusion */
>>         dev->operstate = IF_OPER_UP;
>> -
>> +       netdev_lockdep_set_classes(dev);
>>         return 0;
>>
>>  out_rth:
>>
>
> Still see the problem; all 4 patches applied, make clean followed by a build
> just to make sure.
>
> [   90.956522]
> [   90.956952] ======================================================
> [   90.958441] [ INFO: possible circular locking dependency detected ]
> [   90.959820] 4.7.0-rc1+ #271 Not tainted
> [   90.960672] -------------------------------------------------------
> [   90.962051] ping/1585 is trying to acquire lock:
> [   90.962997]  (&(&list->lock)->rlock#3){+.-...}, at: [<ffffffff8140827c>]
> __dev_queue_xmit+0x3d3/0x751
> [   90.965033]
> [   90.965033] but task is already holding lock:
> [   90.966200]  (dev->qdisc_running_key ?: &qdisc_running_key#2){+.....},
> at: [<ffffffff814082d1>] __dev_queue_xmit+0x428/0x751
> [   90.968591]
> [   90.968591] which lock already depends on the new lock.
> [   90.968591]
> [   90.970014]
> [   90.970014] the existing dependency chain (in reverse order) is:
> [   90.971287]
> -> #1 (dev->qdisc_running_key ?: &qdisc_running_key#2){+.....}:
> [   90.972611]        [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
> [   90.973712]        [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
> [   90.974668]        [<ffffffff8140259d>] write_seqcount_begin+0x21/0x24
> [   90.975673]        [<ffffffff814082d1>] __dev_queue_xmit+0x428/0x751
> [   90.976608]        [<ffffffff81408605>] dev_queue_xmit+0xb/0xd
> [   90.977484]        [<ffffffff81411f40>] neigh_resolve_output+0x113/0x12e
> [   90.978497]        [<ffffffff81397881>]
> dst_neigh_output.isra.20+0x13b/0x148
> [   90.979548]        [<ffffffff81397992>] vrf_finish_output+0x104/0x139
> [   90.980504]        [<ffffffff81397b5d>] vrf_output+0x5c/0xc1
> [   90.981365]        [<ffffffff81441ae3>] dst_output+0x2b/0x30
> [   90.982240]        [<ffffffff8144355a>] ip_local_out+0x2a/0x31
> [   90.983109]        [<ffffffff814443cb>] ip_send_skb+0x14/0x38
> [   90.983974]        [<ffffffff8144441d>] ip_push_pending_frames+0x2e/0x31
> [   90.984887]        [<ffffffff814650ca>] raw_sendmsg+0x788/0x9d2
> [   90.985658]        [<ffffffff81472438>] inet_sendmsg+0x35/0x5c
> [   90.986452]        [<ffffffff813ed311>] sock_sendmsg_nosec+0x12/0x1d
> [   90.987275]        [<ffffffff813ee1c5>] ___sys_sendmsg+0x1b1/0x21f
> [   90.988094]        [<ffffffff813ee4ea>] __sys_sendmsg+0x40/0x5e
> [   90.988882]        [<ffffffff813ee51c>] SyS_sendmsg+0x14/0x16
> [   90.989647]        [<ffffffff814f69bc>]
> entry_SYSCALL_64_fastpath+0x1f/0xbd
> [   90.990590]
> -> #0 (&(&list->lock)->rlock#3){+.-...}:
> [   90.991368]        [<ffffffff8108435a>]
> validate_chain.isra.37+0x7c8/0xa5b
> [   90.992268]        [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
> [   90.993114]        [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
> [   90.993955]        [<ffffffff814f5ee6>] _raw_spin_lock+0x2f/0x65
> [   90.994751]        [<ffffffff8140827c>] __dev_queue_xmit+0x3d3/0x751
> [   90.995574]        [<ffffffff81408605>] dev_queue_xmit+0xb/0xd
> [   90.996338]        [<ffffffff8146ac86>] arp_xmit+0x32/0x7e
> [   90.997062]        [<ffffffff8146ad0e>] arp_send_dst+0x3c/0x42
> [   90.997834]        [<ffffffff8146af8f>] arp_solicit+0x27b/0x28e
> [   90.998631]        [<ffffffff8140f08f>] neigh_probe+0x4a/0x5e
> [   90.999407]        [<ffffffff8141066f>] __neigh_event_send+0x1d0/0x21b
> [   91.000264]        [<ffffffff814106e5>] neigh_event_send+0x2b/0x2d
> [   91.001075]        [<ffffffff81411e45>] neigh_resolve_output+0x18/0x12e
> [   91.001956]        [<ffffffff814421e8>] ip_finish_output2+0x3c0/0x41c
> [   91.002803]        [<ffffffff81442a7b>] ip_finish_output+0x132/0x13e
> [   91.003630]        [<ffffffff81442aa8>]
> NF_HOOK_COND.constprop.43+0x21/0x8a
> [   91.004550]        [<ffffffff81443c19>] ip_output+0x65/0x6a
> [   91.005293]        [<ffffffff81441ae3>] dst_output+0x2b/0x30
> [   91.006066]        [<ffffffff8144355a>] ip_local_out+0x2a/0x31
> [   91.006821]        [<ffffffff813985f1>] vrf_xmit+0x1f6/0x417
> [   91.007554]        [<ffffffff81407ba8>] dev_hard_start_xmit+0x154/0x337
> [   91.008410]        [<ffffffff81427f15>] sch_direct_xmit+0x98/0x16c
> [   91.009211]        [<ffffffff814082fc>] __dev_queue_xmit+0x453/0x751
> [   91.010043]        [<ffffffff81408605>] dev_queue_xmit+0xb/0xd
> [   91.010806]        [<ffffffff81411f40>] neigh_resolve_output+0x113/0x12e
> [   91.011690]        [<ffffffff81397881>]
> dst_neigh_output.isra.20+0x13b/0x148
> [   91.012600]        [<ffffffff81397992>] vrf_finish_output+0x104/0x139
> [   91.013431]        [<ffffffff81397b5d>] vrf_output+0x5c/0xc1
> [   91.014172]        [<ffffffff81441ae3>] dst_output+0x2b/0x30
> [   91.014906]        [<ffffffff8144355a>] ip_local_out+0x2a/0x31
> [   91.015659]        [<ffffffff814443cb>] ip_send_skb+0x14/0x38
> [   91.016398]        [<ffffffff8144441d>] ip_push_pending_frames+0x2e/0x31
> [   91.017259]        [<ffffffff814650ca>] raw_sendmsg+0x788/0x9d2
> [   91.018033]        [<ffffffff81472438>] inet_sendmsg+0x35/0x5c
> [   91.018797]        [<ffffffff813ed311>] sock_sendmsg_nosec+0x12/0x1d
> [   91.019615]        [<ffffffff813ee1c5>] ___sys_sendmsg+0x1b1/0x21f
> [   91.020417]        [<ffffffff813ee4ea>] __sys_sendmsg+0x40/0x5e
> [   91.021180]        [<ffffffff813ee51c>] SyS_sendmsg+0x14/0x16
> [   91.021927]        [<ffffffff814f69bc>]
> entry_SYSCALL_64_fastpath+0x1f/0xbd
> [   91.022820]
> [   91.022820] other info that might help us debug this:
> [   91.022820]
> [   91.023848]  Possible unsafe locking scenario:
> [   91.023848]
> [   91.024595]        CPU0                    CPU1
> [   91.025173]        ----                    ----
> [   91.025751]   lock(dev->qdisc_running_key ?: &qdisc_running_key#2);
> [   91.026600]                                lock(&(&list->lock)->rlock#3);
> [   91.027505] lock(dev->qdisc_running_key ?: &qdisc_running_key#2);
> [   91.028657]   lock(&(&list->lock)->rlock#3);
> [   91.029257]
> [   91.029257]  *** DEADLOCK ***
> [   91.029257]
> [   91.030008] 6 locks held by ping/1585:
> [   91.030485]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8146506b>]
> raw_sendmsg+0x729/0x9d2
> [   91.031643]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff81397076>]
> rcu_lock_acquire+0x0/0x20
> [   91.032834]  #2:  (rcu_read_lock_bh){......}, at: [<ffffffff813ffc04>]
> rcu_lock_acquire+0x0/0x20
> [   91.034040]  #3:  (dev->qdisc_running_key ?:
> &qdisc_running_key#2){+.....}, at: [<ffffffff814082d1>]
> __dev_queue_xmit+0x428/0x751
> [   91.035622]  #4:  (rcu_read_lock_bh){......}, at: [<ffffffff814418d3>]
> rcu_lock_acquire+0x0/0x20
> [   91.036823]  #5:  (rcu_read_lock_bh){......}, at: [<ffffffff813ffc04>]
> rcu_lock_acquire+0x0/0x20
> [   91.038016]
> [   91.038016] stack backtrace:
> [   91.038574] CPU: 6 PID: 1585 Comm: ping Not tainted 4.7.0-rc1+ #271
> [   91.039366] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> 1.7.5-20140531_083030-gandalf 04/01/2014
> [   91.040634]  0000000000000000 ffff8800b84c72d0 ffffffff8127e395
> ffffffff8254b8c0
> [   91.041632]  ffffffff8254b8c0 ffff8800b84c7310 ffffffff81083461
> ffff8800b9b5e240
> [   91.042645]  ffff8800b9b5ea60 0000000000000004 ffff8800b9b5ea98
> ffff8800b9b5e240
> [   91.043645] Call Trace:
> [   91.043968]  [<ffffffff8127e395>] dump_stack+0x81/0xb6
> [   91.044620]  [<ffffffff81083461>] print_circular_bug+0x1f6/0x204
> [   91.045377]  [<ffffffff8108435a>] validate_chain.isra.37+0x7c8/0xa5b
> [   91.046193]  [<ffffffff8101c65c>] ? paravirt_sched_clock+0x9/0xd
> [   91.046951]  [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
> [   91.047666]  [<ffffffff810853b7>] ? __lock_acquire+0x5e4/0x690
> [   91.048404]  [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
> [   91.049104]  [<ffffffff8140827c>] ? __dev_queue_xmit+0x3d3/0x751
> [   91.049868]  [<ffffffff814f5ee6>] _raw_spin_lock+0x2f/0x65
> [   91.050564]  [<ffffffff8140827c>] ? __dev_queue_xmit+0x3d3/0x751
> [   91.051322]  [<ffffffff8140827c>] __dev_queue_xmit+0x3d3/0x751
> [   91.052061]  [<ffffffff813f5620>] ? __alloc_skb+0xae/0x19c
> [   91.052760]  [<ffffffff81408605>] dev_queue_xmit+0xb/0xd
> [   91.053431]  [<ffffffff8146ac86>] arp_xmit+0x32/0x7e
> [   91.054069]  [<ffffffff8146ad0e>] arp_send_dst+0x3c/0x42
> [   91.054741]  [<ffffffff8146af8f>] arp_solicit+0x27b/0x28e
> [   91.055423]  [<ffffffff8140f08f>] neigh_probe+0x4a/0x5e
> [   91.056097]  [<ffffffff8141066f>] __neigh_event_send+0x1d0/0x21b
> [   91.056853]  [<ffffffff814106e5>] neigh_event_send+0x2b/0x2d
> [   91.057569]  [<ffffffff81411e45>] neigh_resolve_output+0x18/0x12e
> [   91.058341]  [<ffffffff814421e8>] ip_finish_output2+0x3c0/0x41c
> [   91.059087]  [<ffffffff81442a7b>] ip_finish_output+0x132/0x13e
> [   91.059820]  [<ffffffff81442aa8>] NF_HOOK_COND.constprop.43+0x21/0x8a
> [   91.060634]  [<ffffffff81434c61>] ? rcu_read_unlock+0x5d/0x5f
> [   91.061362]  [<ffffffff81434e96>] ? nf_hook_slow+0x94/0x9e
> [   91.062061]  [<ffffffff81443c19>] ip_output+0x65/0x6a
> [   91.062703]  [<ffffffff81441ae3>] dst_output+0x2b/0x30
> [   91.063350]  [<ffffffff8144355a>] ip_local_out+0x2a/0x31
> [   91.064025]  [<ffffffff813985f1>] vrf_xmit+0x1f6/0x417
> [   91.064675]  [<ffffffff81081976>] ? __lock_is_held+0x38/0x50
> [   91.065393]  [<ffffffff81407ba8>] dev_hard_start_xmit+0x154/0x337
> [   91.066170]  [<ffffffff81427f15>] sch_direct_xmit+0x98/0x16c
> [   91.066916]  [<ffffffff814082fc>] __dev_queue_xmit+0x453/0x751
> [   91.067663]  [<ffffffff81427011>] ? eth_header+0x27/0xaf
> [   91.068353]  [<ffffffff81408605>] dev_queue_xmit+0xb/0xd
> [   91.069031]  [<ffffffff81411f40>] neigh_resolve_output+0x113/0x12e
> [   91.069834]  [<ffffffff81397881>] dst_neigh_output.isra.20+0x13b/0x148
> [   91.070655]  [<ffffffff81397992>] vrf_finish_output+0x104/0x139
> [   91.071400]  [<ffffffff81397b5d>] vrf_output+0x5c/0xc1
> [   91.072055]  [<ffffffff81443525>] ? __ip_local_out+0x9e/0xa9
> [   91.072769]  [<ffffffff81441ae3>] dst_output+0x2b/0x30
> [   91.073419]  [<ffffffff8144355a>] ip_local_out+0x2a/0x31
> [   91.074093]  [<ffffffff814443cb>] ip_send_skb+0x14/0x38
> [   91.074756]  [<ffffffff8144441d>] ip_push_pending_frames+0x2e/0x31
> [   91.075533]  [<ffffffff814650ca>] raw_sendmsg+0x788/0x9d2
> [   91.076224]  [<ffffffff8101c65c>] ? paravirt_sched_clock+0x9/0xd
> [   91.076984]  [<ffffffff81030008>] ? native_cpu_up+0x214/0x7c1
> [   91.077710]  [<ffffffff81085cd9>] ? lock_release+0x20f/0x4c4
> [   91.078446]  [<ffffffff81472438>] inet_sendmsg+0x35/0x5c
> [   91.079135]  [<ffffffff813ed311>] sock_sendmsg_nosec+0x12/0x1d
> [   91.079873]  [<ffffffff813ee1c5>] ___sys_sendmsg+0x1b1/0x21f
> [   91.080607]  [<ffffffff81085cd9>] ? lock_release+0x20f/0x4c4
> [   91.081333]  [<ffffffff814f421b>] ? __mutex_unlock_slowpath+0x152/0x15f
> [   91.082191]  [<ffffffff814f4231>] ? mutex_unlock+0x9/0xb
> [   91.082872]  [<ffffffff81085cd9>] ? lock_release+0x20f/0x4c4
> [   91.083601]  [<ffffffff81173107>] ? __fget_light+0x48/0x6f
> [   91.084306]  [<ffffffff813ee4ea>] __sys_sendmsg+0x40/0x5e
> [   91.084995]  [<ffffffff813ee4ea>] ? __sys_sendmsg+0x40/0x5e
> [   91.085704]  [<ffffffff813ee51c>] SyS_sendmsg+0x14/0x16
> [   91.086371]  [<ffffffff814f69bc>] entry_SYSCALL_64_fastpath+0x1f/0xbd
> [   91.087206]  [<ffffffff81081420>] ? trace_hardirqs_off_caller+0xbc/0x122


For this one, it looks vrf misses the _xmit_lock lockdep support.

We might need to factorize the code found for example in
bond_set_lockdep_class_one()

Have you run lockdep before ? Strange that these issues were not
spotted earlier.
