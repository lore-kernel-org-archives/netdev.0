From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: oopses since "net: Optimize memory usage when splicing from sockets"
Date: Thu, 30 Apr 2009 05:16:26 +0200
Message-ID: <20090430031626.GM14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:39406 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbZD3DM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 23:12:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 4fb669948116d928ae44262ab7743732c574630d ("net: Optimize memory
usage when splicing from sockets.") I'm seeing this oops (e.g. in
2.6.30-rc3) when splicing from a TCP socket to /dev/null on a driver
(mv643xx_eth) that uses LRO in the skb mode (lro_receive_skb) rather
than the frag mode:

(sorry, truncated at 80 columns due to terminal emulator)


Unable to handle kernel NULL pointer dereference at virtual address 00000100
pgd = dfb54000
[00000100] *pgd=1fb86031, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1]
Modules linked in:
CPU: 0    Not tainted  (2.6.30-rc3-00485-g2ef470b-dirty #1451)
PC is at __skb_splice_bits+0xcc/0x3ac
LR is at skb_splice_bits+0xa0/0x118
pc : [<c023e440>]    lr : [<c023eb20>]    psr: 80000013
sp : de8e1d38  ip : c07fb880  fp : c07fb880
r10: dfb87a00  r9 : 000005a8  r8 : de8e1d70
r7 : 00000000  r6 : 000005a8  r5 : 00000864  r4 : de8e1e78
r3 : 0000079c  r2 : c0404000  r1 : 00000000  r0 : dfb896e0
Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 0005397f  Table: 1fb54000  DAC: 00000015
Process discard_splice (pid: 1420, stack limit = 0xde8e0268)
Stack: (0xde8e1d38 to 0xde8e2000)
1d20:                                                       00000000 00000000
1d40: de8e1d74 dfb896e0 de8e1ea4 dfb896e0 dfb89640 de8e1e78 de8e1d74 de8e1d70
1d60: c0269b18 dfb87a00 000002f8 c023eb20 000005a8 00000000 00000000 000005a8
1d80: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1da0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1dc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
1de0: 00000000 00000000 00000000 00000000 00000000 de8e1e34 00000001 c01b9a4c
1e00: 0000013c 00000000 df41ec24 c0060724 df41ec20 dfbcfe38 dfbcfe38 00000000
1e20: 400c7000 c006f928 dfbcfe38 c00265c0 c03bf774 df9012ac c07f63a0 00000000
1e40: 00000000 df41ec34 0000008a 0000008a dfbcfe38 00000200 00000000 00000000
1e60: c07fe420 00000000 00000000 c0071b54 00000000 df9adb1c de8e1e38 de8e1d78
1e80: 00000001 00000002 c03baf6c c023e720 00000000 de8e1ef0 00100000 8b55851e
1ea0: 00000b50 de8e1ef0 df9284b8 c0269b44 00000002 dfb89640 00000000 df928460
1ec0: 00000000 c02685d8 00000000 df928460 00000000 de8e0000 de8e1ef0 00100000
1ee0: de8e1f00 df9284ec 00000000 c02687e4 00000000 00100000 de8e1f00 00000000
1f00: dfb87a00 00100000 00000002 00000000 c00ac128 df920a20 df920a40 00100000
1f20: dfb87a00 00100000 dfb87a00 0001537c 00000002 c02382c4 00000002 df920a40
1f40: dfb87a00 c009dcc0 00000002 df920a40 dfb87a00 00000000 df920a40 df920a20
1f60: dfbbaa20 c009ded4 00000002 00018068 de8e1f90 0000004e 00000000 00000000
1f80: 00000008 00100000 00000002 00000000 00000154 c0020a24 de8e0000 0001537c
1fa0: 00018018 c00208a0 00100000 00000002 00000008 00000000 00000005 00000000
1fc0: 00100000 00000002 00000000 00000154 00015384 00015380 0001537c 00018018
1fe0: 0001532c becf1af8 00008e5c 4011a928 60000010 00000008 00000000 00000000
[<c023e440>] (__skb_splice_bits+0xcc/0x3ac) from [<c023eb20>] (skb_splice_bits+)
[<c023eb20>] (skb_splice_bits+0xa0/0x118) from [<c0269b44>] (tcp_splice_data_re)
[<c0269b44>] (tcp_splice_data_recv+0x2c/0x40) from [<c02685d8>] (tcp_read_sock+)
[<c02685d8>] (tcp_read_sock+0x6c/0x1e4) from [<c02687e4>] (tcp_splice_read+0x94)
[<c02687e4>] (tcp_splice_read+0x94/0x1d8) from [<c02382c4>] (sock_splice_read+0)
[<c02382c4>] (sock_splice_read+0x28/0x2c) from [<c009dcc0>] (do_splice_to+0x78/)
[<c009dcc0>] (do_splice_to+0x78/0x84) from [<c009ded4>] (sys_splice+0x208/0x2a8)
[<c009ded4>] (sys_splice+0x208/0x2a8) from [<c00208a0>] (ret_fast_syscall+0x0/0)
Code: e2653a01 e5907008 e1560003 21a06003 (e597a100)
---[ end trace 82cf6824c91dfc15 ]---


addr2line suggests skb->sk is NULL in linear_to_page():


	static inline struct page *linear_to_page(struct page *page, unsigned int *len,
						  unsigned int *offset,
						  struct sk_buff *skb)
	{
		struct sock *sk = skb->sk;
		struct page *p = sk->sk_sndmsg_page;		<========
		unsigned int off;

		if (!p) {


When we get here, skb->sk has apparently already been dropped, leading
to a NULL pointer deref.  Backing out the offending commit makes the
oops go away (as does converting the driver to lro frag rx, but that
destroys routing performance).

Thoughts?  Should we just fall back to plain alloc_pages() if skb->sk
is NULL, or should have still have the socket reference when we get here?
