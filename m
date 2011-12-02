From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Fri, 2 Dec 2011 18:04:12 -0500
Message-ID: <20111202230412.GB12057@homer.localdomain>
References: <1321836285.30341.554.camel@debian>
 <20111121080554.GB1625@x4.trippels.de>
 <20111121082445.GD1625@x4.trippels.de>
 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121153621.GA1678@x4.trippels.de>
 <20111123160353.GA1673@x4.trippels.de>
 <alpine.DEB.2.00.1111231004490.17317@router.home>
 <20111124085040.GA1677@x4.trippels.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6c2NcOVqGQ03X4Wi"
Cc: Christoph Lameter <cl@linux.com>, "Alex, Shi" <alex.shi@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	dri-devel@lists.freedesktop.org, Pekka Enberg <penberg@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Matt Mackall <mpm@selenic.com>, tj@kernel.org,
	Alex Deucher <alexander.deucher@amd.com>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20111124085040.GA1677@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 24, 2011 at 09:50:40AM +0100, Markus Trippelsdorf wrote:
> On 2011.11.23 at 10:06 -0600, Christoph Lameter wrote:
> > On Wed, 23 Nov 2011, Markus Trippelsdorf wrote:
> > 
> > > > FIX idr_layer_cache: Marking all objects used
> > >
> > > Yesterday I couldn't reproduce the issue at all. But today I've hit
> > > exactly the same spot again. (CCing the drm list)
> > 
> > Well this is looks like write after free.
> > 
> > > =============================================================================
> > > BUG idr_layer_cache: Poison overwritten
> > > -----------------------------------------------------------------------------
> > > Object ffff8802156487c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > Object ffff8802156487d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > Object ffff8802156487e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > Object ffff8802156487f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > > Object ffff880215648800: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
> > > Object ffff880215648810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > 
> > And its an integer sized write of 0. If you look at the struct definition
> > and lookup the offset you should be able to locate the field that
> > was modified.
> 
> Here are two more BUGs that seem to point to the same bug:
> 
> 1)
> ...
> Nov 21 18:30:30 x4 kernel: [drm] radeon: irq initialized.
> Nov 21 18:30:30 x4 kernel: [drm] GART: num cpu pages 131072, num gpu pages 131072
> Nov 21 18:30:30 x4 kernel: [drm] Loading RS780 Microcode
> Nov 21 18:30:30 x4 kernel: [drm] PCIE GART of 512M enabled (table at 0x00000000C0040000).
> Nov 21 18:30:30 x4 kernel: radeon 0000:01:05.0: WB enabled
> Nov 21 18:30:30 x4 kernel: =============================================================================
> Nov 21 18:30:30 x4 kernel: BUG task_xstate: Not a valid slab page
> Nov 21 18:30:30 x4 kernel: -----------------------------------------------------------------------------
> Nov 21 18:30:30 x4 kernel:
> Nov 21 18:30:30 x4 kernel: INFO: Slab 0xffffea0000044300 objects=32767 used=65535 fp=0x          (null) flags=0x0401
> Nov 21 18:30:30 x4 kernel: Pid: 9, comm: ksoftirqd/1 Not tainted 3.2.0-rc2-00274-g6fe4c6d-dirty #75
> Nov 21 18:30:30 x4 kernel: Call Trace:
> Nov 21 18:30:30 x4 kernel: [<ffffffff81101c1d>] slab_err+0x7d/0x90
> Nov 21 18:30:30 x4 kernel: [<ffffffff8103e29f>] ? dump_trace+0x16f/0x2e0
> Nov 21 18:30:30 x4 kernel: [<ffffffff81044764>] ? free_thread_xstate+0x24/0x40
> Nov 21 18:30:30 x4 kernel: [<ffffffff81044764>] ? free_thread_xstate+0x24/0x40
> Nov 21 18:30:30 x4 kernel: [<ffffffff81102566>] check_slab+0x96/0xc0
> Nov 21 18:30:30 x4 kernel: [<ffffffff814c5c29>] free_debug_processing+0x34/0x19c
> Nov 21 18:30:30 x4 kernel: [<ffffffff81101d9a>] ? set_track+0x5a/0x190
> Nov 21 18:30:30 x4 kernel: [<ffffffff8110cf2b>] ? sys_open+0x1b/0x20
> Nov 21 18:30:30 x4 kernel: [<ffffffff814c5e55>] __slab_free+0x33/0x2d0
> Nov 21 18:30:30 x4 kernel: [<ffffffff8110cf2b>] ? sys_open+0x1b/0x20
> Nov 21 18:30:30 x4 kernel: [<ffffffff81105134>] kmem_cache_free+0x104/0x120
> Nov 21 18:30:30 x4 kernel: [<ffffffff81044764>] free_thread_xstate+0x24/0x40
> Nov 21 18:30:30 x4 kernel: [<ffffffff81044794>] free_thread_info+0x14/0x30
> Nov 21 18:30:30 x4 kernel: [<ffffffff8106a4ff>] free_task+0x2f/0x50
> Nov 21 18:30:30 x4 kernel: [<ffffffff8106a5d0>] __put_task_struct+0xb0/0x110
> Nov 21 18:30:30 x4 kernel: [<ffffffff8106eb4b>] delayed_put_task_struct+0x3b/0xa0
> Nov 21 18:30:30 x4 kernel: [<ffffffff810aa01a>] __rcu_process_callbacks+0x12a/0x350
> Nov 21 18:30:30 x4 kernel: [<ffffffff810aa2a2>] rcu_process_callbacks+0x62/0x140
> Nov 21 18:30:30 x4 kernel: [<ffffffff81072e18>] __do_softirq+0xa8/0x200
> Nov 21 18:30:30 x4 kernel: [<ffffffff81073077>] run_ksoftirqd+0x107/0x210
> Nov 21 18:30:30 x4 kernel: [<ffffffff81072f70>] ? __do_softirq+0x200/0x200
> Nov 21 18:30:30 x4 kernel: [<ffffffff8108bb87>] kthread+0x87/0x90
> Nov 21 18:30:30 x4 kernel: [<ffffffff814cdcf4>] kernel_thread_helper+0x4/0x10
> Nov 21 18:30:30 x4 kernel: [<ffffffff8108bb00>] ? kthread_flush_work_fn+0x10/0x10
> Nov 21 18:30:30 x4 kernel: [<ffffffff814cdcf0>] ? gs_change+0xb/0xb
> Nov 21 18:30:30 x4 kernel: FIX task_xstate: Object at 0xffffffff8110cf2b not freed
> Nov 21 18:30:30 x4 kernel: [drm] ring test succeeded in 1 usecs
> Nov 21 18:30:30 x4 kernel: [drm] radeon: ib pool ready.
> Nov 21 18:30:30 x4 kernel: [drm] ib test succeeded in 0 usecs
> Nov 21 18:30:30 x4 kernel: [drm] Radeon Display Connectors
> Nov 21 18:30:30 x4 kernel: [drm] Connector 0
> 
> 2)
> ...
> Nov 21 17:04:38 x4 kernel: fbcon: radeondrmfb (fb0) is primary device
> Nov 21 17:04:38 x4 kernel: Console: switching to colour frame buffer device 131x105
> Nov 21 17:04:38 x4 kernel: fb0: radeondrmfb frame buffer device
> Nov 21 17:04:38 x4 kernel: drm: registered panic notifier
> Nov 21 17:04:38 x4 kernel: [drm] Initialized radeon 2.11.0 20080528 for 0000:01:05.0 on minor 0
> Nov 21 17:04:38 x4 kernel: loop: module loaded
> Nov 21 17:04:38 x4 kernel: ahci 0000:00:11.0: version 3.0
> Nov 21 17:04:38 x4 kernel: ahci 0000:00:11.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
> Nov 21 17:04:38 x4 kernel: ahci 0000:00:11.0: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
> Nov 21 17:04:38 x4 kernel: ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc
> Nov 21 17:04:38 x4 kernel: scsi0 : ahci
> Nov 21 17:04:38 x4 kernel: scsi1 : ahci
> Nov 21 17:04:38 x4 kernel: =============================================================================
> Nov 21 17:04:38 x4 kernel: BUG task_struct: Poison overwritten
> Nov 21 17:04:38 x4 kernel: -----------------------------------------------------------------------------
> Nov 21 17:04:38 x4 kernel:
> Nov 21 17:04:38 x4 kernel: INFO: 0xffff880215c43800-0xffff880215c43803. First byte 0x0 instead of 0x6b
> Nov 21 17:04:38 x4 kernel: INFO: Allocated in copy_process+0xc4/0xf60 age=168 cpu=1 pid=5
> Nov 21 17:04:38 x4 kernel:      __slab_alloc.constprop.70+0x1a4/0x1e0
> Nov 21 17:04:38 x4 kernel:      kmem_cache_alloc+0x126/0x160
> Nov 21 17:04:38 x4 kernel:      copy_process+0xc4/0xf60
> Nov 21 17:04:38 x4 kernel:      do_fork+0x100/0x2b0
> Nov 21 17:04:38 x4 kernel:      kernel_thread+0x6c/0x70
> Nov 21 17:04:38 x4 kernel:      __call_usermodehelper+0x31/0xa0
> Nov 21 17:04:38 x4 kernel:      process_one_work+0x11a/0x430
> Nov 21 17:04:38 x4 kernel:      worker_thread+0x126/0x2d0
> Nov 21 17:04:38 x4 kernel:      kthread+0x87/0x90
> Nov 21 17:04:38 x4 kernel:      kernel_thread_helper+0x4/0x10
> Nov 21 17:04:38 x4 kernel: INFO: Freed in free_task+0x3e/0x50 age=156 cpu=2 pid=13
> Nov 21 17:04:38 x4 kernel:      __slab_free+0x33/0x2d0
> Nov 21 17:04:38 x4 kernel:      kmem_cache_free+0x104/0x120
> Nov 21 17:04:38 x4 kernel:      free_task+0x3e/0x50
> Nov 21 17:04:38 x4 kernel:      __put_task_struct+0xb0/0x110
> Nov 21 17:04:38 x4 kernel:      delayed_put_task_struct+0x3b/0xa0
> Nov 21 17:04:38 x4 kernel:      __rcu_process_callbacks+0x12a/0x350
> Nov 21 17:04:38 x4 kernel:      rcu_process_callbacks+0x62/0x140
> Nov 21 17:04:38 x4 kernel:      __do_softirq+0xa8/0x200
> Nov 21 17:04:38 x4 kernel:      run_ksoftirqd+0x107/0x210
> Nov 21 17:04:38 x4 kernel:      kthread+0x87/0x90
> Nov 21 17:04:38 x4 kernel:      kernel_thread_helper+0x4/0x10
> Nov 21 17:04:38 x4 kernel: INFO: Slab 0xffffea0008571000 objects=17 used=17 fp=0x          (null) flags=0x4000000000004080
> Nov 21 17:04:38 x4 kernel: INFO: Object 0xffff880215c432c0 @offset=12992 fp=0xffff880215c41d00
> Nov 21 17:04:38 x4 kernel:
> Nov 21 17:04:38 x4 kernel: Bytes b4 ffff880215c432b0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> Nov 21 17:04:38 x4 kernel: Object ffff880215c432c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> ...
> Nov 21 17:04:38 x4 kernel: Object ffff880215c437f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43800: 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  ....kkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43810: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43830: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43840: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43850: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43860: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43870: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43880: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c43890: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Nov 21 17:04:38 x4 kernel: Object ffff880215c438a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
> Nov 21 17:04:38 x4 kernel: Redzone ffff880215c438b0: bb bb bb bb bb bb bb bb                          ........
> Nov 21 17:04:38 x4 kernel: Padding ffff880215c439f0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> Nov 21 17:04:38 x4 kernel: Pid: 5, comm: kworker/u:0 Not tainted 3.2.0-rc2-00274-g6fe4c6d #72
> Nov 21 17:04:38 x4 kernel: Call Trace:
> Nov 21 17:04:38 x4 kernel: [<ffffffff81101ca8>] ? print_section+0x38/0x40
> Nov 21 17:04:38 x4 kernel: [<ffffffff811021a3>] print_trailer+0xe3/0x150
> Nov 21 17:04:38 x4 kernel: [<ffffffff811023a0>] check_bytes_and_report+0xe0/0x100
> Nov 21 17:04:38 x4 kernel: [<ffffffff81103196>] check_object+0x1c6/0x240
> Nov 21 17:04:38 x4 kernel: [<ffffffff8106b034>] ? copy_process+0xc4/0xf60
> Nov 21 17:04:38 x4 kernel: [<ffffffff814c5bb3>] alloc_debug_processing+0x62/0xe4
> Nov 21 17:04:38 x4 kernel: [<ffffffff814c6461>] __slab_alloc.constprop.70+0x1a4/0x1e0
> Nov 21 17:04:38 x4 kernel: [<ffffffff8106b034>] ? copy_process+0xc4/0xf60
> Nov 21 17:04:38 x4 kernel: [<ffffffff814ca12a>] ? schedule+0x3a/0x50
> Nov 21 17:04:38 x4 kernel: [<ffffffff81104d66>] kmem_cache_alloc+0x126/0x160
> Nov 21 17:04:38 x4 kernel: [<ffffffff8106b034>] ? copy_process+0xc4/0xf60
> Nov 21 17:04:38 x4 kernel: [<ffffffff81065f18>] ? enqueue_task_fair+0xf8/0x140
> Nov 21 17:04:38 x4 kernel: [<ffffffff8106b034>] copy_process+0xc4/0xf60
> Nov 21 17:04:38 x4 kernel: [<ffffffff8106c000>] do_fork+0x100/0x2b0
> Nov 21 17:04:38 x4 kernel: [<ffffffff810920fd>] ? sched_clock_local+0x1d/0x90
> Nov 21 17:04:38 x4 kernel: [<ffffffff81044dec>] kernel_thread+0x6c/0x70
> Nov 21 17:04:38 x4 kernel: [<ffffffff81084430>] ? proc_cap_handler+0x180/0x180
> Nov 21 17:04:38 x4 kernel: [<ffffffff814cdd30>] ? gs_change+0xb/0xb
> Nov 21 17:04:38 x4 kernel: [<ffffffff810845a1>] __call_usermodehelper+0x31/0xa0
> Nov 21 17:04:38 x4 kernel: [<ffffffff810869ba>] process_one_work+0x11a/0x430
> Nov 21 17:04:38 x4 kernel: [<ffffffff81084570>] ? call_usermodehelper_freeinfo+0x30/0x30
> Nov 21 17:04:38 x4 kernel: [<ffffffff81087026>] worker_thread+0x126/0x2d0
> Nov 21 17:04:38 x4 kernel: [<ffffffff81086f00>] ? rescuer_thread+0x1f0/0x1f0
> Nov 21 17:04:38 x4 kernel: [<ffffffff8108bb87>] kthread+0x87/0x90
> Nov 21 17:04:38 x4 kernel: [<ffffffff814cdd34>] kernel_thread_helper+0x4/0x10
> Nov 21 17:04:38 x4 kernel: [<ffffffff8108bb00>] ? kthread_flush_work_fn+0x10/0x10
> Nov 21 17:04:38 x4 kernel: [<ffffffff814cdd30>] ? gs_change+0xb/0xb
> Nov 21 17:04:38 x4 kernel: FIX task_struct: Restoring 0xffff880215c43800-0xffff880215c43803=0x6b
> Nov 21 17:04:38 x4 kernel:
> Nov 21 17:04:38 x4 kernel: FIX task_struct: Marking all objects used
> 

I really don't think that drm or radeon is guilty. I tried to reproduce
with rc3+ & rc4+ with slub or slab, did more then 20 kexec cycle with
same kernel parameter and no issue.

To confirm that radeon or drm is not to blame can you trigger the issue
by using nomodeset kernel option (your fb rotate option is then
useless). If with nomodeset you can trigger the issue can you then try
to trigger it with KMS enabled and with attached patch (real ugly printk
debuging)

Note that i walked over the drm mode init code and i believe the root
issue is that some code in the kernel do a double idr_remove/destroy
which trigger the idr slub/slab error. It just happen that radeon/drm
is call after the idr double free but is not the one guilty.

Note that i don't understand the idr code much, so my theory can be
completely wrong but attached patch might help to shed some light.

Cheers,
Jerome

--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-UGLY-DEBUGING.patch"

>From 4262819d046dacfb75ad2d639cb61c5b6985e159 Mon Sep 17 00:00:00 2001
From: Jerome Glisse <jglisse@redhat.com>
Date: Fri, 2 Dec 2011 17:50:02 -0500
Subject: [PATCH] UGLY DEBUGING

WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
---
 drivers/gpu/drm/drm_crtc.c     |    2 ++
 drivers/gpu/drm/drm_pci.c      |    2 ++
 drivers/gpu/drm/drm_platform.c |    2 ++
 lib/idr.c                      |    6 +++++-
 mm/slab.c                      |    2 +-
 5 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/drm_crtc.c b/drivers/gpu/drm/drm_crtc.c
index 8323fc3..a1a0a69 100644
--- a/drivers/gpu/drm/drm_crtc.c
+++ b/drivers/gpu/drm/drm_crtc.c
@@ -242,6 +242,7 @@ again:
 
 	obj->id = new_id;
 	obj->type = obj_type;
+DRM_INFO("allocating idr %p %d idr %d\n", obj, obj_type, new_id);
 	return 0;
 }
 
@@ -259,6 +260,7 @@ static void drm_mode_object_put(struct drm_device *dev,
 				struct drm_mode_object *object)
 {
 	mutex_lock(&dev->mode_config.idr_mutex);
+DRM_INFO("remove idr %p %d idr %d\n", object, object->type, object->id);
 	idr_remove(&dev->mode_config.crtc_idr, object->id);
 	mutex_unlock(&dev->mode_config.idr_mutex);
 }
diff --git a/drivers/gpu/drm/drm_pci.c b/drivers/gpu/drm/drm_pci.c
index d4d10b7..7932ebb 100644
--- a/drivers/gpu/drm/drm_pci.c
+++ b/drivers/gpu/drm/drm_pci.c
@@ -345,11 +345,13 @@ int drm_get_pci_dev(struct pci_dev *pdev, const struct pci_device_id *ent,
 
 	if (drm_core_check_feature(dev, DRIVER_MODESET)) {
 		pci_set_drvdata(pdev, dev);
+printk(KERN_INFO "%s %d\n", __func__, __LINE__);
 		ret = drm_get_minor(dev, &dev->control, DRM_MINOR_CONTROL);
 		if (ret)
 			goto err_g2;
 	}
 
+printk(KERN_INFO "%s %d\n", __func__, __LINE__);
 	if ((ret = drm_get_minor(dev, &dev->primary, DRM_MINOR_LEGACY)))
 		goto err_g3;
 
diff --git a/drivers/gpu/drm/drm_platform.c b/drivers/gpu/drm/drm_platform.c
index ae9db5e..3e7e401 100644
--- a/drivers/gpu/drm/drm_platform.c
+++ b/drivers/gpu/drm/drm_platform.c
@@ -65,11 +65,13 @@ int drm_get_platform_dev(struct platform_device *platdev,
 
 	if (drm_core_check_feature(dev, DRIVER_MODESET)) {
 		dev_set_drvdata(&platdev->dev, dev);
+printk(KERN_INFO "%s %d\n", __func__, __LINE__);
 		ret = drm_get_minor(dev, &dev->control, DRM_MINOR_CONTROL);
 		if (ret)
 			goto err_g1;
 	}
 
+printk(KERN_INFO "%s %d\n", __func__, __LINE__);
 	ret = drm_get_minor(dev, &dev->primary, DRM_MINOR_LEGACY);
 	if (ret)
 		goto err_g2;
diff --git a/lib/idr.c b/lib/idr.c
index ed055b2..22c3ec6 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -427,6 +427,7 @@ void idr_remove(struct idr *idp, int id)
 		 * layers that fall into the freelist are those that have been
 		 * preallocated.
 		 */
+printk(KERN_INFO "%s free idr %p\n", __func__, p);
 		kmem_cache_free(idr_layer_cache, p);
 	}
 	return;
@@ -489,6 +490,7 @@ void idr_destroy(struct idr *idp)
 {
 	while (idp->id_free_cnt) {
 		struct idr_layer *p = get_from_free_list(idp);
+printk(KERN_INFO "%s free idr %p\n", __func__, p);
 		kmem_cache_free(idr_layer_cache, p);
 	}
 }
@@ -841,8 +843,10 @@ int ida_get_new_above(struct ida *ida, int starting_id, int *p_id)
 	 */
 	if (ida->idr.id_free_cnt || ida->free_bitmap) {
 		struct idr_layer *p = get_from_free_list(&ida->idr);
-		if (p)
+		if (p) {
+printk(KERN_INFO "%s free idr %p\n", __func__, p);
 			kmem_cache_free(idr_layer_cache, p);
+		}
 	}
 
 	return 0;
diff --git a/mm/slab.c b/mm/slab.c
index 708efe8..83864f9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1926,7 +1926,7 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 			/* Mismatch ! */
 			/* Print header */
 			if (lines == 0) {
-				printk(KERN_ERR
+				WARN(1, 
 					"Slab corruption: %s start=%p, len=%d\n",
 					cachep->name, realobj, size);
 				print_objinfo(cachep, objp, 0);
-- 
1.7.7.1


--6c2NcOVqGQ03X4Wi--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
