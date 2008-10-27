From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 01/09]IPtablestng/Kernel - some changes for 'x'
Date: Mon, 27 Oct 2008 08:04:15 +0330 (IRST)
Message-ID: <20081027043415.9B336C64088@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

export 'xt' and 'xt_prefix' symbols.

export 'xt' and 'xt_prefix' symbols. this symbols are used by other part of IPtablestng.
also declaring 'classifier' linklist to store the list of clasifiers beside of other linklists(targets/matches).

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index b2c62cc..94a4981 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -124,6 +124,21 @@ struct xt_counters_info
 	struct xt_counters counters[0];
 };
 
+#ifdef __KERNEL__
+#define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
+
+struct xt_af {
+	struct mutex mutex;
+	struct list_head match;
+	struct list_head target;
+	struct list_head classifier;
+#ifdef CONFIG_COMPAT
+	struct mutex compat_mutex;
+	struct compat_delta *compat_offsets;
+#endif
+};
+#endif
+
 #define XT_INV_PROTO		0x40	/* Invert the sense of PROTO. */
 
 /* fn returns 0 to continue iteration */
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index a679208..5120002 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -32,14 +32,14 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_DESCRIPTION("[ip,ip6,arp]_tables backend module");
 
-#define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
+//#define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
 
 struct compat_delta {
 	struct compat_delta *next;
 	unsigned int offset;
 	short delta;
 };
-
+/*
 struct xt_af {
 	struct mutex mutex;
 	struct list_head match;
@@ -49,8 +49,9 @@ struct xt_af {
 	struct compat_delta *compat_offsets;
 #endif
 };
-
-static struct xt_af *xt;
+*/
+struct xt_af *xt;
+EXPORT_SYMBOL(xt);
 
 #ifdef DEBUG_IP_FIREWALL_USER
 #define duprintf(format, args...) printk(format , ## args)
@@ -58,11 +59,12 @@ static struct xt_af *xt;
 #define duprintf(format, args...)
 #endif
 
-static const char *xt_prefix[NPROTO] = {
+const char *xt_prefix[NPROTO] = {
 	[AF_INET]	= "ip",
 	[AF_INET6]	= "ip6",
 	[NF_ARP]	= "arp",
 };
+EXPORT_SYMBOL(xt_prefix);
 
 /* Registration hooks for targets. */
 int
@@ -955,6 +957,7 @@ int xt_proto_init(struct net *net, int af)
 	if (!proc)
 		goto out_remove_matches;
 	proc->data = (void *)(unsigned long)af;
+
 #endif
 
 	return 0;
@@ -1024,6 +1027,7 @@ static int __init xt_init(void)
 #endif
 		INIT_LIST_HEAD(&xt[i].target);
 		INIT_LIST_HEAD(&xt[i].match);
+		INIT_LIST_HEAD(&xt[i].classifier);
 	}
 	rv = register_pernet_subsys(&xt_net_ops);
 	if (rv < 0)

