From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 14/16] proc: clean the ip_misc_proc_init and ip_proc_init_net
 error paths
Date: Thu, 17 Jul 2008 17:40:31 +0400
Message-ID: <487F4BCF.1050502@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38270 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461AbYGQNkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:40:37 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After all this stuff is moved outside, this function can look better.

Besides, I tuned the error path in ip_proc_init_net to make it have
only 2 exit points, not 3.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/proc.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 120e1f7..5543904 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -508,7 +508,7 @@ static const struct file_operations netstat_seq_fops = {
 static __net_init int ip_proc_init_net(struct net *net)
 {
 	if (!proc_net_fops_create(net, "sockstat", S_IRUGO, &sockstat_seq_fops))
-		return -ENOMEM;
+		goto out_sockstat;
 	if (!proc_net_fops_create(net, "netstat", S_IRUGO, &netstat_seq_fops))
 		goto out_netstat;
 	if (!proc_net_fops_create(net, "snmp", S_IRUGO, &snmp_seq_fops))
@@ -520,6 +520,7 @@ out_snmp:
 	proc_net_remove(net, "netstat");
 out_netstat:
 	proc_net_remove(net, "sockstat");
+out_sockstat:
 	return -ENOMEM;
 }
 
@@ -537,16 +538,6 @@ static __net_initdata struct pernet_operations ip_proc_ops = {
 
 int __init ip_misc_proc_init(void)
 {
-	int rc = 0;
-
-	if (register_pernet_subsys(&ip_proc_ops))
-		goto out_pernet;
-
-out:
-	return rc;
-
-out_pernet:
-	rc = -ENOMEM;
-	goto out;
+	return register_pernet_subsys(&ip_proc_ops);
 }
 
-- 
1.5.5.1

