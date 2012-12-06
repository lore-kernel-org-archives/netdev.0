From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] sctp: Add RCU protection to assoc->transport_addr_list
Date: Thu,  6 Dec 2012 19:15:06 +0100
Message-ID: <16453bea94a6fc43d657139dff2ce0b5924e2a1f.1354817574.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:56836
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946471Ab2LFSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 13:15:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

peer.transport_addr_list is currently only protected by sk_sock
which is inpractical to acquire for procfs dumping purposes.

This patch adds RCU protection allowing for the procfs readers to
enter RCU read-side critical sections.

Modification of the list continues to be serialized via sk_lock.

Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/sctp/structs.h |  2 ++
 net/sctp/associola.c       |  4 ++--
 net/sctp/proc.c            |  8 ++++++--
 net/sctp/transport.c       | 18 +++++++++++++-----
 4 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 64158aa..5d6987b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -948,6 +948,8 @@ struct sctp_transport {
 
 	/* 64-bit random number sent with heartbeat. */
 	__u64 hb_nonce;
+
+	struct rcu_head rcu;
 };
 
 struct sctp_transport *sctp_transport_new(struct net *, const union sctp_addr *,
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index b1ef3bc..c826bb8 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -565,7 +565,7 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
 		sctp_assoc_update_retran_path(asoc);
 
 	/* Remove this peer from the list. */
-	list_del(&peer->transports);
+	list_del_rcu(&peer->transports);
 
 	/* Get the first transport of asoc. */
 	pos = asoc->peer.transport_addr_list.next;
@@ -765,7 +765,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 	peer->state = peer_state;
 
 	/* Attach the remote transport to our asoc.  */
-	list_add_tail(&peer->transports, &asoc->peer.transport_addr_list);
+	list_add_tail_rcu(&peer->transports, &asoc->peer.transport_addr_list);
 	asoc->peer.transport_count++;
 
 	/* If we do not yet have a primary path, set one.  */
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index ec9b0c8..36a3f9d 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -159,7 +159,8 @@ static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_associa
 	struct sctp_af *af;
 
 	primary = &assoc->peer.primary_addr;
-	list_for_each_entry(transport, &assoc->peer.transport_addr_list,
+	rcu_read_lock();
+	list_for_each_entry_rcu(transport, &assoc->peer.transport_addr_list,
 			transports) {
 		addr = &transport->ipaddr;
 		af = sctp_get_af_specific(addr->sa.sa_family);
@@ -168,6 +169,7 @@ static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_associa
 		}
 		af->seq_dump_addr(seq, addr);
 	}
+	rcu_read_unlock();
 }
 
 static void * sctp_eps_seq_start(struct seq_file *seq, loff_t *pos)
@@ -438,11 +440,12 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 	head = &sctp_assoc_hashtable[hash];
 	sctp_local_bh_disable();
 	read_lock(&head->lock);
+	rcu_read_lock();
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		if (!net_eq(sock_net(epb->sk), seq_file_net(seq)))
 			continue;
 		assoc = sctp_assoc(epb);
-		list_for_each_entry(tsp, &assoc->peer.transport_addr_list,
+		list_for_each_entry_rcu(tsp, &assoc->peer.transport_addr_list,
 					transports) {
 			/*
 			 * The remote address (ADDR)
@@ -489,6 +492,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 		}
 	}
 
+	rcu_read_unlock();
 	read_unlock(&head->lock);
 	sctp_local_bh_enable();
 
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 206cf52..1295aec 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -163,13 +163,11 @@ void sctp_transport_free(struct sctp_transport *transport)
 	sctp_transport_put(transport);
 }
 
-/* Destroy the transport data structure.
- * Assumes there are no more users of this structure.
- */
-static void sctp_transport_destroy(struct sctp_transport *transport)
+static void sctp_transport_destroy_rcu(struct rcu_head *head)
 {
-	SCTP_ASSERT(transport->dead, "Transport is not dead", return);
+	struct sctp_transport *transport;
 
+	transport = container_of(head, struct sctp_transport, rcu);
 	if (transport->asoc)
 		sctp_association_put(transport->asoc);
 
@@ -180,6 +178,16 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
 	SCTP_DBG_OBJCNT_DEC(transport);
 }
 
+/* Destroy the transport data structure.
+ * Assumes there are no more users of this structure.
+ */
+static void sctp_transport_destroy(struct sctp_transport *transport)
+{
+	SCTP_ASSERT(transport->dead, "Transport is not dead", return);
+
+	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
+}
+
 /* Start T3_rtx timer if it is not already running and update the heartbeat
  * timer.  This routine is called every time a DATA chunk is sent.
  */
-- 
1.7.11.7
