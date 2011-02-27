From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Bug inkvm_set_irq
Date: Sun, 27 Feb 2011 19:00:31 +0200
Message-ID: <20110227170031.GC17973@redhat.com>
References: <4D67714A.2050100@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872Ab1B0RAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Feb 2011 12:00:46 -0500
Content-Disposition: inline
In-Reply-To: <4D67714A.2050100@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 10:07:22AM +0100, Jean-Philippe Menil wrote:
> Hi,
> 
> Each time i try tou use vhost_net, i'm facing a kernel bug.
> I do a "modprobe vhost_net", and start guest whith vhost=on.
> 
> Following is a trace with a kernel 2.6.37, but  i had the same
> problem with 2.6.36 (cf https://lkml.org/lkml/2010/11/30/29).

2.6.36 had a theorectical race that could explain this,
but it should be ok in 2.6.37.

> 
> The bug only occurs whith vhost_net charged, so i don't know if this
> is a bug in kvm module code or in the vhost_net code.

It could be a bug in eventfd which is the interface
used by both kvm and vhost_net.
Just for fun, you can try 3.6.38 - eventfd code has been changed
a lot in 2.6.38 and if it does not trigger there
it's a hint that irqfd is the reason.

> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.243100] BUG: unable to handle kernel paging request at
> 0000000000002458
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.243250] IP: [<ffffffffa041aa8a>] kvm_set_irq+0x2a/0x130 [kvm]


Could you run markup_oops/ ksymoops on this please?
As far as I can see kvm_set_irq can only get a wrong
kvm pointer. Unless there's some general memory corruption,
I'd guess 

You can also try comparing the irqfd->kvm pointer in
kvm_irqfd_assign irqfd_wakeup and kvm_set_irq in
virt/kvm/eventfd.c.

> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.243378] PGD 45d363067 PUD 45e77a067 PMD 0
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.243556] Oops: 0000 [#1] SMP
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.243692] last sysfs file:
> /sys/devices/pci0000:00/0000:00:0d.0/0000:05:00.0/0000:06:00.0/irq
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.243777] CPU 0
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.243820] Modules linked in: vhost_net macvtap macvlan tun
> powernow_k8 mperf cpufreq_userspace cpufreq_stats cpufreq_powersave
> cpufreq_ondemand fre
> q_table cpufreq_conservative fuse xt_physdev ip6t_LOG
> ip6table_filter ip6_tables ipt_LOG xt_multiport xt_limit xt_tcpudp
> xt_state iptable_filter ip_tables x_tables nf_conntrack_tftp
> nf_conntrack_ftp nf_connt
> rack_ipv4 nf_defrag_ipv4 8021q bridge stp ext2 mbcache
> dm_round_robin dm_multipath nf_conntrack_ipv6 nf_conntrack
> nf_defrag_ipv6 kvm_amd kvm ipv6 snd_pcm snd_timer snd soundcore
> snd_page_alloc tpm_tis tpm ps
> mouse dcdbas tpm_bios processor i2c_nforce2 shpchp pcspkr ghes
> serio_raw joydev evdev pci_hotplug i2c_core hed button thermal_sys
> xfs exportfs dm_mod sg sr_mod cdrom usbhid hid usb_storage ses
> sd_mod enclosu
> re megaraid_sas ohci_hcd lpfc scsi_transport_fc scsi_tgt bnx2
> scsi_mod ehci_hcd [last unloaded: scsi_wait_scan]
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.246123]
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] Pid: 10, comm: kworker/0:1 Not tainted
> 2.6.37-dsiun-110105 #17 0K543T/PowerEdge M605
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] RIP: 0010:[<ffffffffa041aa8a>]  [<ffffffffa041aa8a>]
> kvm_set_irq+0x2a/0x130 [kvm]
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] RSP: 0018:ffff88045fc89d30  EFLAGS: 00010246
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] RAX: 0000000000000000 RBX: 000000000000001a RCX:
> 0000000000000001
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> 0000000000000000
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] RBP: 0000000000000000 R08: 0000000000000001 R09:
> ffff880856a91e48
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] R10: 0000000000000000 R11: 00000000ffffffff R12:
> 0000000000000000
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] R13: 0000000000000001 R14: 0000000000000000 R15:
> 0000000000000000
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] FS:  00007f617986c710(0000) GS:ffff88007f800000(0000)
> knlGS:0000000000000000
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] CR2: 0000000000002458 CR3: 000000045d197000 CR4:
> 00000000000006f0
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] Process kworker/0:1 (pid: 10, threadinfo
> ffff88045fc88000, task ffff88085fc53c30)
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [  685.246123] Stack:
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  ffff88045fc89fd8 00000000000119c0 ffff88045fc88010
> ffff88085fc53ee8
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  ffff88045fc89fd8 ffff88085fc53ee0 ffff88085fc53c30
> 00000000000119c0
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  00000000000119c0 ffffffff8137f7ce ffff88007f80df40
> 00000000ffffffff
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] Call Trace:
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff8137f7ce>] ? common_interrupt+0xe/0x13
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffffa041bc30>] ? irqfd_inject+0x0/0x50 [kvm]
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffffa041bc57>] ? irqfd_inject+0x27/0x50 [kvm]
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffffa041bc30>] ? irqfd_inject+0x0/0x50 [kvm]
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff8106b6f2>] ? process_one_work+0x112/0x460
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff8106be25>] ? worker_thread+0x145/0x410
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff8103a3d0>] ? __wake_up_common+0x50/0x80
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff8106bce0>] ? worker_thread+0x0/0x410
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff8106bce0>] ? worker_thread+0x0/0x410
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff8106f786>] ? kthread+0x96/0xa0
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff81003ce4>] ? kernel_thread_helper+0x4/0x10
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff8106f6f0>] ? kthread+0x0/0xa0
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  [<ffffffff81003ce0>] ? kernel_thread_helper+0x0/0x10
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] Code: ff 41 57 41 89 f7 41 56 41 55 41 89 cd 41 54 49 89
> fc 55 53 89 d3 48 81 ec 98 00 00 00 8b 15 c6 79 03 00 85 d2 0f 85 c4
> 00 00 00 <4
> 9> 8b 84 24 58 24 00 00 3b 98 28 01 00 00 73 5e 89 db 48 8b 84
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] RIP  [<ffffffffa041aa8a>] kvm_set_irq+0x2a/0x130 [kvm]
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123]  RSP <ffff88045fc89d30>
> Feb 23 13:56:19 ayrshire.u06.univ-nantes.prive kernel: [
> 685.246123] CR2: 0000000000002458
> 
> 
> If someone can help me, on how to solve this.
> 
> Regards.

> begin:vcard
> fn:Jean-Philippe Menil
> n:Menil;Jean-Philippe
> org;quoted-printable:Universit=C3=A9 de Nantes;IRTS
> adr;dom:;;;Nantes
> email;internet:jean-philippe.menil@univ-nantes.fr
> title:Reseau
> tel;work:02.53.48.49.27
> tel;fax:02.53.48.49.97
> x-mozilla-html:FALSE
> version:2.1
> end:vcard
> 

> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/virtualization

