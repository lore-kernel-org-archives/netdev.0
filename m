From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Thu, 22 Apr 2010 09:01:44 -0700
Message-ID: <20100422160144.GC2524@linux.vnet.ibm.com>
References: <20100419230136.GA16856@linux.vnet.ibm.com>
 <1271726729.2972.13.camel@dhcp231-113.rdu.redhat.com>
 <20100420030452.GB2905@linux.vnet.ibm.com>
 <4BCD646B.1080206@cn.fujitsu.com>
 <1271766716.2972.16.camel@dhcp231-113.rdu.redhat.com>
 <j2ya44ae5cd1004200545q6be4ec82o18ae99d93e8c29c7@mail.gmail.com>
 <20100420135227.GC2628@linux.vnet.ibm.com>
 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
 <20100421213543.GO2563@linux.vnet.ibm.com>
 <20100422145640.GB3228@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miles Lane <miles.lane@gmail.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>
To: Vivek Goyal <vgoyal@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:42405 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755322Ab0DVQCB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 12:02:01 -0400
Content-Disposition: inline
In-Reply-To: <20100422145640.GB3228@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 10:56:40AM -0400, Vivek Goyal wrote:
> On Wed, Apr 21, 2010 at 02:35:43PM -0700, Paul E. McKenney wrote:
> 
> [..]
> > > [    3.116754] [ INFO: suspicious rcu_dereference_check() usage. ]
> > > [    3.116754] ---------------------------------------------------
> > > [    3.116754] kernel/cgroup.c:4432 invoked rcu_dereference_check()
> > > without protection!
> > > [    3.116754]
> > > [    3.116754] other info that might help us debug this:
> > > [    3.116754]
> > > [    3.116754]
> > > [    3.116754] rcu_scheduler_active = 1, debug_locks = 1
> > > [    3.116754] 2 locks held by async/1/666:
> > > [    3.116754]  #0:  (&shost->scan_mutex){+.+.+.}, at:
> > > [<ffffffff812df0a0>] __scsi_add_device+0x83/0xe4
> > > [    3.116754]  #1:  (&(&blkcg->lock)->rlock){......}, at:
> > > [<ffffffff811f2e8d>] blkiocg_add_blkio_group+0x29/0x7f
> > > [    3.116754]
> > > [    3.116754] stack backtrace:
> > > [    3.116754] Pid: 666, comm: async/1 Not tainted 2.6.34-rc5 #18
> > > [    3.116754] Call Trace:
> > > [    3.116754]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d/0xa5
> > > [    3.116754]  [<ffffffff8107f9b1>] css_id+0x3f/0x51
> > > [    3.116754]  [<ffffffff811f2e9c>] blkiocg_add_blkio_group+0x38/0x7f
> > > [    3.116754]  [<ffffffff811f4e64>] cfq_init_queue+0xdf/0x2dc
> > > [    3.116754]  [<ffffffff811e3445>] elevator_init+0xba/0xf5
> > > [    3.116754]  [<ffffffff812dc02a>] ? scsi_request_fn+0x0/0x451
> > > [    3.116754]  [<ffffffff811e696b>] blk_init_queue_node+0x12f/0x135
> > > [    3.116754]  [<ffffffff811e697d>] blk_init_queue+0xc/0xe
> > > [    3.116754]  [<ffffffff812dc49c>] __scsi_alloc_queue+0x21/0x111
> > > [    3.116754]  [<ffffffff812dc5a4>] scsi_alloc_queue+0x18/0x64
> > > [    3.116754]  [<ffffffff812de5a0>] scsi_alloc_sdev+0x19e/0x256
> > > [    3.116754]  [<ffffffff812de73e>] scsi_probe_and_add_lun+0xe6/0x9c5
> > > [    3.116754]  [<ffffffff81068922>] ? trace_hardirqs_on_caller+0x114/0x13f
> > > [    3.116754]  [<ffffffff813ce0d6>] ? __mutex_lock_common+0x3e4/0x43a
> > > [    3.116754]  [<ffffffff812df0a0>] ? __scsi_add_device+0x83/0xe4
> > > [    3.116754]  [<ffffffff812d0a5c>] ? transport_setup_classdev+0x0/0x17
> > > [    3.116754]  [<ffffffff812df0a0>] ? __scsi_add_device+0x83/0xe4
> > > [    3.116754]  [<ffffffff812df0d5>] __scsi_add_device+0xb8/0xe4
> > > [    3.116754]  [<ffffffff812ea9c5>] ata_scsi_scan_host+0x74/0x16e
> > > [    3.116754]  [<ffffffff81057685>] ? autoremove_wake_function+0x0/0x34
> > > [    3.116754]  [<ffffffff812e8e64>] async_port_probe+0xab/0xb7
> > > [    3.116754]  [<ffffffff8105e1b5>] ? async_thread+0x0/0x1f4
> > > [    3.116754]  [<ffffffff8105e2ba>] async_thread+0x105/0x1f4
> > > [    3.116754]  [<ffffffff81033d79>] ? default_wake_function+0x0/0xf
> > > [    3.116754]  [<ffffffff8105e1b5>] ? async_thread+0x0/0x1f4
> > > [    3.116754]  [<ffffffff8105713e>] kthread+0x89/0x91
> > > [    3.116754]  [<ffffffff81068922>] ? trace_hardirqs_on_caller+0x114/0x13f
> > > [    3.116754]  [<ffffffff81003994>] kernel_thread_helper+0x4/0x10
> > > [    3.116754]  [<ffffffff813cfcc0>] ? restore_args+0x0/0x30
> > > [    3.116754]  [<ffffffff810570b5>] ? kthread+0x0/0x91
> > > [    3.116754]  [<ffffffff81003990>] ? kernel_thread_helper+0x0/0x10
> > 
> > I cannot convince myself that the above access is safe.  Vivek, Nauman,
> > thoughts?
> 
> Hi Paul,
> 
> blkiocg_add_blkio_group() is called from two paths.
> 
> First one is following. This path should be safe as it takes rcu read
> lock.
> 
> cfq_get_cfqg()
> 	rcu_read_lock()
> 	cfq_find_alloc_cfqg()
> 		blkiocg_add_blkio_group()
> 	rcu_read_unlock()
> 
> Second one is as shown in above backtrace.
> 
> cfq_init_queue()
> 	blkiocg_add_blkio_group().
> 
> This path is called at request queue and cfq initialization time and
> we access only root cgroup (root blkio_cgroup). As root cgroup can't
> go away, do we have to protect that call also using rcu_read_lock()?

You are correct, if the root cgroup cannot go away and if we only access
the root cgroup, then rcu_read_lock() is not required.

> So I guess it is not unsafe but propably we need to fix the warning, I
> should wrap second call to blkiocg_add_blkio_group() with
> rcu_read_lock/unlock pair?

That would work very well!

							Thanx, Paul
