From: Martin Pelikan <martin.pelikan@gmail.com>
Subject: (patch needs review) NULL dereference in xfrm_output with NAT
Date: Wed, 2 Apr 2014 12:37:11 +0200
Message-ID: <20140402103711.GJ5945@methuselah>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:56782 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758444AbaDBKhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 06:37:16 -0400
Received: by mail-wi0-f180.google.com with SMTP id q5so202412wiv.13
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 03:37:14 -0700 (PDT)
Received: from methuselah (methuselah.storkhole.cz. [2a01:490:19:19::19])
        by mx.google.com with ESMTPSA id e42sm3576717eev.32.2014.04.02.03.37.13
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 03:37:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

There was a protection fault caused by nf_xfrm_me_harder.  The xfrm layer
shouldn't have been drinking during its packets' preNATal period, because
the packets can MASQUERADE and give the layer complications during output.


BUG: unable to handle kernel NULL pointer dereference at 00000000000002d0
IP: [<ffffffff81945458>] xfrm_output_resume+0x1c8/0x3a0
PGD 22dafe067 PUD 2306ac067 PMD 0 
Oops: 0000 [#1] SMP 
CPU: 7 PID: 3087 Comm: ping Not tainted 3.14.0-gentoo #1
Hardware name: Gigabyte Technology Co., Ltd. To be filled by O.E.M./970A-DS3P, BIOS F1 04/08/2013
task: ffff8802341333c0 ti: ffff88022d8ca000 task.ti: ffff88022d8ca000
RIP: 0010:[<ffffffff81945458>]  [<ffffffff81945458>] xfrm_output_resume+0x1c8/0x3a0
RSP: 0018:ffff88022d8cba68  EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff880230702600 RCX: 0000000000000000
RDX: 00000000fffffde4 RSI: 0000000000000000 RDI: ffff880230702600
RBP: ffff88022d8cba90 R08: 0000000000000286 R09: 000000009744b544
R10: ffff88022f32fb60 R11: 0000000000000002 R12: 0000000000000001
R13: 0000000000000000 R14: ffff88023043b800 R15: 0000000000000000
FS:  00007f53a4573700(0000) GS:ffff88023edc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000002d0 CR3: 000000022dafd000 CR4: 00000000000407e0
Stack:
 ffff88022d8cbad0 ffff880230702600 ffff880230702600 ffff88022d8cbf18
 ffff88023043b800 ffff88022d8cbac0 ffffffff8194567d ffffffff81ee64c0
 ffff880230702600 ffffffff8197eba0 ffff88022d8cbf18 ffff88022d8cbad0
Call Trace:
 [<ffffffff8194567d>] xfrm_output+0x3d/0x100
 [<ffffffff8197eba0>] ? xfrm6_prepare_output+0x60/0x60
 [<ffffffff8197ebb7>] xfrm6_output_finish+0x17/0x20
 [<ffffffff8193c006>] xfrm4_output+0x46/0x80
 [<ffffffff818e7bb0>] ip_local_out+0x20/0x30
 [<ffffffff818e9cc0>] ip_send_skb+0x10/0x40
 [<ffffffff818e9d1d>] ip_push_pending_frames+0x2d/0x30
 [<ffffffff8190d071>] raw_sendmsg+0x7b1/0x900
 [<ffffffff8195fd09>] ? ip6_route_output+0x69/0xb0
 [<ffffffff81919eed>] inet_sendmsg+0x5d/0xa0
 [<ffffffff81851208>] sock_sendmsg+0x88/0xc0
 [<ffffffff8113ea64>] ? ttwu_do_wakeup+0x14/0xc0
 [<ffffffff811c2100>] ? find_get_page+0x80/0xc0
 [<ffffffff81850cf4>] ? move_addr_to_kernel+0x24/0x40
 [<ffffffff81851798>] ___sys_sendmsg+0x3d8/0x3e0
 [<ffffffff811d00f9>] ? lru_cache_add+0x9/0x10
 [<ffffffff811eb7d3>] ? handle_mm_fault+0x6d3/0xa60
 [<ffffffff8108b344>] ? __do_page_fault+0x234/0x4d0
 [<ffffffff818525cd>] __sys_sendmsg+0x3d/0x80
 [<ffffffff8185261d>] SyS_sendmsg+0xd/0x20
 [<ffffffff819ddbb9>] system_call_fastpath+0x16/0x1b
Code: 00 00 00 4c 89 e0 48 83 e0 fe e9 88 fe ff ff 0f 1f 40 00 85 f6 0f 8f d7 fe ff ff 31 f6 85 d2 0f 8f cd fe ff ff 66 0f 1f 44 00 00 <49> 8b 85 d0 02 00 00 48 89 de 4c 89 ef ff 50 18 85 c0 41 89 c4 
RIP  [<ffffffff81945458>] xfrm_output_resume+0x1c8/0x3a0
 RSP <ffff88022d8cba68>
CR2: 00000000000002d0
---[ end trace 2deb078a5e49b29c ]---


Obviously, this was caused by a packet being sent into an IPv4 flow in an
IPv6 tunnel, on which a postrouting nftables SNAT rule was applied.  That
rule changed the packet's mind about going through the tunnel, but it was
too late.  xfrm_output_one() does indeed check the validity of xfrm_state
in the chain of dst_entry's, but not the first one (Assuming if something
got into xfrm layer means it actually wants at least one transform?)

Comments?  Fix below, but people need to re-check if it's the right spot.
If you agree and can put your name on it, send me and e-mail and I'll try
to send a patch from git.
--
Martin Pelikan


--- ./net/xfrm/xfrm_output.c	2014-04-02 11:27:04.597375669 +0200
+++ ./net/xfrm/xfrm_output.c	2014-04-02 11:26:33.399378335 +0200
@@ -46,6 +46,10 @@
 
 	if (err <= 0)
 		goto resume;
+
+	/* Netfilter NAT can make us not to do even the first transform. */
+	if (x == NULL)
+		return 0;
 
 	do {
 		err = xfrm_skb_check_space(skb);
