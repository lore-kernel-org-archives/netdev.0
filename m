From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: add rcu locking when changing early demux
Date: Sat, 22 Apr 2017 09:33:16 -0700
Message-ID: <1492878796-31328-1-git-send-email-dsa@cumulusnetworks.com>
Cc: subashab@codeaurora.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:36448 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425606AbdDVQd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 12:33:26 -0400
Received: by mail-it0-f49.google.com with SMTP id g66so17339756ite.1
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 09:33:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

systemd-sysctl is triggering a suspicious RCU usage message when
net.ipv4.tcp_early_demux or net.ipv4.udp_early_demux is changed via
a sysctl config file:

[   33.896184] ===============================
[   33.899558] [ ERR: suspicious RCU usage.  ]
[   33.900624] 4.11.0-rc7+ #104 Not tainted
[   33.901698] -------------------------------
[   33.903059] /home/dsa/kernel-2.git/net/ipv4/sysctl_net_ipv4.c:305 suspicious rcu_dereference_check() usage!
[   33.905724]
other info that might help us debug this:

[   33.907656]
rcu_scheduler_active = 2, debug_locks = 0
[   33.909288] 1 lock held by systemd-sysctl/143:
[   33.910373]  #0:  (sb_writers#5){.+.+.+}, at: [<ffffffff8123a370>] file_start_write+0x45/0x48
[   33.912407]
stack backtrace:
[   33.914018] CPU: 0 PID: 143 Comm: systemd-sysctl Not tainted 4.11.0-rc7+ #104
[   33.915631] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   33.917870] Call Trace:
[   33.918431]  dump_stack+0x81/0xb6
[   33.919241]  lockdep_rcu_suspicious+0x10f/0x118
[   33.920263]  proc_configure_early_demux+0x65/0x10a
[   33.921391]  proc_udp_early_demux+0x3a/0x41

add rcu locking to proc_configure_early_demux.

Fixes: dddb64bcb3461 ("net: Add sysctl to toggle early demux for tcp and udp")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/sysctl_net_ipv4.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 6fb25693c00b..ddac9e64b702 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -302,6 +302,8 @@ static void proc_configure_early_demux(int enabled, int protocol)
 	struct inet6_protocol *ip6prot;
 #endif
 
+	rcu_read_lock();
+
 	ipprot = rcu_dereference(inet_protos[protocol]);
 	if (ipprot)
 		ipprot->early_demux = enabled ? ipprot->early_demux_handler :
@@ -313,6 +315,7 @@ static void proc_configure_early_demux(int enabled, int protocol)
 		ip6prot->early_demux = enabled ? ip6prot->early_demux_handler :
 						 NULL;
 #endif
+	rcu_read_unlock();
 }
 
 static int proc_tcp_early_demux(struct ctl_table *table, int write,
-- 
2.1.4
