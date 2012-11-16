From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 04/17] net: Don't export sysctls to unprivileged users
Date: Fri, 16 Nov 2012 05:02:59 -0800
Message-ID: <1353070992-5552-4-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

In preparation for supporting the creation of network namespaces
by unprivileged users, modify all of the per net sysctl exports
and refuse to allow them to unprivileged users.

This makes it safe for unprivileged users in general to access
per net sysctls, and allows sysctls to be exported to unprivileged
users on an individual basis as they are deemed safe.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/core/neighbour.c                    |    4 ++++
 net/core/sysctl_net_core.c              |    5 +++++
 net/ipv4/devinet.c                      |    8 ++++++++
 net/ipv4/ip_fragment.c                  |    4 ++++
 net/ipv4/route.c                        |    4 ++++
 net/ipv4/sysctl_net_ipv4.c              |    3 +++
 net/ipv6/addrconf.c                     |    4 ++++
 net/ipv6/icmp.c                         |    7 ++++++-
 net/ipv6/reassembly.c                   |    4 ++++
 net/ipv6/route.c                        |    4 ++++
 net/ipv6/sysctl_net_ipv6.c              |    4 ++++
 net/netfilter/ipvs/ip_vs_ctl.c          |    4 ++++
 net/netfilter/ipvs/ip_vs_lblc.c         |    7 ++++++-
 net/netfilter/ipvs/ip_vs_lblcr.c        |    4 ++++
 net/netfilter/nf_conntrack_acct.c       |    4 ++++
 net/netfilter/nf_conntrack_ecache.c     |    4 ++++
 net/netfilter/nf_conntrack_helper.c     |    4 ++++
 net/netfilter/nf_conntrack_proto_dccp.c |    8 ++++++--
 net/netfilter/nf_conntrack_standalone.c |    4 ++++
 net/netfilter/nf_conntrack_timestamp.c  |    4 ++++
 net/unix/sysctl_net_unix.c              |    4 ++++
 net/xfrm/xfrm_sysctl.c                  |    4 ++++
 22 files changed, 98 insertions(+), 4 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2257148..f1c0c2e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2987,6 +2987,10 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].extra1 = dev;
 	}
 
+	/* Don't export sysctls to unprivileged users */
+	if (neigh_parms_net(p)->user_ns != &init_user_ns)
+		t->neigh_vars[0].procname = NULL;
+
 	snprintf(neigh_path, sizeof(neigh_path), "net/%s/neigh/%s",
 		p_name, dev_name_source);
 	t->sysctl_header =
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index a7c3684..d1b0804 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -216,6 +216,11 @@ static __net_init int sysctl_core_net_init(struct net *net)
 			goto err_dup;
 
 		tbl[0].data = &net->core.sysctl_somaxconn;
+
+		/* Don't export any sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns) {
+			tbl[0].procname = NULL;
+		}
 	}
 
 	net->core.sysctl_hdr = register_net_sysctl(net, "net/core", tbl);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 2a6abc1..66df8d1 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1637,6 +1637,10 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 		t->devinet_vars[i].extra2 = net;
 	}
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		t->devinet_vars[0].procname = NULL;
+
 	snprintf(path, sizeof(path), "net/ipv4/conf/%s", dev_name);
 
 	t->sysctl_header = register_net_sysctl(net, path, t->devinet_vars);
@@ -1722,6 +1726,10 @@ static __net_init int devinet_init_net(struct net *net)
 		tbl[0].data = &all->data[IPV4_DEVCONF_FORWARDING - 1];
 		tbl[0].extra1 = all;
 		tbl[0].extra2 = net;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			tbl[0].procname = NULL;
 #endif
 	}
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 448e685..1cf6a76 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -802,6 +802,10 @@ static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 		table[0].data = &net->ipv4.frags.high_thresh;
 		table[1].data = &net->ipv4.frags.low_thresh;
 		table[2].data = &net->ipv4.frags.timeout;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			table[0].procname = NULL;
 	}
 
 	hdr = register_net_sysctl(net, "net/ipv4", table);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a8c6512..5b58788 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2493,6 +2493,10 @@ static __net_init int sysctl_route_net_init(struct net *net)
 		tbl = kmemdup(tbl, sizeof(ipv4_route_flush_table), GFP_KERNEL);
 		if (tbl == NULL)
 			goto err_dup;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			tbl[0].procname = NULL;
 	}
 	tbl[0].extra1 = net;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 63d4ecc..d84400b 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -883,6 +883,9 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 		table[6].data =
 			&net->ipv4.sysctl_ping_group_range;
 
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			table[0].procname = NULL;
 	}
 
 	/*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0424e4e..6378be4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4582,6 +4582,10 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		t->addrconf_vars[i].extra2 = net;
 	}
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		t->addrconf_vars[0].procname = NULL;
+
 	snprintf(path, sizeof(path), "net/ipv6/conf/%s", dev_name);
 
 	t->sysctl_header = register_net_sysctl(net, path, t->addrconf_vars);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 24d69db..db9df8a 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -967,9 +967,14 @@ struct ctl_table * __net_init ipv6_icmp_sysctl_init(struct net *net)
 			sizeof(ipv6_icmp_table_template),
 			GFP_KERNEL);
 
-	if (table)
+	if (table) {
 		table[0].data = &net->ipv6.sysctl.icmpv6_time;
 
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			table[0].procname = NULL;
+	}
+
 	return table;
 }
 #endif
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index da8a4e3..e5253ec 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -616,6 +616,10 @@ static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 		table[0].data = &net->ipv6.frags.high_thresh;
 		table[1].data = &net->ipv6.frags.low_thresh;
 		table[2].data = &net->ipv6.frags.timeout;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			table[0].procname = NULL;
 	}
 
 	hdr = register_net_sysctl(net, "net/ipv6", table);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b1e6cf0..551fb82 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2873,6 +2873,10 @@ struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
 		table[7].data = &net->ipv6.sysctl.ip6_rt_mtu_expires;
 		table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
 		table[9].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			table[0].procname = NULL;
 	}
 
 	return table;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index e85c48b..b06fd07 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -52,6 +52,10 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		ipv6_table[0].procname = NULL;
+
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
 		goto out_ipv6_table;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c4ee437..c6cebd5 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3699,6 +3699,10 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 		tbl = kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
 		if (tbl == NULL)
 			return -ENOMEM;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			tbl[0].procname = NULL;
 	} else
 		tbl = vs_vars;
 	/* Initialize sysctl defaults */
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index df646cc..42ec368 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -560,6 +560,11 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 						GFP_KERNEL);
 		if (ipvs->lblc_ctl_table == NULL)
 			return -ENOMEM;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			ipvs->lblc_ctl_table[0].procname = NULL;
+
 	} else
 		ipvs->lblc_ctl_table = vs_vars_table;
 	ipvs->sysctl_lblc_expiration = DEFAULT_EXPIRATION;
@@ -569,7 +574,7 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 		register_net_sysctl(net, "net/ipv4/vs", ipvs->lblc_ctl_table);
 	if (!ipvs->lblc_ctl_header) {
 		if (!net_eq(net, &init_net))
-			kfree(ipvs->lblc_ctl_table);
+			kfree(ipvs->lblc_ctl_table);\
 		return -ENOMEM;
 	}
 
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 570e31e..2c54a30 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -754,6 +754,10 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 						GFP_KERNEL);
 		if (ipvs->lblcr_ctl_table == NULL)
 			return -ENOMEM;
+
+		/* Don't export sysctls to unprivileged users */
+		if (net->user_ns != &init_user_ns)
+			ipvs->lblcr_ctl_table[0].procname = NULL;
 	} else
 		ipvs->lblcr_ctl_table = vs_vars_table;
 	ipvs->sysctl_lblcr_expiration = DEFAULT_EXPIRATION;
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index d61e078..7df424e 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -69,6 +69,10 @@ static int nf_conntrack_acct_init_sysctl(struct net *net)
 
 	table[0].data = &net->ct.sysctl_acct;
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		table[0].procname = NULL;
+
 	net->ct.acct_sysctl_header = register_net_sysctl(net, "net/netfilter",
 							 table);
 	if (!net->ct.acct_sysctl_header) {
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index de9781b..faa978f 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -196,6 +196,10 @@ static int nf_conntrack_event_init_sysctl(struct net *net)
 	table[0].data = &net->ct.sysctl_events;
 	table[1].data = &net->ct.sysctl_events_retry_timeout;
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		table[0].procname = NULL;
+
 	net->ct.event_sysctl_header =
 		register_net_sysctl(net, "net/netfilter", table);
 	if (!net->ct.event_sysctl_header) {
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index c4bc637..884f2b3 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -64,6 +64,10 @@ static int nf_conntrack_helper_init_sysctl(struct net *net)
 
 	table[0].data = &net->ct.sysctl_auto_assign_helper;
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		table[0].procname = NULL;
+
 	net->ct.helper_sysctl_header =
 		register_net_sysctl(net, "net/netfilter", table);
 
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 6535326..a8ae287 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -815,7 +815,7 @@ static struct ctl_table dccp_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-static int dccp_kmemdup_sysctl_table(struct nf_proto_net *pn,
+static int dccp_kmemdup_sysctl_table(struct net *net, struct nf_proto_net *pn,
 				     struct dccp_net *dn)
 {
 #ifdef CONFIG_SYSCTL
@@ -836,6 +836,10 @@ static int dccp_kmemdup_sysctl_table(struct nf_proto_net *pn,
 	pn->ctl_table[5].data = &dn->dccp_timeout[CT_DCCP_CLOSING];
 	pn->ctl_table[6].data = &dn->dccp_timeout[CT_DCCP_TIMEWAIT];
 	pn->ctl_table[7].data = &dn->dccp_loose;
+
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		pn->ctl_table[0].procname = NULL;
 #endif
 	return 0;
 }
@@ -857,7 +861,7 @@ static int dccp_init_net(struct net *net, u_int16_t proto)
 		dn->dccp_timeout[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL;
 	}
 
-	return dccp_kmemdup_sysctl_table(pn, dn);
+	return dccp_kmemdup_sysctl_table(net, pn, dn);
 }
 
 static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 9b39432..363285d 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -489,6 +489,10 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 	table[3].data = &net->ct.sysctl_checksum;
 	table[4].data = &net->ct.sysctl_log_invalid;
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		table[0].procname = NULL;
+
 	net->ct.sysctl_header = register_net_sysctl(net, "net/netfilter", table);
 	if (!net->ct.sysctl_header)
 		goto out_unregister_netfilter;
diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
index dbb364f..7ea8026 100644
--- a/net/netfilter/nf_conntrack_timestamp.c
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -51,6 +51,10 @@ static int nf_conntrack_tstamp_init_sysctl(struct net *net)
 
 	table[0].data = &net->ct.sysctl_tstamp;
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		table[0].procname = NULL;
+
 	net->ct.tstamp_sysctl_header = register_net_sysctl(net,	"net/netfilter",
 							   table);
 	if (!net->ct.tstamp_sysctl_header) {
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index b34b5b9..8800604 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -34,6 +34,10 @@ int __net_init unix_sysctl_register(struct net *net)
 	if (table == NULL)
 		goto err_alloc;
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		table[0].procname = NULL;
+
 	table[0].data = &net->unx.sysctl_max_dgram_qlen;
 	net->unx.ctl = register_net_sysctl(net, "net/unix", table);
 	if (net->unx.ctl == NULL)
diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 380976f..05a6e3d 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -54,6 +54,10 @@ int __net_init xfrm_sysctl_init(struct net *net)
 	table[2].data = &net->xfrm.sysctl_larval_drop;
 	table[3].data = &net->xfrm.sysctl_acq_expires;
 
+	/* Don't export sysctls to unprivileged users */
+	if (net->user_ns != &init_user_ns)
+		table[0].procname = NULL;
+
 	net->xfrm.sysctl_hdr = register_net_sysctl(net, "net/core", table);
 	if (!net->xfrm.sysctl_hdr)
 		goto out_register;
-- 
1.7.5.4
