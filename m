From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.33 dies on modprobe
Date: Tue, 2 Mar 2010 18:52:13 -0800
Message-ID: <20100302185213.43a1a0d7.akpm@linux-foundation.org>
References: <20100228221257.GA8858@invalid>
	<2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: M G Berberich <berberic@fmi.uni-passau.de>,
	linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2375c9f91002282022n29e83858jd8cadbb2e664b436@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 1 Mar 2010 12:22:59 +0800 Am__rico Wang <xiyou.wangcong@gmail.com> wrote:

> 
> You snipped too much. The full backtrace is useful:
> 
> BUG: unable to handle kernel paging request at ffffffffa001b57f
> IP: [<ffffffff811895db>] strcmp+0xb/0x30
> PGD 1498067 PUD 149c063 PMD 12daf2067 PTE 0
> Oops: 0000 [#1] SMP
> last sysfs file:
> /sys/devices/pci0000:00/0000:00:05.0/host0/target0:0:0/0:0:0:0/type
> CPU 1
> Pid: 1249, comm: modprobe Not tainted 2.6.33-bmg #1 M55S-S3/
> RIP: 0010:[<ffffffff811895db>]  [<ffffffff811895db>] strcmp+0xb/0x30
> RSP: 0018:ffff88012ebe9e58  EFLAGS: 00010282
> RAX: 0000000000000070 RBX: ffff88012f8f4f00 RCX: 00000000ffffffff
> RDX: ffff88012f808800 RSI: ffffffffa001b57f RDI: ffff88012fab2420
> RBP: ffff88012ebe9e58 R08: 0000000000000000 R09: 0000000000000000
> R10: ffff8800284017c0 R11: dead000000200200 R12: ffff88012f9a29c8
> R13: ffff88012f8842a0 R14: ffffffffa001b57f R15: 000000000081c050
> FS:  00007f16bd8916f0(0000) GS:ffff880028280000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: ffffffffa001b57f CR3: 000000012da7c000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process modprobe (pid: 1249, threadinfo ffff88012ebe8000, task ffff88012edec0a0)
> Stack:
>  ffff88012ebe9e88 ffffffff811852e8 ffffffffa0013080 ffffffffa00130e0
> <0> 000000000081e970 000000000081e970 ffff88012ebe9e98 ffffffff81236b87
> <0> ffff88012ebe9ed8 ffffffff81236ca7 0000000000000021 0000000000000021
> Call Trace:
>  [<ffffffff811852e8>] kset_find_obj+0x38/0x80
>  [<ffffffff81236b87>] driver_find+0x17/0x30
>  [<ffffffff81236ca7>] driver_register+0x67/0x140
>  [<ffffffff8119b771>] __pci_register_driver+0x51/0xd0
>  [<ffffffffa0017000>] ? init_nic+0x0/0x20 [forcedeth]
>  [<ffffffffa001701e>] init_nic+0x1e/0x20 [forcedeth]
> 
> 

It could be that some kobject on that list has become invalid (memory
was freed, module was unloaded, etc) and later code stumbled across the
now-invalid object on that list and then crashed.

What we can do to find this is to add a diagnostic each time an object
is registered, and a diagnostic each time kset_find_obj() looks at the
objects.  Then we'll see which kobject caused the crash, then we can
look back and see where that kobject was registered from.

Something like this:

--- a/lib/kobject.c~a
+++ a/lib/kobject.c
@@ -717,6 +717,8 @@ int kset_register(struct kset *k)
 		return -EINVAL;
 
 	kset_init(k);
+	printk("kset_register:%p\n", &k->kobj);
+	dump_stack();
 	err = kobject_add_internal(&k->kobj);
 	if (err)
 		return err;
@@ -751,9 +753,12 @@ struct kobject *kset_find_obj(struct kse
 
 	spin_lock(&kset->list_lock);
 	list_for_each_entry(k, &kset->list, entry) {
-		if (kobject_name(k) && !strcmp(kobject_name(k), name)) {
-			ret = kobject_get(k);
-			break;
+		if (kobject_name(k)) {
+			printk("kset_find_obj:%p\n", k);
+			if (!strcmp(kobject_name(k), name)) {
+				ret = kobject_get(k);
+				break;
+			}
 		}
 	}
 	spin_unlock(&kset->list_lock);
_

This will generate a lot of output and we don't want to lose any of it.
 I'd suggest setting up netconsole so all the output can be reliably
saved: Documentation/networking/netconsole.txt

Thanks.
