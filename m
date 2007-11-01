From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH] Remove /proc/net/stat/*_arp_cache upon module removal
Date: Thu, 1 Nov 2007 16:52:35 +0300
Message-ID: <20071101135235.GB8639@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devel@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:8376 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752379AbXKANwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 09:52:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

neigh_table_init_no_netlink() creates them, but they aren't removed anywhere.

Steps to reproduce:

	modprobe clip
	rmmod clip
	cat /proc/net/stat/clip_arp_cache

BUG: unable to handle kernel paging request at virtual address f89d7758
printing eip: c05a99da *pdpt = 0000000000004001 *pde = 0000000004408067 *pte = 0000000000000000 
Oops: 0000 [#1] PREEMPT SMP 
Modules linked in: atm af_packet ipv6 binfmt_misc sbs sbshc fan dock battery backlight ac power_supply parport loop rtc_cmos rtc_core rtc_lib serio_raw button k8temp hwmon amd_rng sr_mod cdrom shpchp pci_hotplug ehci_hcd ohci_hcd uhci_hcd usbcore
Pid: 2082, comm: cat Not tainted (2.6.24-rc1-b1d08ac064268d0ae2281e98bf5e82627e0f0c56-bloat #4)
EIP: 0060:[<c05a99da>] EFLAGS: 00210256 CPU: 0
EIP is at neigh_stat_seq_next+0x26/0x3f
EAX: 00000001 EBX: f89d7600 ECX: c587bf40 EDX: 00000000
ESI: 00000000 EDI: 00000001 EBP: 00000400 ESP: c587bf1c
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process cat (pid: 2082, ti=c587b000 task=c5984e10 task.ti=c587b000)
Stack: c06228cc c5313790 c049e5c0 0804f000 c45a7b00 c53137b0 00000000 00000000 
       00000082 00000001 00000000 00000000 00000000 fffffffb c58d6780 c049e437 
       c45a7b00 c04b1f93 c587bfa0 00000400 0804f000 00000400 0804f000 c04b1f2f 
Call Trace:
 [<c049e5c0>] seq_read+0x189/0x281
 [<c049e437>] seq_read+0x0/0x281
 [<c04b1f93>] proc_reg_read+0x64/0x77
 [<c04b1f2f>] proc_reg_read+0x0/0x77
 [<c048907e>] vfs_read+0x80/0xd1
 [<c0489491>] sys_read+0x41/0x67
 [<c04080fa>] sysenter_past_esp+0x6b/0xc1
 =======================
Code: e9 ec 8d 05 00 56 8b 11 53 8b 40 70 8b 58 3c eb 29 0f a3 15 80 91 7b c0 19 c0 85 c0 8d 42 01 74 17 89 c6 c1 fe 1f 89 01 89 71 04 <8b> 83 58 01 00 00 f7 d0 8b 04 90 eb 09 89 c2 83 fa 01 7e d2 31 
EIP: [<c05a99da>] neigh_stat_seq_next+0x26/0x3f SS:ESP 0068:c587bf1c

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 net/core/neighbour.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1435,6 +1435,8 @@ int neigh_table_clear(struct neigh_table *tbl)
 	kfree(tbl->phash_buckets);
 	tbl->phash_buckets = NULL;
 
+	remove_proc_entry(tbl->id, init_net.proc_net_stat);
+
 	free_percpu(tbl->stats);
 	tbl->stats = NULL;
 

