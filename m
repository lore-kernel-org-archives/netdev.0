From: Chuck Ebbert <cebbert@redhat.com>
Subject: oops / null deref in __inet6_check_established(), kernel 2.6.29-rc6
Date: Tue, 24 Feb 2009 18:21:47 -0500
Message-ID: <20090224182147.2150468e@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48292 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894AbZBXXV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 18:21:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(This doesn't happen on 2.6.27/28)

tw is NULL at net/ipv6/inet6_hashtables.c:261:

	if (twp != NULL) {
		*twp = tw;
===>		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
	} else if (tw != NULL) {

I can reproduce this on real hardware on x86_64 too...

BUG: unable to handle kernel NULL pointer dereference at 00000024
IP: [<c06d3366>] __inet6_check_established+0x24f/0x2b1
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/virtual/misc/fuse/dev
Modules linked in: fuse bridge stp llc bnep sco l2cap bluetooth sunrpc
ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 dm_multipath
uinput ppdev pcspkr i2c_piix4 i2c_core pcnet32 mii parport_pc parport
ata_generic pata_acpi ext4 jbd2 crc16 [last unloaded: microcode]

Pid: 8212, comm: lt-test_simulta Not tainted (2.6.29-0.137.rc5.git4.fc11.i586
#1) VirtualBox
EIP: 0060:[<c06d3366>] EFLAGS: 00210282 CPU: 0
EIP is at __inet6_check_established+0x24f/0x2b1
EAX: dfb74000 EBX: cae41b28 ECX: 00000001 EDX: d2f26dec
ESI: cae41500 EDI: 00000000 EBP: d2f26db4 ESP: d2f26d80
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process lt-test_simulta (pid: 8212, ti=d2f26000 task=cad8a9e0 task.ti=d2f26000)
Stack:
 c0696885 c093cdfc 00000000 000089dc 89dceec8 c107a798 89dc6f8d fa467c59
 df174c84 df19e2c8 cae41500 cadbbbc0 c107bc00 d2f26e04 c06968cc d2f26dec
 000089dc 000089dc e9dac8e1 01820f4f 89dc0000 c093cdfc 000089dc c107a798
Call Trace:
 [<c0696885>] ? __inet_hash_connect+0xaa/0x259
 [<c06968cc>] ? __inet_hash_connect+0xf1/0x259
 [<c06d3008>] ? inet6_hash_connect+0x3b/0x42
 [<c06d3117>] ? __inet6_check_established+0x0/0x2b1
 [<c06d300f>] ? __inet6_hash+0x0/0x108
 [<e167ae54>] ? tcp_v6_connect+0x40f/0x49b [ipv6]
 [<c0518b24>] ? selinux_socket_connect+0xfa/0x109
 [<c06b32b4>] ? inet_stream_connect+0x8a/0x1f9
 [<c06618fc>] ? sys_connect+0x65/0x7f
 [<c044e4f8>] ? lock_release_holdtime+0x2b/0x123
 [<c04513e7>] ? lock_release_non_nested+0xad/0x1a4
 [<c049104f>] ? might_fault+0x48/0x85
 [<c049104f>] ? might_fault+0x48/0x85
 [<c0661f80>] ? sys_socketcall+0x96/0x18a
 [<c0403f92>] ? syscall_call+0x7/0xb
Code: 50 04 8b 45 e8 89 46 1c 8b 45 ec e8 3a d1 01 00 8b 56 20 b9 01 00 00 00
8b 46 24 e8 3f f0 f8 ff 83 7d 08 00 74 1f 8b 55 08 89 3a <8b> 47 24 64 8b 15 04
d0 9d c0 8b 80 a8 00 00 00 f7 d0 8b 04 90 
EIP: [<c06d3366>] __inet6_check_established+0x24f/0x2b1 SS:ESP 0068:d2f26d80
