From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net 3/4] mpls: fix out-of-bounds access when via address not specified
Date: Thu, 10 Dec 2015 19:30:50 +0000
Message-ID: <1449775851-20758-4-git-send-email-rshearma@brocade.com>
References: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sam.h.russell@gmail.com>, Robert Shearman <rshearma@brocade.com>
To: <ebiederm@xmission.com>, <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48237 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752235AbbLJTcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 14:32:14 -0500
In-Reply-To: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a via address isn't specified, the via table is left initialised
to 0 (NEIGH_ARP_TABLE), and the via address length also left
initialised to 0. This results in a via address array of length 0
being allocated (contiguous with route and nexthop array), meaning
that when a packet is sent using neigh_xmit the neighbour lookup and
creation will cause an out-of-bounds access when accessing the 4 bytes
of the IPv4 address it assumes it has been given a pointer to.

This could be fixed by allocating the 4 bytes of via address necessary
and leaving it as all zeroes. However, it seems wrong to me to use an
ipv4 nexthop (including possibly ARPing for 0.0.0.0) when the user
didn't specify to do so.

Instead, set the via address table to NEIGH_NR_TABLES to signify it
hasn't been specified and use this at forwarding time to signify a
neigh_xmit using an L2 address consisting of the device address. This
mechanism is the same as that used for both ARP and ND for loopback
interfaces and those flagged as no-arp, which are all we can really
support in this case.

Fixes: cf4b24f0024f ("mpls: reduce memory usage of routes")
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index ac1c116abaac..7bfc85f52ca8 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -27,6 +27,8 @@
  */
 #define MAX_MP_SELECT_LABELS 4
 
+#define MPLS_NEIGH_TABLE_UNSPEC (NEIGH_LINK_TABLE + 1)
+
 static int zero = 0;
 static int label_limit = (1 << 20) - 1;
 
@@ -317,7 +319,13 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	err = neigh_xmit(nh->nh_via_table, out_dev, mpls_nh_via(rt, nh), skb);
+	/* If via wasn't specified then send out using device address */
+	if (nh->nh_via_table == MPLS_NEIGH_TABLE_UNSPEC)
+		err = neigh_xmit(NEIGH_LINK_TABLE, out_dev,
+				 out_dev->dev_addr, skb);
+	else
+		err = neigh_xmit(nh->nh_via_table, out_dev,
+				 mpls_nh_via(rt, nh), skb);
 	if (err)
 		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
 				    __func__, err);
@@ -1122,6 +1130,7 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 
 	cfg->rc_label		= LABEL_NOT_SPECIFIED;
 	cfg->rc_protocol	= rtm->rtm_protocol;
+	cfg->rc_via_table	= MPLS_NEIGH_TABLE_UNSPEC;
 	cfg->rc_nlflags		= nlh->nlmsg_flags;
 	cfg->rc_nlinfo.portid	= NETLINK_CB(skb).portid;
 	cfg->rc_nlinfo.nlh	= nlh;
@@ -1235,8 +1244,7 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		    nla_put_labels(skb, RTA_NEWDST, nh->nh_labels,
 				   nh->nh_label))
 			goto nla_put_failure;
-		if ((nh->nh_via_table != NEIGH_ARP_TABLE ||
-		     nh->nh_via_alen != 0) &&
+		if (nh->nh_via_table != MPLS_NEIGH_TABLE_UNSPEC &&
 		    nla_put_via(skb, nh->nh_via_table, mpls_nh_via(rt, nh),
 				nh->nh_via_alen))
 			goto nla_put_failure;
@@ -1325,8 +1333,7 @@ static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
 
 		if (nh->nh_dev)
 			payload += nla_total_size(4); /* RTA_OIF */
-		if (nh->nh_via_table != NEIGH_ARP_TABLE ||
-		    nh->nh_via_alen != 0) /* RTA_VIA */
+		if (nh->nh_via_table != MPLS_NEIGH_TABLE_UNSPEC) /* RTA_VIA */
 			payload += nla_total_size(2 + nh->nh_via_alen);
 		if (nh->nh_labels) /* RTA_NEWDST */
 			payload += nla_total_size(nh->nh_labels * 4);
-- 
2.1.4
