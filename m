From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.33 dies on modprobe
Date: Wed, 3 Mar 2010 16:05:13 -0800
Message-ID: <20100303160513.0c06e094.akpm@linux-foundation.org>
References: <20100228221257.GA8858@invalid>
	<2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
	<20100302185213.43a1a0d7.akpm@linux-foundation.org>
	<20100303221602.GA3264@invalid>
	<20100303142420.accf985e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, Greg KH <greg@kroah.com>,
	Kay Sievers <kay.sievers@vrfy.org>
To: M G Berberich <berberic@fmi.uni-passau.de>,
	=?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100303142420.accf985e.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Mar 2010 14:24:20 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 3 Mar 2010 23:16:02 +0100
> M G Berberich <berberic@fmi.uni-passau.de> wrote:
> 
> > Hello,
> > 
> > Am Dienstag, den 02. M__rz schrieb Andrew Morton:
> > 
> > > It could be that some kobject on that list has become invalid (memory
> > > was freed, module was unloaded, etc) and later code stumbled across the
> > > now-invalid object on that list and then crashed.
> > > 
> > > What we can do to find this is to add a diagnostic each time an object
> > > is registered, and a diagnostic each time kset_find_obj() looks at the
> > > objects.  Then we'll see which kobject caused the crash, then we can
> > > look back and see where that kobject was registered from.
> > 
> > [...]
> > 
> > > This will generate a lot of output and we don't want to lose any of it.
> > >  I'd suggest setting up netconsole so all the output can be reliably
> > > saved: Documentation/networking/netconsole.txt
> > 
> > I have a serial connection to a netbook. Log attached.
> 
> drat, my patch didn't work.  Can you try this one please?

He did.

> --- a/lib/kobject.c~a
> +++ a/lib/kobject.c
> @@ -126,6 +126,8 @@ static void kobj_kset_join(struct kobjec
>  
>  	kset_get(kobj->kset);
>  	spin_lock(&kobj->kset->list_lock);
> +	printk("kobj_kset_join:%p\n", kobj);
> +	dump_stack();
>  	list_add_tail(&kobj->entry, &kobj->kset->list);
>  	spin_unlock(&kobj->kset->list_lock);
>  }
> @@ -751,9 +753,12 @@ struct kobject *kset_find_obj(struct kse
>  
>  	spin_lock(&kset->list_lock);
>  	list_for_each_entry(k, &kset->list, entry) {
> -		if (kobject_name(k) && !strcmp(kobject_name(k), name)) {
> -			ret = kobject_get(k);
> -			break;
> +		if (kobject_name(k)) {
> +			printk("kset_find_obj:%p\n", k);
> +			if (!strcmp(kobject_name(k), name)) {
> +				ret = kobject_get(k);
> +				break;
> +			}
>  		}
>  	}
>  	spin_unlock(&kset->list_lock);

And here's what we have:

kobj_kset_join:ffff88012fa80e40
Pid: 1, comm: swapper Not tainted 2.6.33-bmg #2
Call Trace:
 [<ffffffff811853ce>] kobject_add_internal+0x8e/0x210
 [<ffffffff81185668>] kobject_add_varg+0x38/0x60
 [<ffffffff811856e3>] kobject_init_and_add+0x53/0x70
 [<ffffffff810ae754>] ? kmem_cache_alloc+0x74/0xc0
 [<ffffffff81235fa4>] bus_add_driver+0x94/0x260
 [<ffffffff81236ce8>] driver_register+0x78/0x140
 [<ffffffff8119b7a1>] __pci_register_driver+0x51/0xd0
 [<ffffffff81513f50>] ? pcie_portdrv_init+0x0/0x4c
 [<ffffffff81513f50>] ? pcie_portdrv_init+0x0/0x4c
 [<ffffffff81513f8b>] pcie_portdrv_init+0x3b/0x4c
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff814fa6a4>] kernel_init+0x14d/0x1a3
 [<ffffffff81003194>] kernel_thread_helper+0x4/0x10
 [<ffffffff814fa557>] ? kernel_init+0x0/0x1a3
 [<ffffffff81003190>] ? kernel_thread_helper+0x0/0x10

...

kset_find_obj:ffff88012fa80e40
BUG: unable to handle kernel paging request at ffffffffa005c57f
IP: [<ffffffff8118960b>] strcmp+0xb/0x30
PGD 1498067 PUD 149c063 PMD 12d72c067 PTE 0
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:05.0/host0/target0:0:0/0:0:0:0/block/sda/uevent
CPU 1 
Pid: 1263, comm: modprobe Not tainted 2.6.33-bmg #2 M55S-S3/ 
RIP: 0010:[<ffffffff8118960b>]  [<ffffffff8118960b>] strcmp+0xb/0x30
RSP: 0018:ffff88012ef83e58  EFLAGS: 00010292
RAX: 0000000000000070 RBX: ffff88012fa80e40 RCX: 00000000000005b0
RDX: 0000000000000000 RSI: ffffffffa005c57f RDI: ffff88012f99adb0
RBP: ffff88012ef83e58 R08: 0000000000000000 R09: ffff88012ef83e08
R10: 0000000000000000 R11: 000000000000000f R12: ffff88012f8842a0
R13: ffffffffa005c57f R14: 0000000001a35970 R15: 0000000001a33050
FS:  00007f3b044766f0(0000) GS:ffff880028280000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffffa005c57f CR3: 000000012ea48000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 1263, threadinfo ffff88012ef82000, task ffff88012e4d34e0)
Stack:
 ffff88012ef83e88 ffffffff81185320 ffff88012ef83e88 ffffffffa00540a0
<0> ffffffffa0054100 0000000001a35970 ffff88012ef83e98 ffffffff81236bb7
<0> ffff88012ef83ed8 ffffffff81236cd7 ffff88012ef83f08 ffffffff81034855
Call Trace:
 [<ffffffff81185320>] kset_find_obj+0x70/0x90
 [<ffffffff81236bb7>] driver_find+0x17/0x30
 [<ffffffff81236cd7>] driver_register+0x67/0x140
 [<ffffffff81034855>] ? try_to_wake_up+0x215/0x2f0
 [<ffffffff8119b7a1>] __pci_register_driver+0x51/0xd0
 [<ffffffffa0058000>] ? init_nic+0x0/0x20 [forcedeth]
 [<ffffffffa005801e>] init_nic+0x1e/0x20 [forcedeth]
 [<ffffffff810001d7>] do_one_initcall+0x37/0x190
 [<ffffffff81067296>] sys_init_module+0xd6/0x250
 [<ffffffff8100246b>] system_call_fastpath+0x16/0x1b
Code: 0f b6 3e 48 ff c6 40 84 ff 40 88 39 74 0b 48 ff c1 48 ff ca 75 ea c6 01 00 c9 c3 0f 1f 44 00 00 55 48 89 e5 0f 1f 40 00 0f b6 07 <0f> b6 16 48 ff c7 48 ff c6 38 d0 75 08 84 c0 75 ec 31 c0 c9 c3 
RIP  [<ffffffff8118960b>] strcmp+0xb/0x30
 RSP <ffff88012ef83e58>
CR2: ffffffffa005c57f


So a kobject which was created under pcie_portdrv_init() caused an oops
much later when kset_find_obj() did strcmp(kobject_name(k), name)) on
that object.  Which tends to imply that someone freed that memory or
trashed kobj->name while that pcie kobject was on the list.

Greg, Jesse, Kay, could you take a look please?

I guess one thing we could do is to change that debug patch to print
kobj->name as well, see whether it changes.

M G, do you have all debug options enabled, especially the
memory-management ones?  Perhaps CONFIG_DEBUG_PAGEALLOC will pick
something up.

Thanks.
