From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Regression: ping -R crashes over Ipsec
Date: Mon, 23 Jul 2012 14:30:38 -0700
Message-ID: <20120723143038.4ad5ac7a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	James Davidson <james.davidson@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48847 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755097Ab2GWVbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 17:31:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James is investigating a bug that occurs when record route is used
over ipsec.

  https://bugzilla.vyatta.com/show_bug.cgi?id=8218

It appears that this regression was introduced by:

commit 8e36360ae876995e92d3a7538dda70548e64e685
Author: David S. Miller <davem@davemloft.net>
Date:   Fri May 13 17:29:41 2011 -0400

    ipv4: Remove route key identity dependencies in ip_rt_get_source().
    
    Pass in the sk_buff so that we can fetch the necessary keys from
    the packet header when working with input routes.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>


The problem is that in ip_rt_get_source() it is assuming skb->dev is a
valid pointer and can be used instead of rt->iif. It looks like when running
through Ipsec this isn't true.


[   60.740704] BUG: unable to handle kernel NULL pointer dereference at 00000070
[   60.748066] IP: [<c122dfac>] ip_rt_get_source+0x54/0xd1
[   60.753431] *pde = 00000000
[   60.756455] Oops: 0000 [#1] SMP
[   60.759881] Modules linked in: xt_policy authenc xfrm6_mode_tunnel xfrm4_mode_tunnel deflate zlib_deflate ctr twofish_generic twofish_i586 twofish_common camellia serpent blowfish cast5 des_generic cbc aes_i586 aes_generic xcbc rmd160 sha512_generic sha256_generic crypto_null iptable_nat ip6table_filter ip6table_raw ip6_tables iptable_filter xt_NOTRACK xt_CT iptable_raw nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_h323 nf_conntrack_h323 nf_nat_sip nf_conntrack_sip nf_nat_proto_gre nf_nat_tftp nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_tftp nf_conntrack_ftp nf_conntrack acpi_cpufreq mperf xfrm_user cpufreq_userspace cpufreq_stats xfrm4_tunnel tunnel4 cpufreq_powersave ipcomp cpufreq_ondemand freq_table xfrm_ipcomp esp4 cpufreq_conservative ipv6 ah4 af_
 key dcdbas evdev intel_agp container intel_gtt i2c_i801 i2c_core agpgart pcspkr ghes hed button processor battery usb_storage ohci_hcd squashfs loop ext4 jbd2 crc16 raid10 raid456 async_raid
 6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid1 raid0 multipath linear md_mod usbhid hid fan thermal thermal_sys ahci libahci libata igb dca bnx2 [last unloaded: scsi_wait_scan]
[   60.871342]
[   60.872904] Pid: 0, comm: swapper Not tainted 3.0.23-1-586-vyatta #1 Dell Inc. PowerEdge R210 II/09T7VV
[   60.882593] EIP: 0060:[<c122dfac>] EFLAGS: 00010246 CPU: 0
[   60.888143] EIP is at ip_rt_get_source+0x54/0xd1
[   60.892820] EAX: f3f80000 EBX: f3a4323c ECX: 00000000 EDX: f3829c00
[   60.899157] ESI: f3f00000 EDI: f440ddc0 EBP: f440dda0 ESP: f440dd9c
[   60.905485]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[   60.910947] Process swapper (pid: 0, ti=f440c000 task=c138dee0 task.ti=c1388000)
[   60.918419] Stack:
[   60.920500]  f3a4325b 00000002 00000000 00000000 00000000 00000000 64002cac 010021ac
[   60.928898]  00000000 0000003c f47e0240 00000020 00000010 00000028 f3829c18 f382e0f8
[   60.937295]  f3a43278 f3a4323c c1233483 f3829c00 f3a43250 f47e02f0 f440de98 f3829c00
[   60.945714] Call Trace:
[   60.948232]  [<c1233483>] ? ip_options_build+0x7e/0x12b
[   60.953527]  [<c1234126>] ? __ip_make_skb+0x230/0x280
[   60.958645]  [<c123502c>] ? ip_push_pending_frames+0x13/0x20
[   60.964375]  [<c12520bf>] ? icmp_reply+0x114/0x135
[   60.969230]  [<c12521f5>] ? icmp_echo+0x57/0x5c
[   60.973828]  [<c1252ac9>] ? icmp_rcv+0x176/0x191
[   60.978510]  [<c1231570>] ? ip_local_deliver_finish+0x100/0x19c
[   60.984496]  [<c1231470>] ? T.971+0x41/0x41
[   60.988745]  [<c1231642>] ? T.972+0x36/0x39
[   60.992997]  [<c123167b>] ? ip_local_deliver+0x36/0x39
[   60.998200]  [<c1231470>] ? T.971+0x41/0x41
[   61.002449]  [<c123134f>] ? ip_rcv_finish+0x2cb/0x2f0
[   61.007565]  [<c1231084>] ? inet_del_protocol+0x26/0x26
[   61.012858]  [<c1231642>] ? T.972+0x36/0x39
[   61.017107]  [<c12104b1>] ? __netif_receive_skb+0x393/0x3ba
[   61.022745]  [<c1231084>] ? inet_del_protocol+0x26/0x26
[   61.028035]  [<c1210572>] ? process_backlog+0x9a/0x132
[   61.033236]  [<c103106e>] ? irq_enter+0x49/0x49
[   61.037836]  [<c1210ccd>] ? net_rx_action+0x92/0x19a
[   61.042865]  [<c103106e>] ? irq_enter+0x49/0x49
[   61.047460]  [<c1031104>] ? __do_softirq+0x96/0x144
[   61.052404]  [<c103106e>] ? irq_enter+0x49/0x49
[   61.057001]  <IRQ>
[   61.059247]  [<c1030f55>] ? irq_exit+0x2f/0x91
[   61.063754]  [<c10035d8>] ? do_IRQ+0x73/0x84
[   61.068089]  [<c128bca9>] ? common_interrupt+0x29/0x30
[   61.073290]  [<c103007b>] ? do_setitimer+0xdf/0x1a3
[   61.078233]  [<c1166afe>] ? intel_idle+0x9c/0xb9
[   61.082917]  [<c11fc59d>] ? cpuidle_idle_call+0xcf/0x15a
[   61.088294]  [<c1001b18>] ? cpu_idle+0x41/0x5d
[   61.092796]  [<c13ba6eb>] ? start_kernel+0x2b2/0x2b5
[   61.097825] Code: 00 00 89 ef f3 ab 8b 43 10 89 44 24 18 8b 43 0c 89 44 24 1c 8a 43 01 83 e0 1e 88 44 24 10 8b 46 0c 8b 48 70 89 4c 24 04 8b 4a 14 <8b> 49 70 89 4c 24 08 8b 92 90 00 00 00 8d 4c 24 24 89 54 24 0c
[   61.121450] EIP: [<c122dfac>] ip_rt_get_source+0x54/0xd1 SS:ESP 0068:f440dd9c
[   61.128795] CR2: 0000000000000070
[   61.132180] ---[ end trace d5716a30ffe983e9 ]---

Message from[   61.136923] Kernel panic - not syncing: Fatal exception in interrupt
 syslogd@West at [   61.136924] Pid: 0, comm: swapper Tainted: G      D     3.0.23-1-586-vyatta #1
Jul 13 13:05:19 [   61.136925] Call Trace:
...
 kernel:[ [   61.136927]  [<c1288eba>] ? panic+0x4d/0x12b
  60.756455] Oop[   61.136929]  [<c1004756>] ? oops_end+0x6c/0x76
s: 0000 [#1] SMP[   61.136931]  [<c101b23f>] ? no_context+0x10d/0x116

[   61.136933]  [<c101b37b>] ? bad_area_nosemaphore+0xa/0xc
[   61.136934]  [<c101b75d>] ? do_page_fault+0x131/0x2ec
[   61.136936]  [<c1230f24>] ? inet_getpeer+0x252/0x290
[   61.136938]  [<c1206dac>] ? skb_copy_and_csum_bits+0x50/0x225
[   61.136939]  [<c101b62c>] ? vmalloc_sync_all+0xc4/0xc4
