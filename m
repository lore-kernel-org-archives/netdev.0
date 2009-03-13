From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCHv2] netns: oops in ip_frag_reasm incrementing stats
Date: Fri, 13 Mar 2009 17:35:49 +0100
Message-ID: <49BA8B65.2060408@dti2.net>
References: <49BA87F4.1090709@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:3860 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759427AbZCMQfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 12:35:55 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50002645321.msg
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 17:35:52 +0100
In-Reply-To: <49BA87F4.1090709@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev can be NULL on ip_frag_reasm for skb's coming from RAW sockets.

Quagga's OSPFD sends fragmented packets on a RAW socket, when netfilter
conntrack reassembles them on the OUTPUT path you hit this code path.

Changes from v1:
	- Fixed description

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
  net/ipv4/ip_fragment.c |   14 +++++++-------
  1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 6659ac0..8f150d5 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -84,7 +84,7 @@ int ip_frag_mem(struct net *net)
  	return atomic_read(&net->ipv4.frags.mem);
  }

-static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
+static int ip_frag_reasm(struct net *net, struct ipq *qp, struct 
sk_buff *prev,
  			 struct net_device *dev);

  struct ip4_create_arg {
@@ -296,7 +296,7 @@ static int ip_frag_reinit(struct ipq *qp)
  }

  /* Add new segment to existing queue. */
-static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
+static int ip_frag_queue(struct net *net, struct ipq *qp, struct 
sk_buff *skb)
  {
  	struct sk_buff *prev, *next;
  	struct net_device *dev;
@@ -445,7 +445,7 @@ static int ip_frag_queue(struct ipq *qp, struct 
sk_buff *skb)

  	if (qp->q.last_in == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
  	    qp->q.meat == qp->q.len)
-		return ip_frag_reasm(qp, prev, dev);
+		return ip_frag_reasm(net, qp, prev, dev);

  	write_lock(&ip4_frags.lock);
  	list_move_tail(&qp->q.lru_list, &qp->q.net->lru_list);
@@ -460,7 +460,7 @@ err:

  /* Build a new IP datagram from all its fragments. */

-static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
+static int ip_frag_reasm(struct net *net, struct ipq *qp, struct 
sk_buff *prev,
  			 struct net_device *dev)
  {
  	struct iphdr *iph;
@@ -548,7 +548,7 @@ static int ip_frag_reasm(struct ipq *qp, struct 
sk_buff *prev,
  	iph = ip_hdr(head);
  	iph->frag_off = 0;
  	iph->tot_len = htons(len);
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMOKS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
  	qp->q.fragments = NULL;
  	return 0;

@@ -562,7 +562,7 @@ out_oversize:
  		printk(KERN_INFO "Oversized IP packet from %pI4.\n",
  			&qp->saddr);
  out_fail:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
  	return err;
  }

@@ -585,7 +585,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)

  		spin_lock(&qp->q.lock);

-		ret = ip_frag_queue(qp, skb);
+		ret = ip_frag_queue(net, qp, skb);

  		spin_unlock(&qp->q.lock);
  		ipq_put(qp);
-- 
1.5.6.5

