From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv4: disable BH when changing ip local port range
Date: Tue,  3 Nov 2015 14:32:57 -0800
Message-ID: <1446589977-31225-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33455 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964798AbbKCWdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 17:33:06 -0500
Received: by pabfh17 with SMTP id fh17so30782353pab.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 14:33:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following lockdep warning:

 [ INFO: inconsistent lock state ]
 4.3.0-rc7+ #1197 Not tainted
 ---------------------------------
 inconsistent {IN-SOFTIRQ-R} -> {SOFTIRQ-ON-W} usage.
 sysctl/1019 [HC0[0]:SC0[0]:HE1:SE1] takes:
  (&(&net->ipv4.ip_local_ports.lock)->seqcount){+.+-..}, at: [<ffffffff81921de7>] ipv4_local_port_range+0xb4/0x12a
 {IN-SOFTIRQ-R} state was registered at:
   [<ffffffff810bd682>] __lock_acquire+0x2f6/0xdf0
   [<ffffffff810be6d5>] lock_acquire+0x11c/0x1a4
   [<ffffffff818e599c>] inet_get_local_port_range+0x4e/0xae
   [<ffffffff8166e8e3>] udp_flow_src_port.constprop.40+0x23/0x116
   [<ffffffff81671cb9>] vxlan_xmit_one+0x219/0xa6a
   [<ffffffff81672f75>] vxlan_xmit+0xa6b/0xaa5
   [<ffffffff817f2deb>] dev_hard_start_xmit+0x2ae/0x465
   [<ffffffff817f35ed>] __dev_queue_xmit+0x531/0x633
   [<ffffffff817f3702>] dev_queue_xmit_sk+0x13/0x15
   [<ffffffff818004a5>] neigh_resolve_output+0x12f/0x14d
   [<ffffffff81959cfa>] ip6_finish_output2+0x344/0x39f
   [<ffffffff8195bf58>] ip6_finish_output+0x88/0x8e
   [<ffffffff8195bfef>] ip6_output+0x91/0xe5
   [<ffffffff819792ae>] dst_output_sk+0x47/0x4c
   [<ffffffff81979392>] NF_HOOK_THRESH.constprop.30+0x38/0x82
   [<ffffffff8197981e>] mld_sendpack+0x189/0x266
   [<ffffffff8197b28b>] mld_ifc_timer_expire+0x1ef/0x223
   [<ffffffff810de581>] call_timer_fn+0xfb/0x28c
   [<ffffffff810ded1e>] run_timer_softirq+0x1c7/0x1f1

Fixes: b8f1a55639e6 ("udp: Add function to make source port for UDP tunnels")
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/sysctl_net_ipv4.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 894da3a..ade7737 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -48,14 +48,14 @@ static void set_local_port_range(struct net *net, int range[2])
 {
 	bool same_parity = !((range[0] ^ range[1]) & 1);
 
-	write_seqlock(&net->ipv4.ip_local_ports.lock);
+	write_seqlock_bh(&net->ipv4.ip_local_ports.lock);
 	if (same_parity && !net->ipv4.ip_local_ports.warned) {
 		net->ipv4.ip_local_ports.warned = true;
 		pr_err_ratelimited("ip_local_port_range: prefer different parity for start/end values.\n");
 	}
 	net->ipv4.ip_local_ports.range[0] = range[0];
 	net->ipv4.ip_local_ports.range[1] = range[1];
-	write_sequnlock(&net->ipv4.ip_local_ports.lock);
+	write_sequnlock_bh(&net->ipv4.ip_local_ports.lock);
 }
 
 /* Validate changes from /proc interface. */
-- 
1.8.3.1
