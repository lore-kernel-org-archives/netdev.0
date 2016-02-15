From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 3/6] ipv4: Namespacify ip_dynaddr sysctl knob
Date: Mon, 15 Feb 2016 12:11:29 +0200
Message-ID: <1455531092-23184-4-git-send-email-kernel@kyup.com>
References: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Cc: netfilter-devel@vger.kernel.org, ebiederm@xmission.com,
	pabeni@redhat.com, jmorris@namei.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35298 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbcBOKLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 05:11:39 -0500
Received: by mail-wm0-f44.google.com with SMTP id c200so105165363wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 02:11:39 -0800 (PST)
In-Reply-To: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/ip.h           |  3 ---
 include/net/netns/ipv4.h   |  2 ++
 net/ipv4/af_inet.c         | 10 ++--------
 net/ipv4/sysctl_net_ipv4.c | 15 ++++++++-------
 4 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 1a98f1ca1638..e3fb25d76421 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -248,9 +248,6 @@ extern int inet_peer_maxttl;
 /* From ip_input.c */
 extern int sysctl_ip_early_demux;
 
-/* From ip_output.c */
-extern int sysctl_ip_dynaddr;
-
 void ipfrag_init(void);
 
 void ip_static_sysctl_init(void);
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index bc8f7f94abcb..b7e3fb2587da 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -84,6 +84,8 @@ struct netns_ipv4 {
 	int sysctl_ip_no_pmtu_disc;
 	int sysctl_ip_fwd_use_pmtu;
 	int sysctl_ip_nonlocal_bind;
+	/* Shall we try to damage output packets if routing dev changes? */
+	int sysctl_ip_dynaddr;
 
 	int sysctl_fwmark_reflect;
 	int sysctl_tcp_fwmark_accept;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index eade66db214e..209d1ed28954 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1095,12 +1095,6 @@ void inet_unregister_protosw(struct inet_protosw *p)
 }
 EXPORT_SYMBOL(inet_unregister_protosw);
 
-/*
- *      Shall we try to damage output packets if routing dev changes?
- */
-
-int sysctl_ip_dynaddr __read_mostly;
-
 static int inet_sk_reselect_saddr(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1131,7 +1125,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	if (new_saddr == old_saddr)
 		return 0;
 
-	if (sysctl_ip_dynaddr > 1) {
+	if (sock_net(sk)->ipv4.sysctl_ip_dynaddr > 1) {
 		pr_info("%s(): shifting inet->saddr from %pI4 to %pI4\n",
 			__func__, &old_saddr, &new_saddr);
 	}
@@ -1186,7 +1180,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 		 * Other protocols have to map its equivalent state to TCP_SYN_SENT.
 		 * DCCP maps its DCCP_REQUESTING state to TCP_SYN_SENT. -acme
 		 */
-		if (!sysctl_ip_dynaddr ||
+		if (!sock_net(sk)->ipv4.sysctl_ip_dynaddr ||
 		    sk->sk_state != TCP_SYN_SENT ||
 		    (sk->sk_userlocks & SOCK_BINDADDR_LOCK) ||
 		    (err = inet_sk_reselect_saddr(sk)) != 0)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a833a9f9e4cd..04ac5b763385 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -304,13 +304,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "ip_dynaddr",
-		.data		= &sysctl_ip_dynaddr,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_fastopen",
 		.data		= &sysctl_tcp_fastopen,
 		.maxlen		= sizeof(int),
@@ -744,6 +737,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "ip_dynaddr",
+		.data		= &init_net.ipv4.sysctl_ip_dynaddr,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "ip_default_ttl",
 		.data		= &init_net.ipv4.sysctl_ip_default_ttl,
 		.maxlen		= sizeof(int),
@@ -989,6 +989,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 		goto err_ports;
 
 	net->ipv4.sysctl_ip_default_ttl = IPDEFTTL;
+	net->ipv4.sysctl_ip_dynaddr = 0;
 
 	return 0;
 
-- 
2.5.0
