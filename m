From: kaber@trash.net
Subject: [PATCH 44/84] netfilter: xtables: change matches to return error code
Date: Mon, 10 May 2010 22:18:15 +0200
Message-ID: <1273522735-24672-45-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

The following semantic patch does part of the transformation:
// <smpl>
@ rule1 @
struct xt_match ops;
identifier check;
@@
 ops.checkentry = check;

@@
identifier rule1.check;
@@
 check(...) { <...
-return true;
+return 0;
 ...> }

@@
identifier rule1.check;
@@
 check(...) { <...
-return false;
+return -EINVAL;
 ...> }
// </smpl>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/bridge/netfilter/ebt_802_3.c     |    4 ++--
 net/bridge/netfilter/ebt_among.c     |    8 ++++----
 net/bridge/netfilter/ebt_arp.c       |    6 +++---
 net/bridge/netfilter/ebt_ip.c        |   14 +++++++-------
 net/bridge/netfilter/ebt_ip6.c       |   14 +++++++-------
 net/bridge/netfilter/ebt_limit.c     |    4 ++--
 net/bridge/netfilter/ebt_mark_m.c    |    8 ++++----
 net/bridge/netfilter/ebt_pkttype.c   |    4 ++--
 net/bridge/netfilter/ebt_stp.c       |    6 +++---
 net/bridge/netfilter/ebt_vlan.c      |   14 +++++++-------
 net/ipv4/netfilter/ip_tables.c       |    2 +-
 net/ipv4/netfilter/ipt_addrtype.c    |    8 ++++----
 net/ipv4/netfilter/ipt_ah.c          |    4 ++--
 net/ipv4/netfilter/ipt_ecn.c         |    8 ++++----
 net/ipv6/netfilter/ip6_tables.c      |    2 +-
 net/ipv6/netfilter/ip6t_ah.c         |    4 ++--
 net/ipv6/netfilter/ip6t_frag.c       |    4 ++--
 net/ipv6/netfilter/ip6t_hbh.c        |    6 +++---
 net/ipv6/netfilter/ip6t_ipv6header.c |    4 ++--
 net/ipv6/netfilter/ip6t_mh.c         |    2 +-
 net/ipv6/netfilter/ip6t_rt.c         |    6 +++---
 net/netfilter/x_tables.c             |   12 ++++++++++--
 net/netfilter/xt_cluster.c           |    6 +++---
 net/netfilter/xt_connbytes.c         |    8 ++++----
 net/netfilter/xt_connlimit.c         |    6 +++---
 net/netfilter/xt_connmark.c          |    8 ++++----
 net/netfilter/xt_conntrack.c         |    4 ++--
 net/netfilter/xt_dccp.c              |    8 ++++----
 net/netfilter/xt_dscp.c              |    4 ++--
 net/netfilter/xt_esp.c               |    4 ++--
 net/netfilter/xt_hashlimit.c         |   29 ++++++++++++++---------------
 net/netfilter/xt_helper.c            |    4 ++--
 net/netfilter/xt_limit.c             |    6 +++---
 net/netfilter/xt_physdev.c           |    6 +++---
 net/netfilter/xt_policy.c            |   10 +++++-----
 net/netfilter/xt_quota.c             |    6 +++---
 net/netfilter/xt_rateest.c           |    4 ++--
 net/netfilter/xt_recent.c            |   18 +++++++++---------
 net/netfilter/xt_sctp.c              |   12 ++++++------
 net/netfilter/xt_state.c             |    4 ++--
 net/netfilter/xt_statistic.c         |    6 +++---
 net/netfilter/xt_string.c            |   13 ++++++-------
 net/netfilter/xt_tcpudp.c            |    4 ++--
 net/netfilter/xt_time.c              |    4 ++--
 44 files changed, 162 insertions(+), 156 deletions(-)

diff --git a/net/bridge/netfilter/ebt_802_3.c b/net/bridge/netfilter/ebt_802_3.c
index 7b6f4c4..f7de8db 100644
--- a/net/bridge/netfilter/ebt_802_3.c
+++ b/net/bridge/netfilter/ebt_802_3.c
@@ -41,9 +41,9 @@ static int ebt_802_3_mt_check(const struct xt_mtchk_param *par)
 	const struct ebt_802_3_info *info = par->matchinfo;
 
 	if (info->bitmask & ~EBT_802_3_MASK || info->invflags & ~EBT_802_3_MASK)
-		return false;
+		return -EINVAL;
 
-	return true;
+	return 0;
 }
 
 static struct xt_match ebt_802_3_mt_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 8a75d39..20068e0 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -190,17 +190,17 @@ static int ebt_among_mt_check(const struct xt_mtchk_param *par)
 		pr_info("wrong size: %d against expected %d, rounded to %Zd\n",
 			em->match_size, expected_length,
 			EBT_ALIGN(expected_length));
-		return false;
+		return -EINVAL;
 	}
 	if (wh_dst && (err = ebt_mac_wormhash_check_integrity(wh_dst))) {
 		pr_info("dst integrity fail: %x\n", -err);
-		return false;
+		return -EINVAL;
 	}
 	if (wh_src && (err = ebt_mac_wormhash_check_integrity(wh_src))) {
 		pr_info("src integrity fail: %x\n", -err);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_match ebt_among_mt_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
index fc62055..952150c 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -108,10 +108,10 @@ static int ebt_arp_mt_check(const struct xt_mtchk_param *par)
 	if ((e->ethproto != htons(ETH_P_ARP) &&
 	   e->ethproto != htons(ETH_P_RARP)) ||
 	   e->invflags & EBT_IPROTO)
-		return false;
+		return -EINVAL;
 	if (info->bitmask & ~EBT_ARP_MASK || info->invflags & ~EBT_ARP_MASK)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_match ebt_arp_mt_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
index d1a555d..a1c76c7 100644
--- a/net/bridge/netfilter/ebt_ip.c
+++ b/net/bridge/netfilter/ebt_ip.c
@@ -84,24 +84,24 @@ static int ebt_ip_mt_check(const struct xt_mtchk_param *par)
 
 	if (e->ethproto != htons(ETH_P_IP) ||
 	   e->invflags & EBT_IPROTO)
-		return false;
+		return -EINVAL;
 	if (info->bitmask & ~EBT_IP_MASK || info->invflags & ~EBT_IP_MASK)
-		return false;
+		return -EINVAL;
 	if (info->bitmask & (EBT_IP_DPORT | EBT_IP_SPORT)) {
 		if (info->invflags & EBT_IP_PROTO)
-			return false;
+			return -EINVAL;
 		if (info->protocol != IPPROTO_TCP &&
 		    info->protocol != IPPROTO_UDP &&
 		    info->protocol != IPPROTO_UDPLITE &&
 		    info->protocol != IPPROTO_SCTP &&
 		    info->protocol != IPPROTO_DCCP)
-			 return false;
+			 return -EINVAL;
 	}
 	if (info->bitmask & EBT_IP_DPORT && info->dport[0] > info->dport[1])
-		return false;
+		return -EINVAL;
 	if (info->bitmask & EBT_IP_SPORT && info->sport[0] > info->sport[1])
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_match ebt_ip_mt_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index fa4ecf5..33f8413 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -86,24 +86,24 @@ static int ebt_ip6_mt_check(const struct xt_mtchk_param *par)
 	struct ebt_ip6_info *info = par->matchinfo;
 
 	if (e->ethproto != htons(ETH_P_IPV6) || e->invflags & EBT_IPROTO)
-		return false;
+		return -EINVAL;
 	if (info->bitmask & ~EBT_IP6_MASK || info->invflags & ~EBT_IP6_MASK)
-		return false;
+		return -EINVAL;
 	if (info->bitmask & (EBT_IP6_DPORT | EBT_IP6_SPORT)) {
 		if (info->invflags & EBT_IP6_PROTO)
-			return false;
+			return -EINVAL;
 		if (info->protocol != IPPROTO_TCP &&
 		    info->protocol != IPPROTO_UDP &&
 		    info->protocol != IPPROTO_UDPLITE &&
 		    info->protocol != IPPROTO_SCTP &&
 		    info->protocol != IPPROTO_DCCP)
-			return false;
+			return -EINVAL;
 	}
 	if (info->bitmask & EBT_IP6_DPORT && info->dport[0] > info->dport[1])
-		return false;
+		return -EINVAL;
 	if (info->bitmask & EBT_IP6_SPORT && info->sport[0] > info->sport[1])
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_match ebt_ip6_mt_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_limit.c b/net/bridge/netfilter/ebt_limit.c
index abfb0ec..4b0e2e5 100644
--- a/net/bridge/netfilter/ebt_limit.c
+++ b/net/bridge/netfilter/ebt_limit.c
@@ -74,7 +74,7 @@ static int ebt_limit_mt_check(const struct xt_mtchk_param *par)
 	    user2credits(info->avg * info->burst) < user2credits(info->avg)) {
 		pr_info("overflow, try lower: %u/%u\n",
 			info->avg, info->burst);
-		return false;
+		return -EINVAL;
 	}
 
 	/* User avg in seconds * EBT_LIMIT_SCALE: convert to jiffies * 128. */
@@ -82,7 +82,7 @@ static int ebt_limit_mt_check(const struct xt_mtchk_param *par)
 	info->credit = user2credits(info->avg * info->burst);
 	info->credit_cap = user2credits(info->avg * info->burst);
 	info->cost = user2credits(info->avg);
-	return true;
+	return 0;
 }
 
 
diff --git a/net/bridge/netfilter/ebt_mark_m.c b/net/bridge/netfilter/ebt_mark_m.c
index 1e5b0b3..e4366c0 100644
--- a/net/bridge/netfilter/ebt_mark_m.c
+++ b/net/bridge/netfilter/ebt_mark_m.c
@@ -27,12 +27,12 @@ static int ebt_mark_mt_check(const struct xt_mtchk_param *par)
 	const struct ebt_mark_m_info *info = par->matchinfo;
 
 	if (info->bitmask & ~EBT_MARK_MASK)
-		return false;
+		return -EINVAL;
 	if ((info->bitmask & EBT_MARK_OR) && (info->bitmask & EBT_MARK_AND))
-		return false;
+		return -EINVAL;
 	if (!info->bitmask)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 
diff --git a/net/bridge/netfilter/ebt_pkttype.c b/net/bridge/netfilter/ebt_pkttype.c
index 9b3c645..f34bcc3 100644
--- a/net/bridge/netfilter/ebt_pkttype.c
+++ b/net/bridge/netfilter/ebt_pkttype.c
@@ -25,9 +25,9 @@ static int ebt_pkttype_mt_check(const struct xt_mtchk_param *par)
 	const struct ebt_pkttype_info *info = par->matchinfo;
 
 	if (info->invert != 0 && info->invert != 1)
-		return false;
+		return -EINVAL;
 	/* Allow any pkt_type value */
-	return true;
+	return 0;
 }
 
 static struct xt_match ebt_pkttype_mt_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 521186f..02f28fd 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -162,13 +162,13 @@ static int ebt_stp_mt_check(const struct xt_mtchk_param *par)
 
 	if (info->bitmask & ~EBT_STP_MASK || info->invflags & ~EBT_STP_MASK ||
 	    !(info->bitmask & EBT_STP_MASK))
-		return false;
+		return -EINVAL;
 	/* Make sure the match only receives stp frames */
 	if (compare_ether_addr(e->destmac, bridge_ula) ||
 	    compare_ether_addr(e->destmsk, msk) || !(e->bitmask & EBT_DESTMAC))
-		return false;
+		return -EINVAL;
 
-	return true;
+	return 0;
 }
 
 static struct xt_match ebt_stp_mt_reg __read_mostly = {
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index 04a9575..bf8ae5c 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -88,7 +88,7 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 	if (e->ethproto != htons(ETH_P_8021Q)) {
 		pr_debug("passed entry proto %2.4X is not 802.1Q (8100)\n",
 			 ntohs(e->ethproto));
-		return false;
+		return -EINVAL;
 	}
 
 	/* Check for bitmask range
@@ -96,14 +96,14 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 	if (info->bitmask & ~EBT_VLAN_MASK) {
 		pr_debug("bitmask %2X is out of mask (%2X)\n",
 			 info->bitmask, EBT_VLAN_MASK);
-		return false;
+		return -EINVAL;
 	}
 
 	/* Check for inversion flags range */
 	if (info->invflags & ~EBT_VLAN_MASK) {
 		pr_debug("inversion flags %2X is out of mask (%2X)\n",
 			 info->invflags, EBT_VLAN_MASK);
-		return false;
+		return -EINVAL;
 	}
 
 	/* Reserved VLAN ID (VID) values
@@ -117,7 +117,7 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 			if (info->id > VLAN_GROUP_ARRAY_LEN) {
 				pr_debug("id %d is out of range (1-4096)\n",
 					 info->id);
-				return false;
+				return -EINVAL;
 			}
 			/* Note: This is valid VLAN-tagged frame point.
 			 * Any value of user_priority are acceptable,
@@ -132,7 +132,7 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 		if ((unsigned char) info->prio > 7) {
 			pr_debug("prio %d is out of range (0-7)\n",
 				 info->prio);
-			return false;
+			return -EINVAL;
 		}
 	}
 	/* Check for encapsulated proto range - it is possible to be
@@ -142,11 +142,11 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 		if ((unsigned short) ntohs(info->encap) < ETH_ZLEN) {
 			pr_debug("encap frame length %d is less than "
 				 "minimal\n", ntohs(info->encap));
-			return false;
+			return -EINVAL;
 		}
 	}
 
-	return true;
+	return 0;
 }
 
 static struct xt_match ebt_vlan_mt_reg __read_mostly = {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 771ffa7..18c5b15 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -2181,7 +2181,7 @@ static int icmp_checkentry(const struct xt_mtchk_param *par)
 	const struct ipt_icmp *icmpinfo = par->matchinfo;
 
 	/* Must specify no unknown invflags */
-	return !(icmpinfo->invflags & ~IPT_ICMP_INV);
+	return (icmpinfo->invflags & ~IPT_ICMP_INV) ? -EINVAL : 0;
 }
 
 /* The built-in targets: standard (NULL) and error. */
diff --git a/net/ipv4/netfilter/ipt_addrtype.c b/net/ipv4/netfilter/ipt_addrtype.c
index 81197f4..e4b8f2b 100644
--- a/net/ipv4/netfilter/ipt_addrtype.c
+++ b/net/ipv4/netfilter/ipt_addrtype.c
@@ -78,7 +78,7 @@ static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
 	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_OUT) {
 		pr_info("both incoming and outgoing "
 			"interface limitation cannot be selected\n");
-		return false;
+		return -EINVAL;
 	}
 
 	if (par->hook_mask & ((1 << NF_INET_PRE_ROUTING) |
@@ -86,7 +86,7 @@ static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
 	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_OUT) {
 		pr_info("output interface limitation "
 			"not valid in PREROUTING and INPUT\n");
-		return false;
+		return -EINVAL;
 	}
 
 	if (par->hook_mask & ((1 << NF_INET_POST_ROUTING) |
@@ -94,10 +94,10 @@ static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
 	    info->flags & IPT_ADDRTYPE_LIMIT_IFACE_IN) {
 		pr_info("input interface limitation "
 			"not valid in POSTROUTING and OUTPUT\n");
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 static struct xt_match addrtype_mt_reg[] __read_mostly = {
diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index 667ded1..9f98102 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -62,9 +62,9 @@ static int ah_mt_check(const struct xt_mtchk_param *par)
 	/* Must specify no unknown invflags */
 	if (ahinfo->invflags & ~IPT_AH_INV_MASK) {
 		pr_debug("unknown flags %X\n", ahinfo->invflags);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_match ah_mt_reg __read_mostly = {
diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index d1e234f..32e2410 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -91,18 +91,18 @@ static int ecn_mt_check(const struct xt_mtchk_param *par)
 	const struct ipt_ip *ip = par->entryinfo;
 
 	if (info->operation & IPT_ECN_OP_MATCH_MASK)
-		return false;
+		return -EINVAL;
 
 	if (info->invert & IPT_ECN_OP_MATCH_MASK)
-		return false;
+		return -EINVAL;
 
 	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR) &&
 	    ip->proto != IPPROTO_TCP) {
 		pr_info("cannot match TCP bits in rule for non-tcp packets\n");
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 static struct xt_match ecn_mt_reg __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 595b45d..f2b815e 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2214,7 +2214,7 @@ static int icmp6_checkentry(const struct xt_mtchk_param *par)
 	const struct ip6t_icmp *icmpinfo = par->matchinfo;
 
 	/* Must specify no unknown invflags */
-	return !(icmpinfo->invflags & ~IP6T_ICMP_INV);
+	return (icmpinfo->invflags & ~IP6T_ICMP_INV) ? -EINVAL : 0;
 }
 
 /* The built-in targets: standard (NULL) and error. */
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index 3d57044..1580693 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -93,9 +93,9 @@ static int ah_mt6_check(const struct xt_mtchk_param *par)
 
 	if (ahinfo->invflags & ~IP6T_AH_INV_MASK) {
 		pr_debug("unknown flags %X\n", ahinfo->invflags);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_match ah_mt6_reg __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index c2dba27..a5daf0f 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -108,9 +108,9 @@ static int frag_mt6_check(const struct xt_mtchk_param *par)
 
 	if (fraginfo->invflags & ~IP6T_FRAG_INV_MASK) {
 		pr_debug("unknown flags %X\n", fraginfo->invflags);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_match frag_mt6_reg __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index 1b29431..5e6acda 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -170,15 +170,15 @@ static int hbh_mt6_check(const struct xt_mtchk_param *par)
 
 	if (optsinfo->invflags & ~IP6T_OPTS_INV_MASK) {
 		pr_debug("unknown flags %X\n", optsinfo->invflags);
-		return false;
+		return -EINVAL;
 	}
 
 	if (optsinfo->flags & IP6T_OPTS_NSTRICT) {
 		pr_debug("Not strict - not implemented");
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 static struct xt_match hbh_mt6_reg[] __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t_ipv6header.c
index 90e1e04..46fbabb 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -125,9 +125,9 @@ static int ipv6header_mt6_check(const struct xt_mtchk_param *par)
 	/* invflags is 0 or 0xff in hard mode */
 	if ((!info->modeflag) && info->invflags != 0x00 &&
 	    info->invflags != 0xFF)
-		return false;
+		return -EINVAL;
 
-	return true;
+	return 0;
 }
 
 static struct xt_match ipv6header_mt6_reg __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6t_mh.c b/net/ipv6/netfilter/ip6t_mh.c
index d940804..c9f443e 100644
--- a/net/ipv6/netfilter/ip6t_mh.c
+++ b/net/ipv6/netfilter/ip6t_mh.c
@@ -67,7 +67,7 @@ static int mh_mt6_check(const struct xt_mtchk_param *par)
 	const struct ip6t_mh *mhinfo = par->matchinfo;
 
 	/* Must specify no unknown invflags */
-	return !(mhinfo->invflags & ~IP6T_MH_INV_MASK);
+	return (mhinfo->invflags & ~IP6T_MH_INV_MASK) ? -EINVAL : 0;
 }
 
 static struct xt_match mh_mt6_reg __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index 76397f3..0932272 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -189,17 +189,17 @@ static int rt_mt6_check(const struct xt_mtchk_param *par)
 
 	if (rtinfo->invflags & ~IP6T_RT_INV_MASK) {
 		pr_debug("unknown flags %X\n", rtinfo->invflags);
-		return false;
+		return -EINVAL;
 	}
 	if ((rtinfo->flags & (IP6T_RT_RES | IP6T_RT_FST_MASK)) &&
 	    (!(rtinfo->flags & IP6T_RT_TYP) ||
 	     (rtinfo->rt_type != 0) ||
 	     (rtinfo->invflags & IP6T_RT_INV_TYP))) {
 		pr_debug("`--rt-type 0' required before `--rt-0-*'");
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 static struct xt_match rt_mt6_reg __read_mostly = {
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index ee7fe21..7ee1777 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -363,6 +363,8 @@ static char *textify_hooks(char *buf, size_t size, unsigned int mask)
 int xt_check_match(struct xt_mtchk_param *par,
 		   unsigned int size, u_int8_t proto, bool inv_proto)
 {
+	int ret;
+
 	if (XT_ALIGN(par->match->matchsize) != size &&
 	    par->match->matchsize != -1) {
 		/*
@@ -399,8 +401,14 @@ int xt_check_match(struct xt_mtchk_param *par,
 		       par->match->proto);
 		return -EINVAL;
 	}
-	if (par->match->checkentry != NULL && !par->match->checkentry(par))
-		return -EINVAL;
+	if (par->match->checkentry != NULL) {
+		ret = par->match->checkentry(par);
+		if (ret < 0)
+			return ret;
+		else if (ret > 0)
+			/* Flag up potential errors. */
+			return -EIO;
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xt_check_match);
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 1f2c35e..30cb776 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -140,14 +140,14 @@ static int xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
 		pr_info("you have exceeded the maximum "
 			"number of cluster nodes (%u > %u)\n",
 			info->total_nodes, XT_CLUSTER_NODES_MAX);
-		return false;
+		return -EINVAL;
 	}
 	if (info->node_mask >= (1ULL << info->total_nodes)) {
 		pr_info("this node mask cannot be "
 			"higher than the total number of nodes\n");
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_match xt_cluster_match __read_mostly = {
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 136ef4c..bf8e286 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -100,20 +100,20 @@ static int connbytes_mt_check(const struct xt_mtchk_param *par)
 	if (sinfo->what != XT_CONNBYTES_PKTS &&
 	    sinfo->what != XT_CONNBYTES_BYTES &&
 	    sinfo->what != XT_CONNBYTES_AVGPKT)
-		return false;
+		return -EINVAL;
 
 	if (sinfo->direction != XT_CONNBYTES_DIR_ORIGINAL &&
 	    sinfo->direction != XT_CONNBYTES_DIR_REPLY &&
 	    sinfo->direction != XT_CONNBYTES_DIR_BOTH)
-		return false;
+		return -EINVAL;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 static void connbytes_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index a9fec38..68e89f0 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -228,21 +228,21 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for "
 			"address family %u\n", par->family);
-		return false;
+		return -EINVAL;
 	}
 
 	/* init private data */
 	info->data = kmalloc(sizeof(struct xt_connlimit_data), GFP_KERNEL);
 	if (info->data == NULL) {
 		nf_ct_l3proto_module_put(par->family);
-		return false;
+		return -EINVAL;
 	}
 
 	spin_lock_init(&info->data->lock);
 	for (i = 0; i < ARRAY_SIZE(info->data->iphash); ++i)
 		INIT_LIST_HEAD(&info->data->iphash[i]);
 
-	return true;
+	return 0;
 }
 
 static void connlimit_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 0e69427..e137af5 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -79,9 +79,9 @@ static int connmark_tg_check(const struct xt_tgchk_param *par)
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static void connmark_tg_destroy(const struct xt_tgdtor_param *par)
@@ -108,9 +108,9 @@ static int connmark_mt_check(const struct xt_mtchk_param *par)
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static void connmark_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 500e033..26e34aa 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -211,9 +211,9 @@ static int conntrack_mt_check(const struct xt_mtchk_param *par)
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static void conntrack_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index da8c301..f54699c 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -128,12 +128,12 @@ static int dccp_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_dccp_info *info = par->matchinfo;
 
 	if (info->flags & ~XT_DCCP_VALID_FLAGS)
-		return false;
+		return -EINVAL;
 	if (info->invflags & ~XT_DCCP_VALID_FLAGS)
-		return false;
+		return -EINVAL;
 	if (info->invflags & ~info->flags)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_match dccp_mt_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index 295da4c..f355fb9 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -48,10 +48,10 @@ static int dscp_mt_check(const struct xt_mtchk_param *par)
 
 	if (info->dscp > XT_DSCP_MAX) {
 		pr_info("dscp %x out of range\n", info->dscp);
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 static bool tos_mt(const struct sk_buff *skb, const struct xt_match_param *par)
diff --git a/net/netfilter/xt_esp.c b/net/netfilter/xt_esp.c
index 9f5da97..143bfdc 100644
--- a/net/netfilter/xt_esp.c
+++ b/net/netfilter/xt_esp.c
@@ -66,10 +66,10 @@ static int esp_mt_check(const struct xt_mtchk_param *par)
 
 	if (espinfo->invflags & ~XT_ESP_INV_MASK) {
 		pr_debug("unknown flags %X\n", espinfo->invflags);
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 static struct xt_match esp_mt_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index d13800c..0c01529 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -681,30 +681,29 @@ static int hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 	    user2credits(r->cfg.avg * r->cfg.burst) < user2credits(r->cfg.avg)) {
 		pr_info("overflow, try lower: %u/%u\n",
 			r->cfg.avg, r->cfg.burst);
-		return false;
+		return -EINVAL;
 	}
 	if (r->cfg.mode == 0 ||
 	    r->cfg.mode > (XT_HASHLIMIT_HASH_DPT |
 			   XT_HASHLIMIT_HASH_DIP |
 			   XT_HASHLIMIT_HASH_SIP |
 			   XT_HASHLIMIT_HASH_SPT))
-		return false;
+		return -EINVAL;
 	if (!r->cfg.gc_interval)
-		return false;
+		return -EINVAL;
 	if (!r->cfg.expire)
-		return false;
+		return -EINVAL;
 	if (r->name[sizeof(r->name) - 1] != '\0')
-		return false;
+		return -EINVAL;
 
 	mutex_lock(&hashlimit_mutex);
 	r->hinfo = htable_find_get(net, r->name, par->family);
 	if (!r->hinfo && htable_create_v0(net, r, par->family) != 0) {
 		mutex_unlock(&hashlimit_mutex);
-		return false;
+		return -EINVAL;
 	}
 	mutex_unlock(&hashlimit_mutex);
-
-	return true;
+	return 0;
 }
 
 static int hashlimit_mt_check(const struct xt_mtchk_param *par)
@@ -718,28 +717,28 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 	    user2credits(info->cfg.avg)) {
 		pr_info("overflow, try lower: %u/%u\n",
 			info->cfg.avg, info->cfg.burst);
-		return false;
+		return -EINVAL;
 	}
 	if (info->cfg.gc_interval == 0 || info->cfg.expire == 0)
-		return false;
+		return -EINVAL;
 	if (info->name[sizeof(info->name)-1] != '\0')
-		return false;
+		return -EINVAL;
 	if (par->family == NFPROTO_IPV4) {
 		if (info->cfg.srcmask > 32 || info->cfg.dstmask > 32)
-			return false;
+			return -EINVAL;
 	} else {
 		if (info->cfg.srcmask > 128 || info->cfg.dstmask > 128)
-			return false;
+			return -EINVAL;
 	}
 
 	mutex_lock(&hashlimit_mutex);
 	info->hinfo = htable_find_get(net, info->name, par->family);
 	if (!info->hinfo && htable_create(net, info, par->family) != 0) {
 		mutex_unlock(&hashlimit_mutex);
-		return false;
+		return -EINVAL;
 	}
 	mutex_unlock(&hashlimit_mutex);
-	return true;
+	return 0;
 }
 
 static void
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 6e177b2..eb308b3 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -61,10 +61,10 @@ static int helper_mt_check(const struct xt_mtchk_param *par)
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return false;
+		return -EINVAL;
 	}
 	info->name[29] = '\0';
-	return true;
+	return 0;
 }
 
 static void helper_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 138a324..5ff0580 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -107,12 +107,12 @@ static int limit_mt_check(const struct xt_mtchk_param *par)
 	    || user2credits(r->avg * r->burst) < user2credits(r->avg)) {
 		pr_info("Overflow, try lower: %u/%u\n",
 			r->avg, r->burst);
-		return false;
+		return -EINVAL;
 	}
 
 	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
 	if (priv == NULL)
-		return false;
+		return -EINVAL;
 
 	/* For SMP, we only want to use one set of state. */
 	r->master = priv;
@@ -124,7 +124,7 @@ static int limit_mt_check(const struct xt_mtchk_param *par)
 		r->credit_cap = user2credits(r->avg * r->burst); /* Credits full. */
 		r->cost = user2credits(r->avg);
 	}
-	return true;
+	return 0;
 }
 
 static void limit_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 850e412..d0bdf3d 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -89,7 +89,7 @@ static int physdev_mt_check(const struct xt_mtchk_param *par)
 
 	if (!(info->bitmask & XT_PHYSDEV_OP_MASK) ||
 	    info->bitmask & ~XT_PHYSDEV_OP_MASK)
-		return false;
+		return -EINVAL;
 	if (info->bitmask & XT_PHYSDEV_OP_OUT &&
 	    (!(info->bitmask & XT_PHYSDEV_OP_BRIDGED) ||
 	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&
@@ -99,9 +99,9 @@ static int physdev_mt_check(const struct xt_mtchk_param *par)
 			"POSTROUTING chains for non-bridged traffic is not "
 			"supported anymore.\n");
 		if (par->hook_mask & (1 << NF_INET_LOCAL_OUT))
-			return false;
+			return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_match physdev_mt_reg __read_mostly = {
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index c9965b6..1fa239c 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -134,23 +134,23 @@ static int policy_mt_check(const struct xt_mtchk_param *par)
 
 	if (!(info->flags & (XT_POLICY_MATCH_IN|XT_POLICY_MATCH_OUT))) {
 		pr_info("neither incoming nor outgoing policy selected\n");
-		return false;
+		return -EINVAL;
 	}
 	if (par->hook_mask & ((1 << NF_INET_PRE_ROUTING) |
 	    (1 << NF_INET_LOCAL_IN)) && info->flags & XT_POLICY_MATCH_OUT) {
 		pr_info("output policy not valid in PREROUTING and INPUT\n");
-		return false;
+		return -EINVAL;
 	}
 	if (par->hook_mask & ((1 << NF_INET_POST_ROUTING) |
 	    (1 << NF_INET_LOCAL_OUT)) && info->flags & XT_POLICY_MATCH_IN) {
 		pr_info("input policy not valid in POSTROUTING and OUTPUT\n");
-		return false;
+		return -EINVAL;
 	}
 	if (info->len > XT_POLICY_MAX_ELEM) {
 		pr_info("too many policy elements\n");
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static struct xt_match policy_mt_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 2861fac..766e71c 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -48,14 +48,14 @@ static int quota_mt_check(const struct xt_mtchk_param *par)
 	struct xt_quota_info *q = par->matchinfo;
 
 	if (q->flags & ~XT_QUOTA_MASK)
-		return false;
+		return -EINVAL;
 
 	q->master = kmalloc(sizeof(*q->master), GFP_KERNEL);
 	if (q->master == NULL)
-		return false;
+		return -EINVAL;
 
 	q->master->quota = q->quota;
-	return true;
+	return 0;
 }
 
 static void quota_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 3b5e3d6..0b5c612 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -109,12 +109,12 @@ static int xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
 
 	info->est1 = est1;
 	info->est2 = est2;
-	return true;
+	return 0;
 
 err2:
 	xt_rateest_put(est1);
 err1:
-	return false;
+	return -EINVAL;
 }
 
 static void xt_rateest_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 52042c8..0994ff5 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -314,7 +314,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par)
 	struct proc_dir_entry *pde;
 #endif
 	unsigned i;
-	bool ret = false;
+	int ret = -EINVAL;
 
 	if (unlikely(!hash_rnd_inited)) {
 		get_random_bytes(&hash_rnd, sizeof(hash_rnd));
@@ -323,33 +323,33 @@ static int recent_mt_check(const struct xt_mtchk_param *par)
 	if (info->check_set & ~XT_RECENT_VALID_FLAGS) {
 		pr_info("Unsupported user space flags (%08x)\n",
 			info->check_set);
-		return false;
+		return -EINVAL;
 	}
 	if (hweight8(info->check_set &
 		     (XT_RECENT_SET | XT_RECENT_REMOVE |
 		      XT_RECENT_CHECK | XT_RECENT_UPDATE)) != 1)
-		return false;
+		return -EINVAL;
 	if ((info->check_set & (XT_RECENT_SET | XT_RECENT_REMOVE)) &&
 	    (info->seconds || info->hit_count ||
 	    (info->check_set & XT_RECENT_MODIFIERS)))
-		return false;
+		return -EINVAL;
 	if ((info->check_set & XT_RECENT_REAP) && !info->seconds)
-		return false;
+		return -EINVAL;
 	if (info->hit_count > ip_pkt_list_tot) {
 		pr_info("hitcount (%u) is larger than "
 			"packets to be remembered (%u)\n",
 			info->hit_count, ip_pkt_list_tot);
-		return false;
+		return -EINVAL;
 	}
 	if (info->name[0] == '\0' ||
 	    strnlen(info->name, XT_RECENT_NAME_LEN) == XT_RECENT_NAME_LEN)
-		return false;
+		return -EINVAL;
 
 	mutex_lock(&recent_mutex);
 	t = recent_table_lookup(recent_net, info->name);
 	if (t != NULL) {
 		t->refcnt++;
-		ret = true;
+		ret = 0;
 		goto out;
 	}
 
@@ -375,7 +375,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par)
 	spin_lock_bh(&recent_lock);
 	list_add_tail(&t->list, &recent_net->tables);
 	spin_unlock_bh(&recent_lock);
-	ret = true;
+	ret = 0;
 out:
 	mutex_unlock(&recent_mutex);
 	return ret;
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index 5037a7a..c3694df 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -149,17 +149,17 @@ static int sctp_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_sctp_info *info = par->matchinfo;
 
 	if (info->flags & ~XT_SCTP_VALID_FLAGS)
-		return false;
+		return -EINVAL;
 	if (info->invflags & ~XT_SCTP_VALID_FLAGS)
-		return false;
+		return -EINVAL;
 	if (info->invflags & ~info->flags)
-		return false;
+		return -EINVAL;
 	if (!(info->flags & XT_SCTP_CHUNK_TYPES))
-		return true;
+		return 0;
 	if (info->chunk_match_type & (SCTP_CHUNK_MATCH_ALL |
 	    SCTP_CHUNK_MATCH_ANY | SCTP_CHUNK_MATCH_ONLY))
-		return true;
-	return false;
+		return 0;
+	return -EINVAL;
 }
 
 static struct xt_match sctp_mt_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 8b15b13..8e8c9df 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -42,9 +42,9 @@ static int state_mt_check(const struct xt_mtchk_param *par)
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return false;
+		return -EINVAL;
 	}
-	return true;
+	return 0;
 }
 
 static void state_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index a577ab0..29d76f8 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -58,14 +58,14 @@ static int statistic_mt_check(const struct xt_mtchk_param *par)
 
 	if (info->mode > XT_STATISTIC_MODE_MAX ||
 	    info->flags & ~XT_STATISTIC_MASK)
-		return false;
+		return -EINVAL;
 
 	info->master = kzalloc(sizeof(*info->master), GFP_KERNEL);
 	if (info->master == NULL)
-		return false;
+		return -EINVAL;
 	info->master->count = info->u.nth.count;
 
-	return true;
+	return 0;
 }
 
 static void statistic_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index 7d14121..e1f22a7 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -48,26 +48,25 @@ static int string_mt_check(const struct xt_mtchk_param *par)
 
 	/* Damn, can't handle this case properly with iptables... */
 	if (conf->from_offset > conf->to_offset)
-		return false;
+		return -EINVAL;
 	if (conf->algo[XT_STRING_MAX_ALGO_NAME_SIZE - 1] != '\0')
-		return false;
+		return -EINVAL;
 	if (conf->patlen > XT_STRING_MAX_PATTERN_SIZE)
-		return false;
+		return -EINVAL;
 	if (par->match->revision == 1) {
 		if (conf->u.v1.flags &
 		    ~(XT_STRING_FLAG_IGNORECASE | XT_STRING_FLAG_INVERT))
-			return false;
+			return -EINVAL;
 		if (conf->u.v1.flags & XT_STRING_FLAG_IGNORECASE)
 			flags |= TS_IGNORECASE;
 	}
 	ts_conf = textsearch_prepare(conf->algo, conf->pattern, conf->patlen,
 				     GFP_KERNEL, flags);
 	if (IS_ERR(ts_conf))
-		return false;
+		return -EINVAL;
 
 	conf->config = ts_conf;
-
-	return true;
+	return 0;
 }
 
 static void string_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index 0072841..efa2ede 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -125,7 +125,7 @@ static int tcp_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_tcp *tcpinfo = par->matchinfo;
 
 	/* Must specify no unknown invflags */
-	return !(tcpinfo->invflags & ~XT_TCP_INV_MASK);
+	return (tcpinfo->invflags & ~XT_TCP_INV_MASK) ? -EINVAL : 0;
 }
 
 static bool udp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
@@ -160,7 +160,7 @@ static int udp_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_udp *udpinfo = par->matchinfo;
 
 	/* Must specify no unknown invflags */
-	return !(udpinfo->invflags & ~XT_UDP_INV_MASK);
+	return (udpinfo->invflags & ~XT_UDP_INV_MASK) ? -EINVAL : 0;
 }
 
 static struct xt_match tcpudp_mt_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index db74f4f..8dde5e5 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -225,10 +225,10 @@ static int time_mt_check(const struct xt_mtchk_param *par)
 	    info->daytime_stop > XT_TIME_MAX_DAYTIME) {
 		pr_info("invalid argument - start or "
 			"stop time greater than 23:59:59\n");
-		return false;
+		return -EINVAL;
 	}
 
-	return true;
+	return 0;
 }
 
 static struct xt_match xt_time_mt_reg __read_mostly = {
-- 
1.7.0.4

