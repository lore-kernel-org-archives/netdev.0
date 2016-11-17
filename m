From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netns: make struct pernet_operations::id unsigned int
Date: Thu, 17 Nov 2016 04:58:21 +0300
Message-ID: <20161117015821.GA1200@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35415 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933974AbcKPX6a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 18:58:30 -0500
Received: by mail-wm0-f68.google.com with SMTP id a20so16276089wme.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 15:58:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make struct pernet_operations::id unsigned.

There are 2 reasons to do so:

1)
This field is really an index into an zero based array and
thus is unsigned entity. Using negative value is out-of-bound
access by definition.

2)
On x86_64 unsigned 32-bit data which are mixed with pointers
via array indexing or offsets added or subtracted to pointers
are preffered to signed 32-bit data.

"int" being used as an array index needs to be sign-extended
to 64-bit before being used.

	void f(long *p, int i)
	{
		g(p[i]);
	}

  roughly translates to

	movsx	rsi, esi
	mov	rdi, [rsi+...]
	call 	g

MOVSX is 3 byte instruction which isn't necessary if the variable is
unsigned because x86_64 is zero extending by default.

Now, there is net_generic() function which, you guessed it right, uses
"int" as an array index:

	static inline void *net_generic(const struct net *net, int id)
	{
		...
		ptr = ng->ptr[id - 1];
		...
	}

And this function is used a lot, so those sign extensions add up.

Patch snipes ~1730 bytes on allyesconfig kernel (without all junk
messing with code generation):

	add/remove: 0/0 grow/shrink: 70/598 up/down: 396/-2126 (-1730)

Unfortunately some functions actually grow bigger.
This is a semmingly random artefact of code generation with register
allocator being used differently. gcc decides that some variable
needs to live in new r8+ registers and every access now requires REX
prefix. Or it is shifted into r12, so [r12+0] addressing mode has to be
used which is longer than [r8]

However, overall balance is in negative direction:

	add/remove: 0/0 grow/shrink: 70/598 up/down: 396/-2126 (-1730)
	function                                     old     new   delta
	nfsd4_lock                                  3886    3959     +73
	tipc_link_build_proto_msg                   1096    1140     +44
	mac80211_hwsim_new_radio                    2776    2808     +32
	tipc_mon_rcv                                1032    1058     +26
	svcauth_gss_legacy_init                     1413    1429     +16
	tipc_bcbase_select_primary                   379     392     +13
	nfsd4_exchange_id                           1247    1260     +13
	nfsd4_setclientid_confirm                    782     793     +11
		...
	put_client_renew_locked                      494     480     -14
	ip_set_sockfn_get                            730     716     -14
	geneve_sock_add                              829     813     -16
	nfsd4_sequence_done                          721     703     -18
	nlmclnt_lookup_host                          708     686     -22
	nfsd4_lockt                                 1085    1063     -22
	nfs_get_client                              1077    1050     -27
	tcf_bpf_init                                1106    1076     -30
	nfsd4_encode_fattr                          5997    5930     -67
	Total: Before=154856051, After=154854321, chg -0.00%

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/infiniband/core/cma.c                 |    2 +-
 drivers/net/bonding/bond_main.c               |    2 +-
 drivers/net/geneve.c                          |    2 +-
 drivers/net/gtp.c                             |    2 +-
 drivers/net/ppp/ppp_generic.c                 |    2 +-
 drivers/net/ppp/pppoe.c                       |    2 +-
 drivers/net/vxlan.c                           |    2 +-
 drivers/net/wireless/mac80211_hwsim.c         |    2 +-
 fs/lockd/netns.h                              |    2 +-
 fs/lockd/svc.c                                |    2 +-
 fs/nfs/inode.c                                |    2 +-
 fs/nfs/netns.h                                |    2 +-
 fs/nfs_common/grace.c                         |    2 +-
 fs/nfsd/netns.h                               |    2 +-
 fs/nfsd/nfsctl.c                              |    2 +-
 include/net/bonding.h                         |    2 +-
 include/net/ip_tunnels.h                      |    6 +++---
 include/net/net_namespace.h                   |    2 +-
 include/net/netfilter/nf_conntrack_l4proto.h  |    2 +-
 include/net/netfilter/nf_conntrack_synproxy.h |    2 +-
 include/net/netns/generic.h                   |    2 +-
 kernel/audit.c                                |    2 +-
 net/8021q/vlan.c                              |    2 +-
 net/8021q/vlan.h                              |    2 +-
 net/bridge/br_netfilter_hooks.c               |    2 +-
 net/caif/caif_dev.c                           |    2 +-
 net/core/net_namespace.c                      |    7 +++----
 net/core/pktgen.c                             |    2 +-
 net/ipv4/ip_gre.c                             |    4 ++--
 net/ipv4/ip_tunnel.c                          |    4 ++--
 net/ipv4/ip_vti.c                             |    2 +-
 net/ipv4/ipip.c                               |    2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c            |    2 +-
 net/ipv6/ip6_gre.c                            |    2 +-
 net/ipv6/ip6_tunnel.c                         |    2 +-
 net/ipv6/ip6_vti.c                            |    2 +-
 net/ipv6/sit.c                                |    2 +-
 net/ipv6/xfrm6_tunnel.c                       |    2 +-
 net/key/af_key.c                              |    2 +-
 net/netfilter/ipset/ip_set_core.c             |    2 +-
 net/netfilter/ipvs/ip_vs_core.c               |    2 +-
 net/netfilter/nf_conntrack_proto_dccp.c       |    2 +-
 net/netfilter/nf_conntrack_proto_gre.c        |    2 +-
 net/netfilter/nf_conntrack_proto_sctp.c       |    2 +-
 net/netfilter/nf_conntrack_proto_udplite.c    |    2 +-
 net/netfilter/nf_synproxy_core.c              |    2 +-
 net/netfilter/nfnetlink_log.c                 |    2 +-
 net/netfilter/nfnetlink_queue.c               |    2 +-
 net/netfilter/xt_hashlimit.c                  |    2 +-
 net/netfilter/xt_recent.c                     |    2 +-
 net/openvswitch/datapath.c                    |    2 +-
 net/openvswitch/datapath.h                    |    2 +-
 net/phonet/pn_dev.c                           |    2 +-
 net/rds/tcp.c                                 |    2 +-
 net/sched/act_bpf.c                           |    2 +-
 net/sched/act_connmark.c                      |    2 +-
 net/sched/act_csum.c                          |    2 +-
 net/sched/act_gact.c                          |    2 +-
 net/sched/act_ife.c                           |    2 +-
 net/sched/act_ipt.c                           |    4 ++--
 net/sched/act_mirred.c                        |    2 +-
 net/sched/act_nat.c                           |    2 +-
 net/sched/act_pedit.c                         |    2 +-
 net/sched/act_police.c                        |    2 +-
 net/sched/act_simple.c                        |    2 +-
 net/sched/act_skbedit.c                       |    2 +-
 net/sched/act_skbmod.c                        |    2 +-
 net/sched/act_tunnel_key.c                    |    2 +-
 net/sched/act_vlan.c                          |    2 +-
 net/sunrpc/netns.h                            |    2 +-
 net/sunrpc/sunrpc_syms.c                      |    2 +-
 net/tipc/core.c                               |    2 +-
 net/tipc/core.h                               |    2 +-
 73 files changed, 80 insertions(+), 81 deletions(-)

--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -116,7 +116,7 @@ static LIST_HEAD(dev_list);
 static LIST_HEAD(listen_any_list);
 static DEFINE_MUTEX(lock);
 static struct workqueue_struct *cma_wq;
-static int cma_pernet_id;
+static unsigned int cma_pernet_id;
 
 struct cma_pernet {
 	struct idr tcp_ps;
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -199,7 +199,7 @@ MODULE_PARM_DESC(lp_interval, "The number of seconds between instances where "
 atomic_t netpoll_block_tx = ATOMIC_INIT(0);
 #endif
 
-int bond_net_id __read_mostly;
+unsigned int bond_net_id __read_mostly;
 
 static __be32 arp_target[BOND_MAX_ARP_TARGETS];
 static int arp_ip_count;
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -43,7 +43,7 @@ struct geneve_net {
 	struct list_head	sock_list;
 };
 
-static int geneve_net_id;
+static unsigned int geneve_net_id;
 
 union geneve_addr {
 	struct sockaddr_in sin;
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -77,7 +77,7 @@ struct gtp_dev {
 	struct hlist_head	*addr_hash;
 };
 
-static int gtp_net_id __read_mostly;
+static unsigned int gtp_net_id __read_mostly;
 
 struct gtp_net {
 	struct list_head gtp_dev_list;
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -204,7 +204,7 @@ static atomic_t ppp_unit_count = ATOMIC_INIT(0);
 static atomic_t channel_count = ATOMIC_INIT(0);
 
 /* per-net private data for this module */
-static int ppp_net_id __read_mostly;
+static unsigned int ppp_net_id __read_mostly;
 struct ppp_net {
 	/* units to ppp mapping */
 	struct idr units_idr;
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -95,7 +95,7 @@ static const struct proto_ops pppoe_ops;
 static const struct ppp_channel_ops pppoe_chan_ops;
 
 /* per-net private data for this module */
-static int pppoe_net_id __read_mostly;
+static unsigned int pppoe_net_id __read_mostly;
 struct pppoe_net {
 	/*
 	 * we could use _single_ hash table for all
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -52,7 +52,7 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
-static int vxlan_net_id;
+static unsigned int vxlan_net_id;
 static struct rtnl_link_ops vxlan_link_ops;
 
 static const u8 all_zeros_mac[ETH_ALEN + 2];
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -250,7 +250,7 @@ static inline void hwsim_clear_chanctx_magic(struct ieee80211_chanctx_conf *c)
 	cp->magic = 0;
 }
 
-static int hwsim_net_id;
+static unsigned int hwsim_net_id;
 
 static int hwsim_netgroup;
 
--- a/fs/lockd/netns.h
+++ b/fs/lockd/netns.h
@@ -15,6 +15,6 @@ struct lockd_net {
 	struct list_head nsm_handles;
 };
 
-extern int lockd_net_id;
+extern unsigned int lockd_net_id;
 
 #endif
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -57,7 +57,7 @@ static struct task_struct	*nlmsvc_task;
 static struct svc_rqst		*nlmsvc_rqst;
 unsigned long			nlmsvc_timeout;
 
-int lockd_net_id;
+unsigned int lockd_net_id;
 
 /*
  * These can be set at insmod time (useful for NFS as root filesystem),
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2015,7 +2015,7 @@ static void nfsiod_stop(void)
 	destroy_workqueue(wq);
 }
 
-int nfs_net_id;
+unsigned int nfs_net_id;
 EXPORT_SYMBOL_GPL(nfs_net_id);
 
 static int nfs_net_init(struct net *net)
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -35,6 +35,6 @@ struct nfs_net {
 #endif
 };
 
-extern int nfs_net_id;
+extern unsigned int nfs_net_id;
 
 #endif
--- a/fs/nfs_common/grace.c
+++ b/fs/nfs_common/grace.c
@@ -9,7 +9,7 @@
 #include <net/netns/generic.h>
 #include <linux/fs.h>
 
-static int grace_net_id;
+static unsigned int grace_net_id;
 static DEFINE_SPINLOCK(grace_lock);
 
 /**
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -124,5 +124,5 @@ struct nfsd_net {
 /* Simple check to find out if a given net was properly initialized */
 #define nfsd_netns_ready(nn) ((nn)->sessionid_hashtbl)
 
-extern int nfsd_net_id;
+extern unsigned int nfsd_net_id;
 #endif /* __NFSD_NETNS_H__ */
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1201,7 +1201,7 @@ static int create_proc_exports_entry(void)
 }
 #endif
 
-int nfsd_net_id;
+unsigned int nfsd_net_id;
 
 static __net_init int nfsd_init_net(struct net *net)
 {
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -681,7 +681,7 @@ static inline int bond_get_targets_ip(__be32 *targets, __be32 ip)
 }
 
 /* exported from bond_main.c */
-extern int bond_net_id;
+extern unsigned int bond_net_id;
 extern const struct bond_parm_tbl bond_lacp_tbl[];
 extern const struct bond_parm_tbl xmit_hashtype_tbl[];
 extern const struct bond_parm_tbl arp_validate_tbl[];
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -129,7 +129,7 @@ struct ip_tunnel {
 #endif
 	struct ip_tunnel_prl_entry __rcu *prl;	/* potential router list */
 	unsigned int		prl_count;	/* # of entries in PRL */
-	int			ip_tnl_net_id;
+	unsigned int		ip_tnl_net_id;
 	struct gro_cells	gro_cells;
 	bool			collect_md;
 	bool			ignore_df;
@@ -248,7 +248,7 @@ void ip_tunnel_uninit(struct net_device *dev);
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
 struct net *ip_tunnel_get_link_net(const struct net_device *dev);
 int ip_tunnel_get_iflink(const struct net_device *dev);
-int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
+int ip_tunnel_init_net(struct net *net, unsigned int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
 
 void ip_tunnel_delete_net(struct ip_tunnel_net *itn, struct rtnl_link_ops *ops);
@@ -275,7 +275,7 @@ int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 			 struct ip_tunnel_parm *p);
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p);
-void ip_tunnel_setup(struct net_device *dev, int net_id);
+void ip_tunnel_setup(struct net_device *dev, unsigned int net_id);
 
 struct ip_tunnel_encap_ops {
 	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -291,7 +291,7 @@ struct pernet_operations {
 	int (*init)(struct net *net);
 	void (*exit)(struct net *net);
 	void (*exit_batch)(struct list_head *net_exit_list);
-	int *id;
+	unsigned int *id;
 	size_t size;
 };
 
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -98,7 +98,7 @@ struct nf_conntrack_l4proto {
 		const struct nla_policy *nla_policy;
 	} ctnl_timeout;
 #endif
-	int	*net_id;
+	unsigned int	*net_id;
 	/* Init l4proto pernet data */
 	int (*init_net)(struct net *net, u_int16_t proto);
 
--- a/include/net/netfilter/nf_conntrack_synproxy.h
+++ b/include/net/netfilter/nf_conntrack_synproxy.h
@@ -54,7 +54,7 @@ struct synproxy_net {
 	struct synproxy_stats __percpu	*stats;
 };
 
-extern int synproxy_net_id;
+extern unsigned int synproxy_net_id;
 static inline struct synproxy_net *synproxy_pernet(struct net *net)
 {
 	return net_generic(net, synproxy_net_id);
--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -31,7 +31,7 @@ struct net_generic {
 	void *ptr[0];
 };
 
-static inline void *net_generic(const struct net *net, int id)
+static inline void *net_generic(const struct net *net, unsigned int id)
 {
 	struct net_generic *ng;
 	void *ptr;
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -126,7 +126,7 @@ static atomic_t    audit_lost = ATOMIC_INIT(0);
 
 /* The netlink socket. */
 static struct sock *audit_sock;
-static int audit_net_id;
+static unsigned int audit_net_id;
 
 /* Hash for inode-based rules */
 struct list_head audit_inode_hash[AUDIT_INODE_BUCKETS];
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -44,7 +44,7 @@
 
 /* Global VLAN variables */
 
-int vlan_net_id __read_mostly;
+unsigned int vlan_net_id __read_mostly;
 
 const char vlan_fullname[] = "802.1Q VLAN Support";
 const char vlan_version[] = DRV_VERSION;
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -159,7 +159,7 @@ void vlan_netlink_fini(void);
 
 extern struct rtnl_link_ops vlan_link_ops;
 
-extern int vlan_net_id;
+extern unsigned int vlan_net_id;
 
 struct proc_dir_entry;
 
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -46,7 +46,7 @@
 #include <linux/sysctl.h>
 #endif
 
-static int brnf_net_id __read_mostly;
+static unsigned int brnf_net_id __read_mostly;
 
 struct brnf_net {
 	bool enabled;
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -52,7 +52,7 @@ struct caif_net {
 	struct caif_device_entry_list caifdevs;
 };
 
-static int caif_net_id;
+static unsigned int caif_net_id;
 static int q_high = 50; /* Percent */
 
 struct cfcnfg *get_cfcnfg(struct net *net)
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -55,7 +55,7 @@ static struct net_generic *net_alloc_generic(void)
 	return ng;
 }
 
-static int net_assign_generic(struct net *net, int id, void *data)
+static int net_assign_generic(struct net *net, unsigned int id, void *data)
 {
 	struct net_generic *ng, *old_ng;
 
@@ -122,8 +122,7 @@ static int ops_init(const struct pernet_operations *ops, struct net *net)
 static void ops_free(const struct pernet_operations *ops, struct net *net)
 {
 	if (ops->id && ops->size) {
-		int id = *ops->id;
-		kfree(net_generic(net, id));
+		kfree(net_generic(net, *ops->id));
 	}
 }
 
@@ -881,7 +880,7 @@ static int register_pernet_operations(struct list_head *list,
 			}
 			return error;
 		}
-		max_gen_ptrs = max_t(unsigned int, max_gen_ptrs, *ops->id);
+		max_gen_ptrs = max(max_gen_ptrs, *ops->id);
 	}
 	error = __register_pernet_operations(list, ops);
 	if (error) {
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -413,7 +413,7 @@ struct pktgen_hdr {
 };
 
 
-static int pg_net_id __read_mostly;
+static unsigned int pg_net_id __read_mostly;
 
 struct pktgen_net {
 	struct net		*net;
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -113,8 +113,8 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 static struct rtnl_link_ops ipgre_link_ops __read_mostly;
 static int ipgre_tunnel_init(struct net_device *dev);
 
-static int ipgre_net_id __read_mostly;
-static int gre_tap_net_id __read_mostly;
+static unsigned int ipgre_net_id __read_mostly;
+static unsigned int gre_tap_net_id __read_mostly;
 
 static void ipgre_err(struct sk_buff *skb, u32 info,
 		      const struct tnl_ptk_info *tpi)
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -994,7 +994,7 @@ int ip_tunnel_get_iflink(const struct net_device *dev)
 }
 EXPORT_SYMBOL(ip_tunnel_get_iflink);
 
-int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
+int ip_tunnel_init_net(struct net *net, unsigned int ip_tnl_net_id,
 				  struct rtnl_link_ops *ops, char *devname)
 {
 	struct ip_tunnel_net *itn = net_generic(net, ip_tnl_net_id);
@@ -1196,7 +1196,7 @@ void ip_tunnel_uninit(struct net_device *dev)
 EXPORT_SYMBOL_GPL(ip_tunnel_uninit);
 
 /* Do least required initialization, rest of init is done in tunnel_init call */
-void ip_tunnel_setup(struct net_device *dev, int net_id)
+void ip_tunnel_setup(struct net_device *dev, unsigned int net_id)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	tunnel->ip_tnl_net_id = net_id;
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -46,7 +46,7 @@
 
 static struct rtnl_link_ops vti_link_ops __read_mostly;
 
-static int vti_net_id __read_mostly;
+static unsigned int vti_net_id __read_mostly;
 static int vti_tunnel_init(struct net_device *dev);
 
 static int vti_input(struct sk_buff *skb, int nexthdr, __be32 spi,
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -121,7 +121,7 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
-static int ipip_net_id __read_mostly;
+static unsigned int ipip_net_id __read_mostly;
 
 static int ipip_tunnel_init(struct net_device *dev);
 static struct rtnl_link_ops ipip_link_ops __read_mostly;
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -62,7 +62,7 @@ struct clusterip_config {
 static const struct file_operations clusterip_proc_fops;
 #endif
 
-static int clusterip_net_id __read_mostly;
+static unsigned int clusterip_net_id __read_mostly;
 
 struct clusterip_net {
 	struct list_head configs;
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -64,7 +64,7 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 #define IP6_GRE_HASH_SIZE_SHIFT  5
 #define IP6_GRE_HASH_SIZE (1 << IP6_GRE_HASH_SIZE_SHIFT)
 
-static int ip6gre_net_id __read_mostly;
+static unsigned int ip6gre_net_id __read_mostly;
 struct ip6gre_net {
 	struct ip6_tnl __rcu *tunnels[4][IP6_GRE_HASH_SIZE];
 
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -83,7 +83,7 @@ static int ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
 static struct rtnl_link_ops ip6_link_ops __read_mostly;
 
-static int ip6_tnl_net_id __read_mostly;
+static unsigned int ip6_tnl_net_id __read_mostly;
 struct ip6_tnl_net {
 	/* the IPv6 tunnel fallback device */
 	struct net_device *fb_tnl_dev;
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -64,7 +64,7 @@ static int vti6_dev_init(struct net_device *dev);
 static void vti6_dev_setup(struct net_device *dev);
 static struct rtnl_link_ops vti6_link_ops __read_mostly;
 
-static int vti6_net_id __read_mostly;
+static unsigned int vti6_net_id __read_mostly;
 struct vti6_net {
 	/* the vti6 tunnel fallback device */
 	struct net_device *fb_tnl_dev;
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -76,7 +76,7 @@ static bool check_6rd(struct ip_tunnel *tunnel, const struct in6_addr *v6dst,
 		      __be32 *v4dst);
 static struct rtnl_link_ops sit_link_ops __read_mostly;
 
-static int sit_net_id __read_mostly;
+static unsigned int sit_net_id __read_mostly;
 struct sit_net {
 	struct ip_tunnel __rcu *tunnels_r_l[IP6_SIT_HASH_SIZE];
 	struct ip_tunnel __rcu *tunnels_r[IP6_SIT_HASH_SIZE];
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -44,7 +44,7 @@ struct xfrm6_tunnel_net {
 	u32 spi;
 };
 
-static int xfrm6_tunnel_net_id __read_mostly;
+static unsigned int xfrm6_tunnel_net_id __read_mostly;
 static inline struct xfrm6_tunnel_net *xfrm6_tunnel_pernet(struct net *net)
 {
 	return net_generic(net, xfrm6_tunnel_net_id);
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -36,7 +36,7 @@
 #define _X2KEY(x) ((x) == XFRM_INF ? 0 : (x))
 #define _KEY2X(x) ((x) == 0 ? XFRM_INF : (x))
 
-static int pfkey_net_id __read_mostly;
+static unsigned int pfkey_net_id __read_mostly;
 struct netns_pfkey {
 	/* List of all pfkey sockets. */
 	struct hlist_head table;
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -36,7 +36,7 @@ struct ip_set_net {
 	bool		is_destroyed;	/* all sets are destroyed */
 };
 
-static int ip_set_net_id __read_mostly;
+static unsigned int ip_set_net_id __read_mostly;
 
 static inline struct ip_set_net *ip_set_pernet(struct net *net)
 {
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -70,7 +70,7 @@ EXPORT_SYMBOL(ip_vs_get_debug_level);
 #endif
 EXPORT_SYMBOL(ip_vs_new_conn_out);
 
-static int ip_vs_net_id __read_mostly;
+static unsigned int ip_vs_net_id __read_mostly;
 /* netns cnt used for uniqueness */
 static atomic_t ipvs_netns_cnt = ATOMIC_INIT(0);
 
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -385,7 +385,7 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 };
 
 /* this module per-net specifics */
-static int dccp_net_id __read_mostly;
+static unsigned int dccp_net_id __read_mostly;
 struct dccp_net {
 	struct nf_proto_net pn;
 	int dccp_loose;
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -53,7 +53,7 @@ static unsigned int gre_timeouts[GRE_CT_MAX] = {
 	[GRE_CT_REPLIED]	= 180*HZ,
 };
 
-static int proto_gre_net_id __read_mostly;
+static unsigned int proto_gre_net_id __read_mostly;
 struct netns_proto_gre {
 	struct nf_proto_net	nf;
 	rwlock_t		keymap_lock;
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -144,7 +144,7 @@ static const u8 sctp_conntracks[2][11][SCTP_CONNTRACK_MAX] = {
 	}
 };
 
-static int sctp_net_id	__read_mostly;
+static unsigned int sctp_net_id	__read_mostly;
 struct sctp_net {
 	struct nf_proto_net pn;
 	unsigned int timeouts[SCTP_CONNTRACK_MAX];
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -35,7 +35,7 @@ static unsigned int udplite_timeouts[UDPLITE_CT_MAX] = {
 	[UDPLITE_CT_REPLIED]	= 180*HZ,
 };
 
-static int udplite_net_id __read_mostly;
+static unsigned int udplite_net_id __read_mostly;
 struct udplite_net {
 	struct nf_proto_net pn;
 	unsigned int timeouts[UDPLITE_CT_MAX];
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -24,7 +24,7 @@
 #include <net/netfilter/nf_conntrack_synproxy.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
-int synproxy_net_id;
+unsigned int synproxy_net_id;
 EXPORT_SYMBOL_GPL(synproxy_net_id);
 
 bool
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -80,7 +80,7 @@ struct nfulnl_instance {
 
 #define INSTANCE_BUCKETS	16
 
-static int nfnl_log_net_id __read_mostly;
+static unsigned int nfnl_log_net_id __read_mostly;
 
 struct nfnl_log_net {
 	spinlock_t instances_lock;
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -77,7 +77,7 @@ struct nfqnl_instance {
 
 typedef int (*nfqnl_cmpfn)(struct nf_queue_entry *, unsigned long);
 
-static int nfnl_queue_net_id __read_mostly;
+static unsigned int nfnl_queue_net_id __read_mostly;
 
 #define INSTANCE_BUCKETS	16
 struct nfnl_queue_net {
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -49,7 +49,7 @@ struct hashlimit_net {
 	struct proc_dir_entry	*ip6t_hashlimit;
 };
 
-static int hashlimit_net_id;
+static unsigned int hashlimit_net_id;
 static inline struct hashlimit_net *hashlimit_pernet(struct net *net)
 {
 	return net_generic(net, hashlimit_net_id);
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -95,7 +95,7 @@ struct recent_net {
 #endif
 };
 
-static int recent_net_id __read_mostly;
+static unsigned int recent_net_id __read_mostly;
 
 static inline struct recent_net *recent_pernet(struct net *net)
 {
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -58,7 +58,7 @@
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
-int ovs_net_id __read_mostly;
+unsigned int ovs_net_id __read_mostly;
 
 static struct genl_family dp_packet_genl_family;
 static struct genl_family dp_flow_genl_family;
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -144,7 +144,7 @@ struct ovs_net {
 	bool xt_label;
 };
 
-extern int ovs_net_id;
+extern unsigned int ovs_net_id;
 void ovs_lock(void);
 void ovs_unlock(void);
 
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -44,7 +44,7 @@ struct phonet_net {
 	struct phonet_routes routes;
 };
 
-static int phonet_net_id __read_mostly;
+static unsigned int phonet_net_id __read_mostly;
 
 static struct phonet_net *phonet_pernet(struct net *net)
 {
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -366,7 +366,7 @@ struct rds_transport rds_tcp_transport = {
 	.t_mp_capable		= 1,
 };
 
-static int rds_tcp_netid;
+static unsigned int rds_tcp_netid;
 
 /* per-network namespace private data for this module */
 struct rds_tcp_net {
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -33,7 +33,7 @@ struct tcf_bpf_cfg {
 	bool is_ebpf;
 };
 
-static int bpf_net_id;
+static unsigned int bpf_net_id;
 static struct tc_action_ops act_bpf_ops;
 
 static int tcf_bpf(struct sk_buff *skb, const struct tc_action *act,
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -30,7 +30,7 @@
 
 #define CONNMARK_TAB_MASK     3
 
-static int connmark_net_id;
+static unsigned int connmark_net_id;
 static struct tc_action_ops act_connmark_ops;
 
 static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -42,7 +42,7 @@ static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
 	[TCA_CSUM_PARMS] = { .len = sizeof(struct tc_csum), },
 };
 
-static int csum_net_id;
+static unsigned int csum_net_id;
 static struct tc_action_ops act_csum_ops;
 
 static int tcf_csum_init(struct net *net, struct nlattr *nla,
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -25,7 +25,7 @@
 
 #define GACT_TAB_MASK	15
 
-static int gact_net_id;
+static unsigned int gact_net_id;
 static struct tc_action_ops act_gact_ops;
 
 #ifdef CONFIG_GACT_PROB
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -35,7 +35,7 @@
 
 #define IFE_TAB_MASK 15
 
-static int ife_net_id;
+static unsigned int ife_net_id;
 static int max_metacnt = IFE_META_MAX + 1;
 static struct tc_action_ops act_ife_ops;
 
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -30,10 +30,10 @@
 
 #define IPT_TAB_MASK     15
 
-static int ipt_net_id;
+static unsigned int ipt_net_id;
 static struct tc_action_ops act_ipt_ops;
 
-static int xt_net_id;
+static unsigned int xt_net_id;
 static struct tc_action_ops act_xt_ops;
 
 static int ipt_init_target(struct xt_entry_target *t, char *table,
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -70,7 +70,7 @@ static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 	[TCA_MIRRED_PARMS]	= { .len = sizeof(struct tc_mirred) },
 };
 
-static int mirred_net_id;
+static unsigned int mirred_net_id;
 static struct tc_action_ops act_mirred_ops;
 
 static bool dev_is_mac_header_xmit(const struct net_device *dev)
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -31,7 +31,7 @@
 
 #define NAT_TAB_MASK	15
 
-static int nat_net_id;
+static unsigned int nat_net_id;
 static struct tc_action_ops act_nat_ops;
 
 static const struct nla_policy nat_policy[TCA_NAT_MAX + 1] = {
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -25,7 +25,7 @@
 
 #define PEDIT_TAB_MASK	15
 
-static int pedit_net_id;
+static unsigned int pedit_net_id;
 static struct tc_action_ops act_pedit_ops;
 
 static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -55,7 +55,7 @@ struct tc_police_compat {
 
 /* Each policer is serialized by its individual spinlock */
 
-static int police_net_id;
+static unsigned int police_net_id;
 static struct tc_action_ops act_police_ops;
 
 static int tcf_act_police_walker(struct net *net, struct sk_buff *skb,
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -26,7 +26,7 @@
 
 #define SIMP_TAB_MASK     7
 
-static int simp_net_id;
+static unsigned int simp_net_id;
 static struct tc_action_ops act_simp_ops;
 
 #define SIMP_MAX_DATA	32
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -29,7 +29,7 @@
 
 #define SKBEDIT_TAB_MASK     15
 
-static int skbedit_net_id;
+static unsigned int skbedit_net_id;
 static struct tc_action_ops act_skbedit_ops;
 
 static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
--- a/net/sched/act_skbmod.c
+++ b/net/sched/act_skbmod.c
@@ -22,7 +22,7 @@
 
 #define SKBMOD_TAB_MASK     15
 
-static int skbmod_net_id;
+static unsigned int skbmod_net_id;
 static struct tc_action_ops act_skbmod_ops;
 
 #define MAX_EDIT_LEN ETH_HLEN
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -22,7 +22,7 @@
 
 #define TUNNEL_KEY_TAB_MASK     15
 
-static int tunnel_key_net_id;
+static unsigned int tunnel_key_net_id;
 static struct tc_action_ops act_tunnel_key_ops;
 
 static int tunnel_key_act(struct sk_buff *skb, const struct tc_action *a,
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -21,7 +21,7 @@
 
 #define VLAN_TAB_MASK     15
 
-static int vlan_net_id;
+static unsigned int vlan_net_id;
 static struct tc_action_ops act_vlan_ops;
 
 static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -34,7 +34,7 @@ struct sunrpc_net {
 	struct proc_dir_entry *use_gssp_proc;
 };
 
-extern int sunrpc_net_id;
+extern unsigned int sunrpc_net_id;
 
 int ip_map_cache_create(struct net *);
 void ip_map_cache_destroy(struct net *);
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -24,7 +24,7 @@
 
 #include "netns.h"
 
-int sunrpc_net_id;
+unsigned int sunrpc_net_id;
 EXPORT_SYMBOL_GPL(sunrpc_net_id);
 
 static __net_init int sunrpc_init_net(struct net *net)
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -47,7 +47,7 @@
 #include <linux/module.h>
 
 /* configurable TIPC parameters */
-int tipc_net_id __read_mostly;
+unsigned int tipc_net_id __read_mostly;
 int sysctl_tipc_rmem[3] __read_mostly;	/* min/default/max */
 
 static int __net_init tipc_init_net(struct net *net)
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -74,7 +74,7 @@ struct tipc_monitor;
 #define MAX_BEARERS	         3
 #define TIPC_DEF_MON_THRESHOLD  32
 
-extern int tipc_net_id __read_mostly;
+extern unsigned int tipc_net_id __read_mostly;
 extern int sysctl_tipc_rmem[3] __read_mostly;
 extern int sysctl_tipc_named_timeout __read_mostly;
 
