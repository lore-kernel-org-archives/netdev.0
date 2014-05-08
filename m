From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] ipv4: fix kfree static array pointer in ipv4_sysctl_exit_net
Date: Thu, 8 May 2014 15:40:45 +0800
Message-ID: <536B34FD.8030601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:12061 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbaEHHln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 03:41:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipv4_sysctl_init_net, we don't kmemdup a sysctl_table for init_net,
so init_net->ipv4.ipv4_hdr->ctl_table_arg points to ipv4_net_table which
is a static array pointer. So when do ipv4_sysctl_exit_net, it will
free the ipv4_net_table for init_net.

So add a check net_namespace init_net before kfree the sysctl_table.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/ipv4/sysctl_net_ipv4.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 44eba05..2825577 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -891,7 +891,8 @@ static __net_exit void ipv4_sysctl_exit_net(struct net *net)
 
 	table = net->ipv4.ipv4_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv4.ipv4_hdr);
-	kfree(table);
+	if (!net_eq(net, &init_net))
+		kfree(table);
 }
 
 static __net_initdata struct pernet_operations ipv4_sysctl_ops = {
-- 
1.7.12
