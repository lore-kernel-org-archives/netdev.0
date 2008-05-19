From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 5/6][FRAGS]: Register some ctls at read-only root.
Date: Mon, 19 May 2008 20:04:07 +0400
Message-ID: <4831A4F7.8070108@openvz.org>
References: <4831A1D6.4090503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56968 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755423AbYESQGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 12:06:35 -0400
In-Reply-To: <4831A1D6.4090503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parts of fragments-related sysctls are read-only, but this is
done by cloning all the tables and dropping write-bits from
mode. Do the same but with read-only root.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ip_fragment.c |   16 ++++++++++++++--
 net/ipv6/reassembly.c  |   35 ++++++++++++++++++++++++++++++++++-
 2 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 7f102ee..be1cb89 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -624,6 +624,10 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 		.strategy	= &sysctl_jiffies
 	},
+	{ }
+};
+
+static struct ctl_table ip4_frags_ctl_table[] = {
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_SECRET_INTERVAL,
 		.procname	= "ipfrag_secret_interval",
@@ -658,8 +662,6 @@ static int ip4_frags_ns_ctl_register(struct net *net)
 		table[0].data = &net->ipv4.frags.high_thresh;
 		table[1].data = &net->ipv4.frags.low_thresh;
 		table[2].data = &net->ipv4.frags.timeout;
-		table[3].mode &= ~0222;
-		table[4].mode &= ~0222;
 	}
 
 	hdr = register_net_sysctl_table(net, net_ipv4_ctl_path, table);
@@ -684,6 +686,11 @@ static void ip4_frags_ns_ctl_unregister(struct net *net)
 	unregister_net_sysctl_table(net->ipv4.frags_hdr);
 	kfree(table);
 }
+
+static void ip4_frags_ctl_register(void)
+{
+	register_net_sysctl_rotable(net_ipv4_ctl_path, ip4_frags_ctl_table);
+}
 #else
 static inline int ip4_frags_ns_ctl_register(struct net *net)
 {
@@ -693,6 +700,10 @@ static inline int ip4_frags_ns_ctl_register(struct net *net)
 static inline void ip4_frags_ns_ctl_unregister(struct net *net)
 {
 }
+
+static inline void ip4_frags_ctl_register(void)
+{
+}
 #endif
 
 static int ipv4_frags_init_net(struct net *net)
@@ -730,6 +741,7 @@ static struct pernet_operations ip4_frags_ops = {
 
 void __init ipfrag_init(void)
 {
+	ip4_frags_ctl_register();
 	register_pernet_subsys(&ip4_frags_ops);
 	ip4_frags.hashfn = ip4_hashfn;
 	ip4_frags.constructor = ip4_frag_init;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 130d6f6..9391a69 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -658,6 +658,10 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 		.strategy	= &sysctl_jiffies,
 	},
+	{ }
+};
+
+static struct ctl_table ip6_frags_ctl_table[] = {
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_SECRET_INTERVAL,
 		.procname	= "ip6frag_secret_interval",
@@ -684,7 +688,6 @@ static int ip6_frags_ns_sysctl_register(struct net *net)
 		table[0].data = &net->ipv6.frags.high_thresh;
 		table[1].data = &net->ipv6.frags.low_thresh;
 		table[2].data = &net->ipv6.frags.timeout;
-		table[3].mode &= ~0222;
 	}
 
 	hdr = register_net_sysctl_table(net, net_ipv6_ctl_path, table);
@@ -709,6 +712,20 @@ static void ip6_frags_ns_sysctl_unregister(struct net *net)
 	unregister_net_sysctl_table(net->ipv6.sysctl.frags_hdr);
 	kfree(table);
 }
+
+static struct ctl_table_header *ip6_ctl_header;
+
+static int ip6_frags_sysctl_register(void)
+{
+	ip6_ctl_header = register_net_sysctl_rotable(net_ipv6_ctl_path,
+			ip6_frags_ctl_table);
+	return ip6_ctl_header == NULL ? -ENOMEM : 0;
+}
+
+static void ip6_frags_sysctl_unregister(void)
+{
+	unregister_net_sysctl_table(ip6_ctl_header);
+}
 #else
 static inline int ip6_frags_ns_sysctl_register(struct net *net)
 {
@@ -718,6 +735,15 @@ static inline int ip6_frags_ns_sysctl_register(struct net *net)
 static inline void ip6_frags_ns_sysctl_unregister(struct net *net)
 {
 }
+
+static inline int ip6_frags_sysctl_register(void)
+{
+	return 0;
+}
+
+static inline void ip6_frags_sysctl_unregister(void)
+{
+}
 #endif
 
 static int ipv6_frags_init_net(struct net *net)
@@ -750,6 +776,10 @@ int __init ipv6_frag_init(void)
 	if (ret)
 		goto out;
 
+	ret = ip6_frags_sysctl_register();
+	if (ret)
+		goto err_sysctl;
+
 	ret = register_pernet_subsys(&ip6_frags_ops);
 	if (ret)
 		goto err_pernet;
@@ -767,6 +797,8 @@ out:
 	return ret;
 
 err_pernet:
+	ip6_frags_sysctl_unregister();
+err_sysctl:
 	inet6_del_protocol(&frag_protocol, IPPROTO_FRAGMENT);
 	goto out;
 }
@@ -774,6 +806,7 @@ err_pernet:
 void ipv6_frag_exit(void)
 {
 	inet_frags_fini(&ip6_frags);
+	ip6_frags_sysctl_unregister();
 	unregister_pernet_subsys(&ip6_frags_ops);
 	inet6_del_protocol(&frag_protocol, IPPROTO_FRAGMENT);
 }
-- 
1.5.3.4

