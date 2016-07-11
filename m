From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 3/3] tipc: reset all unicast links
	when broadcast send link fails
Date: Mon, 11 Jul 2016 16:08:37 -0400
Message-ID: <1468267717-518-4-git-send-email-jon.maloy@ericsson.com>
References: <1468267717-518-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1468267717-518-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In test situations with many nodes and a heavily stressed system we have
observed that the transmission broadcast link may fail due to an
excessive number of retransmissions of the same packet. In such
situations we need to reset all unicast links to all peers, in order to
reset and re-synchronize the broadcast link.

In this commit, we add a new function tipc_bearer_reset_all() to be used
in such situations. The function scans across all bearers and resets all
their pertaining links.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c | 15 +++++++++++++++
 net/tipc/bearer.h |  1 +
 net/tipc/node.c   | 15 +++++++++++----
 3 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index bf8f05c..a597708 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -330,6 +330,21 @@ static int tipc_reset_bearer(struct net *net, struct tipc_bearer *b)
 	return 0;
 }
 
+/* tipc_bearer_reset_all - reset all links on all bearers
+ */
+void tipc_bearer_reset_all(struct net *net)
+{
+	struct tipc_net *tn = tipc_net(net);
+	struct tipc_bearer *b;
+	int i;
+
+	for (i = 0; i < MAX_BEARERS; i++) {
+		b = rcu_dereference_rtnl(tn->bearer_list[i]);
+		if (b)
+			tipc_reset_bearer(net, b);
+	}
+}
+
 /**
  * bearer_disable
  *
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index f686e41..60e49c3 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -198,6 +198,7 @@ void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest);
 void tipc_bearer_remove_dest(struct net *net, u32 bearer_id, u32 dest);
 struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name);
 struct tipc_media *tipc_media_find(const char *name);
+void tipc_bearer_reset_all(struct net *net);
 int tipc_bearer_setup(void);
 void tipc_bearer_cleanup(void);
 void tipc_bearer_stop(struct net *net);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index e01e2c71..23d4761 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1297,10 +1297,6 @@ static void tipc_node_bc_rcv(struct net *net, struct sk_buff *skb, int bearer_id
 
 	rc = tipc_bcast_rcv(net, be->link, skb);
 
-	/* Broadcast link reset may happen at reassembly failure */
-	if (rc & TIPC_LINK_DOWN_EVT)
-		tipc_node_reset_links(n);
-
 	/* Broadcast ACKs are sent on a unicast link */
 	if (rc & TIPC_LINK_SND_BC_ACK) {
 		tipc_node_read_lock(n);
@@ -1320,6 +1316,17 @@ static void tipc_node_bc_rcv(struct net *net, struct sk_buff *skb, int bearer_id
 		spin_unlock_bh(&be->inputq2.lock);
 		tipc_sk_mcast_rcv(net, &be->arrvq, &be->inputq2);
 	}
+
+	if (rc & TIPC_LINK_DOWN_EVT) {
+		/* Reception reassembly failure => reset all links to peer */
+		if (!tipc_link_is_up(be->link))
+			tipc_node_reset_links(n);
+
+		/* Retransmission failure => reset all links to all peers */
+		if (!tipc_link_is_up(tipc_bc_sndlink(net)))
+			tipc_bearer_reset_all(net);
+	}
+
 	tipc_node_put(n);
 }
 
-- 
1.9.1


------------------------------------------------------------------------------
Attend Shape: An AT&T Tech Expo July 15-16. Meet us at AT&T Park in San
Francisco, CA to explore cutting-edge tech and listen to tech luminaries
present their vision of the future. This family event has something for
everyone, including kids. Get more information and register today.
http://sdm.link/attshape
