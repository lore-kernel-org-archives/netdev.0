From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Wed, 28 Apr 2010 14:37:05 -0700
Message-ID: <20100428213705.GW2540@linux.vnet.ibm.com>
References: <20100420135227.GC2628@linux.vnet.ibm.com>
 <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
 <20100421213543.GO2563@linux.vnet.ibm.com>
 <20100422145640.GB3228@redhat.com>
 <20100422160144.GC2524@linux.vnet.ibm.com>
 <h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
 <20100423194255.GE2589@linux.vnet.ibm.com>
 <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
 <20100425023455.GM2440@linux.vnet.ibm.com>
 <p2ka44ae5cd1004281358n86ce29d2tbece16b2fb974dab@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <p2ka44ae5cd1004281358n86ce29d2tbece16b2fb974dab@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 28, 2010 at 04:58:54PM -0400, Miles Lane wrote:
> On Sat, Apr 24, 2010 at 10:34 PM, Paul E. McKenney <
> paulmck@linux.vnet.ibm.com> wrote:
> On Fri, Apr 23, 2010 at 06:59:12PM -0400, Miles Lane wrote:

[ . . . ]

> > commit 0868dd631def762ba00c2f0f397a53c5cdf24ae2
> > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Date:   Sat Apr 24 19:23:30 2010 -0700
> >
> >    block-cgroup: fix RCU-lockdep splat in blkiocg_add_blkio_group()
> >
> >    It is necessary to be in an RCU read-side critical section when invoking
> >    css_id(), so this patch adds one to blkiocg_add_blkio_group().  This is
> >    actually a false positive, because this is called at initialization
> > time,
> >    and hence always refers to the root cgroup, which cannot go away.
> >
> >    Located-by: Miles Lane <miles.lane@gmail.com>
> >    Suggested-by: Vivek Goyal <vgoyal@redhat.com>
> >    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >
> > diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> > index 5fe03de..55c8c73 100644
> > --- a/block/blk-cgroup.c
> > +++ b/block/blk-cgroup.c
> > @@ -71,7 +71,9 @@ void blkiocg_add_blkio_group(struct blkio_cgroup *blkcg,
> >
> >        spin_lock_irqsave(&blkcg->lock, flags);
> >        rcu_assign_pointer(blkg->key, key);
> > +       rcu_read_lock();
> >        blkg->blkcg_id = css_id(&blkcg->css);
> > +       rcu_read_unlock();
> >        hlist_add_head_rcu(&blkg->blkcg_node, &blkcg->blkg_list);
> >        spin_unlock_irqrestore(&blkcg->lock, flags);
> >  #ifdef CONFIG_DEBUG_BLK_CGROUP
> >
> 
> Hi Paul,
> Did this patch make it into your patch set?  Has your patch set gone into
> the Linus tree?
> I just tested 2.6.34-rc5-git8 and hit one of the issues again.  I think this
> patch is intended to correct this issue?

I replaced the above with an improved patch from Vivek Goyal, which has
not yet reached mainline.  I will resend my patch stack.

							Thanx, Paul

> [    2.289598] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    2.289604] ---------------------------------------------------
> [    2.289610] kernel/cgroup.c:4438 invoked rcu_dereference_check() without
> protection!
> [    2.289615]
> [    2.289617] other info that might help us debug this:
> [    2.289619]
> [    2.289624]
> [    2.289626] rcu_scheduler_active = 1, debug_locks = 1
> [    2.289632] 2 locks held by async/1/575:
> [    2.289637]  #0:  (&shost->scan_mutex){+.+.+.}, at: [<c121063d>]
> __scsi_add_device+0x5b/0xab
> [    2.289660]  #1:  (&(&blkcg->lock)->rlock){......}, at: [<c1143acb>]
> blkiocg_add_blkio_group+0x1a/0x73
> [    2.289678]
> [    2.289680] stack backtrace:
> [    2.289688] Pid: 575, comm: async/1 Not tainted 2.6.34-rc5-git8 #17
> [    2.289693] Call Trace:
> [    2.289704]  [<c12ee273>] ? printk+0xf/0x14
> [    2.289715]  [<c1050fbd>] lockdep_rcu_dereference+0x74/0x7d
> [    2.289725]  [<c106227d>] css_id+0x37/0x46
> [    2.289734]  [<c1143adc>] blkiocg_add_blkio_group+0x2b/0x73
> [    2.289744]  [<c1146a19>] cfq_init_queue+0xd6/0x2a3
> [    2.289755]  [<c120d657>] ? scsi_request_fn+0x0/0x3ea
> [    2.289764]  [<c113a316>] elevator_init+0xa1/0xd5
> [    2.289774]  [<c113bc3f>] blk_init_queue_node+0x103/0x109
> [    2.289783]  [<c113bc50>] blk_init_queue+0xb/0xd
> [    2.289792]  [<c120da58>] __scsi_alloc_queue+0x17/0xef
> [    2.289802]  [<c120db40>] scsi_alloc_queue+0x10/0x49
> [    2.289811]  [<c120f381>] scsi_alloc_sdev+0x14f/0x1ef
> [    2.289821]  [<c120f617>] scsi_probe_and_add_lun+0xb5/0x7ed
> [    2.289831]  [<c10517dc>] ? trace_hardirqs_on_caller+0x119/0x141
> [    2.289843]  [<c1210669>] __scsi_add_device+0x87/0xab
> [    2.289854]  [<c1232dfe>] ata_scsi_scan_host+0x64/0x136
> [    2.289865]  [<c12312c3>] async_port_probe+0x9e/0xa4
> [    2.289876]  [<c10479c8>] async_thread+0xf0/0x1d4
> [    2.289887]  [<c102b474>] ? default_wake_function+0x0/0xd
> [    2.289896]  [<c10478d8>] ? async_thread+0x0/0x1d4
> [    2.289906]  [<c1041a2a>] kthread+0x6a/0x6f
> [    2.289916]  [<c10419c0>] ? kthread+0x0/0x6f
> [    2.289926]  [<c1003742>] kernel_thread_helper+0x6/0x1a
> [    2.289934]
> [    2.289935] ===================================================
> [    2.289941] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    2.289946] ---------------------------------------------------
> [    2.289951] kernel/cgroup.c:1651 invoked rcu_dereference_check() without
> protection!
> [    2.289957]
> [    2.289958] other info that might help us debug this:
> [    2.289961]
> [    2.289966]
> [    2.289967] rcu_scheduler_active = 1, debug_locks = 1
> [    2.289973] 1 lock held by async/1/575:
> [    2.289978]  #0:  (&shost->scan_mutex){+.+.+.}, at: [<c121063d>]
> __scsi_add_device+0x5b/0xab
> [    2.289995]
> [    2.289996] stack backtrace:
> [    2.290003] Pid: 575, comm: async/1 Not tainted 2.6.34-rc5-git8 #17
> [    2.290008] Call Trace:
> [    2.290016]  [<c12ee273>] ? printk+0xf/0x14
> [    2.290025]  [<c1050fbd>] lockdep_rcu_dereference+0x74/0x7d
> [    2.290035]  [<c106423a>] cgroup_path+0x4a/0x110
> [    2.290045]  [<c1143b12>] blkiocg_add_blkio_group+0x61/0x73
> [    2.290055]  [<c1146a19>] cfq_init_queue+0xd6/0x2a3
> [    2.290065]  [<c120d657>] ? scsi_request_fn+0x0/0x3ea
> [    2.290074]  [<c113a316>] elevator_init+0xa1/0xd5
> [    2.290083]  [<c113bc3f>] blk_init_queue_node+0x103/0x109
> [    2.290093]  [<c113bc50>] blk_init_queue+0xb/0xd
> [    2.290102]  [<c120da58>] __scsi_alloc_queue+0x17/0xef
> [    2.290111]  [<c120db40>] scsi_alloc_queue+0x10/0x49
> [    2.290120]  [<c120f381>] scsi_alloc_sdev+0x14f/0x1ef
> [    2.290131]  [<c120f617>] scsi_probe_and_add_lun+0xb5/0x7ed
> [    2.290140]  [<c10517dc>] ? trace_hardirqs_on_caller+0x119/0x141
> [    2.290152]  [<c1210669>] __scsi_add_device+0x87/0xab
> [    2.290162]  [<c1232dfe>] ata_scsi_scan_host+0x64/0x136
> [    2.290172]  [<c12312c3>] async_port_probe+0x9e/0xa4
> [    2.290182]  [<c10479c8>] async_thread+0xf0/0x1d4
> [    2.290192]  [<c102b474>] ? default_wake_function+0x0/0xd
> [    2.290202]  [<c10478d8>] ? async_thread+0x0/0x1d4
> [    2.290211]  [<c1041a2a>] kthread+0x6a/0x6f
> [    2.290221]  [<c10419c0>] ? kthread+0x0/0x6f
> [    2.290230]  [<c1003742>] kernel_thread_helper+0x6/0x1a
