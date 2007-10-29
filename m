From: Chuck Ebbert <cebbert@redhat.com>
Subject: kernel panic removing devices from a teql queuing discipline
Date: Mon, 29 Oct 2007 14:00:01 -0400
Message-ID: <47261FA1.10300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005AbXJ2SAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 14:00:03 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id l9TI02pv018816
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 14:00:02 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l9TI01bI025210
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 14:00:02 -0400
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id l9TI019t011725
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 14:00:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

https://bugzilla.redhat.com/show_bug.cgi?id=219488

Still happening in 2.6.22.9:

BUG: unable to handle kernel paging request at virtual address 66696674
 printing eip:
d098d4de
*pde = 00000000
Oops: 0000 [#1]
SMP 
last sysfs file: /class/net/lo/ifindex
Modules linked in: sch_teql netconsole autofs4 hidp rfcomm l2cap bluetooth sunrpc ipv6 dm_multipath video sbs i2c_ec button battery asus_acpi ac parport_pc lp parport floppy i2c_piix4 pcspkr i2c_core pcnet32 mii serio_raw ide_cd cdrom dm_snapshot dm_zero dm_mirror dm_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
CPU:    0
EIP:    0060:[<d098d4de>]    Not tainted VLI
EFLAGS: 00010202   (2.6.18-1.2849.fc6 #1) 
EIP is at teql_master_xmit+0xdc/0x3aa [sch_teql]
eax: c06a82c0   ebx: cde25c80   ecx: 00000000   edx: c06ad680
esi: c12f8e00   edi: cfc73800   ebp: 66696670   esp: ca6c8bb8
ds: 007b   es: 007b   ss: 0068
Process ping (pid: 2275, ti=ca6c8000 task=cc7bd400 task.ti=ca6c8000)
Stack: cde25174 00000000 000004cc ca6f0800 c12f8e00 000004cc cc7f5280 ca6f0c00 
       cc7f5280 cc7f5280 00000000 00000000 00000000 c06a82c0 00000000 ca6f0800 
       c12f8e00 c12f8e00 c0823e08 c05b9606 ca6c8c20 00000000 c12f8e00 ca6f0800 
Call Trace:
 [<c05b9606>] dev_hard_start_xmit+0x1b9/0x218
 [<c05c72e1>] __qdisc_run+0xde/0x19b
 [<c05baeea>] dev_queue_xmit+0x147/0x265
 [<c05d8a0c>] ip_output+0x1df/0x20b
 [<c05d63bd>] ip_push_pending_frames+0x301/0x3c3
 [<c05ef0a6>] raw_sendmsg+0x62e/0x6f0
 [<c05f5913>] inet_sendmsg+0x3b/0x45
 [<c05af6a6>] sock_sendmsg+0xd0/0xeb
 [<c05afec9>] sys_sendmsg+0x192/0x1f7
 [<c05b1427>] sys_socketcall+0x240/0x261
 [<c0404013>] syscall_call+0x7/0xb

The panic is in __teql_resolve (which has been inlined into teql_master_xmit) in
net/sched/sch_teql.c at this line:

	if (n && n->tbl == mn->tbl &&

Specifically the dereference of n->tbl is faulting as n is not valid.

And the address looks like part of an ASCCI string...  "figt"
