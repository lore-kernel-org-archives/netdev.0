From: Steven Rostedt <rostedt@goodmis.org>
Subject: [BUG][3.10.15] reading from /proc/sys/net/netfilter/nf_log/*
Date: Sat, 14 Dec 2013 10:10:42 -0500
Message-ID: <20131214101042.5626c785@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	Clark Williams <williams@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:49885 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753597Ab3LNPKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 10:10:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to trace down a bug in 3.10.15 that our -rt patch is based
on. It happens in our complex test environment and I'm having trouble
reproducing it on my box.

When the test suite runs nfs-connectathon (I believe from LTP), then
runs a module-load test (randomly loads and unloads modules), one of
the files in  /proc/sys/net/netfilter/nf_log/ becomes corrupted and we
get this crash:

BUG: unable to handle kernel paging request at ffffffffa06189f0 
IP: [<ffffffff814b7904>] nf_log_proc_dostring+0x94/0x1a0 
PGD 1a0d067 PUD 1a0e063 PMD 127d71067 PTE 0 
Oops: 0000 [#1] PREEMPT SMP  
Modules linked in: ts_kmp nf_conntrack_ipv4 nf_defrag_ipv4 nls_koi8_u nls_cp932 rpcsec_gss_krb5 auth_rpcgss oid_registry nfsv4 nfsv3 nfs_acl nfsv2 nfs lockd sunrpc nfnetlink_queue nfnetlink bluetooth cpufreq_ondemand ipv6 ppdev gpio_ich iTCO_wdt iTCO_vendor_support hp_wmi sparse_keymap rfkill coretemp acpi_cpufreq freq_table mperf microcode parport_pc parport pcspkr serio_raw lpc_ich sg snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc i5k_amb i5000_edac edac_core shpchp tg3 ptp pps_core ext4 jbd2 mbcache sd_mod crc_t10dif sr_mod cdrom firewire_ohci firewire_core crc_itu_t mptsas mptscsih mptbase scsi_transport_sas ahci libahci pata_acpi ata_generic ata_piix floppy nouveau ttm drm_kms_helper drm hwmon i2c_algo_
 bit i2c_core mxm_wmi video wmi dm_mirror dm_region_hash dm_log dm_mod [last unloaded: rmd128] 
CPU: 7 PID: 22196 Comm: cat Not tainted 3.10.15-rt11.4.vanilla.el6rt.x86_64 #1 
Hardware name: Hewlett-Packard HP xw8400 Workstation/0A08h, BIOS 786D5 v02.35 11/25/2008 
task: ffff88012544ae20 ti: ffff880124f8e000 task.ti: ffff880124f8e000 
RIP: 0010:[<ffffffff814b7904>]  [<ffffffff814b7904>] nf_log_proc_dostring+0x94/0x1a0 
RSP: 0018:ffff880124f8fdd8  EFLAGS: 00010282 
RAX: ffffffffa06189e0 RBX: ffffffff81cb7c80 RCX: ffff880124f8fe90 
RDX: 00000000006ca000 RSI: 0000000000000000 RDI: ffffffff81ab2b00 
RBP: ffff880124f8fe68 R08: ffff880124f8ff40 R09: 0000000000000000 
R10: 0000000000008fff R11: 0000000000000246 R12: 0000000000000002 
R13: ffffffff81aaef00 R14: 0000000000000002 R15: 00000000006ca000 
FS:  00007fe090b5a700(0000) GS:ffff88012fdc0000(0000) knlGS:0000000000000000 
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033 
CR2: ffffffffa06189f0 CR3: 0000000124e2e000 CR4: 00000000000007e0 
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
Stack: 
 ffff880124f8ff40 ffff880124f8fe90 ffffffff81cb7c80 0000000000000000 
 ffff880124f8fe08 ffffffff81216788 ffff880124f8fe28 ffffffff81059270 
 ffff880124be5440 ffffffff81cb7c80 ffff880124f8fe48 00000000190b4935 
Call Trace: 
 [<ffffffff81216788>] ? security_capable+0x18/0x20 
 [<ffffffff81059270>] ? ns_capable+0x30/0x60 
 [<ffffffff811eb1a2>] proc_sys_call_handler+0x92/0xd0 
 [<ffffffff811eb211>] proc_sys_read+0x11/0x20 
 [<ffffffff81179221>] vfs_read+0xb1/0x130 
 [<ffffffff811796bf>] SyS_read+0x5f/0xa0 
 [<ffffffff810ca5d6>] ? __audit_syscall_exit+0x236/0x2e0 
 [<ffffffff81567399>] system_call_fastpath+0x16/0x1b 
Code: 78 ff ff ff 4c 89 85 70 ff ff ff e8 b7 3d 0a 00 4b 8b 84 f5 d8 07 00 00 48 8b 8d 78 ff ff ff 4c 8b 85 70 ff ff ff 48 85 c0 74 54 <48> 8b 40 10 48 89 43 08 4c 89 fa 48 89 df 31 f6 e8 d7 08 ba ff  
RIP  [<ffffffff814b7904>] nf_log_proc_dostring+0x94/0x1a0 
 RSP <ffff880124f8fdd8> 
CR2: ffffffffa06189f0 
---[ end trace cae5dc9f8f8299f7 ]--- 


We added to the test suite code that reads the nf_log before and after
the module-load test, and before we have this:

# cat /proc/sys/net/netfilter/nf_log/*
NONE
NONE
NONE
NONE
NONE
nfnetlink_log
NONE
NONE
NONE
NONE
NONE
NONE
NONE

And after the module-load test, it crashes when reading those files.

I'm not very familiar with netfilters, net namespaces or the
netlink_log, so my question to you is, what does one do to get that
"nfnetlink_log" to show up in the nf_log/* files? Loading nfnetlink_log
module is not enough.

Unfortunately, the test suite that triggers this is all automated and
has a complex set up, so trying to figure it out from that is a huge
undertaking, which is why I'm writing this email. Maybe someone here
can see this and say, "Oh, to get that all you need to do is this ..."

:-)

Thanks, any help would be much appreciated.

-- Steve
