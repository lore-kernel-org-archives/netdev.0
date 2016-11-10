From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Long delays creating a netns after deleting one (possibly RCU related)
Date: Thu, 10 Nov 2016 09:37:47 -0800
Message-ID: <CAM_iQpUNRyv3wHi3cJpcH6avo+D7Gxwqp+iybUxYc7PCo3WUPw@mail.gmail.com>
References: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:34226 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964959AbcKJRiJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 12:38:09 -0500
In-Reply-To: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Cc'ing Paul)

On Wed, Nov 9, 2016 at 7:42 AM, Rolf Neugebauer
<rolf.neugebauer@docker.com> wrote:
> Hi
>
> We noticed some long delays starting docker containers on some newer
> kernels (starting with 4.5.x and still present in 4.9-rc4, 4.4.x is
> fine). We narrowed this down to the creation of a network namespace
> being delayed directly after removing another one (details and
> reproduction below). We have seen delays of up to 60s on some systems.
>
> - The delay is proportional to the number of CPUs (online or offline).
> We first discovered it with a Hyper-V Linux VM. Hyper-V advertises up
> to 240 offline vCPUs even if one configures the VM with only, say 2
> vCPUs. We see linear increase in delay when we change NR_CPUS in the
> kernel config.
>
> - The delay is also dependent on some tunnel network interfaces being
> present (which we had compiled in in one of our kernel configs).
>
> - We can reproduce this issue with stock kernels from
> http://kernel.ubuntu.com/~kernel-ppa/mainline/running in Hyper-V VMs
> as well as other hypervisors like qemu and hyperkit where we have good
> control over the number of CPUs.
>
> A simple test is:
> modprobe ipip
> moprobe  ip_gre
> modprobe ip_vti
> echo -n "add netns foo ===> "; /usr/bin/time -f "%E" ip netns add foo
> echo -n "del netns foo ===> "; /usr/bin/time -f "%E" ip netns delete foo
> echo -n "add netns bar ===> "; /usr/bin/time -f "%E" ip netns add bar
> echo -n "del netns bar ===> "; /usr/bin/time -f "%E" ip netns delete bar
>
> with an output like:
> add netns foo ===> 0:00.00
> del netns foo ===> 0:00.01
> add netns bar ===> 0:08.53
> del netns bar ===> 0:00.01
>
> This is on a 4.9-rc4 kernel from the above URL configured with
> NR_CPUS=256 running in a Hyper-V VM (kernel config attached).
>
> Below is a dump of the work queues while the second 'ip add netns' is
> hanging. The state of the work queues does not seem to change while
> the command is delayed and the pattern shown is consistent across
> different kernel versions.
>
> Is this a known issue and/or is someone working on a fix?

Not to me.


>
> [  610.356272] sysrq: SysRq : Show Blocked State
> [  610.356742]   task                        PC stack   pid father
> [  610.357252] kworker/u480:1  D    0  1994      2 0x00000000
> [  610.357752] Workqueue: netns cleanup_net
> [  610.358239]  ffff9892f1065800 0000000000000000 ffff9892ee1e1e00
> ffff9892f8e59340
> [  610.358705]  ffff9892f4526900 ffffbf0104b5ba88 ffffffffbe486df3
> ffffbf0104b5ba60
> [  610.359168]  00ffffffbdcbe663 ffff9892f8e59340 0000000100012e70
> ffff9892ee1e1e00
> [  610.359677] Call Trace:
> [  610.360169]  [<ffffffffbe486df3>] ? __schedule+0x233/0x6e0
> [  610.360723]  [<ffffffffbe4872d6>] schedule+0x36/0x80
> [  610.361194]  [<ffffffffbe48a9ca>] schedule_timeout+0x22a/0x3f0
> [  610.361789]  [<ffffffffbe486dfb>] ? __schedule+0x23b/0x6e0
> [  610.362260]  [<ffffffffbe487d24>] wait_for_completion+0xb4/0x140
> [  610.362736]  [<ffffffffbdcb05a0>] ? wake_up_q+0x80/0x80
> [  610.363306]  [<ffffffffbdceb528>] __wait_rcu_gp+0xc8/0xf0
> [  610.363782]  [<ffffffffbdceea5c>] synchronize_sched+0x5c/0x80
> [  610.364137]  [<ffffffffbdcf0010>] ? call_rcu_bh+0x20/0x20
> [  610.364742]  [<ffffffffbdceb440>] ?
> trace_raw_output_rcu_utilization+0x60/0x60
> [  610.365337]  [<ffffffffbe3696bc>] synchronize_net+0x1c/0x30

This is a worker which holds the net_mutex and is waiting for
a RCU grace period to elapse.


> [  610.365846]  [<ffffffffbe369803>] netif_napi_del+0x23/0x80
> [  610.367494]  [<ffffffffc057f6f8>] ip_tunnel_dev_free+0x68/0xf0 [ip_tunnel]
> [  610.368007]  [<ffffffffbe372c10>] netdev_run_todo+0x230/0x330
> [  610.368454]  [<ffffffffbe37eb4e>] rtnl_unlock+0xe/0x10
> [  610.369001]  [<ffffffffc057f4df>] ip_tunnel_delete_net+0xdf/0x120 [ip_tunnel]
> [  610.369500]  [<ffffffffc058b92c>] ipip_exit_net+0x2c/0x30 [ipip]
> [  610.369997]  [<ffffffffbe362688>] ops_exit_list.isra.4+0x38/0x60
> [  610.370636]  [<ffffffffbe363674>] cleanup_net+0x1c4/0x2b0
> [  610.371130]  [<ffffffffbdc9e4ac>] process_one_work+0x1fc/0x4b0
> [  610.371812]  [<ffffffffbdc9e7ab>] worker_thread+0x4b/0x500
> [  610.373074]  [<ffffffffbdc9e760>] ? process_one_work+0x4b0/0x4b0
> [  610.373622]  [<ffffffffbdc9e760>] ? process_one_work+0x4b0/0x4b0
> [  610.374100]  [<ffffffffbdca4b09>] kthread+0xd9/0xf0
> [  610.374574]  [<ffffffffbdca4a30>] ? kthread_park+0x60/0x60
> [  610.375198]  [<ffffffffbe48c2b5>] ret_from_fork+0x25/0x30
> [  610.375678] ip              D    0  2149   2148 0x00000000
> [  610.376185]  ffff9892f0a99000 0000000000000000 ffff9892f0a66900
> [  610.376185]  ffff9892f8e59340
> [  610.376185]  ffff9892f4526900 ffffbf0101173db8 ffffffffbe486df3
> [  610.376753]  00000005fecffd76
> [  610.376762]  00ff9892f11d9820 ffff9892f8e59340 ffff989200000000
> ffff9892f0a66900
> [  610.377274] Call Trace:
> [  610.377789]  [<ffffffffbe486df3>] ? __schedule+0x233/0x6e0
> [  610.378306]  [<ffffffffbe4872d6>] schedule+0x36/0x80
> [  610.378992]  [<ffffffffbe48756e>] schedule_preempt_disabled+0xe/0x10
> [  610.379514]  [<ffffffffbe489199>] __mutex_lock_slowpath+0xb9/0x130
> [  610.380031]  [<ffffffffbde0fce2>] ? __kmalloc+0x162/0x1e0
> [  610.380556]  [<ffffffffbe48922f>] mutex_lock+0x1f/0x30
> [  610.381135]  [<ffffffffbe3637ff>] copy_net_ns+0x9f/0x170
> [  610.381647]  [<ffffffffbdca5e6b>] create_new_namespaces+0x11b/0x200
> [  610.382249]  [<ffffffffbdca60fa>] unshare_nsproxy_namespaces+0x5a/0xb0
> [  610.382818]  [<ffffffffbdc82dcd>] SyS_unshare+0x1cd/0x360
> [  610.383319]  [<ffffffffbe48c03b>] entry_SYSCALL_64_fastpath+0x1e/0xad

This process is apparently waiting for the net_mutex held by the previous one.

Either RCU implementation is broken or something else is missing.
Do you have more stack traces of related processes? For example,
rcu_tasks_kthread. And if anything you can help to narrow down the problem,
it would be great.

Thanks.
