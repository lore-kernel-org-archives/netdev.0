From: Ben Greear <greearb@candelatech.com>
Subject: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 6 Jun 2017 14:06:26 -0700
Message-ID: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:35652 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdFFVG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 17:06:27 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail2.candelatech.com (Postfix) with ESMTPSA id 6DB04409E08
        for <netdev@vger.kernel.org>; Tue,  6 Jun 2017 14:06:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This bug has been around forever, and we recently got an intern and stuck him with
trying to reproduce it on the latest kernel.  It is still here.  I'm not super excited
about trying to fix this, but we can easily test patches if someone has a
patch to try.

Test case is to create 1000 mac-vlans and bring them up, with user-space
tools running lots of 'dump' related commands as part of bringing up the
interfaces and configuring some special source-based routing tables.

(gdb) l *(inet6_dump_fib+0x109)
0x192f9 is in inet6_dump_fib (/home/greearb/git/linux-2.6/net/ipv6/ip6_fib.c:392).
387			} else
388				w->skip = 0;
389	
390			read_lock_bh(&table->tb6_lock);
391			res = fib6_walk_continue(w);
392			read_unlock_bh(&table->tb6_lock);
393			if (res <= 0) {
394				fib6_walker_unlink(net, w);
395				cb->args[4] = 0;
396			}

(gdb) l *(fib6_walk_continue+0x76)
0x188c6 is in fib6_walk_continue (/home/greearb/git/linux-2.6/net/ipv6/ip6_fib.c:1593).
1588				if (fn == w->root)
1589					return 0;
1590				pn = fn->parent;
1591				w->node = pn;
1592	#ifdef CONFIG_IPV6_SUBTREES
1593				if (FIB6_SUBTREE(pn) == fn) {
1594					WARN_ON(!(fn->fn_flags & RTN_ROOT));
1595					w->state = FWS_L;
1596					continue;
1597				}

[root@ct524-ffb0 ~]# BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
IP: fib6_walk_continue+0x76/0x180 [ipv6]
PGD 3d9226067
P4D 3d9226067
PUD 3d9020067
PMD 0

Oops: 0000 [#1] PREEMPT SMP
Modules linked in: nf_conntrack_netlink nf_conntrack nfnetlink nf_defrag_ipv4 libcrc32c bnep fuse macvlan pktgen cfg80211 ipmi_ssif iTCO_wdt iTCO_vendor_support 
coretemp intel_rapl x86_pkg_temp_thermal intel_powerclamp kvm_intel kvm irqbypass joydev i2c_i801 ie31200_edac intel_pch_thermal shpchp hci_uart ipmi_si btbcm 
btqca ipmi_devintf btintel ipmi_msghandler bluetooth pinctrl_sunrisepoint acpi_als pinctrl_intel video tpm_tis intel_lpss_acpi kfifo_buf tpm_tis_core intel_lpss 
industrialio tpm acpi_pad acpi_power_meter sch_fq_codel nfsd auth_rpcgss nfs_acl lockd grace sunrpc ast drm_kms_helper ttm drm igb hwmon ptp pps_core dca 
i2c_algo_bit i2c_hid i2c_core ipv6 crc_ccitt [last unloaded: nf_conntrack]
CPU: 1 PID: 996 Comm: ip Not tainted 4.12.0-rc4+ #32
Hardware name: Supermicro Super Server/X11SSM-F, BIOS 1.0b 12/29/2015
task: ffff8803d4d61dc0 task.stack: ffffc9000970c000
RIP: 0010:fib6_walk_continue+0x76/0x180 [ipv6]
RSP: 0018:ffffc9000970fbb8 EFLAGS: 00010283
RAX: ffff8803de84b020 RBX: ffff8803e0756f00 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffc9000970fc00 RDI: ffffffff81eee280
RBP: ffffc9000970fbc0 R08: 0000000000000008 R09: ffff8803d4fbbf31
R10: ffffc9000970fb68 R11: 0000000000000000 R12: 0000000000000001
R13: 0000000000000001 R14: ffff8803e0756f00 R15: ffff8803d9345b18
FS:  00007f32ca4ec700(0000) GS:ffff880477840000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000018 CR3: 00000003ddacc000 CR4: 00000000003406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  inet6_dump_fib+0x109/0x290 [ipv6]
  netlink_dump+0x11d/0x290
  netlink_recvmsg+0x260/0x3f0
  sock_recvmsg+0x38/0x40
  ___sys_recvmsg+0xe9/0x230
  ? alloc_pages_vma+0x9d/0x260
  ? page_add_new_anon_rmap+0x88/0xc0
  ? lru_cache_add_active_or_unevictable+0x31/0xb0
  ? __handle_mm_fault+0xce3/0xf70
  __sys_recvmsg+0x3d/0x70
  ? __sys_recvmsg+0x3d/0x70
  SyS_recvmsg+0xd/0x20
  do_syscall_64+0x56/0xc0
  entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f32c9e21050
RSP: 002b:00007fff96401de8 EFLAGS: 00000246 ORIG_RAX: 000000000000002f
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f32c9e21050
RDX: 0000000000000000 RSI: 00007fff96401e50 RDI: 0000000000000004
RBP: 00007fff96405e74 R08: 0000000000003fe4 R09: 0000000000000000
R10: 00007fff96401e90 R11: 0000000000000246 R12: 000000000064f3a0
R13: 00007fff96405ee0 R14: 0000000000003fe4 R15: 0000000000000000
Code: f6 40 2a 04 74 11 8b 53 30 85 d2 0f 84 02 01 00 00 83 ea 01 89 53 30 c7 43 28 04 00 00 00 48 39 43 10 74 33 48 8b 10 48 89 53 18 <48> 39 42 18 0f 84 a3 00 
00 00 48 39 42 08 0f 84 ae 00 00 00 48
RIP: fib6_walk_continue+0x76/0x180 [ipv6] RSP: ffffc9000970fbb8
CR2: 0000000000000018
---[ end trace 5ebbc4ee97bea64e ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: disabled
Rebooting in 10 seconds..
ACPI MEMORY or I/O RESET_REG.


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
