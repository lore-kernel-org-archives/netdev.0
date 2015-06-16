From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH iproute2] Add displaying VF traffic statistics
Date: Tue, 16 Jun 2015 12:13:16 +0300
Message-ID: <1434445996-2493-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36800 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933443AbbFPJNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 05:13:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Enable reading and displaying SRIOV VFs traffic statistics through 
the host PF netdevice using the nested IFLA_VF_STATS attribute.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

---
 include/linux/if_link.h |   13 +++++++++++++
 ip/ipaddress.c          |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 3d0d613..772debf 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -466,6 +466,7 @@ enum {
 	IFLA_VF_RSS_QUERY_EN,	/* RSS Redirection Table and Hash Key query
 				 * on/off switch
 				 */
+	IFLA_VF_STATS,		/* network device statistics */
 	__IFLA_VF_MAX,
 };
 
@@ -515,6 +516,18 @@ struct ifla_vf_rss_query_en {
 	__u32 setting;
 };
 
+enum {
+	IFLA_VF_STATS_RX_PACKETS,
+	IFLA_VF_STATS_TX_PACKETS,
+	IFLA_VF_STATS_RX_BYTES,
+	IFLA_VF_STATS_TX_BYTES,
+	IFLA_VF_STATS_BROADCAST,
+	IFLA_VF_STATS_MULTICAST,
+	__IFLA_VF_STATS_MAX,
+};
+
+#define IFLA_VF_STATS_MAX (__IFLA_VF_STATS_MAX - 1)
+
 /* VF ports management section
  *
  *	Nested layout of set/get msg is:
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 340e1c9..5bbb59e 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -287,6 +287,8 @@ static void print_af_spec(FILE *fp, struct rtattr *af_spec_attr)
 	}
 }
 
+static void print_vf_stats64(FILE *fp, struct rtattr *vfstats);
+
 static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 {
 	struct ifla_vf_mac *vf_mac;
@@ -367,6 +369,8 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 		else
 			fprintf(fp, ", link-state disable");
 	}
+	if (vf[IFLA_VF_STATS] && show_stats)
+		print_vf_stats64(fp, vf[IFLA_VF_STATS]);
 }
 
 static void print_num(FILE *fp, unsigned width, uint64_t count)
@@ -408,6 +412,36 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
 	fprintf(fp, "%-*s ", width, buf);
 }
 
+static void print_vf_stats64(FILE *fp, struct rtattr *vfstats)
+{
+	struct rtattr *vf[IFLA_VF_STATS_MAX + 1] = {};
+
+	if (vfstats->rta_type != IFLA_VF_STATS) {
+		fprintf(stderr, "BUG: rta type is %d\n", vfstats->rta_type);
+		return;
+	}
+
+	parse_rtattr_nested(vf, IFLA_VF_MAX, vfstats);
+
+	/* RX stats */
+	fprintf(fp, "%s", _SL_);
+	fprintf(fp, "    RX: bytes  packets  mcast   bcast %s", _SL_);
+	fprintf(fp, "    ");
+
+	print_num(fp, 10, *(__u64 *)RTA_DATA(vf[IFLA_VF_STATS_RX_BYTES]));
+	print_num(fp, 8, *(__u64 *)RTA_DATA(vf[IFLA_VF_STATS_RX_PACKETS]));
+	print_num(fp, 7, *(__u64 *)RTA_DATA(vf[IFLA_VF_STATS_MULTICAST]));
+	print_num(fp, 7, *(__u64 *)RTA_DATA(vf[IFLA_VF_STATS_BROADCAST]));
+
+	/* TX stats */
+	fprintf(fp, "%s", _SL_);
+	fprintf(fp, "    TX: bytes  packets %s", _SL_);
+	fprintf(fp, "    ");
+
+	print_num(fp, 10, *(__u64 *)RTA_DATA(vf[IFLA_VF_STATS_TX_BYTES]));
+	print_num(fp, 8, *(__u64 *)RTA_DATA(vf[IFLA_VF_STATS_TX_PACKETS]));
+}
+
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
                                const struct rtattr *carrier_changes)
 {
-- 
1.7.1
