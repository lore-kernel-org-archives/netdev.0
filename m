From: Ani Sinha <ani@arista.com>
Subject: [PATCH 1/1] ipmr: fix possible race resulting from improper usage
 of IP_INC_STATS_BH() in preemptible context.
Date: Fri, 30 Oct 2015 16:54:31 -0700 (PDT)
Message-ID: <alpine.OSX.2.00.1510301651240.81585@animac.local>
References: <alpine.OSX.2.00.1510291646320.59200@animac.local> <20151030001510.GG18062@breakpoint.cc> <alpine.OSX.2.00.1510291841480.68875@animac.local> <1446178542.6254.6.camel@edumazet-glaptop2.roam.corp.google.com> <20151030103658.GA25931@breakpoint.cc>
 <1446201624.707140.424480297.4D8B55D6@webmail.messagingengine.com> <20151030104846.GA3461@breakpoint.cc> <1446202828.6254.10.camel@edumazet-glaptop2.roam.corp.google.com> <CAOxq_8Nd8KA8CpwVPtCr2gwDbfzsqRp586PddF7r5DSSmeHb6A@mail.gmail.com>
 <1446232356.6254.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ani Sinha <ani@arista.com>, Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ani Sinha <ani@anirban.org>, fruggeri <fruggeri@arista.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36712 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbJ3Xys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 19:54:48 -0400
Received: by pacfv9 with SMTP id fv9so91023392pac.3
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 16:54:47 -0700 (PDT)
In-Reply-To: <1446232356.6254.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following kernel BUG :

BUG: using __this_cpu_add() in preemptible [00000000] code: bash/2758
caller is __this_cpu_preempt_check+0x13/0x15
CPU: 0 PID: 2758 Comm: bash Tainted: P           O   3.18.19 #2
 ffffffff8170eaca ffff880110d1b788 ffffffff81482b2a 0000000000000000
 0000000000000000 ffff880110d1b7b8 ffffffff812010ae ffff880007cab800
 ffff88001a060800 ffff88013a899108 ffff880108b84240 ffff880110d1b7c8
Call Trace:
[<ffffffff81482b2a>] dump_stack+0x52/0x80
[<ffffffff812010ae>] check_preemption_disabled+0xce/0xe1
[<ffffffff812010d4>] __this_cpu_preempt_check+0x13/0x15
[<ffffffff81419d60>] ipmr_queue_xmit+0x647/0x70c
[<ffffffff8141a154>] ip_mr_forward+0x32f/0x34e
[<ffffffff8141af76>] ip_mroute_setsockopt+0xe03/0x108c
[<ffffffff810553fc>] ? get_parent_ip+0x11/0x42
[<ffffffff810e6974>] ? pollwake+0x4d/0x51
[<ffffffff81058ac0>] ? default_wake_function+0x0/0xf
[<ffffffff810553fc>] ? get_parent_ip+0x11/0x42
[<ffffffff810613d9>] ? __wake_up_common+0x45/0x77
[<ffffffff81486ea9>] ? _raw_spin_unlock_irqrestore+0x1d/0x32
[<ffffffff810618bc>] ? __wake_up_sync_key+0x4a/0x53
[<ffffffff8139a519>] ? sock_def_readable+0x71/0x75
[<ffffffff813dd226>] do_ip_setsockopt+0x9d/0xb55
[<ffffffff81429818>] ? unix_seqpacket_sendmsg+0x3f/0x41
[<ffffffff813963fe>] ? sock_sendmsg+0x6d/0x86
[<ffffffff813959d4>] ? sockfd_lookup_light+0x12/0x5d
[<ffffffff8139650a>] ? SyS_sendto+0xf3/0x11b
[<ffffffff810d5738>] ? new_sync_read+0x82/0xaa
[<ffffffff813ddd19>] compat_ip_setsockopt+0x3b/0x99
[<ffffffff813fb24a>] compat_raw_setsockopt+0x11/0x32
[<ffffffff81399052>] compat_sock_common_setsockopt+0x18/0x1f
[<ffffffff813c4d05>] compat_SyS_setsockopt+0x1a9/0x1cf
[<ffffffff813c4149>] compat_SyS_socketcall+0x180/0x1e3
[<ffffffff81488ea1>] cstar_dispatch+0x7/0x1e

Signed-off-by: Ani Sinha <ani@arista.com>
---
 net/ipv4/ipmr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 866ee89..8e8203d 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1682,8 +1682,8 @@ static inline int ipmr_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip_options *opt = &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
-	IP_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTOCTETS, skb->len);
+	IP_INC_STATS(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_ADD_STATS(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
@@ -1745,7 +1745,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		 * to blackhole.
 		 */
 
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		ip_rt_put(rt);
 		goto out_free;
 	}
-- 
1.8.1.4
