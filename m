From: Julian Anastasov <ja@ssi.bg>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Wed, 5 Sep 2012 23:48:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
References: <20120905043523.GA12988@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39491 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754559Ab2IEUpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 16:45:17 -0400
In-Reply-To: <20120905043523.GA12988@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 5 Sep 2012, Dave Jones wrote:

> Just hit this bug on 3.6-rc4.
> 
> The BUG is..
> 
> 	BUG_ON(!timer->function);
> 
> 
> Not much to go on... Any thoughts on what I could add to get
> more debug info on which protocol etc this was ?
> 
> 	Dave
> 
> 
> kernel BUG at kernel/timer.c:748!
> invalid opcode: 0000 [#1] SMP 
> Modules linked in: tun fuse ipt_ULOG binfmt_misc nfnetlink nfc caif_socket caif phonet can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 nfsv3 nfs_acl nfs fscache lockd sunrpc bluetooth rfkill ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode pcspkr i2c_i801 e1000e uinput i915 video i2c_algo_bit drm_kms_helper drm i2c_core
> CPU 3 
> Pid: 12330, comm: trinity-child3 Not tainted 3.6.0-rc4+ #36
> RIP: 0010:[<ffffffff810813f5>]  [<ffffffff810813f5>] mod_timer+0x2c5/0x2f0
> RSP: 0018:ffff88000dfd7e08  EFLAGS: 00010246
> RAX: 000000000000001a RBX: ffff880122d62948 RCX: 000000000000001a
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88000dfd7e10
> RBP: ffff88000dfd7e48 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000001517000 R11: 0000000000000246 R12: 000000016c000000
> R13: 000000016c12bcb1 R14: ffff8801236cee00 R15: 00000000ffffff01
> FS:  00007fa96745f740(0000) GS:ffff880148200000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000100ff000 CR3: 0000000099344000 CR4: 00000000001407e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process trinity-child3 (pid: 12330, threadinfo ffff88000dfd6000, task ffff880090890000)
> Stack:
>  ffffffff8154cb6d 0000000007b5edf7 ffff88000dfd7e28 ffff880122d62520
>  0000000000000009 0000000000000004 ffff8801236cee00 00000000ffffff01
>  ffff88000dfd7e68 ffffffff8154c79c ffffffff81550e6c ffff880122d62520
> Call Trace:
>  [<ffffffff8154cb6d>] ? lock_sock_nested+0x8d/0xa0
>  [<ffffffff8154c79c>] sk_reset_timer+0x1c/0x30
>  [<ffffffff81550e6c>] ? sock_setsockopt+0x8c/0x960
>  [<ffffffff815a84a0>] inet_csk_reset_keepalive_timer+0x20/0x30
>  [<ffffffff815c018d>] tcp_set_keepalive+0x3d/0x50
>  [<ffffffff81551703>] sock_setsockopt+0x923/0x960
>  [<ffffffff810ddf76>] ? trace_hardirqs_on_caller+0x16/0x1e0
>  [<ffffffff811db0ac>] ? fget_light+0x24c/0x520
>  [<ffffffff8154af86>] sys_setsockopt+0xc6/0xe0
>  [<ffffffff816a50ed>] system_call_fastpath+0x1a/0x1f
> Code: 00 74 43 9c 58 0f 1f 44 00 00 f6 c4 02 0f 84 14 ff ff ff eb 93 48 c7 c7 20 48 c3 81 e8 f5 70 05 00 85 c0 0f 85 fe fe ff ff eb b7 <0f> 0b 48 8b 75 08 48 89 df e8 3d f6 ff ff e9 b2 fd ff ff 4d 89 
> RIP  [<ffffffff810813f5>] mod_timer+0x2c5/0x2f0
>  RSP <ffff88000dfd7e08>
> ---[ end trace 7e7b5910138e49a3 ]---

	Can this help? In case you see ICMPV6_PKT_TOOBIG...

[PATCH] tcp: fix possible socket refcount problem for ipv6

	commit 144d56e91044181ec0ef67aeca91e9a8b5718348
("tcp: fix possible socket refcount problem") is missing
the IPv6 part. As tcp_release_cb is shared by both protocols
we should hold sock reference for the TCP_MTU_REDUCED_DEFERRED
bit.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv6/tcp_ipv6.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 09078b9..f3bfb8b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -403,8 +403,9 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		tp->mtu_info = ntohl(info);
 		if (!sock_owned_by_user(sk))
 			tcp_v6_mtu_reduced(sk);
-		else
-			set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags);
+		else if (!test_and_set_bit(TCP_MTU_REDUCED_DEFERRED,
+					   &tp->tsq_flags))
+			sock_hold(sk);
 		goto out;
 	}
 
-- 
1.7.3.4
