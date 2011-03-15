From: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Subject: Re: Bug inkvm_set_irq
Date: Tue, 15 Mar 2011 15:58:10 +0100
Message-ID: <4D7F7E82.4000600@univ-nantes.fr>
References: <20110303155533.GA13310@redhat.com> <4D70AF3B.5080007@univ-nantes.fr> <20110304093500.GA31844@redhat.com> <4D70B339.3080001@univ-nantes.fr> <20110308111320.GA8002@redhat.com> <4D77727B.2000207@univ-nantes.fr> <20110309130000.GA30297@redhat.com> <4D777CDA.3050500@univ-nantes.fr> <20110309135918.GA31019@redhat.com> <4D788EF4.7040807@univ-nantes.fr> <20110315143230.GA6911@redhat.com>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls1.univ-nantes.fr ([193.52.101.145]:37437 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755731Ab1COO6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 10:58:12 -0400
In-Reply-To: <20110315143230.GA6911@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/03/2011 15:32, Michael S. Tsirkin a =C3=A9crit :
> On Thu, Mar 10, 2011 at 09:42:28AM +0100, Jean-Philippe Menil wrote:
>> Le 09/03/2011 14:59, Michael S. Tsirkin a =C3=A9crit :
>>> On Wed, Mar 09, 2011 at 02:12:58PM +0100, Jean-Philippe Menil wrote=
:
>>>> Le 09/03/2011 14:00, Michael S. Tsirkin a =C3=A9crit :
>>>>> On Wed, Mar 09, 2011 at 01:28:43PM +0100, Jean-Philippe Menil wro=
te:
>>>>>> Le 08/03/2011 12:13, Michael S. Tsirkin a =C3=A9crit :
>>>>>>> On Fri, Mar 04, 2011 at 10:39:05AM +0100, Jean-Philippe Menil w=
rote:
>>>>>>>> Yes, it's a 2.6.37.2 kernel.
>>>>>>> OK, here's a debugging patch.
>>>>>>> Please run with slab debugging as previously until you see
>>>>>>> 'eventfd bug detected!' in dmesg or until there is a crash.
>>>>>>> It might be also useful to enable timestampts on printk with
>>>>>>>   Symbol: PRINTK_TIME [=3Dy]
>>>>>>>    =E2=94=82 Type  : boolean
>>>>>>>    =E2=94=82 Prompt: Show timing information on printks
>>>>>>>
>>>>>>> once you see the error, please upload the
>>>>>>> full dmesg output somewhere to we can track what
>>>>>>> goes on.
>>>>>>>
>>>>>>> Hopefully there won't be an oops this time which
>>>>>>> should make it easier for you to test (no need to
>>>>>>> reboot).
>>>>>>>
>>>>>>>
>>>>>>> diff --git a/virt/kvm/eventfd.c b/virt/kvm/eventfd.c
>>>>>>> index c1f1e3c..3cb679b 100644
>>>>>>> --- a/virt/kvm/eventfd.c
>>>>>>> +++ b/virt/kvm/eventfd.c
>>>>>>> @@ -32,6 +32,7 @@
>>>>>>>   #include<linux/eventfd.h>
>>>>>>>   #include<linux/kernel.h>
>>>>>>>   #include<linux/slab.h>
>>>>>>> +#include<linux/nmi.h>
>>>>>>>
>>>>>>>   #include "iodev.h"
>>>>>>>
>>>>>>> @@ -43,6 +44,8 @@
>>>>>>>    * ----------------------------------------------------------=
----------
>>>>>>>    */
>>>>>>>
>>>>>>> +#define KVM_BAD_PTR ((void*)(long)(0x6b6b6b6b6b6b6b6bull))
>>>>>>> +
>>>>>>>   struct _irqfd {
>>>>>>>   	struct kvm               *kvm;
>>>>>>>   	struct eventfd_ctx       *eventfd;
>>>>>>> @@ -61,6 +64,13 @@ irqfd_inject(struct work_struct *work)
>>>>>>>   {
>>>>>>>   	struct _irqfd *irqfd =3D container_of(work, struct _irqfd, i=
nject);
>>>>>>>   	struct kvm *kvm =3D irqfd->kvm;
>>>>>>> +	if (kvm =3D=3D KVM_BAD_PTR) {
>>>>>>> +		printk(KERN_ERR "Eventfd bug detected!\n");
>>>>>>> +		printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p,gsi=3D%d)\=
n", __func__,
>>>>>>> +			work, irqfd, kvm, irqfd->gsi);
>>>>>>> +		trigger_all_cpu_backtrace();
>>>>>>> +		return;
>>>>>>> +	}
>>>>>>>
>>>>>>>   	kvm_set_irq(kvm, KVM_USERSPACE_IRQ_SOURCE_ID, irqfd->gsi, 1)=
;
>>>>>>>   	kvm_set_irq(kvm, KVM_USERSPACE_IRQ_SOURCE_ID, irqfd->gsi, 0)=
;
>>>>>>> @@ -75,6 +85,8 @@ irqfd_shutdown(struct work_struct *work)
>>>>>>>   	struct _irqfd *irqfd =3D container_of(work, struct _irqfd, s=
hutdown);
>>>>>>>   	u64 cnt;
>>>>>>>
>>>>>>> +	printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p, gsi=3D%d)\=
n", __func__,
>>>>>>> +	       work, irqfd, irqfd->kvm, irqfd->gsi);
>>>>>>>   	/*
>>>>>>>   	 * Synchronize with the wait-queue and unhook ourselves to p=
revent
>>>>>>>   	 * further events.
>>>>>>> @@ -91,6 +103,8 @@ irqfd_shutdown(struct work_struct *work)
>>>>>>>   	 * It is now safe to release the object's resources
>>>>>>>   	 */
>>>>>>>   	eventfd_ctx_put(irqfd->eventfd);
>>>>>>> +	printk(KERN_ERR "kfree at %s(work=3D%p,irqfd=3D%p)\n", __func=
__,
>>>>>>> +	       work, irqfd);
>>>>>>>   	kfree(irqfd);
>>>>>>>   }
>>>>>>>
>>>>>>> @@ -111,6 +125,8 @@ static void
>>>>>>>   irqfd_deactivate(struct _irqfd *irqfd)
>>>>>>>   {
>>>>>>>   	BUG_ON(!irqfd_is_active(irqfd));
>>>>>>> +	printk(KERN_ERR "%s(irqfd=3D%p,kvm=3D%p, gsi=3D%d)\n", __func=
__,
>>>>>>> +	       irqfd, irqfd->kvm, irqfd->gsi);
>>>>>>>
>>>>>>>   	list_del_init(&irqfd->list);
>>>>>>>
>>>>>>> @@ -178,6 +194,8 @@ kvm_irqfd_assign(struct kvm *kvm, int fd, i=
nt gsi)
>>>>>>>
>>>>>>>   	irqfd->kvm =3D kvm;
>>>>>>>   	irqfd->gsi =3D gsi;
>>>>>>> +	printk(KERN_ERR "%s(irqfd=3D%p,kvm=3D%p, gsi=3D%d)\n", __func=
__,
>>>>>>> +	       irqfd, kvm, gsi);
>>>>>>>   	INIT_LIST_HEAD(&irqfd->list);
>>>>>>>   	INIT_WORK(&irqfd->inject, irqfd_inject);
>>>>>>>   	INIT_WORK(&irqfd->shutdown, irqfd_shutdown);
>>>>>>> @@ -264,6 +282,8 @@ kvm_irqfd_deassign(struct kvm *kvm, int fd,=
 int gsi)
>>>>>>>   	struct _irqfd *irqfd, *tmp;
>>>>>>>   	struct eventfd_ctx *eventfd;
>>>>>>>
>>>>>>> +	printk(KERN_ERR "%s(kvm=3D%p, gsi=3D%d)\n", __func__,
>>>>>>> +	       kvm, gsi);
>>>>>>>   	eventfd =3D eventfd_ctx_fdget(fd);
>>>>>>>   	if (IS_ERR(eventfd))
>>>>>>>   		return PTR_ERR(eventfd);
>>>>>>> @@ -305,6 +325,7 @@ void
>>>>>>>   kvm_irqfd_release(struct kvm *kvm)
>>>>>>>   {
>>>>>>>   	struct _irqfd *irqfd, *tmp;
>>>>>>> +	printk(KERN_ERR "%s(kvm=3D%p)\n", __func__, kvm);
>>>>>>>
>>>>>>>   	spin_lock_irq(&kvm->irqfds.lock);
>>>>>>>
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe netde=
v" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.h=
tml
>>>>>> Hi,
>>>>>>
>>>>>> I boot the host with the patched kernel yesterday.
>>>>>> No crach until now, but two "Eventfd bug detected!" in the log a=
t
>>>>>> "Mar  9 02:04:31" and "Mar  9 02:15:17"
>>>>>> You can find part of the log at the following adress:
>>>>>> http://filex.univ-nantes.fr/get?k=3DjL4Fe7yfSMN57toAH7V
>>>>>>
>>>>>> It a split file of the kern.log (1,4G), so if you need another p=
art
>>>>>> of the log, let me know.
>>>>>>
>>>>>> Thanks for all.
>>>>>>
>>>>>> Regards.
>>>>> Downloading, it's big :)
>>>>> What about some 1000 lines before and after Eventfd bug detected!=
 line?
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe kvm" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>>>> Yes, sorry about that.
>>>> I could have split my log into a smaller file.
>>>>
>>>> I was a little afraid of not transmit enough informations, and i w=
as
>>>> a bit wide.
>>>> I hope you can find usefull trace anyway.
>>>>
>>>> Regards.
>>> OK, use after free.
>>>
>>>
>>> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.59368=
1]
>>> kvm_irqfd_assign(irqfd=3Dffff88045e8d6230,kvm=3Dffff88085151c000, g=
si=3D26)
>>> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.60535=
9]
>>> kvm_irqfd_deassign(kvm=3Dffff88085151c000, gsi=3D26)
>>> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.60538=
8]
>>> irqfd_deactivate(irqfd=3Dffff88045e8d6230,kvm=3Dffff88085151c000, g=
si=3D26)
>>> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.60546=
1]
>>> irqfd_shutdown(work=3Dffff88045e8d62b0,irqfd=3Dffff88045e8d6230,kvm=
=3Dffff88085151c000,
>>> gsi=3D26)
>>> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.60550=
9]
>>> kfree at irqfd_shutdown(work=3Dffff88045e8d62b0,irqfd=3Dffff88045e8=
d6230)
>>> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.60558=
8]
>>> Eventfd bug detected!
>>> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.60561=
2]
>>> irqfd_inject(work=3Dffff88045e8d6290,irqfd=3Dffff88045e8d6230,kvm=3D=
6b6b6b6b6b6b6b6b,gsi=3D1802201963)
>>>
>>>
>>> and 1802201963 is also 6b6b6b6b.
>>>
>>>
>>> I suspect that somehow, we get an event from eventfd even
>>> though we did eventfd_ctx_remove_wait_queue.
>>> Could you please try the following patch on top?
>>> When you see Eventfd bug or Wakeup bug, paste some
>>> last lines.
>>> For the full log file - better compress with xz.
>>>
>>>
>>> diff --git a/virt/kvm/eventfd.c b/virt/kvm/eventfd.c
>>> index 3cb679b..63aeba5 100644
>>> --- a/virt/kvm/eventfd.c
>>> +++ b/virt/kvm/eventfd.c
>>> @@ -92,6 +92,8 @@ irqfd_shutdown(struct work_struct *work)
>>>   	 * further events.
>>>   	 */
>>>   	eventfd_ctx_remove_wait_queue(irqfd->eventfd,&irqfd->wait,&cnt);
>>> +	printk(KERN_ERR "remove wq at %s(work=3D%p,irqfd=3D%p)\n", __func=
__,
>>> +	       work, irqfd);
>>>
>>>   	/*
>>>   	 * We know no new events will be scheduled at this point, so blo=
ck
>>> @@ -142,6 +144,13 @@ irqfd_wakeup(wait_queue_t *wait, unsigned mode=
, int sync, void *key)
>>>   	struct _irqfd *irqfd =3D container_of(wait, struct _irqfd, wait)=
;
>>>   	unsigned long flags =3D (unsigned long)key;
>>>
>>> +	if (irqfd->kvm =3D=3D KVM_BAD_PTR) {
>>> +		printk(KERN_ERR "Wakeup bug detected! flags 0x%lx\n", flags);
>>> +		printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p,gsi=3D%d)\n", =
__func__,
>>> +			&irqfd->inject, irqfd, irqfd->kvm, irqfd->gsi);
>>> +		trigger_all_cpu_backtrace();
>>> +		return 0;
>>> +	}
>>>   	if (flags&   POLLIN)
>>>   		/* An event has been signaled, inject an interrupt */
>>>   		schedule_work(&irqfd->inject);
>>> @@ -153,6 +162,9 @@ irqfd_wakeup(wait_queue_t *wait, unsigned mode,=
 int sync, void *key)
>>>
>>>   		spin_lock_irqsave(&kvm->irqfds.lock, flags);
>>>
>>> +		printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p,gsi=3D%d,activ=
e=3D%d)\n", __func__,
>>> +			&irqfd->inject, irqfd, irqfd->kvm, irqfd->gsi,
>>> +			irqfd_is_active(irqfd));
>>>   		/*
>>>   		 * We must check if someone deactivated the irqfd before
>>>   		 * we could acquire the irqfds.lock since the item is
>>>
>> Hi,
>>
>> I noted seven "Eventfd bug detected" events during the night, and
>> only one Wakeup event:
>>
>> fifth.ah:Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.105868] Eventfd bug detected!
>> first.ad:Mar 10 01:08:15 ayrshire.u06.univ-nantes.prive kernel:
>> [34729.771260] Eventfd bug detected!
>> fourth.ad:Mar 10 02:54:41 ayrshire.u06.univ-nantes.prive kernel:
>> [41115.140873] Eventfd bug detected!
>> second.ab:Mar 10 02:41:55 ayrshire.u06.univ-nantes.prive kernel:
>> [40348.967192] Eventfd bug detected!
>> seventh.ab:Mar 10 07:52:29 ayrshire.u06.univ-nantes.prive kernel:
>> [58983.145646] Eventfd bug detected!
>> sixth.ab:Mar 10 05:19:54 ayrshire.u06.univ-nantes.prive kernel:
>> [49828.785558] Eventfd bug detected!
>> third.ae:Mar 10 02:54:07 ayrshire.u06.univ-nantes.prive kernel:
>> [41081.638633] Eventfd bug detected!
>>
>> grep -i wakeup *
>> seventh.ab:Mar 10 07:52:29 ayrshire.u06.univ-nantes.prive kernel:
>> [58983.154161]  [<ffffffffa02cbf96>] vhost_poll_wakeup+0x16/0x20
>> [vhost_net
>>
>>
>> Here is a trace, for the thirst event:
>>
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.101747]
>> irqfd_deactivate(irqfd=3Dffff88042e0b5e00,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.101873] irqfd_shutdown(work=3Dffff88042e0b5e80,irqfd=3Dffff88=
042e0b5e00,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.101928] remove wq at
>> irqfd_shutdown(work=3Dffff88042e0b5e80,irqfd=3Dffff88042e0b5e00)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.101990] kfree at
>> irqfd_shutdown(work=3Dffff88042e0b5e80,irqfd=3Dffff88042e0b5e00)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.102381]
>> kvm_irqfd_assign(irqfd=3Dffff88080f7aa818,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.103796] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.103833]
>> irqfd_deactivate(irqfd=3Dffff88080f7aa818,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.103904] irqfd_shutdown(work=3Dffff88080f7aa898,irqfd=3Dffff88=
080f7aa818,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.103958] remove wq at
>> irqfd_shutdown(work=3Dffff88080f7aa898,irqfd=3Dffff88080f7aa818)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.104023] kfree at
>> irqfd_shutdown(work=3Dffff88080f7aa898,irqfd=3Dffff88080f7aa818)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.104311]
>> kvm_irqfd_assign(irqfd=3Dffff88081a190b78,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.104511] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.104549]
>> irqfd_deactivate(irqfd=3Dffff88081a190b78,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.104614] irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88=
081a190b78,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.104667] remove wq at
>> irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a190b78)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.104715] kfree at
>> irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a190b78)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.104911]
>> kvm_irqfd_assign(irqfd=3Dffff880853b8caa0,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.105868] Eventfd bug detected!
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.105901] irqfd_inject(work=3Dffff88042e0b5e60,irqfd=3Dffff8804=
2e0b5e00,kvm=3D6b6b6b6b6b6b6b6b,gsi=3D1802201963)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.105951] sending NMI to all CPUs:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.105961] NMI backtrace for cpu 0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.105986=
] CPU 0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.105992] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106557=
]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106581] Pid: 10, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17 Dell Inc. PowerEdge M605/0K543T
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106644] RIP: 0010:[<ffffffff8105fa4b>]  [<ffffffff8105fa4b>]
>> default_send_IPI_mask_sequence_phys+0xbb/0xe0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106706] RSP: 0018:ffff88045fcb1d50  EFLAGS: 00000046
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106735] RAX: ffff88087fc00000 RBX: 0000000000000002 RCX:
>> 0000000000000008
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106767] RDX: 0000000000000001 RSI: 0000000000000020 RDI:
>> 0000000000000020
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106799] RBP: ffff88045fcb1d90 R08: ffffffff8159faf0 R09:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106831] R10: 0000000000000000 R11: 0000000000000006 R12:
>> 000000000000c620
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106863] R13: ffffffff8159faf0 R14: 0000000000000400 R15:
>> 0000000000000286
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106896] FS:  00007f66f7754720(0000) GS:ffff88007f800000(0000)
>> knlGS:0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106944] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.106973] CR2: 0000000000e64048 CR3: 000000045ea45000 CR4:
>> 00000000000006f0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.107005] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.107037] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.107070] Process kworker/0:1 (pid: 10, threadinfo
>> ffff88045fcb0000, task ffff88045fcaae70)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.107117=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.107138]  ffffffff00000000 0000000000000000 ffff88045fcb1d70
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  6b6b6b6b6b6b6b6b ffff88007f814e00 ffffffff81008ba0
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  ffff88045fcb1da0 ffffffff81062c12 ffff88045fcb1dc0
>> ffffffff8105fb3c
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81008ba0>] ? irqfd_inject+0x0/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81062c12>] physflat_send_IPI_all+0x12/0x20
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff8105fb3c>]
>> arch_trigger_all_cpu_backtrace+0x3c/0x70
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81008c2f>] irqfd_inject+0x8f/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a971b>] process_one_work+0x11b/0x450
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a9e97>] worker_thread+0x157/0x410
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81078519>] ? __wake_up_common+0x59/0x90
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a9d40>] ? worker_thread+0x0/0x410
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810ad8f6>] kthread+0x96/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81041c64>] kernel_thread_helper+0x4/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810ad860>] ? kthread+0x0/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81041c60>] ? kernel_thread_helper+0x0/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011] Code: 83 fb 02 44 89 f0 0f 45 c3 89 04 25 00 c3 5f ff
>> eb 9e 4c 89 ff 57 9d 66 66 90 66 90 48 83 c4 18 5b 41 5c 41 5d 41 5e
>> 41 5f c9 c3<48>  8b 05 4e fb 53 00 48 89 55 c8 89 4d c0 ff 90 58 01
>> 00 00 48
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81008ba0>] ? irqfd_inject+0x0/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81062c12>] physflat_send_IPI_all+0x12/0x20
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff8105fb3c>]
>> arch_trigger_all_cpu_backtrace+0x3c/0x70
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81008c2f>] irqfd_inject+0x8f/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a971b>] process_one_work+0x11b/0x450
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a9e97>] worker_thread+0x157/0x410
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81078519>] ? __wake_up_common+0x59/0x90
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a9d40>] ? worker_thread+0x0/0x410
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810ad8f6>] kthread+0x96/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81041c64>] kernel_thread_helper+0x4/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810ad860>] ? kthread+0x0/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81041c60>] ? kernel_thread_helper+0x0/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011] Pid: 10, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]<NMI>   [<ffffffff8104a786>] ? show_regs+0x26/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff8105fa4b>] ?
>> default_send_IPI_mask_sequence_phys+0xbb/0xe0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]<<EOE>>   [<ffffffff81008ba0>] ? irqfd_inject+0x0/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81062c12>] physflat_send_IPI_all+0x12/0x20
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff8105fb3c>]
>> arch_trigger_all_cpu_backtrace+0x3c/0x70
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81008c2f>] irqfd_inject+0x8f/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a971b>] process_one_work+0x11b/0x450
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a9e97>] worker_thread+0x157/0x410
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81078519>] ? __wake_up_common+0x59/0x90
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810a9d40>] ? worker_thread+0x0/0x410
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810ad8f6>] kthread+0x96/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81041c64>] kernel_thread_helper+0x4/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff810ad860>] ? kthread+0x0/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108011]  [<ffffffff81041c60>] ? kernel_thread_helper+0x0/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110243] NMI backtrace for cpu 3
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110272=
] CPU 3
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110280] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110882=
]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110906] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17 Dell Inc. PowerEdge M605/0K543T
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110970] RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]
>> native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111030] RSP: 0018:ffff88045fcd3ea8  EFLAGS: 00000246
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111059] RAX: 0000000000000000 RBX: 0000000000000003 RCX:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111091] RDX: 0000000000000000 RSI: ffff88045fcd3ee4 RDI:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111123] RBP: ffff88045fcd3ea8 R08: 0000000000000000 R09:
>> 0000000000000001
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111155] R10: 0000000000000000 R11: 0000000000000001 R12:
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111186] R13: 0000000000000003 R14: 0000000000000000 R15:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111220] FS:  00007fb1eafc6740(0000) GS:ffff88087fc40000(0000)
>> knlGS:0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111268] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111297] CR2: 00007ff12a981de0 CR3: 000000045569f000 CR4:
>> 00000000000006e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111329] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111362] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111395] Process kworker/0:1 (pid: 0, threadinfo
>> ffff88045fcd2000, task ffff88045fcca820)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111442=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111463]  ffff88045fcd3ec8 ffffffff8104a016 ffff88045fcd3ee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111515]  ffff88045fcd3ef8 ffffffff8104a168 ffff88045fcd3ee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111566]  ffff88045fcd2010 ffffffff8159faf0 ffff88045fcd3f28
>> ffffffff8104003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111618] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111648]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111680]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111712]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111745]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111774] Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84
>> 00 00 00 00 00 55 48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48
>> 89 e5 fb f4<c9>  c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66
>> 0f 1f 84
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111982] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112007]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112038]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112069]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112099]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112131] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112176] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112198]<NMI>   [<ffffffff8104a786>] ? show_regs+0x26/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112238]  [<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112272]  [<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112303]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112332]  [<ffffffff81066716>] ? native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112361]<<EOE>>   [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112399]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112430]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112460]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112024] NMI backtrace for cpu 2
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112024=
] CPU 2
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112024] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616=
]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17 Dell Inc. PowerEdge M605/0K543T
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]
>> native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] RSP: 0018:ffff88045fcc5ea8  EFLAGS: 00000246
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] RAX: 0000000000000000 RBX: 0000000000000002 RCX:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] RDX: 0000000000000000 RSI: ffff88045fcc5ee4 RDI:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] RBP: ffff88045fcc5ea8 R08: 0000000000000000 R09:
>> 0000000000000001
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] R10: 0000000000000000 R11: 0000000000000000 R12:
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] R13: 0000000000000002 R14: 0000000000000000 R15:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] FS:  00007f66f7754720(0000) GS:ffff88007f840000(0000)
>> knlGS:0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] CR2: 00007f241ad1f0b8 CR3: 000000045ea45000 CR4:
>> 00000000000006f0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] Process kworker/0:1 (pid: 0, threadinfo
>> ffff88045fcc4000, task ffff88045fcb87e0)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  ffff88045fcc5ec8 ffffffff8104a016 ffff88045fcc5ee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  ffff88045fcc5ef8 ffffffff8104a168 ffff88045fcc5ee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  ffff88045fcc4010 ffffffff8159faf0 ffff88045fcc5f28
>> ffffffff8104003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84
>> 00 00 00 00 00 55 48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48
>> 89 e5 fb f4<c9>  c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66
>> 0f 1f 84
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]<NMI>   [<ffffffff8104a786>] ? show_regs+0x26/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff81066716>] ? native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]<<EOE>>   [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112616]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] NMI backtrace for cpu 1
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285=
] CPU 1
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285=
]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] Pid: 0, comm: kworker/0:0 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17 Dell Inc. PowerEdge M605/0K543T
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]
>> native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] RSP: 0018:ffff88045fcb3ea8  EFLAGS: 00000246
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] RAX: 0000000000000000 RBX: 0000000000000001 RCX:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] RDX: 0000000000000000 RSI: ffff88045fcb3ee4 RDI:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] RBP: ffff88045fcb3ea8 R08: 0000000000000000 R09:
>> ffff88087fc0e408
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] R10: 000028ce70db0d2f R11: 0000000000000001 R12:
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] R13: 0000000000000001 R14: 0000000000000000 R15:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] FS:  00007fb8e1893710(0000) GS:ffff88087fc00000(0000)
>> knlGS:0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] CR2: 00007f241aca71a0 CR3: 000000045ed50000 CR4:
>> 00000000000006e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] Process kworker/0:0 (pid: 0, threadinfo
>> ffff88045fcb2000, task ffff88045fcaa7a0)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  ffff88045fcb3ec8 ffffffff8104a016 ffff88045fcb3ee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  ffff88045fcb3ef8 ffffffff8104a168 ffff88045fcb3ee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  ffff88045fcb2010 ffffffff8159faf0 ffff88045fcb3f28
>> ffffffff8104003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84
>> 00 00 00 00 00 55 48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48
>> 89 e5 fb f4<c9>  c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66
>> 0f 1f 84
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]<NMI>   [<ffffffff8104a786>] ? show_regs+0x26/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]<<EOE>>   [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112285]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896] RAX: 0000000000000000 RBX: 0000000000000005 RCX:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896] RDX: 0000000000000000 RSI: ffff88045fd11ee4 RDI:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896]  ffff88045fd11ef8 ffffffff8104a168 ffff88045fd11ee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896]  ffff88045fd10010 ffffffff8159faf0 ffff88045fd11f28
>> ffffffff8104003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.110896] Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84
>> 00 00 00 00 00 55 48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48
>> 89 e5 fb f4<c9>  c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66
>> 0f 1f 84
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.119695] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.119695]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.119695]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.119695]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.119985]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.119985] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.119985] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.119985]<NMI>   [<ffffffff8104a786>] ? show_regs+0x26/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120119]  [<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120164]  [<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018] CR2: 00007f241ad1f0b8 CR3: 000000045ed50000 CR4:
>> 00000000000006e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018] Process kworker/0:1 (pid: 0, threadinfo
>> ffff88045fd00000, task ffff88045fcd8860)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018]  ffff88045fd01ec8 ffffffff8104a016 ffff88045fd01ee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018]  ffff88045fd01ef8 ffffffff8104a168 ffff88045fd01ee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018]  ffff88045fd00010 ffffffff8159faf0 ffff88045fd01f28
>> ffffffff8104003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.112018]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.123585] NMI backtrace for cpu 7
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.124502] RAX: 0000000000000000 RBX: 0000000000000007 RCX:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.125007] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.125206=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015=
]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17 Dell Inc. PowerEdge M605/0K543T
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]
>> native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] RSP: 0018:ffff88045fd23ea8  EFLAGS: 00000246
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] RAX: 0000000000000000 RBX: 0000000000000006 RCX:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] RDX: 0000000000000000 RSI: ffff88045fd23ee4 RDI:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] RBP: ffff88045fd23ea8 R08: 0000000000000000 R09:
>> ffff88007f8ce408
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] R10: 0000000000000000 R11: 0000000000000001 R12:
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015]  ffff88045fd23ec8 ffffffff8104a016 ffff88045fd23ee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108015]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] R10: 000028ce766a74a3 R11: 0000000000000001 R12:
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] R13: 0000000000000009 R14: 0000000000000000 R15:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] FS:  00007fa0cb316710(0000) GS:ffff88087fd00000(0000)
>> knlGS:0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] CR2: 0000000000e64048 CR3: 000000045ea45000 CR4:
>> 00000000000006e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] Process kworker/0:1 (pid: 0, threadinfo
>> ffff88045fd6e000, task ffff88045fd669a0)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  ffff88045fd6fec8 ffffffff8104a016 ffff88045fd6fee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  ffff88045fd6fef8 ffffffff8104a168 ffff88045fd6fee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  ffff88045fd6e010 ffffffff8159faf0 ffff88045fd6ff28
>> ffffffff8104003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84
>> 00 00 00 00 00 55 48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48
>> 89 e5 fb f4<c9>  c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66
>> 0f 1f 84
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]<NMI>   [<ffffffff8104a786>] ? show_regs+0x26/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff81066716>] ? native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]<<EOE>>   [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.126621]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] NMI backtrace for cpu 11
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] CPU 11
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333=
]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17 Dell Inc. PowerEdge M605/0K543T
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]
>> native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] RSP: 0018:ffff88045fd8fea8  EFLAGS: 00000246
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] RAX: 0000000000000000 RBX: 000000000000000b RCX:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] RDX: 0000000000000000 RSI: ffff88045fd8fee4 RDI:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] RBP: ffff88045fd8fea8 R08: 0000000000000000 R09:
>> ffff88087fd4e408
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] R10: 000028ce71c3578e R11: 0000000000000001 R12:
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] R13: 000000000000000b R14: 0000000000000000 R15:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] FS:  00007fa0ce156740(0000) GS:ffff88087fd40000(0000)
>> knlGS:0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] CR2: 00007f2421c3eae0 CR3: 000000045ea45000 CR4:
>> 00000000000006e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] Process kworker/0:1 (pid: 0, threadinfo
>> ffff88045fd8e000, task ffff88045fd86a20)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  ffff88045fd8fec8 ffffffff8104a016 ffff88045fd8fee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  ffff88045fd8fef8 ffffffff8104a168 ffff88045fd8fee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  ffff88045fd8e010 ffffffff8159faf0 ffff88045fd8ff28
>> ffffffff8104003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84
>> 00 00 00 00 00 55 48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48
>> 89 e5 fb f4<c9>  c3 0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66
>> 0f 1f 84
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]<NMI>   [<ffffffff8104a786>] ? show_regs+0x26/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff81066716>] ? native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]<<EOE>>   [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.111333]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] NMI backtrace for cpu 8
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010=
] CPU 8
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] Modules linked in: btrfs zlib_deflate crc32c
>> libcrc32c ufs qnx4 hfsplus hfs minix ntfs vfat msdos fat jfs
>> reiserfs ext4 jbd2 crc16 ext3 jbd vhost_net macvtap macvlan tun veth
>> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
>> cpufreq_ondemand freq_table cpufreq_conservative fuse xt_physdev
>> ip6t_LOG ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit
>> xt_tcpudp xt_state iptable_filter ip_tables x_tables
>> nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4
>> 8021q bridge stp ext2 mbcache dm_round_robin dm_multipath
>> nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer
>> snd soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm
>> pci_hotplug psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev
>> ghes serio_raw processor thermal_sys hed button xfs exportfs dm_mod
>> sg sr_mod cdrom usbhid hid usb_storage ses sd_mod enclosure lpfc
>> scsi_transport_fc ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2
>> ehci_hcd [last unloaded: scsi_wait_sca
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010=
]
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17 Dell Inc. PowerEdge M605/0K543T
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]
>> native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] RSP: 0018:ffff88045fd63ea8  EFLAGS: 00000246
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] RAX: 0000000000000000 RBX: 0000000000000008 RCX:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] RDX: 0000000000000000 RSI: ffff88045fd63ee4 RDI:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] RBP: ffff88045fd63ea8 R08: 0000000000000000 R09:
>> ffff88007f90e408
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] R10: 0000000000000000 R11: 0000000000000001 R12:
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] R13: 0000000000000008 R14: 0000000000000000 R15:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] FS:  00007fb8e0891710(0000) GS:ffff88007f900000(0000)
>> knlGS:0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] CR2: 0000000000e63f28 CR3: 000000045ed50000 CR4:
>> 00000000000006e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] Process kworker/0:1 (pid: 0, threadinfo
>> ffff88045fd62000, task ffff88045fd34960)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010]  ffff88045fd63ec8 ffffffff8104a016 ffff88045fd63ee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010]  ffff88045fd63ef8 ffffffff8104a168 ffff88045fd63ee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010]  ffff88045fd62010 ffffffff8159faf0 ffff88045fd63f28
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136088] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136098]
>> irqfd_deactivate(irqfd=3Dffff880853b8caa0,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84
>> 00 00 00 00 00 55 48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48
>> 89 e5 fb f4<c9>  c3 0f
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136661] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136665]
>> irqfd_deactivate(irqfd=3Dffff880810a21e00,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136702] irqfd_shutdown(work=3Dffff880810a21e80,irqfd=3Dffff88=
0810a21e00,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136709] remove wq at
>> irqfd_shutdown(work=3Dffff880810a21e80,irqfd=3Dffff880810a21e00)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136715] kfree at
>> irqfd_shutdown(work=3Dffff880810a21e80,irqfd=3Dffff880810a21e00)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] 1f 84 00 00 00
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136910]
>> kvm_irqfd_assign(irqfd=3Dffff880853b8caa0,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] 00 00 55 48 89 e5 f4 c9 c3 66 0f 1f 84
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010]  [<ffffffff8104a168>] c1e_idle+0x58/0x120
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.108010]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136975] Pid: 0, comm: kworker/0:1 Not tainted
>> 2.6.37.2-patchjp-110308-c+ #17
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136975] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136975]<NMI>   [<ffffffff8104a786>] ? show_regs+0x26/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136975]  [<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136975]  [<ffffffff813be5f0>] nmi+0x20/0x30
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.136975]  [<ffffffff81066716>] ? native_safe_halt+0x6/0x10
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004] FS:  00007f2787814700(0000) GS:ffff88007f940000(0000)
>> knlGS:0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004] CR2: 0000000000e63f28 CR3: 000000045ea45000 CR4:
>> 00000000000006e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>> 0000000000000400
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004] Process kworker/0:1 (pid: 0, threadinfo
>> ffff88045fd80000, task ffff88045fd769e0)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004=
] Stack:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  ffff88045fd81ec8 ffffffff8104a016 ffff88045fd81ee4
>> ffffffff8159faf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  ffff88045fd81ef8 ffffffff8104a168 ffff88045fd81ee8
>> 00000000810b3255
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  ffff88045fd80010 ffffffff8159faf0 ffff88045fd81f28
>> ffffffff8104003b
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004] Call Trace:
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  [<ffffffff8104a016>] default_idle+0x46/0xa0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  [<ffffffff8104003b>] cpu_idle+0x6b/0xf0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  [<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.120004]  [<ffffffff813b7247>] start_secondary+0x1b9/0x1be
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.148658] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.148687]
>> irqfd_deactivate(irqfd=3Dffff880853b8caa0,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.148759] irqfd_shutdown(work=3Dffff880853b8cb20,irqfd=3Dffff88=
0853b8caa0,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.148814] remove wq at
>> irqfd_shutdown(work=3Dffff880853b8cb20,irqfd=3Dffff880853b8caa0)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.148862] kfree at
>> irqfd_shutdown(work=3Dffff880853b8cb20,irqfd=3Dffff880853b8caa0)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.149086]
>> kvm_irqfd_assign(irqfd=3Dffff88081a190b78,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.149379] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D48)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.149416]
>> irqfd_deactivate(irqfd=3Dffff88045efd3740,kvm=3Dffff8804542d0000,
>> gsi=3D48)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.149540] irqfd_shutdown(work=3Dffff88045efd37c0,irqfd=3Dffff88=
045efd3740,kvm=3Dffff8804542d0000,
>> gsi=3D48)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.149594] remove wq at
>> irqfd_shutdown(work=3Dffff88045efd37c0,irqfd=3Dffff88045efd3740)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.149643] kfree at
>> irqfd_shutdown(work=3Dffff88045efd37c0,irqfd=3Dffff88045efd3740)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.149922]
>> kvm_irqfd_assign(irqfd=3Dffff88080f7aa818,kvm=3Dffff8804542d0000,
>> gsi=3D48)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.171869] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.171907]
>> irqfd_deactivate(irqfd=3Dffff88081a190b78,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.171989] irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88=
081a190b78,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.172111] remove wq at
>> irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a190b78)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.172160] kfree at
>> irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a190b78)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.172493]
>> kvm_irqfd_assign(irqfd=3Dffff88083b062308,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.172672] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.172710]
>> irqfd_deactivate(irqfd=3Dffff88083b062308,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.172782] irqfd_shutdown(work=3Dffff88083b062388,irqfd=3Dffff88=
083b062308,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.172836] remove wq at
>> irqfd_shutdown(work=3Dffff88083b062388,irqfd=3Dffff88083b062308)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.172884] kfree at
>> irqfd_shutdown(work=3Dffff88083b062388,irqfd=3Dffff88083b062308)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.173074]
>> kvm_irqfd_assign(irqfd=3Dffff88081a190230,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.175303] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.175339]
>> irqfd_deactivate(irqfd=3Dffff88081a190230,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.175466] irqfd_shutdown(work=3Dffff88081a1902b0,irqfd=3Dffff88=
081a190230,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.175521] remove wq at
>> irqfd_shutdown(work=3Dffff88081a1902b0,irqfd=3Dffff88081a190230)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.175569] kfree at
>> irqfd_shutdown(work=3Dffff88081a1902b0,irqfd=3Dffff88081a190230)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.175769]
>> kvm_irqfd_assign(irqfd=3Dffff88045eabb668,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.176002] kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.176058]
>> irqfd_deactivate(irqfd=3Dffff88045eabb668,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.176122] irqfd_shutdown(work=3Dffff88045eabb6e8,irqfd=3Dffff88=
045eabb668,kvm=3Dffff8804542d0000,
>> gsi=3D24)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.176177] remove wq at
>> irqfd_shutdown(work=3Dffff88045eabb6e8,irqfd=3Dffff88045eabb668)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.176225] kfree at
>> irqfd_shutdown(work=3Dffff88045eabb6e8,irqfd=3Dffff88045eabb668)
>> Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:
>> [44867.176427]
>> kvm_irqfd_assign(irqfd=3Dffff88045ed96c50,kvm=3Dffff8804542d0000, gs=
i=3D24
>>
>>
>> You can find all the trace at the following adress:
>> http://filex.univ-nantes.fr/get?k=3DR94kna5sckVmdvCoKsn
>>
>> It's a tar.gz of seven file, from 100k to 200k each ;)
>>
>> Again, thanks a lot for the time you spent on this.
>>
>> Regards.
> Are you running a preemptible kernel?
> Does the following help at all?
>
> diff --git a/virt/kvm/eventfd.c b/virt/kvm/eventfd.c
> index 2ca4535..cdf51c9 100644
> --- a/virt/kvm/eventfd.c
> +++ b/virt/kvm/eventfd.c
> @@ -90,7 +90,7 @@ irqfd_shutdown(struct work_struct *work)
>   	 * We know no new events will be scheduled at this point, so block
>   	 * until all previously outstanding events have completed
>   	 */
> -	flush_work(&irqfd->inject);
> +	flush_work_sync(&irqfd->inject);
>
>   	/*
>   	 * It is now safe to release the object's resources
>
Hi,

thanks for the response.

root@ayrshire:~# zcat /proc/config.gz | grep -i preempt
# CONFIG_PREEMPT_RCU is not set
CONFIG_PREEMPT_NOTIFIERS=3Dy
CONFIG_PREEMPT_NONE=3Dy
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set

It does not seem to be a preemptible kernel.

I will test tour patch, and report the result.

Regards.

--=20
Jean-Philippe Menil - P=C3=B4le r=C3=A9seau Service IRTS
DSI Universit=C3=A9 de Nantes
jean-philippe.menil@univ-nantes.fr
Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09

