From: Chris Caputo <ccaputo@alt.net>
Subject: panic with 2.6.28 while doing "ip -6 route"
Date: Wed, 14 Jan 2009 02:30:11 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0901140204560.16420@nacho.alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([208.90.169.18]:57357 "EHLO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185AbZANCgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 21:36:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a 2.6.28 x86 system with a full IPv6 route table - 1,524 routes - I can 
reproducibly panic the system with the following:

  ip -6 route | head

The above finishes and a command prompt is shown.  Then about half of the 
time I get a panic:

 BUG: unable to handle kernel paging request at 01000014
  [<c0432168>] ? inet6_rtm_delroute+0x0/0x22
  [<c0432184>] ? inet6_rtm_delroute+0x1c/0x22
  [<c03a0e4b>] ? rtnetlink_rcv_msg+0x188/0x1a2
  [<c03a0cc3>] ? rtnetlink_rcv_msg+0x0/0x1a2
  [<c03bdf1f>] ? netlink_rcv_skb+0x30/0x75
  [<c03a0cbb>] ? rtnetlink_rcv+0x17/0x1f
  [<c03bdd50>] ? netlink_unicast+0x1a8/0x209
  [<c03be40d>] ? netlink_sendmsg+0x21a/0x227
  [<c038f25f>] ? sock_sendmsg+0xca/0xe1
  [<c0231271>] ? autoremove_wake_function+0x0/0x33
  [<c02077f8>] ? nommu_map_single+0x0/0x41
  [<c0398149>] ? dev_kfree_skb_any+0x23/0x2e
  [<f807a73b>] ? e1000_unmap_and_free_tx_resource+0x5b/0x70 [e1000]
  [<c02fbb92>] ? copy_from_user+0x2c/0x4f
  [<c03953e1>] ? verify_iovec+0x40/0x73
  [<c038f3c5>] ? sys_sendmsg+0x14f/0x1aa
  [<c03900bb>] ? sys_socketcall+0x140/0x16d
  [<c0202bf1>] ? sysenter_do_call+0x12/0x25
 Code: 00 ff 48 0c 8b 81 dc 01 00 00 ff 40 14 39 53 18 75 07 c7 43 18 00 00 00 00 b8 d0 2d 5a c0 e8 a6 3f 04 00 8b 15 e4 2d 5a c0 eb 1f <80> 7a 14 02 75 16 39 72 10 75 11 8b 86 88 00 00 00 85 c0 89 42
 EIP: [<c04345e1>] fib6_del+0xd9/0x395 SS:ESP 0068:f6457c10
 Kernel panic - not syncing: Fatal exception in interrupt
 Rebooting in 10 seconds..

or:

 BUG: unable to handle kernel NULL pointer dereferen
  [<c0432143>] ? ip6_route_del+0xd7/0xfc
  [<c0432168>] ? inet6_rtm_delroute+0x0/0x22
  [<c0432184>] ? inet6_rtm_delroute+0x1c/0x22
  [<c03a0e4b>] ? rtnetlink_rcv_msg+0x188/0x1a2
  [<c03a0cc3>] ? rtnetlink_rcv_msg+0x0/0x1a2
  [<c03bdf1f>] ? netlink_rcv_skb+0x30/0x75
  [<c03a0cbb>] ? rtnetlink_rcv+0x17/0x1f
  [<c03bdd50>] ? netlink_unicast+0x1a8/0x209
  [<c03be40d>] ? netlink_sendmsg+0x21a/0x227
  [<c038f25f>] ? sock_sendmsg+0xca/0xe1
  [<c0231271>] ? autoremove_wake_function+0x0/0x33
  [<c0393a71>] ? __kfree_skb+0x63/0x66
  [<c0393a9d>] ? kfree_skb+0x29/0x2b
  [<c042694c>] ? unix_stream_recvmsg+0x38e/0x424
  [<c02fbb92>] ? copy_from_user+0x2c/0x4f
  [<c03953e1>] ? verify_iovec+0x40/0x73
  [<c038f3c5>] ? sys_sendmsg+0x14f/0x1aa
  [<c03900bb>] ? sys_socketcall+0x140/0x16d
  [<c0202bf1>] ? sysenter_do_call+0x12/0x25
 Code: 00 ff 48 0c 8b 81 dc 01 00 00 ff 40 14 39 53 18 75 07 c7 43 18 00 00 00 00 b8 d0 2d 5a c0 e8 a6 3f 04 00 8b 15 e4 2d 5a c0 eb 1f <80> 7a 14 02 75 16 39 72 10 75 11 8b 86 88 00 00 00 85 c0 89 42
 EIP: [<c04345e1>] fib6_del+0xd9/0x395 SS:ESP 0068:f6535c10
 Kernel panic - not syncing: Fatal exception in interrupt
 Rebooting in 10 seconds..

I'm not sure if the "head" command is related.  Quagga with BGP is running 
on this system.  Other details:

CPUs: 2x Intel Xeon 3.06ghz 533mhz FSB 512k ECC cache (both are CPUID F29)
RAM: 1GB
Motherboard: Intel SE7501HG2.  Board Part Number: A95718-306
Kernel: Linux 2.6.28
NIC driver: e1000-8.0.6 from sourceforge
NICs:
  - dual GigE on motherboard
  - Intel PRO/1000 MF Dual Port Server Adapter
InterruptThrottleRate: 0

Chris
