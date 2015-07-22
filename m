From: Frank Schreuder <fschreuder@transip.nl>
Subject: Re: reproducable panic eviction work queue
Date: Wed, 22 Jul 2015 10:17:23 +0200
Message-ID: <55AF5193.9090900@transip.nl>
References: <F8D94413-90A2-4F80-AAA2-7A6AB57DF314@transip.nl>
 <1437209795.1026.31.camel@edumazet-glaptop2.roam.corp.google.com>
 <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl>
 <55AA243D.5020306@cumulusnetworks.com>
 <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
 <55AA717D.8080800@cumulusnetworks.com> <55ACEDE9.3090205@transip.nl>
 <20150720143023.GC11985@breakpoint.cc> <55AE3208.8090403@transip.nl>
 <20150721183453.GL11985@breakpoint.cc> <55AF4FD7.2010009@transip.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Johan Schuijt <johan@transip.nl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0141.outbound.protection.outlook.com ([157.55.234.141]:56128
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932424AbbGVIRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 04:17:37 -0400
In-Reply-To: <55AF4FD7.2010009@transip.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got some additional information from syslog:

Jul 22 09:49:33 dommy0 kernel: [  675.987890] NMI watchdog: BUG: soft 
lockup - CPU#3 stuck for 22s! [kworker/3:1:42]
Jul 22 09:49:42 dommy0 kernel: [  685.114033] INFO: rcu_sched 
self-detected stall on CPU { 3}  (t=39918 jiffies g=988 c=987 q=23168)

Thanks,
Frank


Op 7/22/2015 om 10:09 AM schreef Frank Schreuder:
>
>
> Op 7/21/2015 om 8:34 PM schreef Florian Westphal:
>> Frank Schreuder <fschreuder@transip.nl> wrote:
>>
>> [ inet frag evictor crash ]
>>
>> We believe we found the bug.  This patch should fix it.
>>
>> We cannot share list for buckets and evictor, the flag member is
>> subject to race conditions so flags & INET_FRAG_EVICTED test is not
>> reliable.
>>
>> It would be great if you could confirm that this fixes the problem
>> for you, we'll then make formal patch submission.
>>
>> Please apply this on kernel without previous test patches, wheter you
>> use affected -stable or net-next kernel shouldn't matter since those are
>> similar enough.
>>
>> Many thanks!
>>
>> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
>> --- a/include/net/inet_frag.h
>> +++ b/include/net/inet_frag.h
>> @@ -45,6 +45,7 @@ enum {
>>    * @flags: fragment queue flags
>>    * @max_size: maximum received fragment size
>>    * @net: namespace that this frag belongs to
>> + * @list_evictor: list of queues to forcefully evict (e.g. due to 
>> low memory)
>>    */
>>   struct inet_frag_queue {
>>       spinlock_t        lock;
>> @@ -59,6 +60,7 @@ struct inet_frag_queue {
>>       __u8            flags;
>>       u16            max_size;
>>       struct netns_frags    *net;
>> +    struct hlist_node    list_evictor;
>>   };
>>     #define INETFRAGS_HASHSZ    1024
>> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
>> index 5e346a0..1722348 100644
>> --- a/net/ipv4/inet_fragment.c
>> +++ b/net/ipv4/inet_fragment.c
>> @@ -151,14 +151,13 @@ evict_again:
>>           }
>>             fq->flags |= INET_FRAG_EVICTED;
>> -        hlist_del(&fq->list);
>> -        hlist_add_head(&fq->list, &expired);
>> +        hlist_add_head(&fq->list_evictor, &expired);
>>           ++evicted;
>>       }
>>         spin_unlock(&hb->chain_lock);
>>   -    hlist_for_each_entry_safe(fq, n, &expired, list)
>> +    hlist_for_each_entry_safe(fq, n, &expired, list_evictor)
>>           f->frag_expire((unsigned long) fq);
>>         return evicted;
>> @@ -284,8 +283,7 @@ static inline void fq_unlink(struct 
>> inet_frag_queue *fq, struct inet_frags *f)
>>       struct inet_frag_bucket *hb;
>>         hb = get_frag_bucket_locked(fq, f);
>> -    if (!(fq->flags & INET_FRAG_EVICTED))
>> -        hlist_del(&fq->list);
>> +    hlist_del(&fq->list);
>>       spin_unlock(&hb->chain_lock);
>>   }
> Hi Florian,
>
> Thanks for the patch!
>
> After implementing the patch in our setup we are no longer able to 
> reproduct the kernel panic.
> Unfortunately the server load increases after 5/10 minutes and the 
> logs are getting spammed with stacktraces.
> I included a snippet below.
>
> Do you have any insights on why this happens, and how we can resolve 
> this?
>
> Thanks,
> Frank
>
>
> Jul 22 09:44:17 dommy0 kernel: [  360.121516] Modules linked in: 
> parport_pc ppdev lp parport bnep rfcomm bluetooth rfkill uinput nfsd 
> auth_rpcgss oid_registry nfs_acl nfs lockd grace fscache sunrpc loop 
> coretemp kvm ttm drm_kms_helper iTCO_wdt drm psmouse ipmi_si 
> iTCO_vendor_support tpm_tis tpm ipmi_msghandler i2c_algo_bit i2c_core 
> i7core_edac dcdbas serio_raw pcspkr wmi lpc_ich edac_core mfd_core 
> evdev button acpi_power_meter processor thermal_sys ext4 crc16 mbcache 
> jbd2 sd_mod sg sr_mod cdrom hid_generic usbhid ata_generic hid 
> crc32c_intel ata_piix mptsas scsi_transport_sas mptscsih libata 
> mptbase ehci_pci scsi_mod uhci_hcd ehci_hcd usbcore usb_common ixgbe 
> dca ptp bnx2 pps_core mdio
> Jul 22 09:44:17 dommy0 kernel: [  360.121560] CPU: 3 PID: 42 Comm: 
> kworker/3:1 Tainted: G        W    L 3.18.18-transip-1.6 #1
> Jul 22 09:44:17 dommy0 kernel: [  360.121562] Hardware name: Dell Inc. 
> PowerEdge R410/01V648, BIOS 1.12.0 07/30/2013
> Jul 22 09:44:17 dommy0 kernel: [  360.121567] Workqueue: events 
> inet_frag_worker
> Jul 22 09:44:17 dommy0 kernel: [  360.121568] task: ffff880224574490 
> ti: ffff8802240a0000 task.ti: ffff8802240a0000
> Jul 22 09:44:17 dommy0 kernel: [  360.121570] RIP: 
> 0010:[<ffffffff810c0872>]  [<ffffffff810c0872>] del_timer_sync+0x42/0x60
> Jul 22 09:44:17 dommy0 kernel: [  360.121575] RSP: 
> 0018:ffff8802240a3d48  EFLAGS: 00000246
> Jul 22 09:44:17 dommy0 kernel: [  360.121576] RAX: 0000000000000200 
> RBX: 0000000000000000 RCX: 0000000000000000
> Jul 22 09:44:17 dommy0 kernel: [  360.121578] RDX: ffff88022215ce40 
> RSI: 0000000000300000 RDI: ffff88022215cdf0
> Jul 22 09:44:17 dommy0 kernel: [  360.121579] RBP: 0000000000000003 
> R08: ffff880222343c00 R09: 0000000000000101
> Jul 22 09:44:17 dommy0 kernel: [  360.121581] R10: 0000000000000000 
> R11: 0000000000000027 R12: ffff880222343c00
> Jul 22 09:44:17 dommy0 kernel: [  360.121582] R13: 0000000000000101 
> R14: 0000000000000000 R15: 0000000000000027
> Jul 22 09:44:17 dommy0 kernel: [  360.121584] FS: 
> 0000000000000000(0000) GS:ffff88022f260000(0000) knlGS:0000000000000000
> Jul 22 09:44:17 dommy0 kernel: [  360.121585] CS:  0010 DS: 0000 ES: 
> 0000 CR0: 000000008005003b
> Jul 22 09:44:17 dommy0 kernel: [  360.121587] CR2: 00007fb1e9884095 
> CR3: 000000021c084000 CR4: 00000000000007e0
> Jul 22 09:44:17 dommy0 kernel: [  360.121588] Stack:
> Jul 22 09:44:17 dommy0 kernel: [  360.121589]  ffff88022215cdf0 
> ffffffff8149289e ffffffff81a8aa30 ffffffff81a8aa38
> Jul 22 09:44:17 dommy0 kernel: [  360.121592]  0000000000000286 
> ffff88022215ce88 ffffffff8149287f 0000000000000394
> Jul 22 09:44:17 dommy0 kernel: [  360.121594]  ffffffff81a87100 
> 0000000000000001 000000000000007c 0000000000000000
> Jul 22 09:44:17 dommy0 kernel: [  360.121596] Call Trace:
> Jul 22 09:44:17 dommy0 kernel: [  360.121600] [<ffffffff8149289e>] ? 
> inet_evict_bucket+0x11e/0x140
> Jul 22 09:44:17 dommy0 kernel: [  360.121602] [<ffffffff8149287f>] ? 
> inet_evict_bucket+0xff/0x140
> Jul 22 09:44:17 dommy0 kernel: [  360.121605] [<ffffffff814929b0>] ? 
> inet_frag_worker+0x60/0x210
> Jul 22 09:44:17 dommy0 kernel: [  360.121609] [<ffffffff8107e3a2>] ? 
> process_one_work+0x142/0x3b0
> Jul 22 09:44:17 dommy0 kernel: [  360.121612] [<ffffffff815078ed>] ? 
> schedule+0x1d/0x70
> Jul 22 09:44:17 dommy0 kernel: [  360.121614] [<ffffffff8107eb94>] ? 
> worker_thread+0x114/0x440
> Jul 22 09:44:17 dommy0 kernel: [  360.121617] [<ffffffff815073ad>] ? 
> __schedule+0x2cd/0x7b0
> Jul 22 09:44:17 dommy0 kernel: [  360.121619] [<ffffffff8107ea80>] ? 
> create_worker+0x1a0/0x1a0
> Jul 22 09:44:17 dommy0 kernel: [  360.121622] [<ffffffff81083dfc>] ? 
> kthread+0xbc/0xe0
> Jul 22 09:44:17 dommy0 kernel: [  360.121624] [<ffffffff81083d40>] ? 
> kthread_create_on_node+0x1c0/0x1c0
> Jul 22 09:44:17 dommy0 kernel: [  360.121627] [<ffffffff8150b218>] ? 
> ret_from_fork+0x58/0x90
> Jul 22 09:44:17 dommy0 kernel: [  360.121629] [<ffffffff81083d40>] ? 
> kthread_create_on_node+0x1c0/0x1c0
> Jul 22 09:44:17 dommy0 kernel: [  360.121631] Code: 75 29 be 3c 04 00 
> 00 48 c7 c7 0c 73 71 81 e8 26 72 fa ff 48 89 df e8 6e ff ff ff 85 c0 
> 79 18 66 2e 0f 1f 84 00 00 00 00 00 f3 90 <48> 89 df e8 56 ff ff ff 85 
> c0 78 f2 5b 90 c3 66 66 66 66 66 66
>
> Jul 22 09:44:27 dommy0 kernel: [  370.097476] Task dump for CPU 3:
> Jul 22 09:44:27 dommy0 kernel: [  370.097478] kworker/3:1     R 
> running task        0    42      2 0x00000008
> Jul 22 09:44:27 dommy0 kernel: [  370.097482] Workqueue: events 
> inet_frag_worker
> Jul 22 09:44:27 dommy0 kernel: [  370.097483]  0000000000000004 
> ffffffff81849240 ffffffff810b9464 00000000000003dc
> Jul 22 09:44:27 dommy0 kernel: [  370.097485]  ffff88022f26d4c0 
> ffffffff81849180 ffffffff81849240 ffffffff818b4e40
> Jul 22 09:44:27 dommy0 kernel: [  370.097488]  ffffffff810bc797 
> 0000000000000000 ffffffff810c6dc9 0000000000000092
> Jul 22 09:44:27 dommy0 kernel: [  370.097490] Call Trace:
> Jul 22 09:44:27 dommy0 kernel: [  370.097491]  <IRQ> 
> [<ffffffff810b9464>] ? rcu_dump_cpu_stacks+0x84/0xc0
> Jul 22 09:44:27 dommy0 kernel: [  370.097499] [<ffffffff810bc797>] ? 
> rcu_check_callbacks+0x407/0x650
> Jul 22 09:44:27 dommy0 kernel: [  370.097501] [<ffffffff810c6dc9>] ? 
> timekeeping_update.constprop.8+0x89/0x1b0
> Jul 22 09:44:27 dommy0 kernel: [  370.097504] [<ffffffff810c7ec5>] ? 
> update_wall_time+0x225/0x5c0
> Jul 22 09:44:27 dommy0 kernel: [  370.097507] [<ffffffff810cfcb0>] ? 
> tick_sched_do_timer+0x30/0x30
> Jul 22 09:44:27 dommy0 kernel: [  370.097510] [<ffffffff810c14df>] ? 
> update_process_times+0x3f/0x80
> Jul 22 09:44:27 dommy0 kernel: [  370.097513] [<ffffffff810cfb27>] ? 
> tick_sched_handle.isra.12+0x27/0x70
> Jul 22 09:44:27 dommy0 kernel: [  370.097515] [<ffffffff810cfcf5>] ? 
> tick_sched_timer+0x45/0x80
> Jul 22 09:44:27 dommy0 kernel: [  370.097518] [<ffffffff810c1d76>] ? 
> __run_hrtimer+0x66/0x1b0
> Jul 22 09:44:27 dommy0 kernel: [  370.097522] [<ffffffff8101c5c5>] ? 
> read_tsc+0x5/0x10
> Jul 22 09:44:27 dommy0 kernel: [  370.097524] [<ffffffff810c2519>] ? 
> hrtimer_interrupt+0xf9/0x230
> Jul 22 09:44:27 dommy0 kernel: [  370.097528] [<ffffffff81046d86>] ? 
> smp_apic_timer_interrupt+0x36/0x50
> Jul 22 09:44:27 dommy0 kernel: [  370.097531] [<ffffffff8150c0bd>] ? 
> apic_timer_interrupt+0x6d/0x80
> Jul 22 09:44:27 dommy0 kernel: [  370.097532]  <EOI> 
> [<ffffffff8150ad89>] ? _raw_spin_lock+0x9/0x30
> Jul 22 09:44:27 dommy0 kernel: [  370.097537] [<ffffffff814927bb>] ? 
> inet_evict_bucket+0x3b/0x140
> Jul 22 09:44:27 dommy0 kernel: [  370.097539] [<ffffffff8149287f>] ? 
> inet_evict_bucket+0xff/0x140
> Jul 22 09:44:27 dommy0 kernel: [  370.097542] [<ffffffff814929b0>] ? 
> inet_frag_worker+0x60/0x210
> Jul 22 09:44:27 dommy0 kernel: [  370.097545] [<ffffffff8107e3a2>] ? 
> process_one_work+0x142/0x3b0
> Jul 22 09:44:27 dommy0 kernel: [  370.097547] [<ffffffff815078ed>] ? 
> schedule+0x1d/0x70
> Jul 22 09:44:27 dommy0 kernel: [  370.097550] [<ffffffff8107eb94>] ? 
> worker_thread+0x114/0x440
> Jul 22 09:44:27 dommy0 kernel: [  370.097552] [<ffffffff815073ad>] ? 
> __schedule+0x2cd/0x7b0
> Jul 22 09:44:27 dommy0 kernel: [  370.097554] [<ffffffff8107ea80>] ? 
> create_worker+0x1a0/0x1a0
> Jul 22 09:44:27 dommy0 kernel: [  370.097557] [<ffffffff81083dfc>] ? 
> kthread+0xbc/0xe0
> Jul 22 09:44:27 dommy0 kernel: [  370.097559] [<ffffffff81083d40>] ? 
> kthread_create_on_node+0x1c0/0x1c0
> Jul 22 09:44:27 dommy0 kernel: [  370.097562] [<ffffffff8150b218>] ? 
> ret_from_fork+0x58/0x90
> Jul 22 09:44:27 dommy0 kernel: [  370.097564] [<ffffffff81083d40>] ? 
> kthread_create_on_node+0x1c0/0x1c0
>
> Jul 22 09:44:53 dommy0 kernel: [  396.106303] Modules linked in: 
> parport_pc ppdev lp parport bnep rfcomm bluetooth rfkill uinput nfsd 
> auth_rpcgss oid_registry nfs_acl nfs lockd grace fscache sunrpc loop 
> coretemp kvm ttm drm_kms_helper iTCO_wdt drm psmouse ipmi_si 
> iTCO_vendor_support tpm_tis tpm ipmi_msghandler i2c_algo_bit i2c_core 
> i7core_edac dcdbas serio_raw pcspkr wmi lpc_ich edac_core mfd_core 
> evdev button acpi_power_meter processor thermal_sys ext4 crc16 mbcache 
> jbd2 sd_mod sg sr_mod cdrom hid_generic usbhid ata_generic hid 
> crc32c_intel ata_piix mptsas scsi_transport_sas mptscsih libata 
> mptbase ehci_pci scsi_mod uhci_hcd ehci_hcd usbcore usb_common ixgbe 
> dca ptp bnx2 pps_core mdio
> Jul 22 09:44:53 dommy0 kernel: [  396.106347] CPU: 3 PID: 42 Comm: 
> kworker/3:1 Tainted: G        W    L 3.18.18-transip-1.6 #1
> Jul 22 09:44:53 dommy0 kernel: [  396.106348] Hardware name: Dell Inc. 
> PowerEdge R410/01V648, BIOS 1.12.0 07/30/2013
> Jul 22 09:44:53 dommy0 kernel: [  396.106353] Workqueue: events 
> inet_frag_worker
> Jul 22 09:44:53 dommy0 kernel: [  396.106355] task: ffff880224574490 
> ti: ffff8802240a0000 task.ti: ffff8802240a0000
> Jul 22 09:44:53 dommy0 kernel: [  396.106356] RIP: 
> 0010:[<ffffffff8149288d>]  [<ffffffff8149288d>] 
> inet_evict_bucket+0x10d/0x140
> Jul 22 09:44:53 dommy0 kernel: [  396.106359] RSP: 
> 0018:ffff8802240a3d58  EFLAGS: 00000206
> Jul 22 09:44:53 dommy0 kernel: [  396.106361] RAX: 0000000000000000 
> RBX: 0000000000000286 RCX: 0000000000000000
> Jul 22 09:44:53 dommy0 kernel: [  396.106362] RDX: ffff88022215ce40 
> RSI: 0000000000300000 RDI: ffff88022215cdf0
> Jul 22 09:44:53 dommy0 kernel: [  396.106364] RBP: 0000000000000003 
> R08: ffff880222343c00 R09: 0000000000000101
> Jul 22 09:44:53 dommy0 kernel: [  396.106365] R10: 0000000000000000 
> R11: 0000000000000027 R12: 0000000000000000
> Jul 22 09:44:53 dommy0 kernel: [  396.106366] R13: 0000000000000000 
> R14: ffff880222343c00 R15: 0000000000000101
> Jul 22 09:44:53 dommy0 kernel: [  396.106368] FS: 
> 0000000000000000(0000) GS:ffff88022f260000(0000) knlGS:0000000000000000
> Jul 22 09:44:53 dommy0 kernel: [  396.106370] CS:  0010 DS: 0000 ES: 
> 0000 CR0: 000000008005003b
> Jul 22 09:44:53 dommy0 kernel: [  396.106371] CR2: 00007fb1e9884095 
> CR3: 000000021c084000 CR4: 00000000000007e0
> Jul 22 09:44:53 dommy0 kernel: [  396.106372] Stack:
> Jul 22 09:44:53 dommy0 kernel: [  396.106373]  ffffffff81a8aa30 
> ffffffff81a8aa38 0000000000000286 ffff88022215ce88
> Jul 22 09:44:53 dommy0 kernel: [  396.106376]  ffffffff8149287f 
> 0000000000000394 ffffffff81a87100 0000000000000001
> Jul 22 09:44:53 dommy0 kernel: [  396.106378]  000000000000007c 
> 0000000000000000 00000000000000c0 ffffffff814929b0
> Jul 22 09:44:53 dommy0 kernel: [  396.106380] Call Trace:
> Jul 22 09:44:53 dommy0 kernel: [  396.106383] [<ffffffff8149287f>] ? 
> inet_evict_bucket+0xff/0x140
> Jul 22 09:44:53 dommy0 kernel: [  396.106386] [<ffffffff814929b0>] ? 
> inet_frag_worker+0x60/0x210
> Jul 22 09:44:53 dommy0 kernel: [  396.106390] [<ffffffff8107e3a2>] ? 
> process_one_work+0x142/0x3b0
> Jul 22 09:44:53 dommy0 kernel: [  396.106393] [<ffffffff815078ed>] ? 
> schedule+0x1d/0x70
> Jul 22 09:44:53 dommy0 kernel: [  396.106396] [<ffffffff8107eb94>] ? 
> worker_thread+0x114/0x440
> Jul 22 09:44:53 dommy0 kernel: [  396.106398] [<ffffffff815073ad>] ? 
> __schedule+0x2cd/0x7b0
> Jul 22 09:44:53 dommy0 kernel: [  396.106401] [<ffffffff8107ea80>] ? 
> create_worker+0x1a0/0x1a0
> Jul 22 09:44:53 dommy0 kernel: [  396.106403] [<ffffffff81083dfc>] ? 
> kthread+0xbc/0xe0
> Jul 22 09:44:53 dommy0 kernel: [  396.106406] [<ffffffff81083d40>] ? 
> kthread_create_on_node+0x1c0/0x1c0
> Jul 22 09:44:53 dommy0 kernel: [  396.106409] [<ffffffff8150b218>] ? 
> ret_from_fork+0x58/0x90
> Jul 22 09:44:53 dommy0 kernel: [  396.106411] [<ffffffff81083d40>] ? 
> kthread_create_on_node+0x1c0/0x1c0
> Jul 22 09:44:53 dommy0 kernel: [  396.106412] Code: a0 00 00 00 41 ff 
> 94 24 70 40 00 00 48 85 db 75 e5 48 83 c4 28 89 e8 5b 5d 41 5c 41 5d 
> 41 5e 41 5f c3 0f 1f 40 00 f0 41 ff 47 68 <48> 8b 44 24 08 66 83 00 01 
> 48 89 df e8 92 df c2 ff f0 41 ff 4f
>
> Jul 22 09:45:21 dommy0 kernel: [  424.094444] Modules linked in: 
> parport_pc ppdev lp parport bnep rfcomm bluetooth rfkill uinput nfsd 
> auth_rpcgss oid_registry nfs_acl nfs lockd grace fscache sunrpc loop 
> coretemp kvm ttm drm_kms_helper iTCO_wdt drm psmouse ipmi_si 
> iTCO_vendor_support tpm_tis tpm ipmi_msghandler i2c_algo_bit i2c_core 
> i7core_edac dcdbas serio_raw pcspkr wmi lpc_ich edac_core mfd_core 
> evdev button acpi_power_meter processor thermal_sys ext4 crc16 mbcache 
> jbd2 sd_mod sg sr_mod cdrom hid_generic usbhid ata_generic hid 
> crc32c_intel ata_piix mptsas scsi_transport_sas mptscsih libata 
> mptbase ehci_pci scsi_mod uhci_hcd ehci_hcd usbcore usb_common ixgbe 
> dca ptp bnx2 pps_core mdio
> Jul 22 09:45:21 dommy0 kernel: [  424.094487] CPU: 3 PID: 42 Comm: 
> kworker/3:1 Tainted: G        W    L 3.18.18-transip-1.6 #1
> Jul 22 09:45:21 dommy0 kernel: [  424.094488] Hardware name: Dell Inc. 
> PowerEdge R410/01V648, BIOS 1.12.0 07/30/2013
> Jul 22 09:45:21 dommy0 kernel: [  424.094492] Workqueue: events 
> inet_frag_worker
> Jul 22 09:45:21 dommy0 kernel: [  424.094494] task: ffff880224574490 
> ti: ffff8802240a0000 task.ti: ffff8802240a0000
> Jul 22 09:45:21 dommy0 kernel: [  424.094495] RIP: 
> 0010:[<ffffffff810c08ac>]  [<ffffffff810c08ac>] del_timer+0x1c/0x70
> Jul 22 09:45:21 dommy0 kernel: [  424.094500] RSP: 
> 0018:ffff8802240a3d28  EFLAGS: 00000246
> Jul 22 09:45:21 dommy0 kernel: [  424.094502] RAX: ffffffff81895380 
> RBX: 0000000000000000 RCX: 0000000000000000
> Jul 22 09:45:21 dommy0 kernel: [  424.094503] RDX: ffff88022215ce40 
> RSI: 0000000000300000 RDI: ffff88022215cdf0
> Jul 22 09:45:21 dommy0 kernel: [  424.094505] RBP: 0000000000000000 
> R08: ffff880222343c00 R09: 0000000000000101
> Jul 22 09:45:21 dommy0 kernel: [  424.094506] R10: 0000000000000000 
> R11: 0000000000000027 R12: 0000000000000000
> Jul 22 09:45:21 dommy0 kernel: [  424.094507] R13: ffff8802245a8000 
> R14: ffff880222343c00 R15: 0000000000000101
> Jul 22 09:45:21 dommy0 kernel: [  424.094509] FS: 
> 0000000000000000(0000) GS:ffff88022f260000(0000) knlGS:0000000000000000
> Jul 22 09:45:21 dommy0 kernel: [  424.094511] CS:  0010 DS: 0000 ES: 
> 0000 CR0: 000000008005003b
> Jul 22 09:45:21 dommy0 kernel: [  424.094512] CR2: 00007fb1e9884095 
> CR3: 000000021c084000 CR4: 00000000000007e0
> Jul 22 09:45:21 dommy0 kernel: [  424.094513] Stack:
> Jul 22 09:45:21 dommy0 kernel: [  424.094514]  0000000000000296 
> ffff88022215cdf0 ffff88022215cdf0 0000000000000003
> Jul 22 09:45:21 dommy0 kernel: [  424.094517]  ffffffff81a87100 
> ffffffff814927f7 ffffffff81a8aa30 ffffffff81a8aa38
> Jul 22 09:45:21 dommy0 kernel: [  424.094519]  0000000000000286 
> ffff88022215ce88 ffffffff8149287f 0000000000000394
> Jul 22 09:45:21 dommy0 kernel: [  424.094521] Call Trace:
> Jul 22 09:45:21 dommy0 kernel: [  424.094524] [<ffffffff814927f7>] ? 
> inet_evict_bucket+0x77/0x140
> Jul 22 09:45:21 dommy0 kernel: [  424.094527] [<ffffffff8149287f>] ? 
> inet_evict_bucket+0xff/0x140
> Jul 22 09:45:21 dommy0 kernel: [  424.094529] [<ffffffff814929b0>] ? 
> inet_frag_worker+0x60/0x210
> Jul 22 09:45:21 dommy0 kernel: [  424.094533] [<ffffffff8107e3a2>] ? 
> process_one_work+0x142/0x3b0
> Jul 22 09:45:21 dommy0 kernel: [  424.094536] [<ffffffff815078ed>] ? 
> schedule+0x1d/0x70
> Jul 22 09:45:21 dommy0 kernel: [  424.094539] [<ffffffff8107eb94>] ? 
> worker_thread+0x114/0x440
> Jul 22 09:45:21 dommy0 kernel: [  424.094541] [<ffffffff815073ad>] ? 
> __schedule+0x2cd/0x7b0
> Jul 22 09:45:21 dommy0 kernel: [  424.094544] [<ffffffff8107ea80>] ? 
> create_worker+0x1a0/0x1a0
> Jul 22 09:45:21 dommy0 kernel: [  424.094546] [<ffffffff81083dfc>] ? 
> kthread+0xbc/0xe0
> Jul 22 09:45:21 dommy0 kernel: [  424.094549] [<ffffffff81083d40>] ? 
> kthread_create_on_node+0x1c0/0x1c0
> Jul 22 09:45:21 dommy0 kernel: [  424.094552] [<ffffffff8150b218>] ? 
> ret_from_fork+0x58/0x90
> Jul 22 09:45:21 dommy0 kernel: [  424.094554] [<ffffffff81083d40>] ? 
> kthread_create_on_node+0x1c0/0x1c0
> Jul 22 09:45:21 dommy0 kernel: [  424.094555] Code: 66 66 66 66 66 66 
> 2e 0f 1f 84 00 00 00 00 00 48 83 ec 28 48 89 5c 24 10 48 89 6c 24 18 
> 31 ed 4c 89 64 24 20 48 83 3f 00 48 89 fb <48> c7 47 38 00 00 00 00 74 
> 30 48 8d 7f 18 48 8d 74 24 08 e8 0c
>

-- 

TransIP BV

Schipholweg 11E
2316XB Leiden
E: fschreuder@transip.nl
I: https://www.transip.nl
