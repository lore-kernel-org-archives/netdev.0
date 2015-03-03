From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 2/2] neigh: Add helper function neigh_xmit
Date: Tue, 03 Mar 2015 17:11:16 -0600
Message-ID: <8761ahy8vf.fsf_-_@x220.int.ebiederm.org>
References: <874mq22imc.fsf_-_@x220.int.ebiederm.org>
	<20150303.144509.1694022322984204895.davem@davemloft.net>
	<87mw3tzv8u.fsf@x220.int.ebiederm.org>
	<20150303.153310.624302583835136622.davem@davemloft.net>
	<87h9u1y8y8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60684 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756649AbbCCXPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 18:15:32 -0500
In-Reply-To: <87h9u1y8y8.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 03 Mar 2015 17:09:35 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For MPLS I am building the code so that either the neighbour mac
address can be specified or we can have a next hop in ipv4 or ipv6.

The kind of next hop we have is indicated by the neighbour table
pointer.  A neighbour table pointer of NULL is a link layer address.
A non-NULL neighbour table pointer indicates which neighbour table and
thus which address family the next hop address is in that we need to
look up.

The code either sends a packet directly or looks up the appropriate
neighbour table entry and sends the packet.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/neighbour.h |  3 +++
 net/core/neighbour.c    | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 14e3f017966b..afb8237b0a8c 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -358,6 +358,7 @@ void neigh_for_each(struct neigh_table *tbl,
 		    void (*cb)(struct neighbour *, void *), void *cookie);
 void __neigh_for_each_release(struct neigh_table *tbl,
 			      int (*cb)(struct neighbour *));
+int neigh_xmit(int fam, struct net_device *, const void *, struct sk_buff *);
 void pneigh_for_each(struct neigh_table *tbl,
 		     void (*cb)(struct pneigh_entry *));
 
@@ -511,4 +512,6 @@ static inline void neigh_ha_snapshot(char *dst, const struct neighbour *n,
 		memcpy(dst, n->ha, dev->addr_len);
 	} while (read_seqretry(&n->ha_lock, seq));
 }
+
+
 #endif
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index fe3c6eac5805..cffaf00561e7 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2391,6 +2391,40 @@ void __neigh_for_each_release(struct neigh_table *tbl,
 }
 EXPORT_SYMBOL(__neigh_for_each_release);
 
+int neigh_xmit(int family, struct net_device *dev,
+	       const void *addr, struct sk_buff *skb)
+{
+	int err;
+	if (family == AF_PACKET) {
+		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+				      addr, NULL, skb->len);
+		if (err < 0)
+			goto out_kfree_skb;
+		err = dev_queue_xmit(skb);
+	} else {
+		struct neigh_table *tbl;
+		struct neighbour *neigh;
+
+		err = -ENETDOWN;
+		tbl = neigh_find_table(family);
+		if (!tbl)
+			goto out;
+		neigh = __neigh_lookup_noref(tbl, addr, dev);
+		if (!neigh)
+			neigh = __neigh_create(tbl, addr, dev, false);
+		err = PTR_ERR(neigh);
+		if (IS_ERR(neigh))
+			goto out_kfree_skb;
+		err = neigh->output(neigh, skb);
+	}
+out:
+	return err;
+out_kfree_skb:
+	kfree_skb(skb);
+	goto out;
+}
+EXPORT_SYMBOL(neigh_xmit);
+
 #ifdef CONFIG_PROC_FS
 
 static struct neighbour *neigh_get_first(struct seq_file *seq)
-- 
2.2.1
