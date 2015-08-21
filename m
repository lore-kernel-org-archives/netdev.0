From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [net-next:master 1179/1189] include/linux/compiler.h:447:38:
 error: call to '__compiletime_assert_243' declared with attribute error:
 BUILD_BUG_ON failed: offsetof(struct dst_entry, __refcnt) & 63
Date: Fri, 21 Aug 2015 16:48:55 +0200
Message-ID: <20150821164855.5b0341ca@griffin>
References: <201508211329.x7P0JrxH%fengguang.wu@intel.com>
	<20150820.232650.1503466109554752010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955AbbHUOs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 10:48:59 -0400
In-Reply-To: <20150820.232650.1503466109554752010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Aug 2015 23:26:50 -0700 (PDT), David Miller wrote:
> Yeah, I should have predicted this would happen on 32-bit builds when I saw
> the adjustment of __pad_to_align_refcnt[] for 64-bit.
> 
> Jiri, you might not have any reasonable options to fix this I'm afraid.

Still working on this, the patch I sent should at least relieve the
pressure (but of course, I'll understand if you revert the whole set).

I'm currently fighting with vxlan triggering null pointer dereference
in include/net/netns/generic.h:41, seems that net->gen is NULL. This is
with commit 938049e18dca, i.e. before my lwtunnel ipv6 patchset.

Pasting the trace below in case anyone has an idea. CONFIG_NET_NS is
enabled. When adding debug printk to vxlan_init_net (before the call to
net_generic), the issue disappears. Smells like a race.

I'm not sure how much time I will have during the weekend.

 Jiri

[   26.102174] BUG: unable to handle kernel NULL pointer dereference at 00000010
[   26.109299] IP: [<f8501154>] vxlan_init_net+0x14/0x50 [vxlan]
[   26.115032] *pdpt = 0000000033b48001 *pde = 0000000000000000 
[   26.120770] Oops: 0000 [#1] SMP 
[   26.124000] Modules linked in: vxlan(+) tg3(+) ip6_udp_tunnel snd_pcm udp_tunnel snd_timer hp_wmi sparse_keymap snd ptp coretemp rfkill pps_core gpio_ich iTCO_wdt mdio dca iTCO_vendor_support ppdev kvm_intel kvm soundcore lpc_ich mfd_core pcspkr crc32_pclmul floppy parport_pc i7core_edac parport edac_core acpi_cpufreq xfs libcrc32c nouveau video mxm_wmi i2c_algo_bit drm_kms_helper ttm drm mptsas scsi_transport_sas firewire_ohci mptscsih crc32c_intel serio_raw firewire_core mptbase crc_itu_t wmi
[   26.168070] CPU: 0 PID: 370 Comm: systemd-udevd Not tainted 4.2.0-rc6+ #1
[   26.174829] Hardware name: Hewlett-Packard HP Z800 Workstation/0AECh, BIOS 786G5 v03.54 11/02/2011
[   26.183750] task: f4ec45c0 ti: f4a82000 task.ti: f4a82000
[   26.189125] EIP: 0060:[<f8501154>] EFLAGS: 00010282 CPU: 0
[   26.194588] EIP is at vxlan_init_net+0x14/0x50 [vxlan]
[   26.199703] EAX: 00000000 EBX: f8509000 ECX: 00000002 EDX: 00000002
[   26.205942] ESI: f6583000 EDI: c0df7900 EBP: f4a83d74 ESP: f4a83d74
[   26.212182]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   26.217557] CR0: 80050033 CR2: 00000010 CR3: 34a3f4a0 CR4: 000006f0
[   26.223797] Stack:
[   26.225797]  f4a83d94 c09beab1 00000000 f6aed2c0 00000002 f8509000 c0df7900 f8509000
[   26.233576]  f4a83db4 c09bedb4 f4a83d9c f4a83d9c 3cd52c75 f8509000 c0d72780 f8091000
[   26.241355]  f4a83dc0 c09bee51 f4f08960 f4a83dcc f8091040 f4f08960 f4a83e48 c040211a
[   26.249133] Call Trace:
[   26.251568]  [<c09beab1>] ops_init+0x31/0x130
[   26.255905]  [<c09bedb4>] register_pernet_operations+0xe4/0x160
[   26.261798]  [<f8091000>] ? 0xf8091000
[   26.265530]  [<c09bee51>] register_pernet_subsys+0x21/0x40
[   26.270993]  [<f8091040>] vxlan_init_module+0x40/0x1000 [vxlan]
[   26.276889]  [<c040211a>] do_one_initcall+0xaa/0x200
[   26.281829]  [<f8091000>] ? 0xf8091000
[   26.285562]  [<c05a45d5>] ? kmem_cache_alloc_trace+0x175/0x1f0
[   26.291369]  [<c0ac73db>] ? do_init_module+0x21/0x1b5
[   26.296398]  [<c0ac73db>] ? do_init_module+0x21/0x1b5
[   26.301428]  [<c0ac740a>] do_init_module+0x50/0x1b5
[   26.306285]  [<c04e743b>] load_module+0x1dbb/0x23c0
[   26.311143]  [<c04e4049>] ? copy_module_from_fd.isra.48+0xf9/0x190
[   26.317297]  [<c04e7c75>] SyS_finit_module+0xa5/0xf0
[   26.322240]  [<c05724cb>] ? vm_mmap_pgoff+0x9b/0xc0
[   26.327097]  [<c0acd79f>] sysenter_do_call+0x12/0x12
[   26.332038] Code: c0 00 00 00 5d c3 90 55 89 e5 66 66 66 66 90 8b 80 18 05 00 00 5d c3 55 89 e5 66 66 66 66 90 8b 15 4c 94 50 f8 8b 80 98 0c 00 00 <8b> 54 90 08 89 12 89 52 04 8d 42 08 c7 82 08 04 00 00 00 00 00
[   26.351295] EIP: [<f8501154>] vxlan_init_net+0x14/0x50 [vxlan] SS:ESP 0068:f4a83d74
[   26.358938] CR2: 0000000000000010
[   26.362259] ---[ end trace 3aa9af5192e30e1f ]---

-- 
Jiri Benc
