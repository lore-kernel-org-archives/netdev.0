From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net:  Fix ipv6 neighbour unregister_sysctl_table warning
Date: Sun, 30 Jan 2011 12:15:02 -0800
Message-ID: <m11v3utagp.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35945 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814Ab1A3UPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 15:15:09 -0500
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In my testing of 2.6.37 I was occassionally getting a warning about
sysctl table entries being unregistered in the wrong order.  Digging
in it turns out this dates back to the last great sysctl reorg done
where Al Viro introduced the requirement that sysctl directories
needed to be created before and destroyed after the files in them.

It turns out that in that great reorg /proc/sys/net/ipv6/neigh was
overlooked.  So this patch fixes that oversight and makes an annoying
warning message go away.

>------------[ cut here ]------------
>WARNING: at kernel/sysctl.c:1992 unregister_sysctl_table+0x134/0x164()
>Pid: 23951, comm: kworker/u:3 Not tainted 2.6.37-350888.2010AroraKernelBeta.fc14.x86_64 #1
>Call Trace:
> [<ffffffff8103e034>] warn_slowpath_common+0x80/0x98
> [<ffffffff8103e061>] warn_slowpath_null+0x15/0x17
> [<ffffffff810452f8>] unregister_sysctl_table+0x134/0x164
> [<ffffffff810e7834>] ? kfree+0xc4/0xd1
> [<ffffffff813439b2>] neigh_sysctl_unregister+0x22/0x3a
> [<ffffffffa02cd14e>] addrconf_ifdown+0x33f/0x37b [ipv6]
> [<ffffffff81331ec2>] ? skb_dequeue+0x5f/0x6b
> [<ffffffffa02ce4a5>] addrconf_notify+0x69b/0x75c [ipv6]
> [<ffffffffa02eb953>] ? ip6mr_device_event+0x98/0xa9 [ipv6]
> [<ffffffff813d2413>] notifier_call_chain+0x32/0x5e
> [<ffffffff8105bdea>] raw_notifier_call_chain+0xf/0x11
> [<ffffffff8133cdac>] call_netdevice_notifiers+0x45/0x4a
> [<ffffffff8133d2b0>] rollback_registered_many+0x118/0x201
> [<ffffffff8133d3af>] unregister_netdevice_many+0x16/0x6d
> [<ffffffff8133d571>] default_device_exit_batch+0xa4/0xb8
> [<ffffffff81337c42>] ? cleanup_net+0x0/0x194
> [<ffffffff81337a2a>] ops_exit_list+0x4e/0x56
> [<ffffffff81337d36>] cleanup_net+0xf4/0x194
> [<ffffffff81053318>] process_one_work+0x187/0x280
> [<ffffffff8105441b>] worker_thread+0xff/0x19f
> [<ffffffff8105431c>] ? worker_thread+0x0/0x19f
> [<ffffffff8105776d>] kthread+0x7d/0x85
> [<ffffffff81003824>] kernel_thread_helper+0x4/0x10
> [<ffffffff810576f0>] ? kthread+0x0/0x85
> [<ffffffff81003820>] ? kernel_thread_helper+0x0/0x10
>---[ end trace 8a7e9310b35e9486 ]---

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv6/sysctl_net_ipv6.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index fa1d8f4..7cb65ef 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -15,6 +15,8 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
+static struct ctl_table empty[1];
+
 static ctl_table ipv6_table_template[] = {
 	{
 		.procname	= "route",
@@ -35,6 +37,12 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "neigh",
+		.maxlen		= 0,
+		.mode		= 0555,
+		.child		= empty,
+	},
 	{ }
 };
 
@@ -152,7 +160,6 @@ static struct ctl_table_header *ip6_base;
 
 int ipv6_static_sysctl_register(void)
 {
-	static struct ctl_table empty[1];
 	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, empty);
 	if (ip6_base == NULL)
 		return -ENOMEM;
-- 
1.6.5.2.143.g8cc62

