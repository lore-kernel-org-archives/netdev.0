From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: fix icmpv6 endian bug and other sparse warnings
Date: Thu, 13 Dec 2012 08:51:28 -0800
Message-ID: <20121213085128.1db11ee4@nehalam.linuxnetplumber.net>
References: <50c926ab.AI4jRk2MW3J/QuQj%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55120 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484Ab2LMQwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 11:52:43 -0500
In-Reply-To: <50c926ab.AI4jRk2MW3J/QuQj%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the warnings reported by sparse on recent bridge multicast
changes. Mostly just rcu annotation issues but in this case
sparse found a real bug! The ICMPv6 mld2 query mrc
values is in network byte order.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_multicast.c	2012-12-12 10:40:11.939838344 -0800
+++ b/net/bridge/br_multicast.c	2012-12-13 08:47:35.103982170 -0800
@@ -622,7 +622,7 @@ out:
 struct net_bridge_port_group *br_multicast_new_port_group(
 			struct net_bridge_port *port,
 			struct br_ip *group,
-			struct net_bridge_port_group *next)
+			struct net_bridge_port_group __rcu *next)
 {
 	struct net_bridge_port_group *p;
 
@@ -632,7 +632,7 @@ struct net_bridge_port_group *br_multica
 
 	p->addr = *group;
 	p->port = port;
-	p->next = next;
+	rcu_assign_pointer(p->next, next);
 	hlist_add_head(&p->mglist, &port->mglist);
 	setup_timer(&p->timer, br_multicast_port_group_expired,
 		    (unsigned long)p);
@@ -1138,7 +1138,7 @@ static int br_ip6_multicast_query(struct
 				  struct sk_buff *skb)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
-	struct mld_msg *mld = (struct mld_msg *) icmp6_hdr(skb);
+	struct mld_msg *mld;
 	struct net_bridge_mdb_entry *mp;
 	struct mld2_query *mld2q;
 	struct net_bridge_port_group *p;
@@ -1165,6 +1165,7 @@ static int br_ip6_multicast_query(struct
 		if (max_delay)
 			group = &mld->mld_mca;
 	} else if (skb->len >= sizeof(*mld2q)) {
+		u16 mrc;
 		if (!pskb_may_pull(skb, sizeof(*mld2q))) {
 			err = -EINVAL;
 			goto out;
@@ -1172,7 +1173,8 @@ static int br_ip6_multicast_query(struct
 		mld2q = (struct mld2_query *)icmp6_hdr(skb);
 		if (!mld2q->mld2q_nsrcs)
 			group = &mld2q->mld2q_mca;
-		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(mld2q->mld2q_mrc) : 1;
+		mrc = ntohs(mld2q->mld2q_mrc);
+		max_delay = mrc ? MLDV2_MRC(mrc) : 1;
 	}
 
 	if (!group)
