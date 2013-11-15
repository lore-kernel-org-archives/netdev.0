From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH net-next] net: reorder struct netns_ct for better
	cache-line usage
Date: Fri, 15 Nov 2013 15:57:53 +0100
Message-ID: <20131115145459.17641.35021.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reorder struct netns_ct so that atomic_t "count" changes don't
slowdown users of read mostly fields.

This is based on Eric Dumazet's proposed patch:
 "netfilter: conntrack: remove the central spinlock"
 http://thread.gmane.org/gmane.linux.network/268758/focus=47306

The tricky part of cache-aligning this structure, that it is getting
inlined in struct net (include/net/net_namespace.h), thus changes to
other netns_xxx structures affects our alignment.

Eric's original patch contained an ambiguity on 32-bit regarding
alignment in struct net.  This patch also takes 32-bit into account,
and in case of changed (struct net) alignment sysctl_xxx entries have
been ordered according to how often they are accessed.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Reviewed-by: Jiri Benc <jbenc@redhat.com>
---
Yes, I know it's not the time to submit this patch, but
I just want to let Eric know that I'm planning on extracting
part of his proposed patch, which have been stalled for months.
I'll resubmit once net-next/nf-next opens for changes again.


 include/net/netns/conntrack.h |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index c9c0c53..fbcc7fa 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -65,6 +65,23 @@ struct nf_ip_net {
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header	*sysctl_header;
+	struct ctl_table_header	*acct_sysctl_header;
+	struct ctl_table_header	*tstamp_sysctl_header;
+	struct ctl_table_header	*event_sysctl_header;
+	struct ctl_table_header	*helper_sysctl_header;
+#endif
+	char			*slabname;
+	unsigned int		sysctl_log_invalid; /* Log invalid packets */
+	unsigned int		sysctl_events_retry_timeout;
+	int			sysctl_events;
+	int			sysctl_acct;
+	int			sysctl_auto_assign_helper;
+	bool			auto_assign_helper_warned;
+	int			sysctl_tstamp;
+	int			sysctl_checksum;
+
 	unsigned int		htable_size;
 	struct kmem_cache	*nf_conntrack_cachep;
 	struct hlist_nulls_head	*hash;
@@ -75,14 +92,6 @@ struct netns_ct {
 	struct ip_conntrack_stat __percpu *stat;
 	struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
 	struct nf_exp_event_notifier __rcu *nf_expect_event_cb;
-	int			sysctl_events;
-	unsigned int		sysctl_events_retry_timeout;
-	int			sysctl_acct;
-	int			sysctl_tstamp;
-	int			sysctl_checksum;
-	unsigned int		sysctl_log_invalid; /* Log invalid packets */
-	int			sysctl_auto_assign_helper;
-	bool			auto_assign_helper_warned;
 	struct nf_ip_net	nf_ct_proto;
 #if defined(CONFIG_NF_CONNTRACK_LABELS)
 	unsigned int		labels_used;
@@ -92,13 +101,5 @@ struct netns_ct {
 	struct hlist_head	*nat_bysource;
 	unsigned int		nat_htable_size;
 #endif
-#ifdef CONFIG_SYSCTL
-	struct ctl_table_header	*sysctl_header;
-	struct ctl_table_header	*acct_sysctl_header;
-	struct ctl_table_header	*tstamp_sysctl_header;
-	struct ctl_table_header	*event_sysctl_header;
-	struct ctl_table_header	*helper_sysctl_header;
-#endif
-	char			*slabname;
 };
 #endif

