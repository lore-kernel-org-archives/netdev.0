From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] inet: fix sysctl_local_ports init when namespaces
 are used
Date: Tue, 6 May 2014 07:53:41 +0200
Message-ID: <20140506055341.GA9051@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stefan de Konink <stefan@konink.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48918 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933834AbaEFFyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 01:54:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug: https://bugzilla.kernel.org/show_bug.cgi?id=75221

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Reported-by: Stefan de Konink <stefan@konink.de>
Tested-by: Stefan de Konink <stefan@konink.de>
---
 net/ipv4/af_inet.c         | 36 +++++++++++++++++++++++++++++++-----
 net/ipv4/sysctl_net_ipv4.c | 14 --------------
 2 files changed, 31 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870..9ee66e2 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1629,7 +1629,33 @@ err_tcp_mib:
 	return -ENOMEM;
 }
 
-static __net_exit void ipv4_mib_exit_net(struct net *net)
+static __net_init int inet4_net_init(struct net *net)
+{
+	struct netns_ipv4 *nip4 = &net->ipv4;
+	int rc;
+
+	rc = ipv4_mib_init_net(net);
+	if (rc < 0)
+		return rc;
+
+	/*
+	 * Sane defaults - nobody may create ping sockets.
+	 * Boot scripts should set this to distro-specific group.
+	 */
+	nip4->sysctl_ping_group_range[0] = make_kgid(&init_user_ns, 1);
+	nip4->sysctl_ping_group_range[1] = make_kgid(&init_user_ns, 0);
+
+	/*
+	 * Set defaults for local port range
+	 */
+	seqlock_init(&nip4->sysctl_local_ports.lock);
+	nip4->sysctl_local_ports.range[0] = 32768;
+	nip4->sysctl_local_ports.range[1] = 61000;
+
+	return rc;
+}
+
+static __net_exit void inet4_net_exit(struct net *net)
 {
 	kfree(net->mib.icmpmsg_statistics);
 	snmp_mib_free((void __percpu **)net->mib.icmp_statistics);
@@ -1640,14 +1666,14 @@ static __net_exit void ipv4_mib_exit_net(struct net *net)
 	snmp_mib_free((void __percpu **)net->mib.tcp_statistics);
 }
 
-static __net_initdata struct pernet_operations ipv4_mib_ops = {
-	.init = ipv4_mib_init_net,
-	.exit = ipv4_mib_exit_net,
+static __net_initdata struct pernet_operations inet4_net_ops = {
+	.init = inet4_net_init,
+	.exit = inet4_net_exit,
 };
 
 static int __init init_ipv4_mibs(void)
 {
-	return register_pernet_subsys(&ipv4_mib_ops);
+	return register_pernet_subsys(&inet4_net_ops);
 }
 
 static int ipv4_proc_init(void);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 44eba05..24c0e4e 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -858,20 +858,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			table[i].data += (void *)net - (void *)&init_net;
 	}
 
-	/*
-	 * Sane defaults - nobody may create ping sockets.
-	 * Boot scripts should set this to distro-specific group.
-	 */
-	net->ipv4.sysctl_ping_group_range[0] = make_kgid(&init_user_ns, 1);
-	net->ipv4.sysctl_ping_group_range[1] = make_kgid(&init_user_ns, 0);
-
-	/*
-	 * Set defaults for local port range
-	 */
-	seqlock_init(&net->ipv4.sysctl_local_ports.lock);
-	net->ipv4.sysctl_local_ports.range[0] =  32768;
-	net->ipv4.sysctl_local_ports.range[1] =  61000;
-
 	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
 	if (net->ipv4.ipv4_hdr == NULL)
 		goto err_reg;
-- 
1.9.0
