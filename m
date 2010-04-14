From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] e1000e/netdev.c patch -- tx_ring->next_to_use
Date: Wed, 14 Apr 2010 11:12:33 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1004141105060.4368@jbrandeb-desk1.amr.corp.intel.com>
References: <4BC5E563.9050206@cmu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "terry.loftin@hp.com" <terry.loftin@hp.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org, emil.s.tantilov@intel.com
To: Charles Slivkoff <slivkoff@cmu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756020Ab0DNSMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 14:12:34 -0400
In-Reply-To: <4BC5E563.9050206@cmu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 14 Apr 2010, Charles Slivkoff wrote:
> I have been experiencing a number of system hangs which I believe are 
> due to the e1000e driver. I have a Dell Optiplex 760, Intel Core 2 Duo, 
> 4GB RAM, and I'm running Ubuntu 9.10 (32-bit).

have you filed a bug at launchpad?  if so what is the number?  I just want 
to unite all the information we have.

>  From the stack included in the kernel oops output, I decided to apply 
> the patch you provided, which I found posted here:
> 
> 	http://patchwork.ozlabs.org/patch/49175/

Hi Charles, I copied netdev for you.  I agree the panic you're seeing is 
from something inside the e1000e driver.  The question becomes why is the 
driver getting a null pointer dereference in transmit cleanup.

> This morning, I attempted an rsync operation which caused a hang once again.
> 
> I am attaching the oops output from 04/08/2010 and 04/14/2010.

I see you also filed a bug at e1000's sourceforge, thank you.

As a workaround you can try disabling TSO using ethtool to see if that 
helps.  We need to reproduce this here if possible.

ethtool -K eth0 tso off

Do you happen to *not* have irqbalance installed or enabled?  I was 
confused by the move_irq in one of the stack traces.  In any case it 
probably doesn't matter but I was not expecting to see that there.

For others, I've included the panic traces inline here...

[603636.169243] BUG: unable to handle kernel NULL pointer dereference at 000000ac
[603636.172898] IP: [<f82ee88f>] e1000_clean_tx_irq+0x8f/0x330 [e1000e]
[603636.172898] *pdpt = 000000002c954001 *pde = 0000000000000000
[603636.172898] Oops: 0000 [#1] SMP
[603636.172898] last sysfs file: /sys/devices/virtual/block/ram9/uevent
[603636.172898] Modules linked in: isofs udf crc_itu_t ppp_async crc_ccitt 
vmnet vmci vmmon binfmt_misc cisco_ipsec(P) openafs(P) deflate 
zlib_deflate ctr twofish twofish_common camellia serpent blowfish cast5 
des_generic cbc aes_i586 aes_generic xcbc rmd160 sha256_generic 
sha1_generic crypto_null af_key nfsd exportfsnfs lockd nfs_acl auth_rpcgss 
sunrpc snd_hda_codec_analog ipt_REJECT ipt_LOG xt_limit xt_tcpudp xt_state 
ipt_addrtype snd_hda_intel snd_hda_codec snd_usb_audio snd_pcm_oss 
snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_usb_lib snd_seq_midi 
ip6table_filter ip6_tables nf_nat_irc nf_conntrack_irc snd_rawmidi 
snd_seq_midi_event snd_seq nf_nat_ftp nf_nat nf_conntrack_ipv4 
nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack snd_hwdep coretemp 
iptable_filter uvcvideo videodev snd_timer snd_seq_device v4l1_compat 
ip_tables x_tables psmouse serio_raw ppdev dell_wmi dcdbas parport_pc 
fglrx(P) snd soundcore lp snd_page_alloc parport heci(C) usbhid intel_agp 
e1000e agpgart
[603636.172898]
[603636.172898] Pid: 4368, comm: chrome Tainted: P         C  (2.6.31-20-generic-pae #58-Ubuntu) OptiPlex 760
[603636.172898] EIP: 0060:[<f82ee88f>] EFLAGS: 00010246 CPU: 0
[603636.172898] EIP is at e1000_clean_tx_irq+0x8f/0x330 [e1000e]
[603636.172898] EAX: 00000000 EBX: 00000024 ECX: 00000240 EDX: f902e360
[603636.172898] ESI: f6e741e0 EDI: ef412000 EBP: ebcbbd84 ESP: ebcbbd24
[603636.172898]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[603636.172898] Process chrome (pid: 4368, ti=ebcba000 task=ee5cd7f0 task.ti=ebcba000)
[603636.172898] Stack:
[603636.172898]  fffb2668 ec9b6d50 00000001 00000014 d7938e00 ebcbbeb4 0000000000000000
[603636.172898] <0> 00000000 00000000 ec9f01b8 00000001 f64dc000 b54cd000 00000086 00000001
[603636.172898] <0> f64dc340 00000024 00000086 c057bf01 00000001 f64dc340 f64dc340 00000040
[603636.172898] Call Trace:
[603636.172898]  [<c057bf01>] ? do_page_fault+0x141/0x380
[603636.172898]  [<f82f0a54>] ? e1000_clean+0x54/0x270 [e1000e]
[603636.172898]  [<c04a7795>] ? net_rx_action+0xe5/0x1c0
[603636.172898]  [<c014cb30>] ? __do_softirq+0x90/0x1a0
[603636.172898]  [<c019189c>] ? handle_IRQ_event+0x4c/0x140
[603636.172898]  [<c01fcb42>] ? __d_lookup+0x102/0x110
[603636.172898]  [<c0194544>] ? move_native_irq+0x14/0x50
[603636.172898]  [<c014cc7d>] ? do_softirq+0x3d/0x40
[603636.172898]  [<c014cdbd>] ? irq_exit+0x5d/0x70
[603636.172898]  [<c0104f50>] ? do_IRQ+0x50/0xc0
[603636.172898]  [<c01e6ec2>] ? __mem_cgroup_uncharge_common+0xa2/0xf0
[603636.172898]  [<c01039f0>] ? common_interrupt+0x30/0x40
[603636.172898]  [<c048007b>] ? hidinput_configure_usage+0xcab/0x2290
[603636.172898]  [<c05700d8>] ? hlt_loop+0x3/0xb
[603636.172898]  [<c04edbd1>] ? udp_v4_get_port+0x1/0x20
[603636.172898]  [<c04f6421>] ? inet_autobind+0x21/0x60
[603636.172898]  [<c04f659d>] ? inet_dgram_connect+0x5d/0x70
[603636.172898]  [<c049684e>] ? sys_connect+0xae/0xd0
[603636.172898]  [<c02d03b3>] ? security_d_instantiate+0x13/0x30
[603636.172898]  [<c01fc690>] ? d_instantiate+0x40/0x50
[603636.172898]  [<c0495178>] ? sock_attach_fd+0x78/0xc0
[603636.172898]  [<c0579a88>] ? _spin_lock+0x8/0x10
[603636.172898]  [<c01e9207>] ? fd_install+0x47/0x60
[603636.172898]  [<c04951fd>] ? sock_map_fd+0x3d/0x60
[603636.172898]  [<c0497578>] ? sys_socketcall+0x248/0x270
[603636.172898]  [<c01032c3>] ? sysenter_do_call+0x12/0x28
[603636.1: lost 7 rtc interrupts
[603636.538819] hpet1: lost 7 rtc interrupts
[603636.542825] hpet1: lost 7 rtc interrupts
[603636.546830] hpet1: lost 8 rtc interrupts
[603636.550836] hpet1: lost 7 rtc interrupts
[603636.554842] hpet1: lost 7 rtc interrupts
[603636.558848] hpet1: lost 7 rtc interrupts
[603636.562854] hpet1: lost 8 rtc interrupts
[603636.566865] ---[ end trace f3dd0b8abcd2bca2 ]---
[603636.571563] Kernel panic - not syncing: Fatal exception in interrupt
[603636.577995] Pid: 4368, comm: chrome Tainted: P      D  C 2.6.31-20-generic-pae #58-Ubuntu
[603636.586245] Call Trace:
[603636.588779]  [<c05775ee>] ? printk+0x18/0x1a
[603636.593132]  [<c0577532>] panic+0x43/0xe7
[603636.597226]  [<c057a935>] oops_end+0xc5/0xd0
[603636.601580]  [<c0129084>] no_context+0xb4/0xd0
[603636.606107]  [<c01290dd>] __bad_area_nosemaphore+0x3d/0x1a0
[603636.611760]  [<c012eb2e>] ? kmap_atomic_prot+0xde/0x100
[603636.617067]  [<c012e972>] ? kunmap_atomic+0x52/0x70


and....


[496797.222642] BUG: unable to handle kernel NULL pointer dereference at 000000ac
[496797.229405] IP: [<f922d50b>] e1000_clean_tx_irq+0xcb/0x320 [e1000e]
[496797.232626] *pdpt = 000000002b5cd001 *pde = 0000000000000000
[496797.232626] Oops: 0000 [#1] SMP
[496797.232626] last sysfs file: /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/class
[496797.232626] Modules linked in: e1000e vmnet vmci vmmon binfmt_misc 
cisco_ipsec(P) openafs(P) deflate zlib_deflate ctr twofish twofish_common 
camellia serpent blowfish cast5 des_generic cbc aes_i586 aes_generic xcbc 
rmd160 sha256_generic sha1_generic crypto_null af_key nfsd exportfs nfs 
lockd nfs_acl auth_rpcgss sunrpc snd_hda_codec_analog ipt_REJECT ipt_LOG 
xt_limit xt_tcpudp xt_state ipt_addrtype ip6table_filter ip6_tables 
nf_nat_irc nf_conntrack_irc nf_nat_ftp nf_nat nf_conntrack_ipv4 
nf_defrag_ipv4 snd_usb_audio snd_hda_intel snd_hda_codec snd_seq_dummy 
snd_pcm_oss nf_conntrack_ftp snd_mixer_oss nf_conntrack iptable_filter 
ppdev ip_tables x_tables snd_pcm snd_usb_lib snd_hwdep snd_seq_oss 
dell_wmi dcdbas uvcvideo videodev v4l1_compat psmouse serio_raw fglrx(P) 
snd_seq_midi parport_pc snd_rawmidi snd_seq_midi_event snd_seq snd_timer 
snd_seq_device snd soundcoresnd_page_alloc heci(C) coretemp lp parport 
usbhid intel_agp agpgart [last unloaded: e1000e]
[496797.232626]
[496797.232626] Pid: 11466, comm: ssh Tainted: P         C (2.6.31-20-generic-pae #58-Ubuntu) OptiPlex 760
[496797.232626] EIP: 0060:[<f922d50b>] EFLAGS: 00210246 CPU: 1
[496797.232626] EIP is at e1000_clean_tx_irq+0xcb/0x320 [e1000e]
[496797.232626] EAX: 00000000 EBX: 00000056 ECX: 00000560 EDX: f8554810
[496797.232626] ESI: e9cba360 EDI: e9c6c000 EBP: efc8fcfc ESP: efc8fc9c
[496797.232626]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[496797.232626] Process ssh (pid: 11466, ti=efc8e000 task=f0554b60 task.ti=efc8e000)
[496797.232626] Stack:
[496797.232626]  00000020 20dd855d 00000005 f0014c00 e49ea5a0 efc8fcf8 c04e2387efc8fce4
[496797.232626] <0> c04dfc04 000252d0 00002b00 00000001 f6074000 e49ea580 00004912 0000000f
[496797.232626] <0> f6074340 00000056 0000058e c0127f01 0000000f f6074340 f6074340 00000040
[496797.232626] Call Trace:
[496797.232626]  [<c04e2387>] ? tcp_transmit_skb+0x397/0x650
[496797.232626]  [<c04dfc04>] ? tcp_clean_rtx_queue+0x3f4/0x7b0
[496797.232626]  [<c0127f01>] ? native_patch+0xf1/0x110
[496797.232626]  [<f922f504>] ? e1000_clean+0x54/0x270 [e1000e]
[496797.232626]  [<c0152227>] ? lock_timer_base+0x27/0x50
[496797.232626]  [<c04a7795>] ? net_rx_action+0xe5/0x1c0
[496797.232626]  [<c014cb30>] ? __do_softirq+0x90/0x1a0
[496797.232626]  [<c04db9df>] ? __tcp_ack_snd_check+0x5f/0x80
[496797.232626]  [<c04e0dfe>] ? tcp_rcv_established+0x32e/0x5f0
[496797.232626]  [<c014cc7d>] ? do_softirq+0x3d/0x40
[496797.232626]  [<c014d805>] ? local_bh_enable_ip+0x75/0x90
[496797.232626]  [<c0579c51>] ? _spin_unlock_bh+0x11/0x20
[496797.232626]  [<c04983d4>] ? release_sock+0x94/0xa0
[496797.232626]  [<c04d5535>] ? tcp_push+0x75/0xb0
[496797.488251]  [<c04d86bd>] ? tcp_sendmsg+0x67d/0x900


