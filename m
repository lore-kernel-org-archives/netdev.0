From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 20/20] batman-adv: Allow to disable debugfs support
Date: Mon, 22 Aug 2016 15:56:20 +0200
Message-ID: <20160822135620.15337-21-sw@simonwunderlich.de>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:39006 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755506AbcHVN57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:57:59 -0400
In-Reply-To: <20160822135620.15337-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The files provided by batman-adv via debugfs are currently converted to
netlink. Tools which are not yet converted to use the netlink interface may
still rely on the old debugfs files. But systems which already upgraded
their tools can save some space by disabling this feature. The default
configuration of batman-adv on amd64 can reduce the size of the module by
around 11% when this feature is disabled.

    $ size net/batman-adv/batman-adv.ko*
       text    data     bss     dec     hex filename
     150507   10395    4160  165062   284c6 net/batman-adv/batman-adv.ko.y
     137106    7099    2112  146317   23b8d net/batman-adv/batman-adv.ko.n

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/Kconfig                 | 15 +++++++++++++--
 net/batman-adv/Makefile                |  4 ++--
 net/batman-adv/bat_algo.c              |  2 ++
 net/batman-adv/bat_iv_ogm.c            | 12 ++++++++++++
 net/batman-adv/bat_v.c                 | 12 ++++++++++++
 net/batman-adv/bridge_loop_avoidance.c |  4 ++++
 net/batman-adv/debugfs.h               |  2 +-
 net/batman-adv/distributed-arp-table.c |  2 ++
 net/batman-adv/gateway_client.c        |  2 ++
 net/batman-adv/icmp_socket.h           | 18 +++++++++++++++++-
 net/batman-adv/main.c                  |  2 ++
 net/batman-adv/multicast.c             |  2 ++
 net/batman-adv/network-coding.c        |  2 ++
 net/batman-adv/originator.c            |  4 ++++
 net/batman-adv/translation-table.c     |  4 ++++
 net/batman-adv/types.h                 |  6 ++++++
 16 files changed, 87 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 833bb14..f20742c 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -73,10 +73,21 @@ config BATMAN_ADV_MCAST
 	  reduce the air overhead while improving the reliability of
 	  multicast messages.
 
-config BATMAN_ADV_DEBUG
-	bool "B.A.T.M.A.N. debugging"
+config BATMAN_ADV_DEBUGFS
+	bool "batman-adv debugfs entries"
 	depends on BATMAN_ADV
 	depends on DEBUG_FS
+	default y
+	help
+	  Enable this to export routing related debug tables via debugfs.
+	  The information for each soft-interface and used hard-interface can be
+	  found under batman_adv/
+
+	  If unsure, say Y.
+
+config BATMAN_ADV_DEBUG
+	bool "B.A.T.M.A.N. debugging"
+	depends on BATMAN_ADV_DEBUGFS
 	help
 	  This is an option for use by developers; most people should
 	  say N here. This enables compilation of support for
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index a83fc6c..f724d3c 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -24,14 +24,14 @@ batman-adv-$(CONFIG_BATMAN_ADV_BATMAN_V) += bat_v_elp.o
 batman-adv-$(CONFIG_BATMAN_ADV_BATMAN_V) += bat_v_ogm.o
 batman-adv-y += bitarray.o
 batman-adv-$(CONFIG_BATMAN_ADV_BLA) += bridge_loop_avoidance.o
-batman-adv-$(CONFIG_DEBUG_FS) += debugfs.o
+batman-adv-$(CONFIG_BATMAN_ADV_DEBUGFS) += debugfs.o
 batman-adv-$(CONFIG_BATMAN_ADV_DAT) += distributed-arp-table.o
 batman-adv-y += fragmentation.o
 batman-adv-y += gateway_client.o
 batman-adv-y += gateway_common.o
 batman-adv-y += hard-interface.o
 batman-adv-y += hash.o
-batman-adv-y += icmp_socket.o
+batman-adv-$(CONFIG_BATMAN_ADV_DEBUGFS) += icmp_socket.o
 batman-adv-$(CONFIG_BATMAN_ADV_DEBUG) += log.o
 batman-adv-y += main.o
 batman-adv-$(CONFIG_BATMAN_ADV_MCAST) += multicast.o
diff --git a/net/batman-adv/bat_algo.c b/net/batman-adv/bat_algo.c
index f2cc50d3..623d043 100644
--- a/net/batman-adv/bat_algo.c
+++ b/net/batman-adv/bat_algo.c
@@ -101,6 +101,7 @@ int batadv_algo_select(struct batadv_priv *bat_priv, char *name)
 	return 0;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct batadv_algo_ops *bat_algo_ops;
@@ -113,6 +114,7 @@ int batadv_algo_seq_print_text(struct seq_file *seq, void *offset)
 
 	return 0;
 }
+#endif
 
 static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
 {
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 3c7900d..e2d18d0 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1855,6 +1855,7 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	return NET_RX_SUCCESS;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_iv_ogm_orig_print_neigh - print neighbors for the originator table
  * @orig_node: the orig_node for which the neighbors are printed
@@ -1952,6 +1953,7 @@ next:
 	if (batman_count == 0)
 		seq_puts(seq, "No batman nodes in range ...\n");
 }
+#endif
 
 /**
  * batadv_iv_ogm_neigh_get_tq_avg - Get the TQ average for a neighbour on a
@@ -2182,6 +2184,7 @@ batadv_iv_ogm_orig_dump(struct sk_buff *msg, struct netlink_callback *cb,
 	cb->args[2] = sub;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_iv_hardif_neigh_print - print a single hop neighbour node
  * @seq: neighbour table seq_file struct
@@ -2232,6 +2235,7 @@ static void batadv_iv_neigh_print(struct batadv_priv *bat_priv,
 	if (batman_count == 0)
 		seq_puts(seq, "No batman nodes in range ...\n");
 }
+#endif
 
 /**
  * batadv_iv_ogm_neigh_diff - calculate tq difference of two neighbors
@@ -2618,6 +2622,7 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /* fails if orig_node has no router */
 static int batadv_iv_gw_write_buffer_text(struct batadv_priv *bat_priv,
 					  struct seq_file *seq,
@@ -2681,6 +2686,7 @@ static void batadv_iv_gw_print(struct batadv_priv *bat_priv,
 	if (gw_count == 0)
 		seq_puts(seq, "No gateways in range ...\n");
 }
+#endif
 
 /**
  * batadv_iv_gw_dump_entry - Dump a gateway into a message
@@ -2798,11 +2804,15 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.neigh = {
 		.cmp = batadv_iv_ogm_neigh_cmp,
 		.is_similar_or_better = batadv_iv_ogm_neigh_is_sob,
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 		.print = batadv_iv_neigh_print,
+#endif
 		.dump = batadv_iv_ogm_neigh_dump,
 	},
 	.orig = {
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 		.print = batadv_iv_ogm_orig_print,
+#endif
 		.dump = batadv_iv_ogm_orig_dump,
 		.free = batadv_iv_ogm_orig_free,
 		.add_if = batadv_iv_ogm_orig_add_if,
@@ -2811,7 +2821,9 @@ static struct batadv_algo_ops batadv_batman_iv __read_mostly = {
 	.gw = {
 		.get_best_gw_node = batadv_iv_gw_get_best_gw_node,
 		.is_eligible = batadv_iv_gw_is_eligible,
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 		.print = batadv_iv_gw_print,
+#endif
 		.dump = batadv_iv_gw_dump,
 	},
 };
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index 9e872dc..e79f6f0 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -129,6 +129,7 @@ batadv_v_hardif_neigh_init(struct batadv_hardif_neigh_node *hardif_neigh)
 		  batadv_v_elp_throughput_metric_update);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_v_orig_print_neigh - print neighbors for the originator table
  * @orig_node: the orig_node for which the neighbors are printed
@@ -212,6 +213,7 @@ static void batadv_v_neigh_print(struct batadv_priv *bat_priv,
 	if (batman_count == 0)
 		seq_puts(seq, "No batman nodes in range ...\n");
 }
+#endif
 
 /**
  * batadv_v_neigh_dump_neigh - Dump a neighbour into a message
@@ -345,6 +347,7 @@ batadv_v_neigh_dump(struct sk_buff *msg, struct netlink_callback *cb,
 	cb->args[1] = idx;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_v_orig_print - print the originator table
  * @bat_priv: the bat priv with all the soft interface information
@@ -411,6 +414,7 @@ next:
 	if (batman_count == 0)
 		seq_puts(seq, "No batman nodes in range ...\n");
 }
+#endif
 
 /**
  * batadv_v_orig_dump_subentry - Dump an originator subentry into a
@@ -827,6 +831,7 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /* fails if orig_node has no router */
 static int batadv_v_gw_write_buffer_text(struct batadv_priv *bat_priv,
 					 struct seq_file *seq,
@@ -896,6 +901,7 @@ static void batadv_v_gw_print(struct batadv_priv *bat_priv,
 	if (gw_count == 0)
 		seq_puts(seq, "No gateways in range ...\n");
 }
+#endif
 
 /**
  * batadv_v_gw_dump_entry - Dump a gateway into a message
@@ -1034,11 +1040,15 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 		.hardif_init = batadv_v_hardif_neigh_init,
 		.cmp = batadv_v_neigh_cmp,
 		.is_similar_or_better = batadv_v_neigh_is_sob,
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 		.print = batadv_v_neigh_print,
+#endif
 		.dump = batadv_v_neigh_dump,
 	},
 	.orig = {
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 		.print = batadv_v_orig_print,
+#endif
 		.dump = batadv_v_orig_dump,
 	},
 	.gw = {
@@ -1046,7 +1056,9 @@ static struct batadv_algo_ops batadv_batman_v __read_mostly = {
 		.show_sel_class = batadv_v_show_sel_class,
 		.get_best_gw_node = batadv_v_gw_get_best_gw_node,
 		.is_eligible = batadv_v_gw_is_eligible,
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 		.print = batadv_v_gw_print,
+#endif
 		.dump = batadv_v_gw_dump,
 	},
 };
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 1db3c12..e7f690b 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1996,6 +1996,7 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_bla_claim_table_seq_print_text - print the claim table in a seq file
  * @seq: seq file to print on
@@ -2056,6 +2057,7 @@ out:
 		batadv_hardif_put(primary_if);
 	return 0;
 }
+#endif
 
 /**
  * batadv_bla_claim_dump_entry - dump one entry of the claim table
@@ -2219,6 +2221,7 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_bla_backbone_table_seq_print_text - print the backbone table in a seq
  *  file
@@ -2282,6 +2285,7 @@ out:
 		batadv_hardif_put(primary_if);
 	return 0;
 }
+#endif
 
 /**
  * batadv_bla_backbone_dump_entry - dump one entry of the backbone table
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index 1ab4e2e6..c68ff3d 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -26,7 +26,7 @@ struct net_device;
 
 #define BATADV_DEBUGFS_SUBDIR "batman_adv"
 
-#if IS_ENABLED(CONFIG_DEBUG_FS)
+#if IS_ENABLED(CONFIG_BATMAN_ADV_DEBUGFS)
 
 void batadv_debugfs_init(void);
 void batadv_debugfs_destroy(void);
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 059bc23..e257efd 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -795,6 +795,7 @@ void batadv_dat_free(struct batadv_priv *bat_priv)
 	batadv_dat_hash_free(bat_priv);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_dat_cache_seq_print_text - print the local DAT hash table
  * @seq: seq file to print on
@@ -846,6 +847,7 @@ out:
 		batadv_hardif_put(primary_if);
 	return 0;
 }
+#endif
 
 /**
  * batadv_arp_get_type - parse an ARP packet and gets the type
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 4b51b1c..de055d6 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -482,6 +482,7 @@ void batadv_gw_node_free(struct batadv_priv *bat_priv)
 	spin_unlock_bh(&bat_priv->gw.list_lock);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
@@ -509,6 +510,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 
 	return 0;
 }
+#endif
 
 /**
  * batadv_gw_dump - Dump gateways into a message
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 618d5de..e44a7da 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -26,9 +26,25 @@ struct batadv_icmp_header;
 
 #define BATADV_ICMP_SOCKET "socket"
 
-void batadv_socket_init(void);
 int batadv_socket_setup(struct batadv_priv *bat_priv);
+
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
+
+void batadv_socket_init(void);
 void batadv_socket_receive_packet(struct batadv_icmp_header *icmph,
 				  size_t icmp_len);
 
+#else
+
+static inline void batadv_socket_init(void)
+{
+}
+
+static inline void
+batadv_socket_receive_packet(struct batadv_icmp_header *icmph, size_t icmp_len)
+{
+}
+
+#endif
+
 #endif /* _NET_BATMAN_ADV_ICMP_SOCKET_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index ef07e5b..2c017ab 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -282,6 +282,7 @@ bool batadv_is_my_mac(struct batadv_priv *bat_priv, const u8 *addr)
 	return is_my_mac;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_seq_print_text_primary_if_get - called from debugfs table printing
  *  function that requires the primary interface
@@ -317,6 +318,7 @@ batadv_seq_print_text_primary_if_get(struct seq_file *seq)
 out:
 	return primary_if;
 }
+#endif
 
 /**
  * batadv_max_header_len - calculate maximum encapsulation overhead for a
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 894df60..13661f4 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -1134,6 +1134,7 @@ void batadv_mcast_init(struct batadv_priv *bat_priv)
 				     BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_mcast_flags_print_header - print own mcast flags to debugfs table
  * @bat_priv: the bat priv with all the soft interface information
@@ -1234,6 +1235,7 @@ int batadv_mcast_flags_seq_print_text(struct seq_file *seq, void *offset)
 
 	return 0;
 }
+#endif
 
 /**
  * batadv_mcast_free - free the multicast optimizations structures
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 165cd27..e3baf69 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1881,6 +1881,7 @@ void batadv_nc_mesh_free(struct batadv_priv *bat_priv)
 	batadv_hash_destroy(bat_priv->nc.decoding_hash);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_nc_nodes_seq_print_text - print the nc node information
  * @seq: seq file to print on
@@ -1980,3 +1981,4 @@ int batadv_nc_init_debugfs(struct batadv_priv *bat_priv)
 out:
 	return -ENOMEM;
 }
+#endif
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 0b7d57a..5f3bfc4 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -693,6 +693,7 @@ batadv_neigh_node_get_or_create(struct batadv_orig_node *orig_node,
 	return batadv_neigh_node_create(orig_node, hard_iface, neigh_addr);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_hardif_neigh_seq_print_text - print the single hop neighbour list
  * @seq: neighbour table seq_file struct
@@ -726,6 +727,7 @@ int batadv_hardif_neigh_seq_print_text(struct seq_file *seq, void *offset)
 	bat_priv->algo_ops->neigh.print(bat_priv, seq);
 	return 0;
 }
+#endif
 
 /**
  * batadv_hardif_neigh_dump - Dump to netlink the neighbor infos for a specific
@@ -1339,6 +1341,7 @@ void batadv_purge_orig_ref(struct batadv_priv *bat_priv)
 	_batadv_purge_orig(bat_priv);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 int batadv_orig_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
@@ -1412,6 +1415,7 @@ out:
 		batadv_hardif_put(hard_iface);
 	return 0;
 }
+#endif
 
 /**
  * batadv_orig_dump - Dump to netlink the originator infos for a specific
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d94e298..7f66309 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1047,6 +1047,7 @@ container_register:
 	kfree(tt_data);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 int batadv_tt_local_seq_print_text(struct seq_file *seq, void *offset)
 {
 	struct net_device *net_dev = (struct net_device *)seq->private;
@@ -1114,6 +1115,7 @@ out:
 		batadv_hardif_put(primary_if);
 	return 0;
 }
+#endif
 
 /**
  * batadv_tt_local_dump_entry - Dump one TT local entry into a message
@@ -1796,6 +1798,7 @@ batadv_transtable_best_orig(struct batadv_priv *bat_priv,
 	return best_entry;
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 /**
  * batadv_tt_global_print_entry - print all orig nodes who announce the address
  *  for this global entry
@@ -1919,6 +1922,7 @@ out:
 		batadv_hardif_put(primary_if);
 	return 0;
 }
+#endif
 
 /**
  * batadv_tt_global_dump_subentry - Dump all TT local entries into a message
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b5f01a3..b3dd1a3 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1431,7 +1431,9 @@ struct batadv_algo_neigh_ops {
 				     struct batadv_hard_iface *if_outgoing1,
 				     struct batadv_neigh_node *neigh2,
 				     struct batadv_hard_iface *if_outgoing2);
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 	void (*print)(struct batadv_priv *priv, struct seq_file *seq);
+#endif
 	void (*dump)(struct sk_buff *msg, struct netlink_callback *cb,
 		     struct batadv_priv *priv,
 		     struct batadv_hard_iface *hard_iface);
@@ -1453,8 +1455,10 @@ struct batadv_algo_orig_ops {
 	int (*add_if)(struct batadv_orig_node *orig_node, int max_if_num);
 	int (*del_if)(struct batadv_orig_node *orig_node, int max_if_num,
 		      int del_if_num);
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 	void (*print)(struct batadv_priv *priv, struct seq_file *seq,
 		      struct batadv_hard_iface *hard_iface);
+#endif
 	void (*dump)(struct sk_buff *msg, struct netlink_callback *cb,
 		     struct batadv_priv *priv,
 		     struct batadv_hard_iface *hard_iface);
@@ -1480,7 +1484,9 @@ struct batadv_algo_gw_ops {
 	bool (*is_eligible)(struct batadv_priv *bat_priv,
 			    struct batadv_orig_node *curr_gw_orig,
 			    struct batadv_orig_node *orig_node);
+#ifdef CONFIG_BATMAN_ADV_DEBUGFS
 	void (*print)(struct batadv_priv *bat_priv, struct seq_file *seq);
+#endif
 	void (*dump)(struct sk_buff *msg, struct netlink_callback *cb,
 		     struct batadv_priv *priv);
 };
-- 
2.9.3
