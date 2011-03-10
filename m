From: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Subject: Re: Bug inkvm_set_irq
Date: Thu, 10 Mar 2011 09:42:28 +0100
Message-ID: <4D788EF4.7040807@univ-nantes.fr>
References: <20110303144715.GA12400@redhat.com> <4D6FB313.1010400@univ-nantes.fr> <20110303155533.GA13310@redhat.com> <4D70AF3B.5080007@univ-nantes.fr> <20110304093500.GA31844@redhat.com> <4D70B339.3080001@univ-nantes.fr> <20110308111320.GA8002@redhat.com> <4D77727B.2000207@univ-nantes.fr> <20110309130000.GA30297@redhat.com> <4D777CDA.3050500@univ-nantes.fr> <20110309135918.GA31019@redhat.com>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110309135918.GA31019@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 09/03/2011 14:59, Michael S. Tsirkin a =C3=A9crit :
> On Wed, Mar 09, 2011 at 02:12:58PM +0100, Jean-Philippe Menil wrote:
>> Le 09/03/2011 14:00, Michael S. Tsirkin a =C3=A9crit :
>>> On Wed, Mar 09, 2011 at 01:28:43PM +0100, Jean-Philippe Menil wrote=
:
>>>> Le 08/03/2011 12:13, Michael S. Tsirkin a =C3=A9crit :
>>>>> On Fri, Mar 04, 2011 at 10:39:05AM +0100, Jean-Philippe Menil wro=
te:
>>>>>> Yes, it's a 2.6.37.2 kernel.
>>>>> OK, here's a debugging patch.
>>>>> Please run with slab debugging as previously until you see
>>>>> 'eventfd bug detected!' in dmesg or until there is a crash.
>>>>> It might be also useful to enable timestampts on printk with
>>>>>   Symbol: PRINTK_TIME [=3Dy]
>>>>>    =E2=94=82 Type  : boolean
>>>>>    =E2=94=82 Prompt: Show timing information on printks
>>>>>
>>>>> once you see the error, please upload the
>>>>> full dmesg output somewhere to we can track what
>>>>> goes on.
>>>>>
>>>>> Hopefully there won't be an oops this time which
>>>>> should make it easier for you to test (no need to
>>>>> reboot).
>>>>>
>>>>>
>>>>> diff --git a/virt/kvm/eventfd.c b/virt/kvm/eventfd.c
>>>>> index c1f1e3c..3cb679b 100644
>>>>> --- a/virt/kvm/eventfd.c
>>>>> +++ b/virt/kvm/eventfd.c
>>>>> @@ -32,6 +32,7 @@
>>>>>   #include<linux/eventfd.h>
>>>>>   #include<linux/kernel.h>
>>>>>   #include<linux/slab.h>
>>>>> +#include<linux/nmi.h>
>>>>>
>>>>>   #include "iodev.h"
>>>>>
>>>>> @@ -43,6 +44,8 @@
>>>>>    * ------------------------------------------------------------=
--------
>>>>>    */
>>>>>
>>>>> +#define KVM_BAD_PTR ((void*)(long)(0x6b6b6b6b6b6b6b6bull))
>>>>> +
>>>>>   struct _irqfd {
>>>>>   	struct kvm               *kvm;
>>>>>   	struct eventfd_ctx       *eventfd;
>>>>> @@ -61,6 +64,13 @@ irqfd_inject(struct work_struct *work)
>>>>>   {
>>>>>   	struct _irqfd *irqfd =3D container_of(work, struct _irqfd, inj=
ect);
>>>>>   	struct kvm *kvm =3D irqfd->kvm;
>>>>> +	if (kvm =3D=3D KVM_BAD_PTR) {
>>>>> +		printk(KERN_ERR "Eventfd bug detected!\n");
>>>>> +		printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p,gsi=3D%d)\n"=
, __func__,
>>>>> +			work, irqfd, kvm, irqfd->gsi);
>>>>> +		trigger_all_cpu_backtrace();
>>>>> +		return;
>>>>> +	}
>>>>>
>>>>>   	kvm_set_irq(kvm, KVM_USERSPACE_IRQ_SOURCE_ID, irqfd->gsi, 1);
>>>>>   	kvm_set_irq(kvm, KVM_USERSPACE_IRQ_SOURCE_ID, irqfd->gsi, 0);
>>>>> @@ -75,6 +85,8 @@ irqfd_shutdown(struct work_struct *work)
>>>>>   	struct _irqfd *irqfd =3D container_of(work, struct _irqfd, shu=
tdown);
>>>>>   	u64 cnt;
>>>>>
>>>>> +	printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p, gsi=3D%d)\n"=
, __func__,
>>>>> +	       work, irqfd, irqfd->kvm, irqfd->gsi);
>>>>>   	/*
>>>>>   	 * Synchronize with the wait-queue and unhook ourselves to pre=
vent
>>>>>   	 * further events.
>>>>> @@ -91,6 +103,8 @@ irqfd_shutdown(struct work_struct *work)
>>>>>   	 * It is now safe to release the object's resources
>>>>>   	 */
>>>>>   	eventfd_ctx_put(irqfd->eventfd);
>>>>> +	printk(KERN_ERR "kfree at %s(work=3D%p,irqfd=3D%p)\n", __func__=
,
>>>>> +	       work, irqfd);
>>>>>   	kfree(irqfd);
>>>>>   }
>>>>>
>>>>> @@ -111,6 +125,8 @@ static void
>>>>>   irqfd_deactivate(struct _irqfd *irqfd)
>>>>>   {
>>>>>   	BUG_ON(!irqfd_is_active(irqfd));
>>>>> +	printk(KERN_ERR "%s(irqfd=3D%p,kvm=3D%p, gsi=3D%d)\n", __func__=
,
>>>>> +	       irqfd, irqfd->kvm, irqfd->gsi);
>>>>>
>>>>>   	list_del_init(&irqfd->list);
>>>>>
>>>>> @@ -178,6 +194,8 @@ kvm_irqfd_assign(struct kvm *kvm, int fd, int=
 gsi)
>>>>>
>>>>>   	irqfd->kvm =3D kvm;
>>>>>   	irqfd->gsi =3D gsi;
>>>>> +	printk(KERN_ERR "%s(irqfd=3D%p,kvm=3D%p, gsi=3D%d)\n", __func__=
,
>>>>> +	       irqfd, kvm, gsi);
>>>>>   	INIT_LIST_HEAD(&irqfd->list);
>>>>>   	INIT_WORK(&irqfd->inject, irqfd_inject);
>>>>>   	INIT_WORK(&irqfd->shutdown, irqfd_shutdown);
>>>>> @@ -264,6 +282,8 @@ kvm_irqfd_deassign(struct kvm *kvm, int fd, i=
nt gsi)
>>>>>   	struct _irqfd *irqfd, *tmp;
>>>>>   	struct eventfd_ctx *eventfd;
>>>>>
>>>>> +	printk(KERN_ERR "%s(kvm=3D%p, gsi=3D%d)\n", __func__,
>>>>> +	       kvm, gsi);
>>>>>   	eventfd =3D eventfd_ctx_fdget(fd);
>>>>>   	if (IS_ERR(eventfd))
>>>>>   		return PTR_ERR(eventfd);
>>>>> @@ -305,6 +325,7 @@ void
>>>>>   kvm_irqfd_release(struct kvm *kvm)
>>>>>   {
>>>>>   	struct _irqfd *irqfd, *tmp;
>>>>> +	printk(KERN_ERR "%s(kvm=3D%p)\n", __func__, kvm);
>>>>>
>>>>>   	spin_lock_irq(&kvm->irqfds.lock);
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>>>> Hi,
>>>>
>>>> I boot the host with the patched kernel yesterday.
>>>> No crach until now, but two "Eventfd bug detected!" in the log at
>>>> "Mar  9 02:04:31" and "Mar  9 02:15:17"
>>>> You can find part of the log at the following adress:
>>>> http://filex.univ-nantes.fr/get?k=3DjL4Fe7yfSMN57toAH7V
>>>>
>>>> It a split file of the kern.log (1,4G), so if you need another par=
t
>>>> of the log, let me know.
>>>>
>>>> Thanks for all.
>>>>
>>>> Regards.
>>> Downloading, it's big :)
>>> What about some 1000 lines before and after Eventfd bug detected! l=
ine?
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe kvm" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Yes, sorry about that.
>> I could have split my log into a smaller file.
>>
>> I was a little afraid of not transmit enough informations, and i was
>> a bit wide.
>> I hope you can find usefull trace anyway.
>>
>> Regards.
>
> OK, use after free.
>
>
> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.593681]
> kvm_irqfd_assign(irqfd=3Dffff88045e8d6230,kvm=3Dffff88085151c000, gsi=
=3D26)
> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.605359]
> kvm_irqfd_deassign(kvm=3Dffff88085151c000, gsi=3D26)
> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.605388]
> irqfd_deactivate(irqfd=3Dffff88045e8d6230,kvm=3Dffff88085151c000, gsi=
=3D26)
> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.605461]
> irqfd_shutdown(work=3Dffff88045e8d62b0,irqfd=3Dffff88045e8d6230,kvm=3D=
ffff88085151c000,
> gsi=3D26)
> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.605509]
> kfree at irqfd_shutdown(work=3Dffff88045e8d62b0,irqfd=3Dffff88045e8d6=
230)
> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.605588]
> Eventfd bug detected!
> Mar  9 02:15:17 ayrshire.u06.univ-nantes.prive kernel: [37461.605612]
> irqfd_inject(work=3Dffff88045e8d6290,irqfd=3Dffff88045e8d6230,kvm=3D6=
b6b6b6b6b6b6b6b,gsi=3D1802201963)
>
>
> and 1802201963 is also 6b6b6b6b.
>
>
> I suspect that somehow, we get an event from eventfd even
> though we did eventfd_ctx_remove_wait_queue.
> Could you please try the following patch on top?
> When you see Eventfd bug or Wakeup bug, paste some
> last lines.
> For the full log file - better compress with xz.
>
>
> diff --git a/virt/kvm/eventfd.c b/virt/kvm/eventfd.c
> index 3cb679b..63aeba5 100644
> --- a/virt/kvm/eventfd.c
> +++ b/virt/kvm/eventfd.c
> @@ -92,6 +92,8 @@ irqfd_shutdown(struct work_struct *work)
>   	 * further events.
>   	 */
>   	eventfd_ctx_remove_wait_queue(irqfd->eventfd,&irqfd->wait,&cnt);
> +	printk(KERN_ERR "remove wq at %s(work=3D%p,irqfd=3D%p)\n", __func__=
,
> +	       work, irqfd);
>
>   	/*
>   	 * We know no new events will be scheduled at this point, so block
> @@ -142,6 +144,13 @@ irqfd_wakeup(wait_queue_t *wait, unsigned mode, =
int sync, void *key)
>   	struct _irqfd *irqfd =3D container_of(wait, struct _irqfd, wait);
>   	unsigned long flags =3D (unsigned long)key;
>
> +	if (irqfd->kvm =3D=3D KVM_BAD_PTR) {
> +		printk(KERN_ERR "Wakeup bug detected! flags 0x%lx\n", flags);
> +		printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p,gsi=3D%d)\n", __=
func__,
> +			&irqfd->inject, irqfd, irqfd->kvm, irqfd->gsi);
> +		trigger_all_cpu_backtrace();
> +		return 0;
> +	}
>   	if (flags&  POLLIN)
>   		/* An event has been signaled, inject an interrupt */
>   		schedule_work(&irqfd->inject);
> @@ -153,6 +162,9 @@ irqfd_wakeup(wait_queue_t *wait, unsigned mode, i=
nt sync, void *key)
>
>   		spin_lock_irqsave(&kvm->irqfds.lock, flags);
>
> +		printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p,gsi=3D%d,active=3D=
%d)\n", __func__,
> +			&irqfd->inject, irqfd, irqfd->kvm, irqfd->gsi,
> +			irqfd_is_active(irqfd));
>   		/*
>   		 * We must check if someone deactivated the irqfd before
>   		 * we could acquire the irqfds.lock since the item is
>
Hi,

I noted seven "Eventfd bug detected" events during the night, and only=20
one Wakeup event:

fifth.ah:Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel:=20
[44867.105868] Eventfd bug detected!
first.ad:Mar 10 01:08:15 ayrshire.u06.univ-nantes.prive kernel:=20
[34729.771260] Eventfd bug detected!
fourth.ad:Mar 10 02:54:41 ayrshire.u06.univ-nantes.prive kernel:=20
[41115.140873] Eventfd bug detected!
second.ab:Mar 10 02:41:55 ayrshire.u06.univ-nantes.prive kernel:=20
[40348.967192] Eventfd bug detected!
seventh.ab:Mar 10 07:52:29 ayrshire.u06.univ-nantes.prive kernel:=20
[58983.145646] Eventfd bug detected!
sixth.ab:Mar 10 05:19:54 ayrshire.u06.univ-nantes.prive kernel:=20
[49828.785558] Eventfd bug detected!
third.ae:Mar 10 02:54:07 ayrshire.u06.univ-nantes.prive kernel:=20
[41081.638633] Eventfd bug detected!

grep -i wakeup *
seventh.ab:Mar 10 07:52:29 ayrshire.u06.univ-nantes.prive kernel:=20
[58983.154161]  [<ffffffffa02cbf96>] vhost_poll_wakeup+0x16/0x20 [vhost=
_net


Here is a trace, for the thirst event:

Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.101747]=20
irqfd_deactivate(irqfd=3Dffff88042e0b5e00,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.101873]=20
irqfd_shutdown(work=3Dffff88042e0b5e80,irqfd=3Dffff88042e0b5e00,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.101928]=20
remove wq at irqfd_shutdown(work=3Dffff88042e0b5e80,irqfd=3Dffff88042e0=
b5e00)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.101990]=20
kfree at irqfd_shutdown(work=3Dffff88042e0b5e80,irqfd=3Dffff88042e0b5e0=
0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.102381]=20
kvm_irqfd_assign(irqfd=3Dffff88080f7aa818,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.103796]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.103833]=20
irqfd_deactivate(irqfd=3Dffff88080f7aa818,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.103904]=20
irqfd_shutdown(work=3Dffff88080f7aa898,irqfd=3Dffff88080f7aa818,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.103958]=20
remove wq at irqfd_shutdown(work=3Dffff88080f7aa898,irqfd=3Dffff88080f7=
aa818)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.104023]=20
kfree at irqfd_shutdown(work=3Dffff88080f7aa898,irqfd=3Dffff88080f7aa81=
8)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.104311]=20
kvm_irqfd_assign(irqfd=3Dffff88081a190b78,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.104511]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.104549]=20
irqfd_deactivate(irqfd=3Dffff88081a190b78,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.104614]=20
irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a190b78,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.104667]=20
remove wq at irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a1=
90b78)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.104715]=20
kfree at irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a190b7=
8)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.104911]=20
kvm_irqfd_assign(irqfd=3Dffff880853b8caa0,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.105868]=20
Eventfd bug detected!
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.105901]=20
irqfd_inject(work=3Dffff88042e0b5e60,irqfd=3Dffff88042e0b5e00,kvm=3D6b6=
b6b6b6b6b6b6b,gsi=3D1802201963)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.105951]=20
sending NMI to all CPUs:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.105961]=20
NMI backtrace for cpu 0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.105986] C=
PU 0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.105992]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106557]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106581]=20
Pid: 10, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17=20
Dell Inc. PowerEdge M605/0K543T
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106644]=20
RIP: 0010:[<ffffffff8105fa4b>]  [<ffffffff8105fa4b>]=20
default_send_IPI_mask_sequence_phys+0xbb/0xe0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106706]=20
RSP: 0018:ffff88045fcb1d50  EFLAGS: 00000046
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106735]=20
RAX: ffff88087fc00000 RBX: 0000000000000002 RCX: 0000000000000008
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106767]=20
RDX: 0000000000000001 RSI: 0000000000000020 RDI: 0000000000000020
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106799]=20
RBP: ffff88045fcb1d90 R08: ffffffff8159faf0 R09: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106831]=20
R10: 0000000000000000 R11: 0000000000000006 R12: 000000000000c620
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106863]=20
R13: ffffffff8159faf0 R14: 0000000000000400 R15: 0000000000000286
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106896]=20
=46S:  00007f66f7754720(0000) GS:ffff88007f800000(0000) knlGS:000000000=
0000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106944]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.106973]=20
CR2: 0000000000e64048 CR3: 000000045ea45000 CR4: 00000000000006f0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.107005]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.107037]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.107070]=20
Process kworker/0:1 (pid: 10, threadinfo ffff88045fcb0000, task=20
ffff88045fcaae70)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.107117] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.107138] =20
ffffffff00000000 0000000000000000 ffff88045fcb1d70 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
6b6b6b6b6b6b6b6b ffff88007f814e00 ffffffff81008ba0 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
ffff88045fcb1da0 ffffffff81062c12 ffff88045fcb1dc0 ffffffff8105fb3c
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81008ba0>] ? irqfd_inject+0x0/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81062c12>] physflat_send_IPI_all+0x12/0x20
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff8105fb3c>] arch_trigger_all_cpu_backtrace+0x3c/0x70
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81008c2f>] irqfd_inject+0x8f/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a971b>] process_one_work+0x11b/0x450
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a9e97>] worker_thread+0x157/0x410
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81078519>] ? __wake_up_common+0x59/0x90
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a9d40>] ? worker_thread+0x0/0x410
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810ad8f6>] kthread+0x96/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81041c64>] kernel_thread_helper+0x4/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810ad860>] ? kthread+0x0/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81041c60>] ? kernel_thread_helper+0x0/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011]=20
Code: 83 fb 02 44 89 f0 0f 45 c3 89 04 25 00 c3 5f ff eb 9e 4c 89 ff 57=
=20
9d 66 66 90 66 90 48 83 c4 18 5b 41 5c 41 5d 41 5e 41 5f c9 c3 <48> 8b=20
05 4e fb 53 00 48 89 55 c8 89 4d c0 ff 90 58 01 00 00 48
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81008ba0>] ? irqfd_inject+0x0/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81062c12>] physflat_send_IPI_all+0x12/0x20
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff8105fb3c>] arch_trigger_all_cpu_backtrace+0x3c/0x70
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81008c2f>] irqfd_inject+0x8f/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a971b>] process_one_work+0x11b/0x450
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a9e97>] worker_thread+0x157/0x410
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81078519>] ? __wake_up_common+0x59/0x90
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a9d40>] ? worker_thread+0x0/0x410
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810ad8f6>] kthread+0x96/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81041c64>] kernel_thread_helper+0x4/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810ad860>] ? kthread+0x0/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81041c60>] ? kernel_thread_helper+0x0/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011]=20
Pid: 10, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011]=20
<NMI>  [<ffffffff8104a786>] ? show_regs+0x26/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff8105fa4b>] ? default_send_IPI_mask_sequence_phys+0xbb/0xe0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011]=20
<<EOE>>  [<ffffffff81008ba0>] ? irqfd_inject+0x0/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81062c12>] physflat_send_IPI_all+0x12/0x20
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff8105fb3c>] arch_trigger_all_cpu_backtrace+0x3c/0x70
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81008c2f>] irqfd_inject+0x8f/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a971b>] process_one_work+0x11b/0x450
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a9e97>] worker_thread+0x157/0x410
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81078519>] ? __wake_up_common+0x59/0x90
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810a9d40>] ? worker_thread+0x0/0x410
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810ad8f6>] kthread+0x96/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81041c64>] kernel_thread_helper+0x4/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff810ad860>] ? kthread+0x0/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108011] =20
[<ffffffff81041c60>] ? kernel_thread_helper+0x0/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110243]=20
NMI backtrace for cpu 3
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110272] C=
PU 3
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110280]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110882]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110906]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17=20
Dell Inc. PowerEdge M605/0K543T
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110970]=20
RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]=20
native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111030]=20
RSP: 0018:ffff88045fcd3ea8  EFLAGS: 00000246
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111059]=20
RAX: 0000000000000000 RBX: 0000000000000003 RCX: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111091]=20
RDX: 0000000000000000 RSI: ffff88045fcd3ee4 RDI: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111123]=20
RBP: ffff88045fcd3ea8 R08: 0000000000000000 R09: 0000000000000001
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111155]=20
R10: 0000000000000000 R11: 0000000000000001 R12: ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111186]=20
R13: 0000000000000003 R14: 0000000000000000 R15: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111220]=20
=46S:  00007fb1eafc6740(0000) GS:ffff88087fc40000(0000) knlGS:000000000=
0000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111268]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111297]=20
CR2: 00007ff12a981de0 CR3: 000000045569f000 CR4: 00000000000006e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111329]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111362]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111395]=20
Process kworker/0:1 (pid: 0, threadinfo ffff88045fcd2000, task=20
ffff88045fcca820)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111442] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111463] =20
ffff88045fcd3ec8 ffffffff8104a016 ffff88045fcd3ee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111515] =20
ffff88045fcd3ef8 ffffffff8104a168 ffff88045fcd3ee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111566] =20
ffff88045fcd2010 ffffffff8159faf0 ffff88045fcd3f28 ffffffff8104003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111618]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111648] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111680] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111712] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111745] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111774]=20
Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84 00 00 00 00 00 55=
=20
48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <c9> c3=20
0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66 0f 1f 84
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111982]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112007] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112038] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112069] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112099] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112131]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112176]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112198]=20
<NMI>  [<ffffffff8104a786>] ? show_regs+0x26/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112238] =20
[<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112272] =20
[<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112303] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112332] =20
[<ffffffff81066716>] ? native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112361]=20
<<EOE>>  [<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112399] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112430] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112460] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112024]=20
NMI backtrace for cpu 2
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112024] C=
PU 2
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112024]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17=20
Dell Inc. PowerEdge M605/0K543T
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]=20
native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
RSP: 0018:ffff88045fcc5ea8  EFLAGS: 00000246
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
RAX: 0000000000000000 RBX: 0000000000000002 RCX: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
RDX: 0000000000000000 RSI: ffff88045fcc5ee4 RDI: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
RBP: ffff88045fcc5ea8 R08: 0000000000000000 R09: 0000000000000001
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
R13: 0000000000000002 R14: 0000000000000000 R15: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
=46S:  00007f66f7754720(0000) GS:ffff88007f840000(0000) knlGS:000000000=
0000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
CR2: 00007f241ad1f0b8 CR3: 000000045ea45000 CR4: 00000000000006f0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
Process kworker/0:1 (pid: 0, threadinfo ffff88045fcc4000, task=20
ffff88045fcb87e0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
ffff88045fcc5ec8 ffffffff8104a016 ffff88045fcc5ee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
ffff88045fcc5ef8 ffffffff8104a168 ffff88045fcc5ee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
ffff88045fcc4010 ffffffff8159faf0 ffff88045fcc5f28 ffffffff8104003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84 00 00 00 00 00 55=
=20
48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <c9> c3=20
0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66 0f 1f 84
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
<NMI>  [<ffffffff8104a786>] ? show_regs+0x26/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff81066716>] ? native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616]=20
<<EOE>>  [<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112616] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
NMI backtrace for cpu 1
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] C=
PU 1
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
Pid: 0, comm: kworker/0:0 Not tainted 2.6.37.2-patchjp-110308-c+ #17=20
Dell Inc. PowerEdge M605/0K543T
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]=20
native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
RSP: 0018:ffff88045fcb3ea8  EFLAGS: 00000246
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
RDX: 0000000000000000 RSI: ffff88045fcb3ee4 RDI: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
RBP: ffff88045fcb3ea8 R08: 0000000000000000 R09: ffff88087fc0e408
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
R10: 000028ce70db0d2f R11: 0000000000000001 R12: ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
=46S:  00007fb8e1893710(0000) GS:ffff88087fc00000(0000) knlGS:000000000=
0000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
CR2: 00007f241aca71a0 CR3: 000000045ed50000 CR4: 00000000000006e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
Process kworker/0:0 (pid: 0, threadinfo ffff88045fcb2000, task=20
ffff88045fcaa7a0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
ffff88045fcb3ec8 ffffffff8104a016 ffff88045fcb3ee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
ffff88045fcb3ef8 ffffffff8104a168 ffff88045fcb3ee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
ffff88045fcb2010 ffffffff8159faf0 ffff88045fcb3f28 ffffffff8104003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84 00 00 00 00 00 55=
=20
48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <c9> c3=20
0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66 0f 1f 84
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
<NMI>  [<ffffffff8104a786>] ? show_regs+0x26/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285]=20
<<EOE>>  [<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112285] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896]=20
RAX: 0000000000000000 RBX: 0000000000000005 RCX: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896]=20
RDX: 0000000000000000 RSI: ffff88045fd11ee4 RDI: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896] =20
ffff88045fd11ef8 ffffffff8104a168 ffff88045fd11ee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896] =20
ffff88045fd10010 ffffffff8159faf0 ffff88045fd11f28 ffffffff8104003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.110896]=20
Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84 00 00 00 00 00 55=
=20
48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <c9> c3=20
0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66 0f 1f 84
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.119695]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.119695] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.119695] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.119695] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.119985] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.119985]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.119985]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.119985]=20
<NMI>  [<ffffffff8104a786>] ? show_regs+0x26/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120119] =20
[<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120164] =20
[<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018]=20
CR2: 00007f241ad1f0b8 CR3: 000000045ed50000 CR4: 00000000000006e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018]=20
Process kworker/0:1 (pid: 0, threadinfo ffff88045fd00000, task=20
ffff88045fcd8860)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] =20
ffff88045fd01ec8 ffffffff8104a016 ffff88045fd01ee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] =20
ffff88045fd01ef8 ffffffff8104a168 ffff88045fd01ee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] =20
ffff88045fd00010 ffffffff8159faf0 ffff88045fd01f28 ffffffff8104003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.112018] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.123585]=20
NMI backtrace for cpu 7
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.124502]=20
RAX: 0000000000000000 RBX: 0000000000000007 RCX: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.125007]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.125206] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17=20
Dell Inc. PowerEdge M605/0K543T
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]=20
native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
RSP: 0018:ffff88045fd23ea8  EFLAGS: 00000246
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
RAX: 0000000000000000 RBX: 0000000000000006 RCX: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
RDX: 0000000000000000 RSI: ffff88045fd23ee4 RDI: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
RBP: ffff88045fd23ea8 R08: 0000000000000000 R09: ffff88007f8ce408
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
R10: 0000000000000000 R11: 0000000000000001 R12: ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] =20
ffff88045fd23ec8 ffffffff8104a016 ffff88045fd23ee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108015] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
R10: 000028ce766a74a3 R11: 0000000000000001 R12: ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
R13: 0000000000000009 R14: 0000000000000000 R15: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
=46S:  00007fa0cb316710(0000) GS:ffff88087fd00000(0000) knlGS:000000000=
0000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
CR2: 0000000000e64048 CR3: 000000045ea45000 CR4: 00000000000006e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
Process kworker/0:1 (pid: 0, threadinfo ffff88045fd6e000, task=20
ffff88045fd669a0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
ffff88045fd6fec8 ffffffff8104a016 ffff88045fd6fee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
ffff88045fd6fef8 ffffffff8104a168 ffff88045fd6fee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
ffff88045fd6e010 ffffffff8159faf0 ffff88045fd6ff28 ffffffff8104003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84 00 00 00 00 00 55=
=20
48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <c9> c3=20
0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66 0f 1f 84
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
<NMI>  [<ffffffff8104a786>] ? show_regs+0x26/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff81066716>] ? native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621]=20
<<EOE>>  [<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.126621] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
NMI backtrace for cpu 11
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
CPU 11
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17=20
Dell Inc. PowerEdge M605/0K543T
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]=20
native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
RSP: 0018:ffff88045fd8fea8  EFLAGS: 00000246
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
RAX: 0000000000000000 RBX: 000000000000000b RCX: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
RDX: 0000000000000000 RSI: ffff88045fd8fee4 RDI: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
RBP: ffff88045fd8fea8 R08: 0000000000000000 R09: ffff88087fd4e408
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
R10: 000028ce71c3578e R11: 0000000000000001 R12: ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
R13: 000000000000000b R14: 0000000000000000 R15: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
=46S:  00007fa0ce156740(0000) GS:ffff88087fd40000(0000) knlGS:000000000=
0000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
CR2: 00007f2421c3eae0 CR3: 000000045ea45000 CR4: 00000000000006e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
Process kworker/0:1 (pid: 0, threadinfo ffff88045fd8e000, task=20
ffff88045fd86a20)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
ffff88045fd8fec8 ffffffff8104a016 ffff88045fd8fee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
ffff88045fd8fef8 ffffffff8104a168 ffff88045fd8fee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
ffff88045fd8e010 ffffffff8159faf0 ffff88045fd8ff28 ffffffff8104003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84 00 00 00 00 00 55=
=20
48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <c9> c3=20
0f 1f 84 00 00 00 00 00 55 48 89 e5 f4 c9 c3 66 0f 1f 84
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
<NMI>  [<ffffffff8104a786>] ? show_regs+0x26/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff81066716>] ? native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333]=20
<<EOE>>  [<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.111333] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
NMI backtrace for cpu 8
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] C=
PU 8
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
Modules linked in: btrfs zlib_deflate crc32c libcrc32c ufs qnx4 hfsplus=
=20
hfs minix ntfs vfat msdos fat jfs reiserfs ext4 jbd2 crc16 ext3 jbd=20
vhost_net macvtap macvlan tun veth powernow_k8 mperf cpufreq_userspace=20
cpufreq_stats cpufreq_powersave cpufreq_ondemand freq_table=20
cpufreq_conservative fuse xt_physdev ip6t_LOG ip6table_filter ip6_table=
s=20
ipt_LOG xt_multiport xt_limit xt_tcpudp xt_state iptable_filter=20
ip_tables x_tables nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4=
=20
nf_defrag_ipv4 8021q bridge stp ext2 mbcache dm_round_robin dm_multipat=
h=20
nf_conntrack_ipv6 nf_conntrack nf_defrag_ipv6 ipv6 snd_pcm snd_timer sn=
d=20
soundcore snd_page_alloc shpchp i2c_nforce2 tpm_tis tpm pci_hotplug=20
psmouse evdev i2c_core tpm_bios dcdbas pcspkr joydev ghes serio_raw=20
processor thermal_sys hed button xfs exportfs dm_mod sg sr_mod cdrom=20
usbhid hid usb_storage ses sd_mod enclosure lpfc scsi_transport_fc=20
ohci_hcd scsi_tgt megaraid_sas scsi_mod bnx2 ehci_hcd [last unloaded:=20
scsi_wait_sca
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: n]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17=20
Dell Inc. PowerEdge M605/0K543T
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
RIP: 0010:[<ffffffff81066716>]  [<ffffffff81066716>]=20
native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
RSP: 0018:ffff88045fd63ea8  EFLAGS: 00000246
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
RAX: 0000000000000000 RBX: 0000000000000008 RCX: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
RDX: 0000000000000000 RSI: ffff88045fd63ee4 RDI: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
RBP: ffff88045fd63ea8 R08: 0000000000000000 R09: ffff88007f90e408
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
R10: 0000000000000000 R11: 0000000000000001 R12: ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
R13: 0000000000000008 R14: 0000000000000000 R15: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
=46S:  00007fb8e0891710(0000) GS:ffff88007f900000(0000) knlGS:000000000=
0000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
CR2: 0000000000e63f28 CR3: 000000045ed50000 CR4: 00000000000006e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
Process kworker/0:1 (pid: 0, threadinfo ffff88045fd62000, task=20
ffff88045fd34960)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] =20
ffff88045fd63ec8 ffffffff8104a016 ffff88045fd63ee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] =20
ffff88045fd63ef8 ffffffff8104a168 ffff88045fd63ee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] =20
ffff88045fd62010 ffffffff8159faf0 ffff88045fd63f28
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136088]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136098]=20
irqfd_deactivate(irqfd=3Dffff880853b8caa0,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
Code: 00 00 00 00 00 55 48 89 e5 fa c9 c3 66 0f 1f 84 00 00 00 00 00 55=
=20
48 89 e5 fb c9 c3 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 fb f4 <c9> c3 =
0f
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136661]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136665]=20
irqfd_deactivate(irqfd=3Dffff880810a21e00,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136702]=20
irqfd_shutdown(work=3Dffff880810a21e80,irqfd=3Dffff880810a21e00,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136709]=20
remove wq at irqfd_shutdown(work=3Dffff880810a21e80,irqfd=3Dffff880810a=
21e00)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136715]=20
kfree at irqfd_shutdown(work=3Dffff880810a21e80,irqfd=3Dffff880810a21e0=
0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] 1=
f=20
84 00 00 00
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136910]=20
kvm_irqfd_assign(irqfd=3Dffff880853b8caa0,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] 0=
0=20
00 55 48 89 e5 f4 c9 c3 66 0f 1f 84
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] =20
[<ffffffff8104a168>] c1e_idle+0x58/0x120
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.108010] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136975]=20
Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-patchjp-110308-c+ #17
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136975]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136975]=20
<NMI>  [<ffffffff8104a786>] ? show_regs+0x26/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136975] =20
[<ffffffff8105fde1>] nmi_watchdog_tick+0x191/0x1b0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136975] =20
[<ffffffff813be5f0>] nmi+0x20/0x30
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.136975] =20
[<ffffffff81066716>] ? native_safe_halt+0x6/0x10
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004]=20
=46S:  00007f2787814700(0000) GS:ffff88007f940000(0000) knlGS:000000000=
0000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004]=20
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004]=20
CR2: 0000000000e63f28 CR3: 000000045ea45000 CR4: 00000000000006e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004]=20
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004]=20
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004]=20
Process kworker/0:1 (pid: 0, threadinfo ffff88045fd80000, task=20
ffff88045fd769e0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] S=
tack:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
ffff88045fd81ec8 ffffffff8104a016 ffff88045fd81ee4 ffffffff8159faf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
ffff88045fd81ef8 ffffffff8104a168 ffff88045fd81ee8 00000000810b3255
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
ffff88045fd80010 ffffffff8159faf0 ffff88045fd81f28 ffffffff8104003b
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004]=20
Call Trace:
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
[<ffffffff8104a016>] default_idle+0x46/0xa0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
[<ffffffff8104003b>] cpu_idle+0x6b/0xf0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
[<ffffffff81042ef1>] do_nmi+0x1c1/0x2e0
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.120004] =20
[<ffffffff813b7247>] start_secondary+0x1b9/0x1be
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.148658]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.148687]=20
irqfd_deactivate(irqfd=3Dffff880853b8caa0,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.148759]=20
irqfd_shutdown(work=3Dffff880853b8cb20,irqfd=3Dffff880853b8caa0,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.148814]=20
remove wq at irqfd_shutdown(work=3Dffff880853b8cb20,irqfd=3Dffff880853b=
8caa0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.148862]=20
kfree at irqfd_shutdown(work=3Dffff880853b8cb20,irqfd=3Dffff880853b8caa=
0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.149086]=20
kvm_irqfd_assign(irqfd=3Dffff88081a190b78,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.149379]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D48)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.149416]=20
irqfd_deactivate(irqfd=3Dffff88045efd3740,kvm=3Dffff8804542d0000, gsi=3D=
48)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.149540]=20
irqfd_shutdown(work=3Dffff88045efd37c0,irqfd=3Dffff88045efd3740,kvm=3Df=
fff8804542d0000,=20
gsi=3D48)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.149594]=20
remove wq at irqfd_shutdown(work=3Dffff88045efd37c0,irqfd=3Dffff88045ef=
d3740)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.149643]=20
kfree at irqfd_shutdown(work=3Dffff88045efd37c0,irqfd=3Dffff88045efd374=
0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.149922]=20
kvm_irqfd_assign(irqfd=3Dffff88080f7aa818,kvm=3Dffff8804542d0000, gsi=3D=
48)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.171869]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.171907]=20
irqfd_deactivate(irqfd=3Dffff88081a190b78,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.171989]=20
irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a190b78,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.172111]=20
remove wq at irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a1=
90b78)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.172160]=20
kfree at irqfd_shutdown(work=3Dffff88081a190bf8,irqfd=3Dffff88081a190b7=
8)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.172493]=20
kvm_irqfd_assign(irqfd=3Dffff88083b062308,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.172672]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.172710]=20
irqfd_deactivate(irqfd=3Dffff88083b062308,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.172782]=20
irqfd_shutdown(work=3Dffff88083b062388,irqfd=3Dffff88083b062308,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.172836]=20
remove wq at irqfd_shutdown(work=3Dffff88083b062388,irqfd=3Dffff88083b0=
62308)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.172884]=20
kfree at irqfd_shutdown(work=3Dffff88083b062388,irqfd=3Dffff88083b06230=
8)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.173074]=20
kvm_irqfd_assign(irqfd=3Dffff88081a190230,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.175303]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.175339]=20
irqfd_deactivate(irqfd=3Dffff88081a190230,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.175466]=20
irqfd_shutdown(work=3Dffff88081a1902b0,irqfd=3Dffff88081a190230,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.175521]=20
remove wq at irqfd_shutdown(work=3Dffff88081a1902b0,irqfd=3Dffff88081a1=
90230)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.175569]=20
kfree at irqfd_shutdown(work=3Dffff88081a1902b0,irqfd=3Dffff88081a19023=
0)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.175769]=20
kvm_irqfd_assign(irqfd=3Dffff88045eabb668,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.176002]=20
kvm_irqfd_deassign(kvm=3Dffff8804542d0000, gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.176058]=20
irqfd_deactivate(irqfd=3Dffff88045eabb668,kvm=3Dffff8804542d0000, gsi=3D=
24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.176122]=20
irqfd_shutdown(work=3Dffff88045eabb6e8,irqfd=3Dffff88045eabb668,kvm=3Df=
fff8804542d0000,=20
gsi=3D24)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.176177]=20
remove wq at irqfd_shutdown(work=3Dffff88045eabb6e8,irqfd=3Dffff88045ea=
bb668)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.176225]=20
kfree at irqfd_shutdown(work=3Dffff88045eabb6e8,irqfd=3Dffff88045eabb66=
8)
Mar 10 03:57:13 ayrshire.u06.univ-nantes.prive kernel: [44867.176427]=20
kvm_irqfd_assign(irqfd=3Dffff88045ed96c50,kvm=3Dffff8804542d0000, gsi=3D=
24


You can find all the trace at the following adress:
http://filex.univ-nantes.fr/get?k=3DR94kna5sckVmdvCoKsn

It's a tar.gz of seven file, from 100k to 200k each ;)

Again, thanks a lot for the time you spent on this.

Regards.

--=20
Jean-Philippe Menil - P=C3=B4le r=C3=A9seau Service IRTS
DSI Universit=C3=A9 de Nantes
jean-philippe.menil@univ-nantes.fr
Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09

