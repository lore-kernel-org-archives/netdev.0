From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2] openvswitch: Initialize unmasked key and uid len
Date: Fri,  6 Feb 2015 11:17:13 -0800
Message-ID: <1423250233-1529-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Joe Stringer <joestringer@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:35166 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751522AbbBFTRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 14:17:13 -0500
Received: by mail-pd0-f173.google.com with SMTP id nh10so13924705pdb.12
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 11:17:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flow alloc needs to initialize unmasked key pointer. Otherwise
it can crash kernel trying to free random unmasked-key pointer.

general protection fault: 0000 [#1] SMP
3.19.0-rc6-net-next+ #457
Hardware name: Supermicro X7DWU/X7DWU, BIOS  1.1 04/30/2008
RIP: 0010:[<ffffffff8111df0e>] [<ffffffff8111df0e>] kfree+0xac/0x196
Call Trace:
 [<ffffffffa060bd87>] flow_free+0x21/0x59 [openvswitch]
 [<ffffffffa060bde0>] ovs_flow_free+0x21/0x23 [openvswitch]
 [<ffffffffa0605b4a>] ovs_packet_cmd_execute+0x2f3/0x35f [openvswitch]
 [<ffffffffa0605995>] ? ovs_packet_cmd_execute+0x13e/0x35f [openvswitch]
 [<ffffffff811fe6fb>] ? nla_parse+0x4f/0xec
 [<ffffffff8139a2fc>] genl_family_rcv_msg+0x26d/0x2c9
 [<ffffffff8107620f>] ? __lock_acquire+0x90e/0x9aa
 [<ffffffff8139a3be>] genl_rcv_msg+0x66/0x89
 [<ffffffff8139a358>] ? genl_family_rcv_msg+0x2c9/0x2c9
 [<ffffffff81399591>] netlink_rcv_skb+0x3e/0x95
 [<ffffffff81399898>] ? genl_rcv+0x18/0x37
 [<ffffffff813998a7>] genl_rcv+0x27/0x37
 [<ffffffff81399033>] netlink_unicast+0x103/0x191
 [<ffffffff81399382>] netlink_sendmsg+0x2c1/0x310
 [<ffffffff811007ad>] ? might_fault+0x50/0xa0
 [<ffffffff8135c773>] do_sock_sendmsg+0x5f/0x7a
 [<ffffffff8135c799>] sock_sendmsg+0xb/0xd
 [<ffffffff8135cacf>] ___sys_sendmsg+0x1a3/0x218
 [<ffffffff8113e54b>] ? get_close_on_exec+0x86/0x86
 [<ffffffff8115a9d0>] ? fsnotify+0x32c/0x348
 [<ffffffff8115a720>] ? fsnotify+0x7c/0x348
 [<ffffffff8113e5f5>] ? __fget+0xaa/0xbf
 [<ffffffff8113e54b>] ? get_close_on_exec+0x86/0x86
 [<ffffffff8135cccd>] __sys_sendmsg+0x3d/0x5e
 [<ffffffff8135cd02>] SyS_sendmsg+0x14/0x16
 [<ffffffff81411852>] system_call_fastpath+0x12/0x17

Fixes: 74ed7ab9264("openvswitch: Add support for unique flow IDs.")
CC: Joe Stringer <joestringer@nicira.com>
Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_table.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 5e57628..d58447d 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -85,6 +85,8 @@ struct sw_flow *ovs_flow_alloc(void)
 
 	flow->sf_acts = NULL;
 	flow->mask = NULL;
+	flow->id.unmasked_key = NULL;
+	flow->id.ufid_len = 0;
 	flow->stats_last_writer = NUMA_NO_NODE;
 
 	/* Initialize the default stat node. */
-- 
1.7.1
