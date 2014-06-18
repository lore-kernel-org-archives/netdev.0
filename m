From: roopa@cumulusnetworks.com
Subject: [RFC PATCH net-next] bridge: Add bridge port learn filter and priority
Date: Wed, 18 Jun 2014 00:16:07 -0700
Message-ID: <1403075767-31908-1-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, scotte@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, shm@cumulusnetworks.com,
	nolan@cumulusnetworks.com, sfeldma@cumulusnetworks.com,
	jhs@mojatatu.com
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44305 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933231AbaFRHPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 03:15:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This RFC patch introduces bridge port learning priority.

In certain network topologies, there is a need to give priority to certain
bridge port(s) over other bridge port(s) such that an fdb learned on the port
with higher priority does not move to the port(s) with lower priority.
One such topology is when there are multiple paths to a dual-homed host. In
this situation the path used by a bridge to reach the host is the port which
last received a packet from the host.

But, instead of having the path to a dual-connected host flip-flop back and
forth between the ports to the host based on the last received a packet from
that host, it is desirable to be able to define the preferred path to that
host. This is accomplished by defining an address movement priority for each
port, and restricting fdb address movement based on these priorities. The
rules are as follows:

    - all ports of a bridge are assigned a priority (LEARN_PRIO),
      default is 0 (lowest priority)
    - enforcement of the learning rules is activated on a port if
      LEARN_FILTER is set, default is not set
    - if a bridge port, say p1, is enabled with the LEARN_FILTER, and an fdb
      shows up on that port, and if the fdb is already learned on another
      bridge port, say p0:
         - if the priority of p0 is higher than the priority of p1, then the
           fdb remains learned on p0 and not allowed to move to p1
         - if the priority of p0 is equal or lower than the priority of p1,
           then the fdb moves to p1

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |    2 ++
 net/bridge/br_fdb.c          |   12 ++++++++++++
 net/bridge/br_netlink.c      |   33 ++++++++++++++++++++++++++++++++-
 net/bridge/br_private.h      |    2 ++
 4 files changed, 48 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b385348..ade556f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -225,6 +225,8 @@ enum {
 	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
 	IFLA_BRPORT_LEARNING,	/* mac learning */
 	IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
+	IFLA_BRPORT_LEARN_PRIO, /* learn priority          */
+	IFLA_BRPORT_LEARN_FILTER,  /* learn filter         */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b524c36..38e246e 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -505,6 +505,10 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		 */
 		if (fdb->is_local)
 			return 0;
+		if ((fdb->dst != source) && source &&
+			source->learn_filter &&
+			(fdb->dst->learn_priority > source->learn_priority))
+			return 0;
 		br_warn(br, "adding interface %s with same address "
 		       "as a received packet\n",
 		       source ? source->dev->name : br->dev->name);
@@ -559,6 +563,11 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 					source->dev->name);
 		} else {
 			/* fastpath: update of existing entry */
+			if (fdb->dst && source && (fdb->dst != source) &&
+				source->learn_filter &&
+				(fdb->dst->learn_priority > source->learn_priority))
+				return;
+
 			if (unlikely(source != fdb->dst)) {
 				fdb->dst = source;
 				fdb_modified = true;
@@ -732,6 +741,9 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 			return -EEXIST;
 
 		if (fdb->dst != source) {
+			if (source->learn_filter &&
+				(fdb->dst->learn_priority > source->learn_priority))
+				return 0;
 			fdb->dst = source;
 			modified = true;
 		}
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 26edb51..2b5f770 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -32,6 +32,8 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_FAST_LEAVE */
 		+ nla_total_size(1)	/* IFLA_BRPORT_LEARNING */
 		+ nla_total_size(1)	/* IFLA_BRPORT_UNICAST_FLOOD */
+		+ nla_total_size(1) /* IFLA_BRPORT_LEARN_PRIO */
+		+ nla_total_size(1) /* IFLA_BRPORT_LEARN_FILTER */
 		+ 0;
 }
 
@@ -60,7 +62,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u8(skb, IFLA_BRPORT_PROTECT, !!(p->flags & BR_ROOT_BLOCK)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_FAST_LEAVE, !!(p->flags & BR_MULTICAST_FAST_LEAVE)) ||
 	    nla_put_u8(skb, IFLA_BRPORT_LEARNING, !!(p->flags & BR_LEARNING)) ||
-	    nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)))
+		nla_put_u8(skb, IFLA_BRPORT_UNICAST_FLOOD, !!(p->flags & BR_FLOOD)) ||
+		nla_put_u8(skb, IFLA_BRPORT_LEARN_FILTER, p->learn_filter) ||
+		nla_put_u8(skb, IFLA_BRPORT_LEARN_PRIO, p->learn_priority))
 		return -EMSGSIZE;
 
 	return 0;
@@ -286,6 +290,8 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_LEARNING]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_UNICAST_FLOOD] = { .type = NLA_U8 },
+	[IFLA_BRPORT_LEARN_PRIO] = { .type = NLA_U8 },
+	[IFLA_BRPORT_LEARN_FILTER] = { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -324,6 +330,18 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
 	}
 }
 
+static int br_set_port_learn_priority(struct net_bridge_port *p, u8 prio)
+{
+	p->learn_priority = prio;
+	return 0;
+}
+
+static int br_set_port_learn_filter(struct net_bridge_port *p, u8 enable)
+{
+	p->learn_filter = enable;
+	return 0;
+}
+
 /* Process bridge protocol info on port */
 static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
@@ -355,6 +373,19 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 			return err;
 	}
 
+	if (tb[IFLA_BRPORT_LEARN_PRIO]) {
+		err = br_set_port_learn_priority(p, nla_get_u8(tb[IFLA_BRPORT_LEARN_PRIO]));
+		if (err)
+			return err;
+	}
+
+	if (tb[IFLA_BRPORT_LEARN_FILTER]) {
+		err = br_set_port_learn_filter(p,
+					nla_get_u8(tb[IFLA_BRPORT_LEARN_FILTER]));
+		if (err)
+			return err;
+	}
+
 	br_port_flags_change(p, old_flags ^ p->flags);
 	return 0;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 23caf5b..35f032a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -194,6 +194,8 @@ struct net_bridge_port
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	struct net_port_vlans __rcu	*vlan_info;
 #endif
+	u8				learn_priority;
+	u8				learn_filter;
 };
 
 #define br_auto_port(p) ((p)->flags & BR_AUTO_MASK)
-- 
1.7.10.4
