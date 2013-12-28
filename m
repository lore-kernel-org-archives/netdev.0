From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/8] netfilter: nfnetlink_log: unset nf_loggers for netns when unloading module
Date: Sat, 28 Dec 2013 23:03:00 +0100
Message-ID: <1388268187-11569-2-git-send-email-pablo@netfilter.org>
References: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43857 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150Ab3L1WDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Dec 2013 17:03:24 -0500
In-Reply-To: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Steven Rostedt and Arnaldo Carvalho de Melo reported a panic
when access the files /proc/sys/net/netfilter/nf_log/*.

This problem will occur when we do:

 echo nfnetlink_log > /proc/sys/net/netfilter/nf_log/any_file
 rmmod nfnetlink_log

and then access the files.

Since the nf_loggers of netns hasn't been unset, it will point
to the memory that has been freed.

This bug is introduced by commit 9368a53c ("netfilter: nfnetlink_log:
add net namespace support for nfnetlink_log").

[17261.822047] BUG: unable to handle kernel paging request at ffffffffa0d49090
[17261.822056] IP: [<ffffffff8157aba0>] nf_log_proc_dostring+0xf0/0x1d0
[...]
[17261.822226] Call Trace:
[17261.822235]  [<ffffffff81297b98>] ? security_capable+0x18/0x20
[17261.822240]  [<ffffffff8106fa09>] ? ns_capable+0x29/0x50
[17261.822247]  [<ffffffff8163d25f>] ? net_ctl_permissions+0x1f/0x90
[17261.822254]  [<ffffffff81216613>] proc_sys_call_handler+0xb3/0xc0
[17261.822258]  [<ffffffff81216651>] proc_sys_read+0x11/0x20
[17261.822265]  [<ffffffff811a80de>] vfs_read+0x9e/0x170
[17261.822270]  [<ffffffff811a8c09>] SyS_read+0x49/0xa0
[17261.822276]  [<ffffffff810e6496>] ? __audit_syscall_exit+0x1f6/0x2a0
[17261.822283]  [<ffffffff81656e99>] system_call_fastpath+0x16/0x1b
[17261.822285] Code: cc 81 4d 63 e4 4c 89 45 88 48 89 4d 90 e8 19 03 0d 00 4b 8b 84 e5 28 08 00 00 48 8b 4d 90 4c 8b 45 88 48 85 c0 0f 84 a8 00 00 00 <48> 8b 40 10 48 89 43 08 48 89 df 4c 89 f2 31 f6 e8 4b 35 af ff
[17261.822329] RIP  [<ffffffff8157aba0>] nf_log_proc_dostring+0xf0/0x1d0
[17261.822334]  RSP <ffff880274d3fe28>
[17261.822336] CR2: ffffffffa0d49090
[17261.822340] ---[ end trace a14ce54c0897a90d ]---

Reported-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 3c4b69e..a155d19 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1053,6 +1053,7 @@ static void __net_exit nfnl_log_net_exit(struct net *net)
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("nfnetlink_log", net->nf.proc_netfilter);
 #endif
+	nf_log_unset(net, &nfulnl_logger);
 }
 
 static struct pernet_operations nfnl_log_net_ops = {
-- 
1.7.10.4
