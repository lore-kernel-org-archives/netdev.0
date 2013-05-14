From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Tue, 14 May 2013 12:45:51 -0700
Message-ID: <5192946F.1050700@intel.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org> <1368498506-25857-7-git-send-email-yinghai@kernel.org> <51925FB0.4080504@intel.com> <CAE9FiQXYQEAZ=0sG6+2OdffBqfLS9MpoN1xviRR9aDbxPxcKxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAE9FiQXYQEAZ=0sG6+2OdffBqfLS9MpoN1xviRR9aDbxPxcKxQ@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/14/2013 11:44 AM, Yinghai Lu wrote:
> On Tue, May 14, 2013 at 9:00 AM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> On 05/13/2013 07:28 PM, Yinghai Lu wrote:
>>> Found kernel try to load mlx4 drivers for VFs before
>>> PF's is really loaded when the drivers are built-in, and kernel
>>> command line include probe_vfs=63, num_vfs=63.
>>>
>>> It turns that it also happen for hotadd path even drivers are
>>> compiled as modules and if they loaded. Esp some VF share the
>>> same driver with PF.
>>>
>>> calling path:
>>>       device driver probe
>>>               ==> pci_enable_sriov
>>>                       ==> virtfn_add
>>>                               ==> pci_dev_add
>>>                               ==> pci_bus_device_add
>>> when pci_bus_device_add is called, the VF's driver will be attached.
>>> and at that time PF's driver does not finish yet.
>>>
>>> Need to move out pci_bus_device_add from virtfn_add and call it
>>> later. Fix the problem for two path,
>>> 1. hotadd path: use device_schedule_callback.
>>> 2. for booting path, use initcall to call that for all VF's.
>>>
>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>>> Cc: netdev@vger.kernel.org
>>>
>> I'm sorry, but what is the point of this patch?  With device assignment
>> it is always possible to have VFs loaded and the PF driver unloaded
>> since you cannot remove the VFs if they are assigned to a VM.
> unload PF driver will not call pci_disable_sriov?

You cannot call pci_disable_sriov because you will panic all of the
guests that have devices assigned.

>> If there is a driver that has to have the PF driver fully loaded before
>> it instantiates the VFs then it sounds like a buggy driver to me.  The
>> VF driver should be able to be loaded when the PF driver is not
>> present.  We handle it in igb and ixgbe last I checked, and I don't see
>> any reason why it cannot be handled in all other VF drivers.  I'm not
>> saying the VF has to be able to fully functional, but it should be able
>> to detect the PF becoming enabled and then bring itself to a fully
>> functional state.  To not handle that case is a bug.
> more than that.
>
> there is work_on_cpu nested lock problem. from calling pci_bus_add_device
> in driver pci probe function.
>
> [  181.938110] mlx4_core 0000:02:00.0: Started init_resource_tracker: 80 slaves
> [  181.938759]   alloc irq_desc for 1170 on node 0
> [  181.949104] mlx4_core 0000:02:00.0: irq 1170 for MSI-X
> [  181.949404]   alloc irq_desc for 1171 on node 0
> [  181.949741] mlx4_core 0000:02:00.0: irq 1171 for MSI-X
> [  181.969253]   alloc irq_desc for 1172 on node 0
> [  181.969564] mlx4_core 0000:02:00.0: irq 1172 for MSI-X
> [  181.989137]   alloc irq_desc for 1173 on node 0
> [  181.989485] mlx4_core 0000:02:00.0: irq 1173 for MSI-X
> [  182.033789] mlx4_core 0000:02:00.0: NOP command IRQ test passed
> [  182.035380]
> [  182.035473] =============================================
> [  182.049065] [ INFO: possible recursive locking detected ]
> [  182.049349] 3.10.0-rc1-yh-00114-gf59c98e-dirty #1588 Not tainted
> [  182.069079] ---------------------------------------------
> [  182.069354] kworker/0:1/2285 is trying to acquire lock:
> [  182.089080]  ((&wfc.work)){+.+.+.}, at: [<ffffffff810ab745>]
> flush_work+0x5/0x280
> [  182.089500]
> [  182.089500] but task is already holding lock:
> [  182.109671]  ((&wfc.work)){+.+.+.}, at: [<ffffffff810aabe2>]
> process_one_work+0x202/0x490
> [  182.129097]
> [  182.129097] other info that might help us debug this:
> [  182.129415]  Possible unsafe locking scenario:
> [  182.129415]
> [  182.149275]        CPU0
> [  182.149386]        ----
> [  182.149513]   lock((&wfc.work));
> [  182.149705]   lock((&wfc.work));
> [  182.169391]
> [  182.169391]  *** DEADLOCK ***
> [  182.169391]
> [  182.169722]  May be due to missing lock nesting notation
> [  182.169722]
> [  182.189461] 3 locks held by kworker/0:1/2285:
> [  182.189664]  #0:  (events){.+.+.+}, at: [<ffffffff810aabe2>]
> process_one_work+0x202/0x490
> [  182.209468]  #1:  ((&wfc.work)){+.+.+.}, at: [<ffffffff810aabe2>]
> process_one_work+0x202/0x490
> [  182.229176]  #2:  (&__lockdep_no_validate__){......}, at:
> [<ffffffff81765eea>] device_attach+0x2a/0xc0
> [  182.249108]
> [  182.249108] stack backtrace:
> [  182.249362] CPU: 0 PID: 2285 Comm: kworker/0:1 Not tainted
> 3.10.0-rc1-yh-00114-gf59c98e-dirty #1588
> [  182.269258] Hardware name: Oracle Corporation  unknown       /
> , BIOS 11016600    05/17/2011
> [  182.289141] Workqueue: events work_for_cpu_fn
> [  182.289410]  ffffffff83350bc0 ffff881025c11778 ffffffff82093a74
> ffff881025c11838
> [  182.309167]  ffffffff810ed194 ffff881025c117b8 ffff881025c38000
> 0000b787702301dc
> [  182.309587]  ffff881000000000 0000000000000002 ffffffff8322cba0
> ffff881025c11878
> [  182.329524] Call Trace:
> [  182.329669]  [<ffffffff82093a74>] dump_stack+0x19/0x1b
> [  182.349365]  [<ffffffff810ed194>] validate_chain.isra.19+0x8f4/0x1210
> [  182.349720]  [<ffffffff810ed3b6>] ? validate_chain.isra.19+0xb16/0x1210
> [  182.369261]  [<ffffffff810eacf8>] ? trace_hardirqs_off_caller+0x28/0x160
> [  182.389069]  [<ffffffff810f0c40>] __lock_acquire+0xac0/0xce0
> [  182.389330]  [<ffffffff810f150a>] lock_acquire+0xda/0x130
> [  182.409077]  [<ffffffff810ab745>] ? flush_work+0x5/0x280
> [  182.409320]  [<ffffffff810ab78c>] flush_work+0x4c/0x280
> [  182.409595]  [<ffffffff810ab745>] ? flush_work+0x5/0x280
> [  182.429306]  [<ffffffff810ee506>] ? mark_held_locks+0x136/0x150
> [  182.429634]  [<ffffffff820a67fb>] ? _raw_spin_unlock+0x2b/0x40
> [  182.449352]  [<ffffffff810aa5a5>] ? queue_work_on+0x75/0xa0
> [  182.469088]  [<ffffffff810ee78d>] ? trace_hardirqs_on+0xd/0x10
> [  182.469352]  [<ffffffff810aba42>] work_on_cpu+0x82/0x90
> [  182.489073]  [<ffffffff810a7940>] ? find_worker_executing_work+0x90/0x90
> [  182.489426]  [<ffffffff8151e290>] ? pci_device_shutdown+0x70/0x70
> [  182.509188]  [<ffffffff8151ebcf>] pci_device_probe+0xaf/0x110
> [  182.509448]  [<ffffffff8176608d>] driver_probe_device+0xdd/0x220
> [  182.529193]  [<ffffffff81766280>] ? __driver_attach+0xb0/0xb0
> [  182.529516]  [<ffffffff817662b3>] __device_attach+0x33/0x50
> [  182.549222]  [<ffffffff817640b6>] bus_for_each_drv+0x56/0xa0
> [  182.549503]  [<ffffffff81765f48>] device_attach+0x88/0xc0
> [  182.569215]  [<ffffffff81515b49>] pci_bus_add_device+0x39/0x60
> [  182.569513]  [<ffffffff81540605>] pci_bus_add_vf+0x25/0x40
> [  182.589239]  [<ffffffff81540834>] pci_bus_add_device_vfs+0xa4/0xe0
> [  182.589618]  [<ffffffff81c1faa6>] __mlx4_init_one+0xa96/0xc90
> [  182.609273]  [<ffffffff81c1fd0d>] mlx4_init_one+0x4d/0x60
> [  182.609588]  [<ffffffff8151e2db>] local_pci_probe+0x4b/0x80
> [  182.629584]  [<ffffffff810a7958>] work_for_cpu_fn+0x18/0x30
> [  182.629869]  [<ffffffff810aac6b>] process_one_work+0x28b/0x490
> [  182.649313]  [<ffffffff810aabe2>] ? process_one_work+0x202/0x490
> [  182.649608]  [<ffffffff810abf68>] ? worker_thread+0x48/0x370
> [  182.669325]  [<ffffffff810aae9c>] process_scheduled_works+0x2c/0x40
> [  182.690446]  [<ffffffff810ac158>] worker_thread+0x238/0x370
> [  182.690712]  [<ffffffff810ee78d>] ? trace_hardirqs_on+0xd/0x10
> [  182.709143]  [<ffffffff810abf20>] ? manage_workers.isra.18+0x330/0x330
> [  182.709499]  [<ffffffff810b2e78>] kthread+0xe8/0xf0

So how does your patch actually fix this problem?  It seems like it is
just avoiding it.

>From what I can tell your problem is originating in pci_call_probe.  I
believe it is calling work_on_cpu and that doesn't seem correct since
the work should be taking place on a CPU already local to the PF.  You
might want to look there to see why you are trying to schedule work on a
CPU which should be perfectly fine for you to already be doing your work on.

Thanks,

Alex
