From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: Re: [Bugme-new] [Bug 13617] New: GRO:__napi_complete from net_rx_action
 crash
Date: Fri, 26 Jun 2009 10:13:59 -0700
Message-ID: <4A4501D7.8050301@qlogic.com>
References: <bug-13617-10286@http.bugzilla.kernel.org/> <20090625122915.eedcea39.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>,
	David Miller <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:31586 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbZFZRN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 13:13:56 -0400
In-Reply-To: <20090625122915.eedcea39.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mea culpa, likely driver can wait more for rx to drain
so that we race with napi disable.

Although, I have question for Dave. If napi code is
anyway forcing napi completion, should it not flush
gro flows also? This code predates GRO.

-Dhananjay

Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> 
> netdev core crashed.  The netxen driver may be implicated.
> 
> 
> Why did amit@netxen.com create this bug report?  Isn't Dhananjay
> sitting in the next cube?  Perhaps you believe that the driver is OK
> and that the bug lies in the netdev core?
> 
> 
> 
> On Thu, 25 Jun 2009 06:55:14 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=13617
>>
>>            Summary: GRO:__napi_complete from net_rx_action crash
>>            Product: Drivers
>>            Version: 2.5
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>>         ReportedBy: amit@netxen.com
>>         Regression: No
>>
>>
>> In net_rx_action, there is check if napi_disable_pending then call
>> __napi_complete.
>> In __napi_complete, there is BUG_ON(n->gro_list);
>> Which has hit in below bug dump.
>> Why __napi_complete is called from net_rx_action instead of napi_complete.
>> napi_complete flushes the gro list.
>>
>> Below code excerpt from net_rx_action 
>> http://lxr.linux.no/linux+v2.6.30/net/core/dev.c#L2736
>>
>>    if (unlikely(work == weight)) {
>> 2791       if (unlikely(napi_disable_pending(n)))
>> 2792              __napi_complete(n);
>> 2793        else
>> 2794              list_move_tail(&n->poll_list, list);
>> 2795   }
>>
>> ------------[ cut here ]------------
>> kernel BUG at net/core/dev.c:2672!
>> invalid opcode: 0000 [#1] SMP 
>> last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
>> CPU 2 
>> Modules linked in: netxen_nic nfs lockd nfs_acl auth_rpcgss ipv6 deflate
>> zlib_deflate ctr twofish twofish_common serpent blowfish des_generic cbc
>> aes_x86_64 aes_generic xcbc sha256_generic md5 crypto_null af_key autofs4
>> sunrpc iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi dm_mirror
>> dm_region_hash dm_log dm_multipath dm_mod video output sbs sbshc pci_slot
>> battery acpi_memhotplug ac parport ipmi_devintf ide_cd_mod rtc_cmos bnx2 cdrom
>> serio_raw ipmi_si rtc_core button ipmi_msghandler iTCO_wdt rtc_lib shpchp hpilo
>> hpwdt i5000_edac pcspkr edac_core ata_piix libata sd_mod scsi_mod cciss ext3
>> jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
>> Pid: 0, comm: swapper Tainted: G        W  2.6.30 #1 ProLiant DL380 G5
>> RIP: 0010:[<ffffffff8043b128>]  [<ffffffff8043b128>] __napi_complete+0x15/0x25
>> RSP: 0018:ffff880028139eb0  EFLAGS: 00010086
>> RAX: ffff88023d4056b8 RBX: ffff88023d4056a8 RCX: 0000000002202318
>> RDX: 00000000001b0000 RSI: ffff880028139d98 RDI: ffff88023d4056a8
>> RBP: 0000000000000080 R08: 0000000002200000 R09: 000006de15931680
>> R10: ffffc20011a32318 R11: 0000000000000005 R12: 0000000000000000
>> R13: ffff8800281440e0 R14: 0000000000000080 R15: 000000000000012c
>> FS:  0000000000000000(0000) GS:ffff880028136000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
>> CR2: 00000000008cb530 CR3: 000000023d9ab000 CR4: 00000000000006e0
>> Jun 23 23:41:27 DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Process swapper (pid: 0, threadinfo ffff88023ed28000, task ffff88023ed27570)
>> Stack:
>>  ffff88023d4056a8 ffffffff8043ec9f 0000000000000001dut4146 last mes
>> 000000010004f429
>>  ffff88023d4056b8sage repeated 6  0000000000000046 0000000000000001
>> 0000000000000100times
>> Jun 23 23
>>  ffffffff8069a098 0000000000000018 000000000000000a:41:32 dut4146 k
>> ffffffff8023eba6
>> ernel: BUG: scheCall Trace:
>> duling while ato <IRQ> <0>mic: swapper/0/0 [<ffffffff8043ec9f>] ?
>> net_rx_action+0xf0/0x162
>>  [<ffffffff8023eba6>] ? __do_softirq+0xa3/0x163
>>  [<ffffffff8020ca7c>] ? call_softirq+0x1c/0x28
>> x10000100
>> Jun 2 [<ffffffff8020dc1a>] ? do_softirq+0x2c/0x68
>>  [<ffffffff8023eac6>] ? irq_exit+0x3f/0x7c
>>  [<ffffffff8020d46b>] ? do_IRQ+0xa9/0xbf
>> 3 23:41:32 dut41 [<ffffffff8020c353>] ? ret_from_intr+0x0/0xa
>>  <EOI> 46 kernel: Modul<0> [<ffffffff80220e41>] ?
>> hpet_legacy_next_event+0x0/0x7
>> es linked in: ne [<ffffffff80386e2c>] ? acpi_hw_register_read+0x52/0xe5
>>  [<ffffffff80394b2a>] ? acpi_idle_enter_simple+0x120/0x14e
>>  [<ffffffff80394b20>] ? acpi_idle_enter_simple+0x116/0x14e
>>  [<ffffffff8039486b>] ? acpi_idle_enter_bm+0xd5/0x274
>>  [<ffffffff8041c020>] ? cpuidle_idle_call+0x7f/0xbb
>>  [<ffffffff8020aaa5>] ? cpu_idle+0x4a/0x6d
>> Code: txen_nic nfs loc48 8d kd nfs_acl auth_43 70 48 rpcgss ipv6 defl39 c2 ate
>> zlib_deflate0f  ctr twofish two18 0e 75 fish_common serpdf ent blowfish des31
>> c9 41 _generic cbc aes58 5b _x86_64 aes_gene5d 48 89 ric xcbc sha256_c8 c3
>> generic md5 cryp53 f6 to_null af_key a47 10 01 utofs4 sunrpc is48 89 fb csi_tcp
>> libiscsi75 04 _tcp libiscsi sc0f 0b eb si_transport_iscfe 48 83 si dm_mirror
>> dm_7f 50 region_hash dm_l00 74 04 og dm_multipath <0f> dm_mod video out0b eb
>> put sbs sbshc pcfe e8 i_slot battery a1f cpi_memhotplug a10 f1 ff c parport
>> ipmi_df0 80 evintf ide_cd_mo63 10 fe d rtc_cmos bnx2 5b c3 cdrom serio_raw 53
>> 48 89 ipmi_si rtc_corefb e8 
>>  button ipmi_msgRIP  [<ffffffff8043b128>] __napi_complete+0x15/0x25
>>  RSP <ffff880028139eb0>
>> ---[ end trace 9c6b22b26aefd1b1 ]---
>> handler iTCO_wdtKernel panic - not syncing: Fatal exception in interrupt
>> Pid: 0, comm: swapper Tainted: G      D W  2.6.30 #1
>> Call Trace:
>>  <IRQ>  [<ffffffff8023a3b5>] ? panic+0x86/0x134
>>  [<ffffffff8020e348>] ? show_registers+0x211/0x21d
>>  [<ffffffff8024f5ea>] ? up+0xe/0x36
>>  [<ffffffff8023a9db>] ? release_console_sem+0x174/0x18e
>>  [<ffffffff804bdd54>] ? oops_end+0xa0/0xad
>>  [<ffffffff8020cf2c>] ? do_invalid_op+0x85/0x8f
>>  [<ffffffff8043b128>] ? __napi_complete+0x15/0x25
>>  [<ffffffffa03ebfe2>] ? netxen_nic_hw_write_wx_2M+0x24/0xa8 [netxen_nic]
>>  [<ffffffffa03ef866>] ? netxen_process_rcv_ring+0x4eb/0x501 [netxen_nic]
>>  rtc_lib shpchp  [<ffffffff8020c715>] ? invalid_op+0x15/0x20
>>  [<ffffffff8043b128>] ? __napi_complete+0x15/0x25
>>  [<ffffffff8043ec9f>] ? net_rx_action+0xf0/0x162
>>  [<ffffffff8023eba6>] ? __do_softirq+0xa3/0x163
>>  [<ffffffff8020ca7c>] ? call_softirq+0x1c/0x28
>>  [<ffffffff8020dc1a>] ? do_softirq+0x2c/0x68
>>  [<ffffffff8023eac6>] ? irq_exit+0x3f/0x7c
>>  [<ffffffff8020d46b>] ? do_IRQ+0xa9/0xbf
>>  [<ffffffff8020c353>] ? ret_from_intr+0x0/0xa
>>  <EOI>  [<ffffffff80220e41>] ? hpet_legacy_next_event+0x0/0x7
>>  [<ffffffff80386e2c>] ? acpi_hw_register_read+0x52/0xe5
>>  [<ffffffff80394b2a>] ? acpi_idle_enter_simple+0x120/0x14e
>>  [<ffffffff80394b20>] ? acpi_idle_enter_simple+0x116/0x14e
>>  [<ffffffff8039486b>] ? acpi_idle_enter_bm+0xd5/0x274
>>  [<ffffffff8041c020>] ? cpuidle_idle_call+0x7f/0xbb
>>  [<ffffffff8020aaa5>] ? cpu_idle+0x4a/0x6d
>>
>> -- 
>> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
>> ------- You are receiving this mail because: -------
>> You are on the CC list for the bug.
> 
> Checked by AVG - www.avg.com 
> Version: 8.5.374 / Virus Database: 270.12.91/2201 - Release Date: 06/25/09 17:58:00
