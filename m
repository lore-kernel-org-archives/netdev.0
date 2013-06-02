From: =?iso-8859-1?Q?S=E9bastien_RAULT?= <sebastien@kveer.com>
Subject: Oops when masquerading ipv4 on ipv6 ipsec
Date: Mon, 3 Jun 2013 00:02:52 +0200
Message-ID: <002601ce5fdc$f0789040$d169b0c0$@kveer.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stormrage.kveer.com ([87.98.189.21]:34604 "EHLO
	stormrage.kveer.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab3FBWDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 18:03:20 -0400
Received: from Anubis (home.kveer.fr [109.190.65.50])
	by stormrage.kveer.com (Postfix) with ESMTPSA id AFB571E0F56
	for <netdev@vger.kernel.org>; Mon,  3 Jun 2013 00:03:12 +0200 (CEST)
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I wish to report an oops which occurred when using NAT for IPv4 and an ipv6
ipsec tunnel.
Steps to reproduce the bug:
- Host A is a linux router for the private network 192.168.0.1/24. his
public address is 2001::a on enp2s0, the public interface.
- Host B is a linux router (same as A) for the private network
192.168.1.1/24, his public address is 2001::b.
- On Host A, have this only rule on PSOTROUTING of table nat: iptables -t
nat -A POSTROUTING -o enp2s0 -s 192.168.0.0/24 -j MASQUERADE --random
- Configure & start ipsec (I use strongswan) to link the 2 private networks.
- Do this ping on Host A: ping 192.168.1.1

This bug exists at least on kernel 3.7.5, 3.8.3, 3.8.6 and 3.9.2 (archi
x64).

The trace (it's with grsec, but I have also tested with a vanilla kernel):
May 20 12:51:06 sargeras kernel: PAX: please report this to
pageexec@freemail.hu
May 20 12:51:06 sargeras kernel: BUG: unable to handle kernel NULL pointer
dereference at 00000000000002a0
May 20 12:51:06 sargeras kernel: IP: [<ffffffff813bd7b6>]
xfrm_output_one+0xa7/0x230
May 20 12:51:06 sargeras kernel: PGD 7ca5f000
May 20 12:51:06 sargeras kernel: Thread overran stack, or stack corrupted
May 20 12:51:06 sargeras kernel: Oops: 0000 [#1] SMP
May 20 12:51:06 sargeras kernel: Modules linked in: xfrm_user vsock(O)
vmsync(O) coretemp processor thermal_sys microcode vmci(O)
May 20 12:51:06 sargeras kernel: CPU 0
May 20 12:51:06 sargeras kernel: Pid: 2274, comm: ping Tainted: G
O 3.8.6-hardened #2 VMware, Inc. VMware Virtual Platform/440BX Desktop
Reference Platform
May 20 12:51:06 sargeras kernel: RIP: 0010:[<ffffffff813bd7b6>]
[<ffffffff813bd7b6>] xfrm_output_one+0xa7/0x230 #
/usr/src/linux/net/xfrm/xfrm_output.c:57
May 20 12:51:06 sargeras kernel: RSP: 0018:ffff88007b4b98e8  EFLAGS:
00010286
May 20 12:51:06 sargeras kernel: RAX: 000000000000021c RBX: ffff88007b400d80
RCX: 0000000000000000
May 20 12:51:06 sargeras kernel: RDX: 00000000fffffde4 RSI: 0000000000000000
RDI: ffff88007b400d80
May 20 12:51:06 sargeras kernel: RBP: ffff88007b4b9918 R08: 00000000d97586c6
R09: 0000000000000600
May 20 12:51:06 sargeras kernel: R10: ffff88007b4b9718 R11: ffff88007ada90f0
R12: 0000000000000000
May 20 12:51:06 sargeras kernel: R13: 8000000000000000 R14: 000000000203a8c0
R15: 0000000000000000
May 20 12:51:06 sargeras kernel: FS:  0000032bc14a9700(0000)
GS:ffff88007fc00000(0000) knlGS:0000000000000000
May 20 12:51:06 sargeras kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
000000008005003b
May 20 12:51:06 sargeras kernel: CR2: 00000000000002a0 CR3: 0000000001434000
CR4: 00000000000007f0
May 20 12:51:06 sargeras kernel: DR0: 0000000000000000 DR1: 0000000000000000
DR2: 0000000000000000
May 20 12:51:06 sargeras kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0
DR7: 0000000000000400
May 20 12:51:06 sargeras kernel: Process ping (pid: 2274, threadinfo
ffff88007cb1dc40, task ffff88007cb1d850)
May 20 12:51:06 sargeras kernel: Stack:
May 20 12:51:06 sargeras kernel: ffff88007b4b9948 ffffffff00000001
0000000000000001 ffff88007b400d80
May 20 12:51:06 sargeras kernel: 8000000000000000 000000000203a8c0
ffff88007b4b9958 ffffffff813bda44
May 20 12:51:06 sargeras kernel: ffffffff813ed84c ffff88007b400d80
0000000000000004 ffff88007b400d80
May 20 12:51:06 sargeras kernel: Call Trace:
May 20 12:51:06 sargeras kernel: [<ffffffff813bda44>]
xfrm_output_resume+0x105/0x131	# /usr/src/linux/net/xfrm/xfrm_output.c:116
May 20 12:51:06 sargeras kernel: [<ffffffff813ed84c>] ?
xfrm6_extract_output+0x3d/0x3d
May 20 12:51:06 sargeras kernel: [<ffffffff813ed84c>] ?
xfrm6_extract_output+0x3d/0x3d	# /usr/src/linux/net/ipv6/xfrm6_output.c:126
May 20 12:51:06 sargeras kernel: [<ffffffff813bda8a>] xfrm_output2+0x1a/0x22
# /usr/src/linux/net/xfrm/xfrm_output.c:144
May 20 12:51:06 sargeras kernel: [<ffffffff8136e65d>] ?
ip_setup_cork+0xfb/0xfb			#
/usr/src/linux/net/ipv4/ip_output.c:722
May 20 12:51:06 sargeras kernel: [<ffffffff813bdb4b>] xfrm_output+0xb9/0xca
# /usr/src/linux/net/xfrm/xfrm_output.c:195
May 20 12:51:06 sargeras kernel: [<ffffffff813ed84c>] ?
xfrm6_extract_output+0x3d/0x3d	# /usr/src/linux/net/ipv6/xfrm6_output.c:126
May 20 12:51:06 sargeras kernel: [<ffffffff813ed86c>]
xfrm6_output_finish+0x20/0x28		#
/usr/src/linux/net/ipv6/xfrm6_output.c:133
May 20 12:51:06 sargeras kernel: [<ffffffff813b4ea1>] xfrm4_output+0x78/0x87
# /usr/src/linux/net/ipv4/xfrm4_output.c:101
May 20 12:51:06 sargeras kernel: [<ffffffff8136fcd7>] ip_local_out+0x31/0x3b
# /usr/src/linux/net/ipv4/ip_output.c:113
May 20 12:51:06 sargeras kernel: [<ffffffff81370cff>] ip_send_skb+0x15/0x41
# /usr/src/linux/net/ipv4/ip_output.c:1365
May 20 12:51:06 sargeras kernel: [<ffffffff81370d68>]
ip_push_pending_frames+0x3d/0x4a	#
/usr/src/linux/net/ipv4/ip_output.c:1385 /
/usr/src/linux/include/net/ip.h:137
May 20 12:51:06 sargeras kernel: [<ffffffff81390ab1>]
raw_sendmsg+0x365/0x401			# /usr/src/linux/net/ipv4/raw.c:615
/ 
May 20 12:51:06 sargeras kernel: [<ffffffff8139b811>] inet_sendmsg+0x97/0xa6
May 20 12:51:06 sargeras kernel: [<ffffffff8130aaa7>] sock_sendmsg+0x9e/0xc5
May 20 12:51:06 sargeras kernel: [<ffffffff81319973>] ?
verify_iovec+0x168/0x1e9
May 20 12:51:06 sargeras kernel: [<ffffffff8130afc4>]
__sys_sendmsg+0x3d5/0x4cf
May 20 12:51:06 sargeras kernel: [<ffffffff8130ab61>] ?
sockfd_lookup_light+0x2a/0x73
May 20 12:51:06 sargeras kernel: [<ffffffff8130e912>] sys_sendmsg+0x43/0x6a
May 20 12:51:06 sargeras kernel: [<ffffffff81427cfa>]
system_call_fastpath+0x18/0x1d
May 20 12:51:06 sargeras kernel: Code: 85 f6 7f 08 31 f6 85 d2 7f 0c eb 1f
85 d2 b8 00 00 00 00 0f 48 d0 b9 20 00 00 00 48 89 df e8 6a 94 f5 ff 85 c0
0f 85 79 01 00 00 <49> 8b 84 24 a0 02 00 00 49 be 00 00 00 00 00 00 00 80 48
89 de
May 20 12:51:06 sargeras kernel: RIP  [<ffffffff813bd7b6>]
xfrm_output_one+0xa7/0x230
May 20 12:51:06 sargeras kernel: RSP <ffff88007b4b98e8>
May 20 12:51:06 sargeras kernel: CR2: 00000000000002a0
May 20 12:51:06 sargeras kernel: ---[ end trace 15eb41c127dbce11 ]---
