From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] decnet initialization race
Date: Wed, 14 Jan 2004 16:40:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114164045.06dd85f3.shemminger@osdl.org>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
	<20040113163631.1a9c1a59.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040113163631.1a9c1a59.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Decnet exposes itself to proc and packets before it has finished initializing.
This was always a race, but the notifier replay might expose it worse.

diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	Wed Jan 14 16:27:05 2004
+++ b/net/decnet/af_decnet.c	Wed Jan 14 16:27:05 2004
@@ -2363,17 +2363,16 @@
 	if (!dn_sk_cachep)
 		return -ENOMEM;
 
-	sock_register(&dn_family_ops);
-	dev_add_pack(&dn_dix_packet_type);
-	register_netdevice_notifier(&dn_dev_notifier);
-
-	proc_net_fops_create("decnet", S_IRUGO, &dn_socket_seq_fops);
-
 	dn_neigh_init();
 	dn_dev_init();
 	dn_route_init();
 	dn_fib_init();
 
+	sock_register(&dn_family_ops);
+	dev_add_pack(&dn_dix_packet_type);
+	register_netdevice_notifier(&dn_dev_notifier);
+
+	proc_net_fops_create("decnet", S_IRUGO, &dn_socket_seq_fops);
 	dn_register_sysctl();
 
 	return 0;
