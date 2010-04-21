From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Wed, 21 Apr 2010 14:35:43 -0700
Message-ID: <20100421213543.GO2563@linux.vnet.ibm.com>
References: <1271242058.32749.19.camel@laptop>
 <1271701612.2972.5.camel@dhcp231-113.rdu.redhat.com>
 <20100419230136.GA16856@linux.vnet.ibm.com>
 <1271726729.2972.13.camel@dhcp231-113.rdu.redhat.com>
 <20100420030452.GB2905@linux.vnet.ibm.com>
 <4BCD646B.1080206@cn.fujitsu.com>
 <1271766716.2972.16.camel@dhcp231-113.rdu.redhat.com>
 <j2ya44ae5cd1004200545q6be4ec82o18ae99d93e8c29c7@mail.gmail.com>
 <20100420135227.GC2628@linux.vnet.ibm.com>
 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, vgoyal@redhat.com,
	nauman@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 20, 2010 at 11:38:28AM -0400, Miles Lane wrote:
> Excellent.  Here are the results on my machine.  .config appended.

First, thank you very much for testing this, Miles!

> [    0.177300] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    0.177428] ---------------------------------------------------
> [    0.177557] include/linux/cgroup.h:533 invoked
> rcu_dereference_check() without protection!
> [    0.177760]
> [    0.177761] other info that might help us debug this:
> [    0.177762]
> [    0.178123]
> [    0.178124] rcu_scheduler_active = 1, debug_locks = 1
> [    0.178369] no locks held by watchdog/0/5.
> [    0.178493]
> [    0.178494] stack backtrace:
> [    0.178735] Pid: 5, comm: watchdog/0 Not tainted 2.6.34-rc5 #18
> [    0.178863] Call Trace:
> [    0.178994]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d/0xa5
> [    0.179127]  [<ffffffff8102d667>] task_subsys_state+0x48/0x60
> [    0.179259]  [<ffffffff810328e5>] __sched_setscheduler+0x19d/0x300
> [    0.179392]  [<ffffffff8102b477>] ? need_resched+0x1e/0x28
> [    0.179523]  [<ffffffff813cd501>] ? schedule+0x643/0x66e
> [    0.179653]  [<ffffffff81091903>] ? watchdog+0x0/0x8c
> [    0.179783]  [<ffffffff81032a63>] sched_setscheduler+0xe/0x10
> [    0.179913]  [<ffffffff8109192d>] watchdog+0x2a/0x8c
> [    0.180010]  [<ffffffff81091903>] ? watchdog+0x0/0x8c
> [    0.180142]  [<ffffffff8105713e>] kthread+0x89/0x91
> [    0.180272]  [<ffffffff81068922>] ? trace_hardirqs_on_caller+0x114/0x13f
> [    0.180405]  [<ffffffff81003994>] kernel_thread_helper+0x4/0x10
> [    0.180537]  [<ffffffff813cfcc0>] ? restore_args+0x0/0x30
> [    0.180667]  [<ffffffff810570b5>] ? kthread+0x0/0x91
> [    0.180796]  [<ffffffff81003990>] ? kernel_thread_helper+0x0/0x10

I have a prototype patch for this way down below, but someone who knows
more about CONFIG_RT_GROUP_SCHED than I do should look it over.  In the
meantime, could you please see if it helps?

> [    3.116754] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    3.116754] ---------------------------------------------------
> [    3.116754] kernel/cgroup.c:4432 invoked rcu_dereference_check()
> without protection!
> [    3.116754]
> [    3.116754] other info that might help us debug this:
> [    3.116754]
> [    3.116754]
> [    3.116754] rcu_scheduler_active = 1, debug_locks = 1
> [    3.116754] 2 locks held by async/1/666:
> [    3.116754]  #0:  (&shost->scan_mutex){+.+.+.}, at:
> [<ffffffff812df0a0>] __scsi_add_device+0x83/0xe4
> [    3.116754]  #1:  (&(&blkcg->lock)->rlock){......}, at:
> [<ffffffff811f2e8d>] blkiocg_add_blkio_group+0x29/0x7f
> [    3.116754]
> [    3.116754] stack backtrace:
> [    3.116754] Pid: 666, comm: async/1 Not tainted 2.6.34-rc5 #18
> [    3.116754] Call Trace:
> [    3.116754]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d/0xa5
> [    3.116754]  [<ffffffff8107f9b1>] css_id+0x3f/0x51
> [    3.116754]  [<ffffffff811f2e9c>] blkiocg_add_blkio_group+0x38/0x7f
> [    3.116754]  [<ffffffff811f4e64>] cfq_init_queue+0xdf/0x2dc
> [    3.116754]  [<ffffffff811e3445>] elevator_init+0xba/0xf5
> [    3.116754]  [<ffffffff812dc02a>] ? scsi_request_fn+0x0/0x451
> [    3.116754]  [<ffffffff811e696b>] blk_init_queue_node+0x12f/0x135
> [    3.116754]  [<ffffffff811e697d>] blk_init_queue+0xc/0xe
> [    3.116754]  [<ffffffff812dc49c>] __scsi_alloc_queue+0x21/0x111
> [    3.116754]  [<ffffffff812dc5a4>] scsi_alloc_queue+0x18/0x64
> [    3.116754]  [<ffffffff812de5a0>] scsi_alloc_sdev+0x19e/0x256
> [    3.116754]  [<ffffffff812de73e>] scsi_probe_and_add_lun+0xe6/0x9c5
> [    3.116754]  [<ffffffff81068922>] ? trace_hardirqs_on_caller+0x114/0x13f
> [    3.116754]  [<ffffffff813ce0d6>] ? __mutex_lock_common+0x3e4/0x43a
> [    3.116754]  [<ffffffff812df0a0>] ? __scsi_add_device+0x83/0xe4
> [    3.116754]  [<ffffffff812d0a5c>] ? transport_setup_classdev+0x0/0x17
> [    3.116754]  [<ffffffff812df0a0>] ? __scsi_add_device+0x83/0xe4
> [    3.116754]  [<ffffffff812df0d5>] __scsi_add_device+0xb8/0xe4
> [    3.116754]  [<ffffffff812ea9c5>] ata_scsi_scan_host+0x74/0x16e
> [    3.116754]  [<ffffffff81057685>] ? autoremove_wake_function+0x0/0x34
> [    3.116754]  [<ffffffff812e8e64>] async_port_probe+0xab/0xb7
> [    3.116754]  [<ffffffff8105e1b5>] ? async_thread+0x0/0x1f4
> [    3.116754]  [<ffffffff8105e2ba>] async_thread+0x105/0x1f4
> [    3.116754]  [<ffffffff81033d79>] ? default_wake_function+0x0/0xf
> [    3.116754]  [<ffffffff8105e1b5>] ? async_thread+0x0/0x1f4
> [    3.116754]  [<ffffffff8105713e>] kthread+0x89/0x91
> [    3.116754]  [<ffffffff81068922>] ? trace_hardirqs_on_caller+0x114/0x13f
> [    3.116754]  [<ffffffff81003994>] kernel_thread_helper+0x4/0x10
> [    3.116754]  [<ffffffff813cfcc0>] ? restore_args+0x0/0x30
> [    3.116754]  [<ffffffff810570b5>] ? kthread+0x0/0x91
> [    3.116754]  [<ffffffff81003990>] ? kernel_thread_helper+0x0/0x10

I cannot convince myself that the above access is safe.  Vivek, Nauman,
thoughts?

> [   33.425087] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   33.425090] ---------------------------------------------------
> [   33.425094] net/core/dev.c:1993 invoked rcu_dereference_check()
> without protection!
> [   33.425098]
> [   33.425098] other info that might help us debug this:
> [   33.425100]
> [   33.425103]
> [   33.425104] rcu_scheduler_active = 1, debug_locks = 1
> [   33.425108] 2 locks held by canberra-gtk-pl/4208:
> [   33.425111]  #0:  (sk_lock-AF_INET){+.+.+.}, at:
> [<ffffffff81394ffd>] inet_stream_connect+0x3a/0x24d
> [   33.425125]  #1:  (rcu_read_lock_bh){.+....}, at:
> [<ffffffff8134a809>] dev_queue_xmit+0x14e/0x4b8
> [   33.425137]
> [   33.425138] stack backtrace:
> [   33.425142] Pid: 4208, comm: canberra-gtk-pl Not tainted 2.6.34-rc5 #18
> [   33.425146] Call Trace:
> [   33.425154]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d/0xa5
> [   33.425161]  [<ffffffff8134a914>] dev_queue_xmit+0x259/0x4b8
> [   33.425167]  [<ffffffff8134a809>] ? dev_queue_xmit+0x14e/0x4b8
> [   33.425173]  [<ffffffff81041c52>] ? _local_bh_enable_ip+0xcd/0xda
> [   33.425180]  [<ffffffff8135375a>] neigh_resolve_output+0x234/0x285
> [   33.425188]  [<ffffffff8136f71f>] ip_finish_output2+0x257/0x28c
> [   33.425193]  [<ffffffff8136f7bc>] ip_finish_output+0x68/0x6a
> [   33.425198]  [<ffffffff813704b3>] T.866+0x52/0x59
> [   33.425203]  [<ffffffff813706fe>] ip_output+0xaa/0xb4
> [   33.425209]  [<ffffffff8136ebb8>] ip_local_out+0x20/0x24
> [   33.425215]  [<ffffffff8136f204>] ip_queue_xmit+0x309/0x368
> [   33.425223]  [<ffffffff810e41e6>] ? __kmalloc_track_caller+0x111/0x155
> [   33.425230]  [<ffffffff813831ef>] ? tcp_connect+0x223/0x3d3
> [   33.425236]  [<ffffffff81381971>] tcp_transmit_skb+0x707/0x745
> [   33.425243]  [<ffffffff81383342>] tcp_connect+0x376/0x3d3
> [   33.425250]  [<ffffffff81268ac3>] ? secure_tcp_sequence_number+0x55/0x6f
> [   33.425256]  [<ffffffff813872f0>] tcp_v4_connect+0x3df/0x455
> [   33.425263]  [<ffffffff8133cbd9>] ? lock_sock_nested+0xf3/0x102
> [   33.425269]  [<ffffffff81395067>] inet_stream_connect+0xa4/0x24d
> [   33.425276]  [<ffffffff8133b418>] sys_connect+0x90/0xd0
> [   33.425283]  [<ffffffff81002b9c>] ? sysret_check+0x27/0x62
> [   33.425289]  [<ffffffff81068922>] ? trace_hardirqs_on_caller+0x114/0x13f
> [   33.425296]  [<ffffffff813ced00>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [   33.425303]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b

This looks like an rcu_dereference() needs to instead be
rcu_dereference_bh(), but the line numbering in my version of
net/core/dev.c does not match yours.  CCing netdev, hopefully
someone there will know which rcu_dereference() is indicated.

> [   52.869375] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   52.869378] ---------------------------------------------------
> [   52.869382] net/mac80211/sta_info.c:886 invoked
> rcu_dereference_check() without protection!
> [   52.869386]
> [   52.869387] other info that might help us debug this:
> [   52.869389]
> [   52.869392]
> [   52.869392] rcu_scheduler_active = 1, debug_locks = 1
> [   52.869397] 1 lock held by Xorg/4051:
> [   52.869399]  #0:  (&dev->struct_mutex){+.+.+.}, at:
> [<ffffffff812afdc4>] i915_gem_do_execbuffer+0xf4c/0xfda
> [   52.869414]
> [   52.869415] stack backtrace:
> [   52.869420] Pid: 4051, comm: Xorg Not tainted 2.6.34-rc5 #18
> [   52.869423] Call Trace:
> [   52.869426]  <IRQ>  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d/0xa5
> [   52.869454]  [<ffffffffa01289ae>]
> ieee80211_find_sta_by_hw+0x46/0x10f [mac80211]
> [   52.869467]  [<ffffffffa0128a8e>] ieee80211_find_sta+0x17/0x19 [mac80211]
> [   52.869483]  [<ffffffffa017a0f2>] iwl_tx_queue_reclaim+0xdb/0x1b1 [iwlcore]
> [   52.869490]  [<ffffffff8106842f>] ? mark_lock+0x2d/0x235
> [   52.869501]  [<ffffffffa01a2f1c>] iwl5000_rx_reply_tx+0x4a9/0x556 [iwlagn]
> [   52.869508]  [<ffffffff8120a3d3>] ? is_swiotlb_buffer+0x2e/0x3b
> [   52.869518]  [<ffffffffa019bbf4>] iwl_rx_handle+0x163/0x2b5 [iwlagn]
> [   52.869524]  [<ffffffff81068908>] ? trace_hardirqs_on_caller+0xfa/0x13f
> [   52.869534]  [<ffffffffa019c3ac>] iwl_irq_tasklet+0x2bb/0x3c0 [iwlagn]
> [   52.869540]  [<ffffffff810411df>] tasklet_action+0xa7/0x10f
> [   52.869546]  [<ffffffff810421f1>] __do_softirq+0x144/0x252
> [   52.869553]  [<ffffffff81003a8c>] call_softirq+0x1c/0x34
> [   52.869559]  [<ffffffff810050e4>] do_softirq+0x38/0x80
> [   52.869564]  [<ffffffff81041cbe>] irq_exit+0x45/0x94
> [   52.869569]  [<ffffffff81004829>] do_IRQ+0xad/0xc4
> [   52.869576]  [<ffffffff813cfc13>] ret_from_intr+0x0/0xf
> [   52.869580]  <EOI>  [<ffffffff81068765>] ? lockdep_trace_alloc+0xbe/0xc2
> [   52.869592]  [<ffffffff810bca55>] __alloc_pages_nodemask+0x8f/0x6a5
> [   52.869598]  [<ffffffff810b70f5>] ? rcu_read_lock+0x0/0x35
> [   52.869604]  [<ffffffff810b70f5>] ? rcu_read_lock+0x0/0x35
> [   52.869610]  [<ffffffff810c33cb>] ? kmap_atomic+0x16/0x4b
> [   52.869615]  [<ffffffff810b71ad>] ? rcu_read_unlock+0x21/0x23
> [   52.869621]  [<ffffffff810b6c3c>] __page_cache_alloc+0x14/0x16
> [   52.869627]  [<ffffffff810b836d>] do_read_cache_page+0x43/0x121
> [   52.869632]  [<ffffffff810c54bd>] ? shmem_readpage+0x0/0x3c
> [   52.869638]  [<ffffffff810b8464>] read_cache_page_gfp+0x19/0x23
> [   52.869644]  [<ffffffff812aac10>] i915_gem_object_get_pages+0xa1/0x115
> [   52.869651]  [<ffffffff812ad23e>] i915_gem_object_bind_to_gtt+0x16d/0x2ce
> [   52.869657]  [<ffffffff812ad3c6>] i915_gem_object_pin+0x27/0x88
> [   52.869663]  [<ffffffff812af316>] i915_gem_do_execbuffer+0x49e/0xfda
> [   52.869670]  [<ffffffff810cbb93>] ? might_fault+0x63/0xb3
> [   52.869676]  [<ffffffff810cbbdc>] ? might_fault+0xac/0xb3
> [   52.869681]  [<ffffffff810cbb93>] ? might_fault+0x63/0xb3
> [   52.869687]  [<ffffffff812b010d>] i915_gem_execbuffer+0x192/0x221
> [   52.869694]  [<ffffffff812900d0>] drm_ioctl+0x25a/0x36e
> [   52.869700]  [<ffffffff812aff7b>] ? i915_gem_execbuffer+0x0/0x221
> [   52.869707]  [<ffffffff810e9ad1>] ? do_sync_read+0xc6/0x103
> [   52.869714]  [<ffffffff810f6dcd>] vfs_ioctl+0x2d/0xa1
> [   52.869720]  [<ffffffff810f7343>] do_vfs_ioctl+0x48b/0x4d1
> [   52.869726]  [<ffffffff810f73da>] sys_ioctl+0x51/0x74
> [   52.869733]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b

This one looks to be an update-side reference protected by dev->struct_mutex,
but there is no obvious way to get that information to the pair
of rcu_dereference() calls in for_each_sta_info().  Besides which,
I am not 100% certain that this one is really only a false positive.
Especially given that the next one looks similar, but uses a different
lock.

Eric, and enlightenment?

> [   52.884563] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   52.884566] ---------------------------------------------------
> [   52.884571] net/mac80211/sta_info.c:886 invoked
> rcu_dereference_check() without protection!
> [   52.884574]
> [   52.884575] other info that might help us debug this:
> [   52.884577]
> [   52.884580]
> [   52.884581] rcu_scheduler_active = 1, debug_locks = 1
> [   52.884585] 1 lock held by rsyslogd/3854:
> [   52.884588]  #0:  (&sb->s_type->i_mutex_key#10){+.+.+.}, at:
> [<ffffffff810b7f97>] generic_file_aio_write+0x47/0xa8
> [   52.884604]
> [   52.884605] stack backtrace:
> [   52.884610] Pid: 3854, comm: rsyslogd Not tainted 2.6.34-rc5 #18
> [   52.884613] Call Trace:
> [   52.884617]  <IRQ>  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d/0xa5
> [   52.884645]  [<ffffffffa01289fe>]
> ieee80211_find_sta_by_hw+0x96/0x10f [mac80211]
> [   52.884658]  [<ffffffffa0128a8e>] ieee80211_find_sta+0x17/0x19 [mac80211]
> [   52.884675]  [<ffffffffa017a0f2>] iwl_tx_queue_reclaim+0xdb/0x1b1 [iwlcore]
> [   52.884681]  [<ffffffff8106842f>] ? mark_lock+0x2d/0x235
> [   52.884693]  [<ffffffffa01a2f1c>] iwl5000_rx_reply_tx+0x4a9/0x556 [iwlagn]
> [   52.884701]  [<ffffffff8120a3d3>] ? is_swiotlb_buffer+0x2e/0x3b
> [   52.884710]  [<ffffffffa019bbf4>] iwl_rx_handle+0x163/0x2b5 [iwlagn]
> [   52.884717]  [<ffffffff81068908>] ? trace_hardirqs_on_caller+0xfa/0x13f
> [   52.884726]  [<ffffffffa019c3ac>] iwl_irq_tasklet+0x2bb/0x3c0 [iwlagn]
> [   52.884733]  [<ffffffff810411df>] tasklet_action+0xa7/0x10f
> [   52.884739]  [<ffffffff810421f1>] __do_softirq+0x144/0x252
> [   52.884746]  [<ffffffff81003a8c>] call_softirq+0x1c/0x34
> [   52.884752]  [<ffffffff810050e4>] do_softirq+0x38/0x80
> [   52.884757]  [<ffffffff81041cbe>] irq_exit+0x45/0x94
> [   52.884762]  [<ffffffff81004829>] do_IRQ+0xad/0xc4
> [   52.884769]  [<ffffffff813cfc13>] ret_from_intr+0x0/0xf
> [   52.884773]  <EOI>  [<ffffffff810e3509>] ? kmem_cache_free+0xb0/0x134
> [   52.884789]  [<ffffffff811913dc>] ? jbd2_journal_stop+0x32c/0x33e
> [   52.884796]  [<ffffffff811913dc>] jbd2_journal_stop+0x32c/0x33e
> [   52.884804]  [<ffffffff8115e689>] ? ext4_dirty_inode+0x40/0x45
> [   52.884811]  [<ffffffff81105fdb>] ? __mark_inode_dirty+0x2f/0x12e
> [   52.884819]  [<ffffffff81170a65>] __ext4_journal_stop+0x6f/0x75
> [   52.884825]  [<ffffffff81162949>] ext4_da_write_end+0x25c/0x2fc
> [   52.884833]  [<ffffffff810b6b2e>] generic_file_buffered_write+0x161/0x25b
> [   52.884840]  [<ffffffff810b7f1b>] __generic_file_aio_write+0x24a/0x27f
> [   52.884845]  [<ffffffff810b7f97>] ? generic_file_aio_write+0x47/0xa8
> [   52.884852]  [<ffffffff810b7faa>] generic_file_aio_write+0x5a/0xa8
> [   52.884858]  [<ffffffff8115ab2a>] ext4_file_write+0x8c/0x96
> [   52.884864]  [<ffffffff810e99ce>] do_sync_write+0xc6/0x103
> [   52.884871]  [<ffffffff810eac6d>] ? rcu_read_lock+0x0/0x35
> [   52.884878]  [<ffffffff811c17db>] ? selinux_file_permission+0x57/0xaf
> [   52.884885]  [<ffffffff811bb085>] ? security_file_permission+0x11/0x13
> [   52.884893]  [<ffffffff810e9f33>] vfs_write+0xa9/0x106
> [   52.884898]  [<ffffffff810ea046>] sys_write+0x45/0x69
> [   52.884905]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b

Ditto!

> [   85.939528] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   85.939531] ---------------------------------------------------
> [   85.939535] include/net/inet_timewait_sock.h:227 invoked
> rcu_dereference_check() without protection!
> [   85.939539]
> [   85.939540] other info that might help us debug this:
> [   85.939541]
> [   85.939544]
> [   85.939545] rcu_scheduler_active = 1, debug_locks = 1
> [   85.939549] 2 locks held by gwibber-service/4798:
> [   85.939552]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff811034b2>]
> seq_read+0x37/0x381
> [   85.939566]  #1:  (&(&hashinfo->ehash_locks[i])->rlock){+.-...},
> at: [<ffffffff81386355>] established_get_next+0xc4/0x132
> [   85.939579]
> [   85.939580] stack backtrace:
> [   85.939585] Pid: 4798, comm: gwibber-service Not tainted 2.6.34-rc5 #18
> [   85.939588] Call Trace:
> [   85.939598]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d/0xa5
> [   85.939604]  [<ffffffff81385018>] twsk_net+0x4f/0x57
> [   85.939610]  [<ffffffff813862e5>] established_get_next+0x54/0x132
> [   85.939615]  [<ffffffff813864c7>] tcp_seq_next+0x5d/0x6a
> [   85.939621]  [<ffffffff81103701>] seq_read+0x286/0x381
> [   85.939627]  [<ffffffff8110347b>] ? seq_read+0x0/0x381
> [   85.939633]  [<ffffffff81133240>] proc_reg_read+0x8d/0xac
> [   85.939640]  [<ffffffff810ea110>] vfs_read+0xa6/0x103
> [   85.939645]  [<ffffffff810ea223>] sys_read+0x45/0x69
> [   85.939652]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b

This one appears to be a case of missing rcu_read_lock(), but it is
not clear to me at what level it needs to go.

Eric, any enlightenment on this one and the next one?

> [   87.296366] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   87.296369] ---------------------------------------------------
> [   87.296373] include/net/inet_timewait_sock.h:227 invoked
> rcu_dereference_check() without protection!
> [   87.296377]
> [   87.296377] other info that might help us debug this:
> [   87.296379]
> [   87.296382]
> [   87.296383] rcu_scheduler_active = 1, debug_locks = 1
> [   87.296386] no locks held by gwibber-service/4803.
> [   87.296389]
> [   87.296390] stack backtrace:
> [   87.296395] Pid: 4803, comm: gwibber-service Not tainted 2.6.34-rc5 #18
> [   87.296398] Call Trace:
> [   87.296411]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d/0xa5
> [   87.296419]  [<ffffffff813733d3>] twsk_net+0x4f/0x57
> [   87.296424]  [<ffffffff813737f3>] __inet_twsk_hashdance+0x50/0x158
> [   87.296431]  [<ffffffff81389239>] tcp_time_wait+0x1c1/0x24b
> [   87.296437]  [<ffffffff8137c417>] tcp_fin+0x83/0x162
> [   87.296443]  [<ffffffff8137cda7>] tcp_data_queue+0x1ff/0xa1e
> [   87.296450]  [<ffffffff810495c6>] ? mod_timer+0x1e/0x20
> [   87.296456]  [<ffffffff813809e3>] tcp_rcv_state_process+0x89d/0x8f2
> [   87.296463]  [<ffffffff8133ca0b>] ? release_sock+0x30/0x10b
> [   87.296468]  [<ffffffff81386df2>] tcp_v4_do_rcv+0x2de/0x33f
> [   87.296475]  [<ffffffff8133ca5d>] release_sock+0x82/0x10b
> [   87.296481]  [<ffffffff81376ef5>] tcp_close+0x1b5/0x37e
> [   87.296487]  [<ffffffff81395437>] inet_release+0x50/0x57
> [   87.296493]  [<ffffffff8133a134>] sock_release+0x1a/0x66
> [   87.296498]  [<ffffffff8133a1a2>] sock_close+0x22/0x26
> [   87.296505]  [<ffffffff810eb003>] __fput+0x120/0x1cd
> [   87.296510]  [<ffffffff810eb0c5>] fput+0x15/0x17
> [   87.296516]  [<ffffffff810e7f3d>] filp_close+0x63/0x6d
> [   87.296521]  [<ffffffff810e801e>] sys_close+0xd7/0x111
> [   87.296528]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b

commit d3b8ba1bde9afb7d50cf0712f9d95317ea66c06f
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Wed Apr 21 14:04:56 2010 -0700

    sched: protect __sched_setscheduler() access to cgroups
    
    A given task's cgroups structures must remain while that task is running
    due to reference counting, so this is presumably a false positive.
    
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/sched.c b/kernel/sched.c
index 14c44ec..1d43c1a 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4575,9 +4575,11 @@ recheck:
 		 * Do not allow realtime tasks into groups that have no runtime
 		 * assigned.
 		 */
+		rcu_read_lock();
 		if (rt_bandwidth_enabled() && rt_policy(policy) &&
 				task_group(p)->rt_bandwidth.rt_runtime == 0)
 			return -EPERM;
+		rcu_read_unlock();
 #endif
 
 		retval = security_task_setscheduler(p, policy, param);
