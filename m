From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 6/7] sctp: use generic union inet_addr
Date: Mon, 22 Jul 2013 15:05:12 +0800
Message-ID: <1374476713-8838-7-git-send-email-amwang@redhat.com>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51589 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756507Ab3GVHGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 03:06:24 -0400
In-Reply-To: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

sctp has its own union sctp_addr which is nearly same
with the generic union inet_addr, so just convert it
to the generic one.

Sorry for the big patch, it is not easy to split it. Most
of the patch simply does s/union sctp_addr/union inet_addr/
and some adjustments for the fields.

The address family specific ops, ->cmp_addr(), ->is_any() etc.,
are removed, since we have generic helpers, they are unnecessary.

Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: linux-sctp@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/net/sctp/sctp.h    |   22 ++--
 include/net/sctp/sm.h      |    4 +-
 include/net/sctp/structs.h |  132 +++++++++++-------------
 net/sctp/associola.c       |   26 +++---
 net/sctp/bind_addr.c       |   61 ++++--------
 net/sctp/endpointola.c     |   12 +-
 net/sctp/input.c           |   56 +++++-----
 net/sctp/ipv6.c            |  240 +++++++++++++++++++-------------------------
 net/sctp/outqueue.c        |    4 +-
 net/sctp/proc.c            |   10 +-
 net/sctp/protocol.c        |  198 ++++++++++++++----------------------
 net/sctp/sm_make_chunk.c   |   54 +++++-----
 net/sctp/sm_statefuns.c    |   23 ++---
 net/sctp/socket.c          |  126 +++++++++++++-----------
 net/sctp/transport.c       |   12 +-
 net/sctp/ulpevent.c        |    2 +-
 16 files changed, 437 insertions(+), 545 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index d8e37ec..de34bd7 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -590,22 +590,22 @@ static inline int __sctp_sstate(const struct sock *sk, sctp_sock_state_t state)
 }
 
 /* Map v4-mapped v6 address back to v4 address */
-static inline void sctp_v6_map_v4(union sctp_addr *addr)
+static inline void sctp_v6_map_v4(union inet_addr *addr)
 {
-	addr->v4.sin_family = AF_INET;
-	addr->v4.sin_port = addr->v6.sin6_port;
-	addr->v4.sin_addr.s_addr = addr->v6.sin6_addr.s6_addr32[3];
+	addr->sin.sin_family = AF_INET;
+	addr->sin.sin_port = addr->sin6.sin6_port;
+	addr->sin.sin_addr.s_addr = addr->sin6.sin6_addr.s6_addr32[3];
 }
 
 /* Map v4 address to v4-mapped v6 address */
-static inline void sctp_v4_map_v6(union sctp_addr *addr)
+static inline void sctp_v4_map_v6(union inet_addr *addr)
 {
-	addr->v6.sin6_family = AF_INET6;
-	addr->v6.sin6_port = addr->v4.sin_port;
-	addr->v6.sin6_addr.s6_addr32[3] = addr->v4.sin_addr.s_addr;
-	addr->v6.sin6_addr.s6_addr32[0] = 0;
-	addr->v6.sin6_addr.s6_addr32[1] = 0;
-	addr->v6.sin6_addr.s6_addr32[2] = htonl(0x0000ffff);
+	addr->sin6.sin6_family = AF_INET6;
+	addr->sin6.sin6_port = addr->sin.sin_port;
+	addr->sin6.sin6_addr.s6_addr32[3] = addr->sin.sin_addr.s_addr;
+	addr->sin6.sin6_addr.s6_addr32[0] = 0;
+	addr->sin6.sin6_addr.s6_addr32[1] = 0;
+	addr->sin6.sin6_addr.s6_addr32[2] = htonl(0x0000ffff);
 }
 
 /* The cookie is always 0 since this is how it's used in the
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 2a82d13..b0e8173 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -250,11 +250,11 @@ struct sctp_chunk *sctp_make_op_error(const struct sctp_association *,
 				 size_t reserve_tail);
 
 struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *,
-					      union sctp_addr *,
+					      union inet_addr *,
 					      struct sockaddr *,
 					      int, __be16);
 struct sctp_chunk *sctp_make_asconf_set_prim(struct sctp_association *asoc,
-					     union sctp_addr *addr);
+					     union inet_addr *addr);
 int sctp_verify_asconf(const struct sctp_association *asoc,
 		       struct sctp_paramhdr *param_hdr, void *chunk_end,
 		       struct sctp_paramhdr **errp);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e745c92..ae77fb6 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -65,15 +65,7 @@
 #include <linux/workqueue.h>	/* We need tq_struct.	 */
 #include <linux/sctp.h>		/* We need sctp* header structs.  */
 #include <net/sctp/auth.h>	/* We need auth specific structs */
-
-/* A convenience structure for handling sockaddr structures.
- * We should wean ourselves off this.
- */
-union sctp_addr {
-	struct sockaddr_in v4;
-	struct sockaddr_in6 v6;
-	struct sockaddr sa;
-};
+#include <net/inet_addr.h>
 
 /* Forward declarations for data structures. */
 struct sctp_globals;
@@ -296,7 +288,7 @@ struct sctp_cookie {
 	__u32 initial_tsn;
 
 	/* This holds the originating address of the INIT packet.  */
-	union sctp_addr peer_addr;
+	union inet_addr peer_addr;
 
 	/* IG Section 2.35.3 
 	 * Include the source port of the INIT-ACK
@@ -372,7 +364,7 @@ union sctp_params {
  */
 typedef struct sctp_sender_hb_info {
 	struct sctp_paramhdr param_hdr;
-	union sctp_addr daddr;
+	union inet_addr daddr;
 	unsigned long sent_at;
 	__u64 hb_nonce;
 } __packed sctp_sender_hb_info_t;
@@ -453,7 +445,7 @@ struct sctp_af {
 					 char __user *optval,
 					 int __user *optlen);
 	void		(*get_dst)	(struct sctp_transport *t,
-					 union sctp_addr *saddr,
+					 union inet_addr *saddr,
 					 struct flowi *fl,
 					 struct sock *sk);
 	void		(*get_saddr)	(struct sctp_sock *sk,
@@ -461,36 +453,32 @@ struct sctp_af {
 					 struct flowi *fl);
 	void		(*copy_addrlist) (struct list_head *,
 					  struct net_device *);
-	int		(*cmp_addr)	(const union sctp_addr *addr1,
-					 const union sctp_addr *addr2);
-	void		(*addr_copy)	(union sctp_addr *dst,
-					 union sctp_addr *src);
-	void		(*from_skb)	(union sctp_addr *,
+	bool		(*cmp_addr)	(const union inet_addr *addr1,
+					 const union inet_addr *addr2);
+	void		(*addr_copy)	(union inet_addr *dst,
+					 union inet_addr *src);
+	void		(*from_skb)	(union inet_addr *,
 					 struct sk_buff *skb,
 					 int saddr);
-	void		(*from_sk)	(union sctp_addr *,
+	void		(*from_sk)	(union inet_addr *,
 					 struct sock *sk);
-	void		(*to_sk_saddr)	(union sctp_addr *,
+	void		(*to_sk_saddr)	(union inet_addr *,
 					 struct sock *sk);
-	void		(*to_sk_daddr)	(union sctp_addr *,
+	void		(*to_sk_daddr)	(union inet_addr *,
 					 struct sock *sk);
-	void		(*from_addr_param) (union sctp_addr *,
+	void		(*from_addr_param) (union inet_addr *,
 					    union sctp_addr_param *,
 					    __be16 port, int iif);
-	int		(*to_addr_param) (const union sctp_addr *,
+	int		(*to_addr_param) (const union inet_addr *,
 					  union sctp_addr_param *); 
-	int		(*addr_valid)	(union sctp_addr *,
+	int		(*addr_valid)	(union inet_addr *,
 					 struct sctp_sock *,
 					 const struct sk_buff *);
-	sctp_scope_t	(*scope) (union sctp_addr *);
-	void		(*inaddr_any)	(union sctp_addr *, __be16);
-	int		(*is_any)	(const union sctp_addr *);
-	int		(*available)	(union sctp_addr *,
+	sctp_scope_t	(*scope) (union inet_addr *);
+	int		(*available)	(union inet_addr *,
 					 struct sctp_sock *);
 	int		(*skb_iif)	(const struct sk_buff *sk);
 	int		(*is_ce)	(const struct sk_buff *sk);
-	void		(*seq_dump_addr)(struct seq_file *seq,
-					 union sctp_addr *addr);
 	void		(*ecn_capable)(struct sock *sk);
 	__u16		net_header_len;
 	int		sockaddr_len;
@@ -506,15 +494,15 @@ struct sctp_pf {
 	void (*event_msgname)(struct sctp_ulpevent *, char *, int *);
 	void (*skb_msgname)  (struct sk_buff *, char *, int *);
 	int  (*af_supported) (sa_family_t, struct sctp_sock *);
-	int  (*cmp_addr) (const union sctp_addr *,
-			  const union sctp_addr *,
+	int  (*cmp_addr) (const union inet_addr *,
+			  const union inet_addr *,
 			  struct sctp_sock *);
-	int  (*bind_verify) (struct sctp_sock *, union sctp_addr *);
-	int  (*send_verify) (struct sctp_sock *, union sctp_addr *);
+	int  (*bind_verify) (struct sctp_sock *, union inet_addr *);
+	int  (*send_verify) (struct sctp_sock *, union inet_addr *);
 	int  (*supported_addrs)(const struct sctp_sock *, __be16 *);
 	struct sock *(*create_accept_sk) (struct sock *sk,
 					  struct sctp_association *asoc);
-	void (*addr_v4map) (struct sctp_sock *, union sctp_addr *);
+	void (*addr_v4map) (struct sctp_sock *, union inet_addr *);
 	struct sctp_af *af;
 };
 
@@ -613,9 +601,9 @@ struct sctp_chunk {
 	unsigned long sent_at;
 
 	/* What is the origin IP address for this chunk?  */
-	union sctp_addr source;
+	union inet_addr source;
 	/* Destination address for this chunk. */
-	union sctp_addr dest;
+	union inet_addr dest;
 
 	/* For outbound message, track all fragments for SEND_FAILED. */
 	struct sctp_datamsg *msg;
@@ -661,9 +649,9 @@ void  *sctp_addto_chunk_fixed(struct sctp_chunk *, int len, const void *data);
 struct sctp_chunk *sctp_chunkify(struct sk_buff *,
 				 const struct sctp_association *,
 				 struct sock *);
-void sctp_init_addrs(struct sctp_chunk *, union sctp_addr *,
-		     union sctp_addr *);
-const union sctp_addr *sctp_source(const struct sctp_chunk *chunk);
+void sctp_init_addrs(struct sctp_chunk *, union inet_addr *,
+		     union inet_addr *);
+const union inet_addr *sctp_source(const struct sctp_chunk *chunk);
 
 enum {
 	SCTP_ADDR_NEW,		/* new address added to assoc/ep */
@@ -675,7 +663,7 @@ enum {
 struct sctp_sockaddr_entry {
 	struct list_head list;
 	struct rcu_head	rcu;
-	union sctp_addr a;
+	union inet_addr a;
 	__u8 state;
 	__u8 valid;
 };
@@ -734,7 +722,7 @@ static inline int sctp_packet_empty(struct sctp_packet *packet)
 }
 
 /* This represents a remote transport address.
- * For local transport addresses, we just use union sctp_addr.
+ * For local transport addresses, we just use union inet_addr.
  *
  * RFC2960 Section 1.4 Key Terms
  *
@@ -786,7 +774,7 @@ struct sctp_transport {
 	struct flowi fl;
 
 	/* This is the peer's IP address and port. */
-	union sctp_addr ipaddr;
+	union inet_addr ipaddr;
 
 	/* These are the functions we call to handle LLP stuff.	 */
 	struct sctp_af *af_specific;
@@ -835,7 +823,7 @@ struct sctp_transport {
 	/* Destination */
 	struct dst_entry *dst;
 	/* Source address. */
-	union sctp_addr saddr;
+	union inet_addr saddr;
 
 	/* Heartbeat interval: The endpoint sends out a Heartbeat chunk to
 	 * the destination address every heartbeat interval.
@@ -948,11 +936,11 @@ struct sctp_transport {
 	struct rcu_head rcu;
 };
 
-struct sctp_transport *sctp_transport_new(struct net *, const union sctp_addr *,
+struct sctp_transport *sctp_transport_new(struct net *, const union inet_addr *,
 					  gfp_t);
 void sctp_transport_set_owner(struct sctp_transport *,
 			      struct sctp_association *);
-void sctp_transport_route(struct sctp_transport *, union sctp_addr *,
+void sctp_transport_route(struct sctp_transport *, union inet_addr *,
 			  struct sctp_sock *);
 void sctp_transport_pmtu(struct sctp_transport *, struct sock *sk);
 void sctp_transport_free(struct sctp_transport *);
@@ -1103,17 +1091,17 @@ int sctp_bind_addr_copy(struct net *net, struct sctp_bind_addr *dest,
 int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
 			const struct sctp_bind_addr *src,
 			gfp_t gfp);
-int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
+int sctp_add_bind_addr(struct sctp_bind_addr *, union inet_addr *,
 		       __u8 addr_state, gfp_t gfp);
-int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
-int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
+int sctp_del_bind_addr(struct sctp_bind_addr *, union inet_addr *);
+int sctp_bind_addr_match(struct sctp_bind_addr *, const union inet_addr *,
 			 struct sctp_sock *);
-int sctp_bind_addr_conflict(struct sctp_bind_addr *, const union sctp_addr *,
+int sctp_bind_addr_conflict(struct sctp_bind_addr *, const union inet_addr *,
 			 struct sctp_sock *, struct sctp_sock *);
 int sctp_bind_addr_state(const struct sctp_bind_addr *bp,
-			 const union sctp_addr *addr);
-union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
-					const union sctp_addr	*addrs,
+			 const union inet_addr *addr);
+union inet_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
+					const union inet_addr	*addrs,
 					int			addrcnt,
 					struct sctp_sock	*opt);
 union sctp_params sctp_bind_addrs_to_raw(const struct sctp_bind_addr *bp,
@@ -1122,10 +1110,10 @@ union sctp_params sctp_bind_addrs_to_raw(const struct sctp_bind_addr *bp,
 int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw, int len,
 			   __u16 port, gfp_t gfp);
 
-sctp_scope_t sctp_scope(const union sctp_addr *);
-int sctp_in_scope(struct net *net, const union sctp_addr *addr, const sctp_scope_t scope);
-int sctp_is_any(struct sock *sk, const union sctp_addr *addr);
-int sctp_addr_is_valid(const union sctp_addr *addr);
+sctp_scope_t sctp_scope(const union inet_addr *);
+int sctp_in_scope(struct net *net, const union inet_addr *addr, const sctp_scope_t scope);
+int sctp_is_any(struct sock *sk, const union inet_addr *addr);
+int sctp_addr_is_valid(const union inet_addr *addr);
 int sctp_is_ep_boundall(struct sock *sk);
 
 
@@ -1271,20 +1259,20 @@ void sctp_endpoint_hold(struct sctp_endpoint *);
 void sctp_endpoint_add_asoc(struct sctp_endpoint *, struct sctp_association *);
 struct sctp_association *sctp_endpoint_lookup_assoc(
 	const struct sctp_endpoint *ep,
-	const union sctp_addr *paddr,
+	const union inet_addr *paddr,
 	struct sctp_transport **);
 int sctp_endpoint_is_peeled_off(struct sctp_endpoint *,
-				const union sctp_addr *);
+				const union inet_addr *);
 struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *,
-					struct net *, const union sctp_addr *);
-int sctp_has_association(struct net *net, const union sctp_addr *laddr,
-			 const union sctp_addr *paddr);
+					struct net *, const union inet_addr *);
+int sctp_has_association(struct net *net, const union inet_addr *laddr,
+			 const union inet_addr *paddr);
 
 int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
 		     sctp_cid_t, sctp_init_chunk_t *peer_init,
 		     struct sctp_chunk *chunk, struct sctp_chunk **err_chunk);
 int sctp_process_init(struct sctp_association *, struct sctp_chunk *chunk,
-		      const union sctp_addr *peer,
+		      const union inet_addr *peer,
 		      sctp_init_chunk_t *init, gfp_t gfp);
 __u32 sctp_generate_tag(const struct sctp_endpoint *);
 __u32 sctp_generate_tsn(const struct sctp_endpoint *);
@@ -1424,7 +1412,7 @@ struct sctp_association {
 		/* Cache the primary path address here, when we
 		 * need a an address for msg_name.
 		 */
-		union sctp_addr primary_addr;
+		union inet_addr primary_addr;
 
 		/* active_path
 		 *   The path that we are currently using to
@@ -1825,7 +1813,7 @@ struct sctp_association {
 	 * after reaching 4294967295.
 	 */
 	__u32 addip_serial;
-	union sctp_addr *asconf_addr_del_pending;
+	union inet_addr *asconf_addr_del_pending;
 	int src_out_of_asoc_ok;
 	struct sctp_transport *new_transport;
 
@@ -1884,15 +1872,15 @@ struct sctp_transport *sctp_assoc_choose_alter_transport(
 	struct sctp_association *, struct sctp_transport *);
 void sctp_assoc_update_retran_path(struct sctp_association *);
 struct sctp_transport *sctp_assoc_lookup_paddr(const struct sctp_association *,
-					  const union sctp_addr *);
+					  const union inet_addr *);
 int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
-			    const union sctp_addr *laddr);
+			    const union inet_addr *laddr);
 struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *,
-				     const union sctp_addr *address,
+				     const union inet_addr *address,
 				     const gfp_t gfp,
 				     const int peer_state);
 void sctp_assoc_del_peer(struct sctp_association *asoc,
-			 const union sctp_addr *addr);
+			 const union inet_addr *addr);
 void sctp_assoc_rm_peer(struct sctp_association *asoc,
 			 struct sctp_transport *peer);
 void sctp_assoc_control_transport(struct sctp_association *,
@@ -1901,8 +1889,8 @@ void sctp_assoc_control_transport(struct sctp_association *,
 struct sctp_transport *sctp_assoc_lookup_tsn(struct sctp_association *, __u32);
 struct sctp_transport *sctp_assoc_is_match(struct sctp_association *,
 					   struct net *,
-					   const union sctp_addr *,
-					   const union sctp_addr *);
+					   const union inet_addr *,
+					   const union inet_addr *);
 void sctp_assoc_migrate(struct sctp_association *, struct sock *);
 void sctp_assoc_update(struct sctp_association *old,
 		       struct sctp_association *new);
@@ -1928,8 +1916,8 @@ struct sctp_chunk *sctp_assoc_lookup_asconf_ack(
 					__be32 serial);
 void sctp_asconf_queue_teardown(struct sctp_association *asoc);
 
-int sctp_cmp_addr_exact(const union sctp_addr *ss1,
-			const union sctp_addr *ss2);
+int sctp_cmp_addr_exact(const union inet_addr *ss1,
+			const union inet_addr *ss2);
 struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc);
 
 /* A convenience structure to parse out SCTP specific CMSGs. */
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 3084c7c..84806cb 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -493,7 +493,7 @@ void sctp_assoc_set_primary(struct sctp_association *asoc,
 
 	/* Set a default msg_name for events. */
 	memcpy(&asoc->peer.primary_addr, &transport->ipaddr,
-	       sizeof(union sctp_addr));
+	       sizeof(union inet_addr));
 
 	/* If the primary path is changing, assume that the
 	 * user wants to use this new path.
@@ -623,7 +623,7 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
 
 /* Add a transport address to an association.  */
 struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
-					   const union sctp_addr *addr,
+					   const union inet_addr *addr,
 					   const gfp_t gfp,
 					   const int peer_state)
 {
@@ -635,7 +635,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 	sp = sctp_sk(asoc->base.sk);
 
 	/* AF_INET and AF_INET6 share common port field. */
-	port = ntohs(addr->v4.sin_port);
+	port = ntohs(addr->sin.sin_port);
 
 	pr_debug("%s: association:%p addr:%pIApc state:%d\n", __func__,
 		 asoc, &addr->sa, peer_state);
@@ -767,7 +767,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 
 /* Delete a transport address from an association.  */
 void sctp_assoc_del_peer(struct sctp_association *asoc,
-			 const union sctp_addr *addr)
+			 const union inet_addr *addr)
 {
 	struct list_head	*pos;
 	struct list_head	*temp;
@@ -786,7 +786,7 @@ void sctp_assoc_del_peer(struct sctp_association *asoc,
 /* Lookup a transport by address. */
 struct sctp_transport *sctp_assoc_lookup_paddr(
 					const struct sctp_association *asoc,
-					const union sctp_addr *address)
+					const union inet_addr *address)
 {
 	struct sctp_transport *t;
 
@@ -983,8 +983,8 @@ __u32 sctp_association_get_next_tsn(struct sctp_association *asoc)
 /* Compare two addresses to see if they match.  Wildcard addresses
  * only match themselves.
  */
-int sctp_cmp_addr_exact(const union sctp_addr *ss1,
-			const union sctp_addr *ss2)
+int sctp_cmp_addr_exact(const union inet_addr *ss1,
+			const union inet_addr *ss2)
 {
 	struct sctp_af *af;
 
@@ -1075,13 +1075,13 @@ out:
 /* Is this the association we are looking for? */
 struct sctp_transport *sctp_assoc_is_match(struct sctp_association *asoc,
 					   struct net *net,
-					   const union sctp_addr *laddr,
-					   const union sctp_addr *paddr)
+					   const union inet_addr *laddr,
+					   const union inet_addr *paddr)
 {
 	struct sctp_transport *transport;
 
-	if ((htons(asoc->base.bind_addr.port) == laddr->v4.sin_port) &&
-	    (htons(asoc->peer.port) == paddr->v4.sin_port) &&
+	if ((htons(asoc->base.bind_addr.port) == laddr->sin.sin_port) &&
+	    (htons(asoc->peer.port) == paddr->sin.sin_port) &&
 	    net_eq(sock_net(asoc->base.sk), net)) {
 		transport = sctp_assoc_lookup_paddr(asoc, paddr);
 		if (!transport)
@@ -1557,11 +1557,11 @@ int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *asoc,
 
 /* Lookup laddr in the bind address list of an association. */
 int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
-			    const union sctp_addr *laddr)
+			    const union inet_addr *laddr)
 {
 	int found = 0;
 
-	if ((asoc->base.bind_addr.port == ntohs(laddr->v4.sin_port)) &&
+	if ((asoc->base.bind_addr.port == ntohs(laddr->sin.sin_port)) &&
 	    sctp_bind_addr_match(&asoc->base.bind_addr, laddr,
 				 sctp_sk(asoc->base.sk)))
 		found = 1;
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 64977ea..336ec32 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -53,7 +53,7 @@
 
 /* Forward declarations for internal helpers. */
 static int sctp_copy_one_addr(struct net *, struct sctp_bind_addr *,
-			      union sctp_addr *, sctp_scope_t scope, gfp_t gfp,
+			      union inet_addr *, sctp_scope_t scope, gfp_t gfp,
 			      int flags);
 static void sctp_bind_addr_clean(struct sctp_bind_addr *);
 
@@ -156,7 +156,7 @@ void sctp_bind_addr_free(struct sctp_bind_addr *bp)
 }
 
 /* Add an address to the bind address list in the SCTP_bind_addr structure. */
-int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
+int sctp_add_bind_addr(struct sctp_bind_addr *bp, union inet_addr *new,
 		       __u8 addr_state, gfp_t gfp)
 {
 	struct sctp_sockaddr_entry *addr;
@@ -171,8 +171,8 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
 	/* Fix up the port if it has not yet been set.
 	 * Both v4 and v6 have the port at the same offset.
 	 */
-	if (!addr->a.v4.sin_port)
-		addr->a.v4.sin_port = htons(bp->port);
+	if (!addr->a.sin.sin_port)
+		addr->a.sin.sin_port = htons(bp->port);
 
 	addr->state = addr_state;
 	addr->valid = 1;
@@ -191,7 +191,7 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
 /* Delete an address from the bind address list in the SCTP_bind_addr
  * structure.
  */
-int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
+int sctp_del_bind_addr(struct sctp_bind_addr *bp, union inet_addr *del_addr)
 {
 	struct sctp_sockaddr_entry *addr, *temp;
 	int found = 0;
@@ -259,7 +259,7 @@ union sctp_params sctp_bind_addrs_to_raw(const struct sctp_bind_addr *bp,
 	addrparms = retval;
 
 	list_for_each_entry(addr, &bp->address_list, list) {
-		af = sctp_get_af_specific(addr->a.v4.sin_family);
+		af = sctp_get_af_specific(addr->a.sin.sin_family);
 		len = af->to_addr_param(&addr->a, &rawaddr);
 		memcpy(addrparms.v, &rawaddr, len);
 		addrparms.v += len;
@@ -280,7 +280,7 @@ int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw_addr_list,
 {
 	union sctp_addr_param *rawaddr;
 	struct sctp_paramhdr *param;
-	union sctp_addr addr;
+	union inet_addr addr;
 	int retval = 0;
 	int len;
 	struct sctp_af *af;
@@ -319,7 +319,7 @@ int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw_addr_list,
 
 /* Does this contain a specified address?  Allow wildcarding. */
 int sctp_bind_addr_match(struct sctp_bind_addr *bp,
-			 const union sctp_addr *addr,
+			 const union inet_addr *addr,
 			 struct sctp_sock *opt)
 {
 	struct sctp_sockaddr_entry *laddr;
@@ -343,7 +343,7 @@ int sctp_bind_addr_match(struct sctp_bind_addr *bp,
  * the bp.
  */
 int sctp_bind_addr_conflict(struct sctp_bind_addr *bp,
-			    const union sctp_addr *addr,
+			    const union inet_addr *addr,
 			    struct sctp_sock *bp_sp,
 			    struct sctp_sock *addr_sp)
 {
@@ -378,7 +378,7 @@ int sctp_bind_addr_conflict(struct sctp_bind_addr *bp,
 
 /* Get the state of the entry in the bind_addr_list */
 int sctp_bind_addr_state(const struct sctp_bind_addr *bp,
-			 const union sctp_addr *addr)
+			 const union inet_addr *addr)
 {
 	struct sctp_sockaddr_entry *laddr;
 	struct sctp_af *af;
@@ -405,13 +405,13 @@ int sctp_bind_addr_state(const struct sctp_bind_addr *bp,
 /* Find the first address in the bind address list that is not present in
  * the addrs packed array.
  */
-union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
-					const union sctp_addr	*addrs,
+union inet_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
+					const union inet_addr	*addrs,
 					int			addrcnt,
 					struct sctp_sock	*opt)
 {
 	struct sctp_sockaddr_entry	*laddr;
-	union sctp_addr			*addr;
+	union inet_addr			*addr;
 	void 				*addr_buf;
 	struct sctp_af			*af;
 	int				i;
@@ -421,10 +421,10 @@ union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
 	 * can't change.
 	 */
 	list_for_each_entry(laddr, &bp->address_list, list) {
-		addr_buf = (union sctp_addr *)addrs;
+		addr_buf = (union inet_addr *)addrs;
 		for (i = 0; i < addrcnt; i++) {
 			addr = addr_buf;
-			af = sctp_get_af_specific(addr->v4.sin_family);
+			af = sctp_get_af_specific(addr->sin.sin_family);
 			if (!af)
 				break;
 
@@ -442,13 +442,13 @@ union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
 
 /* Copy out addresses from the global local address list. */
 static int sctp_copy_one_addr(struct net *net, struct sctp_bind_addr *dest,
-			      union sctp_addr *addr,
+			      union inet_addr *addr,
 			      sctp_scope_t scope, gfp_t gfp,
 			      int flags)
 {
 	int error = 0;
 
-	if (sctp_is_any(NULL, addr)) {
+	if (inet_addr_any(addr)) {
 		error = sctp_copy_local_addr_list(net, dest, scope, gfp, flags);
 	} else if (sctp_in_scope(net, addr, scope)) {
 		/* Now that the address is in scope, check to see if
@@ -467,27 +467,8 @@ static int sctp_copy_one_addr(struct net *net, struct sctp_bind_addr *dest,
 	return error;
 }
 
-/* Is this a wildcard address?  */
-int sctp_is_any(struct sock *sk, const union sctp_addr *addr)
-{
-	unsigned short fam = 0;
-	struct sctp_af *af;
-
-	/* Try to get the right address family */
-	if (addr->sa.sa_family != AF_UNSPEC)
-		fam = addr->sa.sa_family;
-	else if (sk)
-		fam = sk->sk_family;
-
-	af = sctp_get_af_specific(fam);
-	if (!af)
-		return 0;
-
-	return af->is_any(addr);
-}
-
 /* Is 'addr' valid for 'scope'?  */
-int sctp_in_scope(struct net *net, const union sctp_addr *addr, sctp_scope_t scope)
+int sctp_in_scope(struct net *net, const union inet_addr *addr, sctp_scope_t scope)
 {
 	sctp_scope_t addr_scope = sctp_scope(addr);
 
@@ -536,7 +517,7 @@ int sctp_is_ep_boundall(struct sock *sk)
 	if (sctp_list_single_entry(&bp->address_list)) {
 		addr = list_entry(bp->address_list.next,
 				  struct sctp_sockaddr_entry, list);
-		if (sctp_is_any(sk, &addr->a))
+		if (inet_addr_any(&addr->a))
 			return 1;
 	}
 	return 0;
@@ -547,7 +528,7 @@ int sctp_is_ep_boundall(struct sock *sk)
  ********************************************************************/
 
 /* What is the scope of 'addr'?  */
-sctp_scope_t sctp_scope(const union sctp_addr *addr)
+sctp_scope_t sctp_scope(const union inet_addr *addr)
 {
 	struct sctp_af *af;
 
@@ -555,5 +536,5 @@ sctp_scope_t sctp_scope(const union sctp_addr *addr)
 	if (!af)
 		return SCTP_SCOPE_UNUSABLE;
 
-	return af->scope((union sctp_addr *)addr);
+	return af->scope((union inet_addr *)addr);
 }
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 9e3d257..9434c6a 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -305,11 +305,11 @@ void sctp_endpoint_put(struct sctp_endpoint *ep)
 /* Is this the endpoint we are looking for?  */
 struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *ep,
 					       struct net *net,
-					       const union sctp_addr *laddr)
+					       const union inet_addr *laddr)
 {
 	struct sctp_endpoint *retval = NULL;
 
-	if ((htons(ep->base.bind_addr.port) == laddr->v4.sin_port) &&
+	if ((htons(ep->base.bind_addr.port) == laddr->sin.sin_port) &&
 	    net_eq(sock_net(ep->base.sk), net)) {
 		if (sctp_bind_addr_match(&ep->base.bind_addr, laddr,
 					 sctp_sk(ep->base.sk)))
@@ -325,7 +325,7 @@ struct sctp_endpoint *sctp_endpoint_is_match(struct sctp_endpoint *ep,
  */
 static struct sctp_association *__sctp_endpoint_lookup_assoc(
 	const struct sctp_endpoint *ep,
-	const union sctp_addr *paddr,
+	const union inet_addr *paddr,
 	struct sctp_transport **transport)
 {
 	struct sctp_association *asoc = NULL;
@@ -344,7 +344,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 	if (!ep->base.bind_addr.port)
 		goto out;
 
-	rport = ntohs(paddr->v4.sin_port);
+	rport = ntohs(paddr->sin.sin_port);
 
 	hash = sctp_assoc_hashfn(sock_net(ep->base.sk), ep->base.bind_addr.port,
 				 rport);
@@ -370,7 +370,7 @@ out:
 /* Lookup association on an endpoint based on a peer address.  BH-safe.  */
 struct sctp_association *sctp_endpoint_lookup_assoc(
 	const struct sctp_endpoint *ep,
-	const union sctp_addr *paddr,
+	const union inet_addr *paddr,
 	struct sctp_transport **transport)
 {
 	struct sctp_association *asoc;
@@ -386,7 +386,7 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
  * given peer address.
  */
 int sctp_endpoint_is_peeled_off(struct sctp_endpoint *ep,
-				const union sctp_addr *paddr)
+				const union inet_addr *paddr)
 {
 	struct sctp_sockaddr_entry *addr;
 	struct sctp_bind_addr *bp;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 3fa4d85..24619d4 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -68,15 +68,15 @@
 static int sctp_rcv_ootb(struct sk_buff *);
 static struct sctp_association *__sctp_rcv_lookup(struct net *net,
 				      struct sk_buff *skb,
-				      const union sctp_addr *paddr,
-				      const union sctp_addr *laddr,
+				      const union inet_addr *paddr,
+				      const union inet_addr *laddr,
 				      struct sctp_transport **transportp);
 static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
-						const union sctp_addr *laddr);
+						const union inet_addr *laddr);
 static struct sctp_association *__sctp_lookup_association(
 					struct net *net,
-					const union sctp_addr *local,
-					const union sctp_addr *peer,
+					const union inet_addr *local,
+					const union inet_addr *peer,
 					struct sctp_transport **pt);
 
 static int sctp_add_backlog(struct sock *sk, struct sk_buff *skb);
@@ -128,8 +128,8 @@ int sctp_rcv(struct sk_buff *skb)
 	struct sctp_transport *transport = NULL;
 	struct sctp_chunk *chunk;
 	struct sctphdr *sh;
-	union sctp_addr src;
-	union sctp_addr dest;
+	union inet_addr src;
+	union inet_addr dest;
 	int family;
 	struct sctp_af *af;
 	struct net *net = dev_net(skb->dev);
@@ -484,8 +484,8 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
 			     struct sctp_association **app,
 			     struct sctp_transport **tpp)
 {
-	union sctp_addr saddr;
-	union sctp_addr daddr;
+	union inet_addr saddr;
+	union inet_addr daddr;
 	struct sctp_af *af;
 	struct sock *sk = NULL;
 	struct sctp_association *asoc;
@@ -779,14 +779,14 @@ void sctp_unhash_endpoint(struct sctp_endpoint *ep)
 
 /* Look up an endpoint. */
 static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
-						const union sctp_addr *laddr)
+						const union inet_addr *laddr)
 {
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
 	struct sctp_endpoint *ep;
 	int hash;
 
-	hash = sctp_ep_hashfn(net, ntohs(laddr->v4.sin_port));
+	hash = sctp_ep_hashfn(net, ntohs(laddr->sin.sin_port));
 	head = &sctp_ep_hashtable[hash];
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
@@ -867,8 +867,8 @@ void sctp_unhash_established(struct sctp_association *asoc)
 /* Look up an association. */
 static struct sctp_association *__sctp_lookup_association(
 					struct net *net,
-					const union sctp_addr *local,
-					const union sctp_addr *peer,
+					const union inet_addr *local,
+					const union inet_addr *peer,
 					struct sctp_transport **pt)
 {
 	struct sctp_hashbucket *head;
@@ -880,8 +880,8 @@ static struct sctp_association *__sctp_lookup_association(
 	/* Optimize here for direct hit, only listening connections can
 	 * have wildcards anyways.
 	 */
-	hash = sctp_assoc_hashfn(net, ntohs(local->v4.sin_port),
-				 ntohs(peer->v4.sin_port));
+	hash = sctp_assoc_hashfn(net, ntohs(local->sin.sin_port),
+				 ntohs(peer->sin.sin_port));
 	head = &sctp_assoc_hashtable[hash];
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
@@ -905,8 +905,8 @@ hit:
 /* Look up an association. BH-safe. */
 static
 struct sctp_association *sctp_lookup_association(struct net *net,
-						 const union sctp_addr *laddr,
-						 const union sctp_addr *paddr,
+						 const union inet_addr *laddr,
+						 const union inet_addr *paddr,
 						 struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc;
@@ -920,8 +920,8 @@ struct sctp_association *sctp_lookup_association(struct net *net,
 
 /* Is there an association matching the given local and peer addresses? */
 int sctp_has_association(struct net *net,
-			 const union sctp_addr *laddr,
-			 const union sctp_addr *paddr)
+			 const union inet_addr *laddr,
+			 const union inet_addr *paddr)
 {
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
@@ -954,11 +954,11 @@ int sctp_has_association(struct net *net,
  */
 static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 	struct sk_buff *skb,
-	const union sctp_addr *laddr, struct sctp_transport **transportp)
+	const union inet_addr *laddr, struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc;
-	union sctp_addr addr;
-	union sctp_addr *paddr = &addr;
+	union inet_addr addr;
+	union inet_addr *paddr = &addr;
 	struct sctphdr *sh = sctp_hdr(skb);
 	union sctp_params params;
 	sctp_init_chunk_t *init;
@@ -1018,14 +1018,14 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 static struct sctp_association *__sctp_rcv_asconf_lookup(
 					struct net *net,
 					sctp_chunkhdr_t *ch,
-					const union sctp_addr *laddr,
+					const union inet_addr *laddr,
 					__be16 peer_port,
 					struct sctp_transport **transportp)
 {
 	sctp_addip_chunk_t *asconf = (struct sctp_addip_chunk *)ch;
 	struct sctp_af *af;
 	union sctp_addr_param *param;
-	union sctp_addr paddr;
+	union inet_addr paddr;
 
 	/* Skip over the ADDIP header and find the Address parameter */
 	param = (union sctp_addr_param *)(asconf + 1);
@@ -1051,7 +1051,7 @@ static struct sctp_association *__sctp_rcv_asconf_lookup(
 */
 static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 				      struct sk_buff *skb,
-				      const union sctp_addr *laddr,
+				      const union inet_addr *laddr,
 				      struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc = NULL;
@@ -1118,7 +1118,7 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
  */
 static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 				      struct sk_buff *skb,
-				      const union sctp_addr *laddr,
+				      const union inet_addr *laddr,
 				      struct sctp_transport **transportp)
 {
 	sctp_chunkhdr_t *ch;
@@ -1152,8 +1152,8 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 /* Lookup an association for an inbound skb. */
 static struct sctp_association *__sctp_rcv_lookup(struct net *net,
 				      struct sk_buff *skb,
-				      const union sctp_addr *paddr,
-				      const union sctp_addr *laddr,
+				      const union inet_addr *paddr,
+				      const union inet_addr *laddr,
 				      struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 09ffcc9..149d811 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -80,12 +80,12 @@
 
 #include <asm/uaccess.h>
 
-static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
-					 union sctp_addr *s2);
-static void sctp_v6_to_addr(union sctp_addr *addr, struct in6_addr *saddr,
+static inline int sctp_v6_addr_match_len(union inet_addr *s1,
+					 union inet_addr *s2);
+static void sctp_v6_to_addr(union inet_addr *addr, struct in6_addr *saddr,
 			      __be16 port);
-static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
-			    const union sctp_addr *addr2);
+static bool sctp_v6_cmp_addr(const union inet_addr *addr1,
+			     const union inet_addr *addr2);
 
 /* Event handler for inet6 address addition/deletion events.
  * The sctp_local_addr_list needs to be protocted by a spin lock since
@@ -106,10 +106,10 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 	case NETDEV_UP:
 		addr = kmalloc(sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
 		if (addr) {
-			addr->a.v6.sin6_family = AF_INET6;
-			addr->a.v6.sin6_port = 0;
-			addr->a.v6.sin6_addr = ifa->addr;
-			addr->a.v6.sin6_scope_id = ifa->idev->dev->ifindex;
+			addr->a.sin6.sin6_family = AF_INET6;
+			addr->a.sin6.sin6_port = 0;
+			addr->a.sin6.sin6_addr = ifa->addr;
+			addr->a.sin6.sin6_scope_id = ifa->idev->dev->ifindex;
 			addr->valid = 1;
 			spin_lock_bh(&net->sctp.local_addr_lock);
 			list_add_tail_rcu(&addr->list, &net->sctp.local_addr_list);
@@ -122,7 +122,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 		list_for_each_entry_safe(addr, temp,
 					&net->sctp.local_addr_list, list) {
 			if (addr->a.sa.sa_family == AF_INET6 &&
-					ipv6_addr_equal(&addr->a.v6.sin6_addr,
+					ipv6_addr_equal(&addr->a.sin6.sin6_addr,
 						&ifa->addr)) {
 				sctp_addr_wq_mgmt(net, addr, SCTP_ADDR_DEL);
 				found = 1;
@@ -224,13 +224,13 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 	/* Fill in the dest address from the route entry passed with the skb
 	 * and the source address from the transport.
 	 */
-	fl6.daddr = transport->ipaddr.v6.sin6_addr;
-	fl6.saddr = transport->saddr.v6.sin6_addr;
+	fl6.daddr = transport->ipaddr.sin6.sin6_addr;
+	fl6.saddr = transport->saddr.sin6.sin6_addr;
 
 	fl6.flowlabel = np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl6.flowlabel);
 	if (ipv6_addr_type(&fl6.saddr) & IPV6_ADDR_LINKLOCAL)
-		fl6.flowi6_oif = transport->saddr.v6.sin6_scope_id;
+		fl6.flowi6_oif = transport->saddr.sin6.sin6_scope_id;
 	else
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 
@@ -253,7 +253,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 /* Returns the dst cache entry for the given source and destination ip
  * addresses.
  */
-static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
+static void sctp_v6_get_dst(struct sctp_transport *t, union inet_addr *saddr,
 			    struct flowi *fl, struct sock *sk)
 {
 	struct sctp_association *asoc = t->asoc;
@@ -261,19 +261,19 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	struct flowi6 *fl6 = &fl->u.ip6;
 	struct sctp_bind_addr *bp;
 	struct sctp_sockaddr_entry *laddr;
-	union sctp_addr *baddr = NULL;
-	union sctp_addr *daddr = &t->ipaddr;
-	union sctp_addr dst_saddr;
+	union inet_addr *baddr = NULL;
+	union inet_addr *daddr = &t->ipaddr;
+	union inet_addr dst_saddr;
 	__u8 matchlen = 0;
 	__u8 bmatchlen;
 	sctp_scope_t scope;
 
 	memset(fl6, 0, sizeof(struct flowi6));
-	fl6->daddr = daddr->v6.sin6_addr;
-	fl6->fl6_dport = daddr->v6.sin6_port;
+	fl6->daddr = daddr->sin6.sin6_addr;
+	fl6->fl6_dport = daddr->sin6.sin6_port;
 	fl6->flowi6_proto = IPPROTO_SCTP;
-	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		fl6->flowi6_oif = daddr->v6.sin6_scope_id;
+	if (ipv6_addr_type(&daddr->sin6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
+		fl6->flowi6_oif = daddr->sin6.sin6_scope_id;
 
 	pr_debug("%s: dst=%pI6 ", __func__, &fl6->daddr);
 
@@ -281,8 +281,8 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		fl6->fl6_sport = htons(asoc->base.bind_addr.port);
 
 	if (saddr) {
-		fl6->saddr = saddr->v6.sin6_addr;
-		fl6->fl6_sport = saddr->v6.sin6_port;
+		fl6->saddr = saddr->sin6.sin6_addr;
+		fl6->fl6_sport = saddr->sin6.sin6_port;
 
 		pr_debug("src=%pI6 - ", &fl6->saddr);
 	}
@@ -340,8 +340,8 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	}
 	rcu_read_unlock();
 	if (baddr) {
-		fl6->saddr = baddr->v6.sin6_addr;
-		fl6->fl6_sport = baddr->v6.sin6_port;
+		fl6->saddr = baddr->sin6.sin6_addr;
+		fl6->fl6_sport = baddr->sin6.sin6_port;
 		dst = ip6_dst_lookup_flow(sk, fl6, NULL, false);
 	}
 
@@ -364,10 +364,10 @@ out:
 /* Returns the number of consecutive initial bits that match in the 2 ipv6
  * addresses.
  */
-static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
-					 union sctp_addr *s2)
+static inline int sctp_v6_addr_match_len(union inet_addr *s1,
+					 union inet_addr *s2)
 {
-	return ipv6_addr_diff(&s1->v6.sin6_addr, &s2->v6.sin6_addr);
+	return ipv6_addr_diff(&s1->sin6.sin6_addr, &s2->sin6.sin6_addr);
 }
 
 /* Fills in the source address(saddr) based on the destination address(daddr)
@@ -378,13 +378,13 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 			      struct flowi *fl)
 {
 	struct flowi6 *fl6 = &fl->u.ip6;
-	union sctp_addr *saddr = &t->saddr;
+	union inet_addr *saddr = &t->saddr;
 
 	pr_debug("%s: asoc:%p dst:%p\n", __func__, t->asoc, t->dst);
 
 	if (t->dst) {
-		saddr->v6.sin6_family = AF_INET6;
-		saddr->v6.sin6_addr = fl6->saddr;
+		saddr->sin6.sin6_family = AF_INET6;
+		saddr->sin6.sin6_addr = fl6->saddr;
 	}
 }
 
@@ -407,10 +407,10 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 		/* Add the address to the local list.  */
 		addr = kzalloc(sizeof(*addr), GFP_ATOMIC);
 		if (addr) {
-			addr->a.v6.sin6_family = AF_INET6;
-			addr->a.v6.sin6_port = 0;
-			addr->a.v6.sin6_addr = ifp->addr;
-			addr->a.v6.sin6_scope_id = dev->ifindex;
+			addr->a.sin6.sin6_family = AF_INET6;
+			addr->a.sin6.sin6_port = 0;
+			addr->a.sin6.sin6_addr = ifp->addr;
+			addr->a.sin6.sin6_scope_id = dev->ifindex;
 			addr->valid = 1;
 			INIT_LIST_HEAD(&addr->list);
 			list_add_tail(&addr->list, addrlist);
@@ -422,155 +422,132 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 }
 
 /* Initialize a sockaddr_storage from in incoming skb. */
-static void sctp_v6_from_skb(union sctp_addr *addr,struct sk_buff *skb,
+static void sctp_v6_from_skb(union inet_addr *addr,struct sk_buff *skb,
 			     int is_saddr)
 {
 	__be16 *port;
 	struct sctphdr *sh;
 
-	port = &addr->v6.sin6_port;
-	addr->v6.sin6_family = AF_INET6;
-	addr->v6.sin6_flowinfo = 0; /* FIXME */
-	addr->v6.sin6_scope_id = ((struct inet6_skb_parm *)skb->cb)->iif;
+	port = &addr->sin6.sin6_port;
+	addr->sin6.sin6_family = AF_INET6;
+	addr->sin6.sin6_flowinfo = 0; /* FIXME */
+	addr->sin6.sin6_scope_id = ((struct inet6_skb_parm *)skb->cb)->iif;
 
 	sh = sctp_hdr(skb);
 	if (is_saddr) {
 		*port  = sh->source;
-		addr->v6.sin6_addr = ipv6_hdr(skb)->saddr;
+		addr->sin6.sin6_addr = ipv6_hdr(skb)->saddr;
 	} else {
 		*port = sh->dest;
-		addr->v6.sin6_addr = ipv6_hdr(skb)->daddr;
+		addr->sin6.sin6_addr = ipv6_hdr(skb)->daddr;
 	}
 }
 
-/* Initialize an sctp_addr from a socket. */
-static void sctp_v6_from_sk(union sctp_addr *addr, struct sock *sk)
+/* Initialize an inet_addr from a socket. */
+static void sctp_v6_from_sk(union inet_addr *addr, struct sock *sk)
 {
-	addr->v6.sin6_family = AF_INET6;
-	addr->v6.sin6_port = 0;
-	addr->v6.sin6_addr = inet6_sk(sk)->rcv_saddr;
+	addr->sin6.sin6_family = AF_INET6;
+	addr->sin6.sin6_port = 0;
+	addr->sin6.sin6_addr = inet6_sk(sk)->rcv_saddr;
 }
 
-/* Initialize sk->sk_rcv_saddr from sctp_addr. */
-static void sctp_v6_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
+/* Initialize sk->sk_rcv_saddr from inet_addr. */
+static void sctp_v6_to_sk_saddr(union inet_addr *addr, struct sock *sk)
 {
 	if (addr->sa.sa_family == AF_INET && sctp_sk(sk)->v4mapped) {
 		inet6_sk(sk)->rcv_saddr.s6_addr32[0] = 0;
 		inet6_sk(sk)->rcv_saddr.s6_addr32[1] = 0;
 		inet6_sk(sk)->rcv_saddr.s6_addr32[2] = htonl(0x0000ffff);
 		inet6_sk(sk)->rcv_saddr.s6_addr32[3] =
-			addr->v4.sin_addr.s_addr;
+			addr->sin.sin_addr.s_addr;
 	} else {
-		inet6_sk(sk)->rcv_saddr = addr->v6.sin6_addr;
+		inet6_sk(sk)->rcv_saddr = addr->sin6.sin6_addr;
 	}
 }
 
-/* Initialize sk->sk_daddr from sctp_addr. */
-static void sctp_v6_to_sk_daddr(union sctp_addr *addr, struct sock *sk)
+/* Initialize sk->sk_daddr from inet_addr. */
+static void sctp_v6_to_sk_daddr(union inet_addr *addr, struct sock *sk)
 {
 	if (addr->sa.sa_family == AF_INET && sctp_sk(sk)->v4mapped) {
 		inet6_sk(sk)->daddr.s6_addr32[0] = 0;
 		inet6_sk(sk)->daddr.s6_addr32[1] = 0;
 		inet6_sk(sk)->daddr.s6_addr32[2] = htonl(0x0000ffff);
-		inet6_sk(sk)->daddr.s6_addr32[3] = addr->v4.sin_addr.s_addr;
+		inet6_sk(sk)->daddr.s6_addr32[3] = addr->sin.sin_addr.s_addr;
 	} else {
-		inet6_sk(sk)->daddr = addr->v6.sin6_addr;
+		inet6_sk(sk)->daddr = addr->sin6.sin6_addr;
 	}
 }
 
-/* Initialize a sctp_addr from an address parameter. */
-static void sctp_v6_from_addr_param(union sctp_addr *addr,
+/* Initialize a inet_addr from an address parameter. */
+static void sctp_v6_from_addr_param(union inet_addr *addr,
 				    union sctp_addr_param *param,
 				    __be16 port, int iif)
 {
-	addr->v6.sin6_family = AF_INET6;
-	addr->v6.sin6_port = port;
-	addr->v6.sin6_flowinfo = 0; /* BUG */
-	addr->v6.sin6_addr = param->v6.addr;
-	addr->v6.sin6_scope_id = iif;
+	addr->sin6.sin6_family = AF_INET6;
+	addr->sin6.sin6_port = port;
+	addr->sin6.sin6_flowinfo = 0; /* BUG */
+	addr->sin6.sin6_addr = param->v6.addr;
+	addr->sin6.sin6_scope_id = iif;
 }
 
-/* Initialize an address parameter from a sctp_addr and return the length
+/* Initialize an address parameter from a inet_addr and return the length
  * of the address parameter.
  */
-static int sctp_v6_to_addr_param(const union sctp_addr *addr,
+static int sctp_v6_to_addr_param(const union inet_addr *addr,
 				 union sctp_addr_param *param)
 {
 	int length = sizeof(sctp_ipv6addr_param_t);
 
 	param->v6.param_hdr.type = SCTP_PARAM_IPV6_ADDRESS;
 	param->v6.param_hdr.length = htons(length);
-	param->v6.addr = addr->v6.sin6_addr;
+	param->v6.addr = addr->sin6.sin6_addr;
 
 	return length;
 }
 
-/* Initialize a sctp_addr from struct in6_addr. */
-static void sctp_v6_to_addr(union sctp_addr *addr, struct in6_addr *saddr,
+/* Initialize a inet_addr from struct in6_addr. */
+static void sctp_v6_to_addr(union inet_addr *addr, struct in6_addr *saddr,
 			      __be16 port)
 {
 	addr->sa.sa_family = AF_INET6;
-	addr->v6.sin6_port = port;
-	addr->v6.sin6_addr = *saddr;
+	addr->sin6.sin6_port = port;
+	addr->sin6.sin6_addr = *saddr;
 }
 
 /* Compare addresses exactly.
  * v4-mapped-v6 is also in consideration.
  */
-static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
-			    const union sctp_addr *addr2)
+static bool sctp_v6_cmp_addr(const union inet_addr *addr1,
+			     const union inet_addr *addr2)
 {
 	if (addr1->sa.sa_family != addr2->sa.sa_family) {
 		if (addr1->sa.sa_family == AF_INET &&
 		    addr2->sa.sa_family == AF_INET6 &&
-		    ipv6_addr_v4mapped(&addr2->v6.sin6_addr)) {
-			if (addr2->v6.sin6_port == addr1->v4.sin_port &&
-			    addr2->v6.sin6_addr.s6_addr32[3] ==
-			    addr1->v4.sin_addr.s_addr)
+		    ipv6_addr_v4mapped(&addr2->sin6.sin6_addr)) {
+			if (addr2->sin6.sin6_port == addr1->sin.sin_port &&
+			    addr2->sin6.sin6_addr.s6_addr32[3] ==
+			    addr1->sin.sin_addr.s_addr)
 				return 1;
 		}
 		if (addr2->sa.sa_family == AF_INET &&
 		    addr1->sa.sa_family == AF_INET6 &&
-		    ipv6_addr_v4mapped(&addr1->v6.sin6_addr)) {
-			if (addr1->v6.sin6_port == addr2->v4.sin_port &&
-			    addr1->v6.sin6_addr.s6_addr32[3] ==
-			    addr2->v4.sin_addr.s_addr)
+		    ipv6_addr_v4mapped(&addr1->sin6.sin6_addr)) {
+			if (addr1->sin6.sin6_port == addr2->sin.sin_port &&
+			    addr1->sin6.sin6_addr.s6_addr32[3] ==
+			    addr2->sin.sin_addr.s_addr)
 				return 1;
 		}
 		return 0;
 	}
-	if (!ipv6_addr_equal(&addr1->v6.sin6_addr, &addr2->v6.sin6_addr))
-		return 0;
-	/* If this is a linklocal address, compare the scope_id. */
-	if (ipv6_addr_type(&addr1->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
-		if (addr1->v6.sin6_scope_id && addr2->v6.sin6_scope_id &&
-		    (addr1->v6.sin6_scope_id != addr2->v6.sin6_scope_id)) {
-			return 0;
-		}
-	}
-
-	return 1;
-}
 
-/* Initialize addr struct to INADDR_ANY. */
-static void sctp_v6_inaddr_any(union sctp_addr *addr, __be16 port)
-{
-	memset(addr, 0x00, sizeof(union sctp_addr));
-	addr->v6.sin6_family = AF_INET6;
-	addr->v6.sin6_port = port;
-}
-
-/* Is this a wildcard address? */
-static int sctp_v6_is_any(const union sctp_addr *addr)
-{
-	return ipv6_addr_any(&addr->v6.sin6_addr);
+	return inet_addr_equal(addr1, addr2);
 }
 
 /* Should this be available for binding?   */
-static int sctp_v6_available(union sctp_addr *addr, struct sctp_sock *sp)
+static int sctp_v6_available(union inet_addr *addr, struct sctp_sock *sp)
 {
 	int type;
-	const struct in6_addr *in6 = (const struct in6_addr *)&addr->v6.sin6_addr;
+	const struct in6_addr *in6 = (const struct in6_addr *)&addr->sin6.sin6_addr;
 
 	type = ipv6_addr_type(in6);
 	if (IPV6_ADDR_ANY == type)
@@ -596,11 +573,11 @@ static int sctp_v6_available(union sctp_addr *addr, struct sctp_sock *sp)
  * Return 0 - If the address is a non-unicast or an illegal address.
  * Return 1 - If the address is a unicast.
  */
-static int sctp_v6_addr_valid(union sctp_addr *addr,
+static int sctp_v6_addr_valid(union inet_addr *addr,
 			      struct sctp_sock *sp,
 			      const struct sk_buff *skb)
 {
-	int ret = ipv6_addr_type(&addr->v6.sin6_addr);
+	int ret = ipv6_addr_type(&addr->sin6.sin6_addr);
 
 	/* Support v4-mapped-v6 address. */
 	if (ret == IPV6_ADDR_MAPPED) {
@@ -623,7 +600,7 @@ static int sctp_v6_addr_valid(union sctp_addr *addr,
 }
 
 /* What is the scope of 'addr'?  */
-static sctp_scope_t sctp_v6_scope(union sctp_addr *addr)
+static sctp_scope_t sctp_v6_scope(union inet_addr *addr)
 {
 	int v6scope;
 	sctp_scope_t retval;
@@ -632,7 +609,7 @@ static sctp_scope_t sctp_v6_scope(union sctp_addr *addr)
 	 * See IFA_* in <net/if_inet6.h>.  Map to a generic SCTP scope.
 	 */
 
-	v6scope = ipv6_addr_scope(&addr->v6.sin6_addr);
+	v6scope = ipv6_addr_scope(&addr->sin6.sin6_addr);
 	switch (v6scope) {
 	case IFA_HOST:
 		retval = SCTP_SCOPE_LOOPBACK;
@@ -694,7 +671,7 @@ out:
 }
 
 /* Map v4 address to mapped v6 address */
-static void sctp_v6_addr_v4map(struct sctp_sock *sp, union sctp_addr *addr)
+static void sctp_v6_addr_v4map(struct sctp_sock *sp, union inet_addr *addr)
 {
 	if (sp->v4mapped && AF_INET == addr->sa.sa_family)
 		sctp_v4_map_v6(addr);
@@ -713,12 +690,6 @@ static int sctp_v6_is_ce(const struct sk_buff *skb)
 	return *((__u32 *)(ipv6_hdr(skb))) & htonl(1 << 20);
 }
 
-/* Dump the v6 addr to the seq file. */
-static void sctp_v6_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
-{
-	seq_printf(seq, "%pI6 ", &addr->v6.sin6_addr);
-}
-
 static void sctp_v6_ecn_capable(struct sock *sk)
 {
 	inet6_sk(sk)->tclass |= INET_ECN_ECT_0;
@@ -743,7 +714,7 @@ static void sctp_inet6_event_msgname(struct sctp_ulpevent *event,
 	struct sockaddr_in6 *sin6, *sin6from;
 
 	if (msgname) {
-		union sctp_addr *addr;
+		union inet_addr *addr;
 		struct sctp_association *asoc;
 
 		asoc = event->asoc;
@@ -759,13 +730,13 @@ static void sctp_inet6_event_msgname(struct sctp_ulpevent *event,
 		/* Map ipv4 address into v4-mapped-on-v6 address.  */
 		if (sctp_sk(asoc->base.sk)->v4mapped &&
 		    AF_INET == addr->sa.sa_family) {
-			sctp_v4_map_v6((union sctp_addr *)sin6);
+			sctp_v4_map_v6((union inet_addr *)sin6);
 			sin6->sin6_addr.s6_addr32[3] =
-				addr->v4.sin_addr.s_addr;
+				addr->sin.sin_addr.s_addr;
 			return;
 		}
 
-		sin6from = &asoc->peer.primary_addr.v6;
+		sin6from = &asoc->peer.primary_addr.sin6;
 		sin6->sin6_addr = sin6from->sin6_addr;
 		if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 			sin6->sin6_scope_id = sin6from->sin6_scope_id;
@@ -788,7 +759,7 @@ static void sctp_inet6_skb_msgname(struct sk_buff *skb, char *msgname,
 		/* Map ipv4 address into v4-mapped-on-v6 address. */
 		if (sctp_sk(skb->sk)->v4mapped &&
 		    ip_hdr(skb)->version == 4) {
-			sctp_v4_map_v6((union sctp_addr *)sin6);
+			sctp_v4_map_v6((union inet_addr *)sin6);
 			sin6->sin6_addr.s6_addr32[3] = ip_hdr(skb)->saddr;
 			return;
 		}
@@ -821,8 +792,8 @@ static int sctp_inet6_af_supported(sa_family_t family, struct sctp_sock *sp)
  * of indirection lets us choose whether a PF_INET6 should
  * disallow any v4 addresses if we so choose.
  */
-static int sctp_inet6_cmp_addr(const union sctp_addr *addr1,
-			       const union sctp_addr *addr2,
+static int sctp_inet6_cmp_addr(const union inet_addr *addr1,
+			       const union inet_addr *addr2,
 			       struct sctp_sock *opt)
 {
 	struct sctp_af *af1, *af2;
@@ -839,7 +810,7 @@ static int sctp_inet6_cmp_addr(const union sctp_addr *addr1,
 		return 0;
 
 	/* Today, wildcard AF_INET/AF_INET6. */
-	if (sctp_is_any(sk, addr1) || sctp_is_any(sk, addr2))
+	if (inet_addr_any(addr1) || inet_addr_any(addr2))
 		return 1;
 
 	if (addr1->sa.sa_family != addr2->sa.sa_family)
@@ -851,7 +822,7 @@ static int sctp_inet6_cmp_addr(const union sctp_addr *addr1,
 /* Verify that the provided sockaddr looks bindable.   Common verification,
  * has already been taken care of.
  */
-static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
+static int sctp_inet6_bind_verify(struct sctp_sock *opt, union inet_addr *addr)
 {
 	struct sctp_af *af;
 
@@ -859,18 +830,18 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 	if (addr->sa.sa_family != AF_INET6)
 		af = sctp_get_af_specific(addr->sa.sa_family);
 	else {
-		int type = ipv6_addr_type(&addr->v6.sin6_addr);
+		int type = ipv6_addr_type(&addr->sin6.sin6_addr);
 		struct net_device *dev;
 
 		if (type & IPV6_ADDR_LINKLOCAL) {
 			struct net *net;
-			if (!addr->v6.sin6_scope_id)
+			if (!addr->sin6.sin6_scope_id)
 				return 0;
 			net = sock_net(&opt->inet.sk);
 			rcu_read_lock();
-			dev = dev_get_by_index_rcu(net, addr->v6.sin6_scope_id);
+			dev = dev_get_by_index_rcu(net, addr->sin6.sin6_scope_id);
 			if (!dev ||
-			    !ipv6_chk_addr(net, &addr->v6.sin6_addr, dev, 0)) {
+			    !ipv6_chk_addr(net, &addr->sin6.sin6_addr, dev, 0)) {
 				rcu_read_unlock();
 				return 0;
 			}
@@ -888,7 +859,7 @@ static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 /* Verify that the provided sockaddr looks sendable.   Common verification,
  * has already been taken care of.
  */
-static int sctp_inet6_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
+static int sctp_inet6_send_verify(struct sctp_sock *opt, union inet_addr *addr)
 {
 	struct sctp_af *af = NULL;
 
@@ -896,15 +867,15 @@ static int sctp_inet6_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
 	if (addr->sa.sa_family != AF_INET6)
 		af = sctp_get_af_specific(addr->sa.sa_family);
 	else {
-		int type = ipv6_addr_type(&addr->v6.sin6_addr);
+		int type = ipv6_addr_type(&addr->sin6.sin6_addr);
 		struct net_device *dev;
 
 		if (type & IPV6_ADDR_LINKLOCAL) {
-			if (!addr->v6.sin6_scope_id)
+			if (!addr->sin6.sin6_scope_id)
 				return 0;
 			rcu_read_lock();
 			dev = dev_get_by_index_rcu(sock_net(&opt->inet.sk),
-						   addr->v6.sin6_scope_id);
+						   addr->sin6.sin6_scope_id);
 			rcu_read_unlock();
 			if (!dev)
 				return 0;
@@ -1001,12 +972,9 @@ static struct sctp_af sctp_af_inet6 = {
 	.cmp_addr	   = sctp_v6_cmp_addr,
 	.scope		   = sctp_v6_scope,
 	.addr_valid	   = sctp_v6_addr_valid,
-	.inaddr_any	   = sctp_v6_inaddr_any,
-	.is_any		   = sctp_v6_is_any,
 	.available	   = sctp_v6_available,
 	.skb_iif	   = sctp_v6_skb_iif,
 	.is_ce		   = sctp_v6_is_ce,
-	.seq_dump_addr	   = sctp_v6_seq_dump_addr,
 	.ecn_capable	   = sctp_v6_ecn_capable,
 	.net_header_len	   = sizeof(struct ipv6hdr),
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index ef9e2bb..fb13b89 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -63,7 +63,7 @@ static int sctp_acked(struct sctp_sackhdr *sack, __u32 tsn);
 static void sctp_check_transmitted(struct sctp_outq *q,
 				   struct list_head *transmitted_queue,
 				   struct sctp_transport *transport,
-				   union sctp_addr *saddr,
+				   union inet_addr *saddr,
 				   struct sctp_sackhdr *sack,
 				   __u32 *highest_new_tsn);
 
@@ -1321,7 +1321,7 @@ int sctp_outq_is_empty(const struct sctp_outq *q)
 static void sctp_check_transmitted(struct sctp_outq *q,
 				   struct list_head *transmitted_queue,
 				   struct sctp_transport *transport,
-				   union sctp_addr *saddr,
+				   union inet_addr *saddr,
 				   struct sctp_sackhdr *sack,
 				   __u32 *highest_new_tsn_in_sack)
 {
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 62526c4..0a597e8 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -130,7 +130,7 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 	struct sctp_association *asoc;
 	struct sctp_sockaddr_entry *laddr;
 	struct sctp_transport *peer;
-	union sctp_addr *addr, *primary = NULL;
+	union inet_addr *addr, *primary = NULL;
 	struct sctp_af *af;
 
 	if (epb->type == SCTP_EP_TYPE_ASSOCIATION) {
@@ -155,7 +155,7 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 		if (primary && af->cmp_addr(addr, primary)) {
 			seq_printf(seq, "*");
 		}
-		af->seq_dump_addr(seq, addr);
+		seq_printf(seq, "%pIA ", &addr);
 	}
 	rcu_read_unlock();
 }
@@ -164,7 +164,7 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_association *assoc)
 {
 	struct sctp_transport *transport;
-	union sctp_addr *addr, *primary;
+	union inet_addr *addr, *primary;
 	struct sctp_af *af;
 
 	primary = &assoc->peer.primary_addr;
@@ -179,7 +179,7 @@ static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_associa
 		if (af->cmp_addr(addr, primary)) {
 			seq_printf(seq, "*");
 		}
-		af->seq_dump_addr(seq, addr);
+		seq_printf(seq, "%pIA ", addr);
 	}
 	rcu_read_unlock();
 }
@@ -468,7 +468,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 			/*
 			 * The remote address (ADDR)
 			 */
-			tsp->af_specific->seq_dump_addr(seq, &tsp->ipaddr);
+			seq_printf(seq, "%pIA ", &tsp->ipaddr);
 			seq_printf(seq, " ");
 
 			/*
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index f8953c2..0eef603 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -155,9 +155,9 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
 		/* Add the address to the local list.  */
 		addr = kzalloc(sizeof(*addr), GFP_ATOMIC);
 		if (addr) {
-			addr->a.v4.sin_family = AF_INET;
-			addr->a.v4.sin_port = 0;
-			addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
+			addr->a.sa.sa_family = AF_INET;
+			addr->a.sin.sin_port = 0;
+			addr->a.sin.sin_addr.s_addr = ifa->ifa_local;
 			addr->valid = 1;
 			INIT_LIST_HEAD(&addr->list);
 			list_add_tail(&addr->list, addrlist);
@@ -233,16 +233,16 @@ end_copy:
 	return error;
 }
 
-/* Initialize a sctp_addr from in incoming skb.  */
-static void sctp_v4_from_skb(union sctp_addr *addr, struct sk_buff *skb,
+/* Initialize a inet_addr from in incoming skb.  */
+static void sctp_v4_from_skb(union inet_addr *addr, struct sk_buff *skb,
 			     int is_saddr)
 {
 	void *from;
 	__be16 *port;
 	struct sctphdr *sh;
 
-	port = &addr->v4.sin_port;
-	addr->v4.sin_family = AF_INET;
+	port = &addr->sin.sin_port;
+	addr->sa.sa_family = AF_INET;
 
 	sh = sctp_hdr(skb);
 	if (is_saddr) {
@@ -252,89 +252,61 @@ static void sctp_v4_from_skb(union sctp_addr *addr, struct sk_buff *skb,
 		*port = sh->dest;
 		from = &ip_hdr(skb)->daddr;
 	}
-	memcpy(&addr->v4.sin_addr.s_addr, from, sizeof(struct in_addr));
+	memcpy(&addr->sin.sin_addr.s_addr, from, sizeof(struct in_addr));
 }
 
-/* Initialize an sctp_addr from a socket. */
-static void sctp_v4_from_sk(union sctp_addr *addr, struct sock *sk)
+/* Initialize an inet_addr from a socket. */
+static void sctp_v4_from_sk(union inet_addr *addr, struct sock *sk)
 {
-	addr->v4.sin_family = AF_INET;
-	addr->v4.sin_port = 0;
-	addr->v4.sin_addr.s_addr = inet_sk(sk)->inet_rcv_saddr;
+	addr->sa.sa_family = AF_INET;
+	addr->sin.sin_port = 0;
+	addr->sin.sin_addr.s_addr = inet_sk(sk)->inet_rcv_saddr;
 }
 
-/* Initialize sk->sk_rcv_saddr from sctp_addr. */
-static void sctp_v4_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
+/* Initialize sk->sk_rcv_saddr from inet_addr. */
+static void sctp_v4_to_sk_saddr(union inet_addr *addr, struct sock *sk)
 {
-	inet_sk(sk)->inet_rcv_saddr = addr->v4.sin_addr.s_addr;
+	inet_sk(sk)->inet_rcv_saddr = addr->sin.sin_addr.s_addr;
 }
 
-/* Initialize sk->sk_daddr from sctp_addr. */
-static void sctp_v4_to_sk_daddr(union sctp_addr *addr, struct sock *sk)
+/* Initialize sk->sk_daddr from inet_addr. */
+static void sctp_v4_to_sk_daddr(union inet_addr *addr, struct sock *sk)
 {
-	inet_sk(sk)->inet_daddr = addr->v4.sin_addr.s_addr;
+	inet_sk(sk)->inet_daddr = addr->sin.sin_addr.s_addr;
 }
 
-/* Initialize a sctp_addr from an address parameter. */
-static void sctp_v4_from_addr_param(union sctp_addr *addr,
+/* Initialize a inet_addr from an address parameter. */
+static void sctp_v4_from_addr_param(union inet_addr *addr,
 				    union sctp_addr_param *param,
 				    __be16 port, int iif)
 {
-	addr->v4.sin_family = AF_INET;
-	addr->v4.sin_port = port;
-	addr->v4.sin_addr.s_addr = param->v4.addr.s_addr;
+	addr->sa.sa_family = AF_INET;
+	addr->sin.sin_port = port;
+	addr->sin.sin_addr.s_addr = param->v4.addr.s_addr;
 }
 
-/* Initialize an address parameter from a sctp_addr and return the length
+/* Initialize an address parameter from a inet_addr and return the length
  * of the address parameter.
  */
-static int sctp_v4_to_addr_param(const union sctp_addr *addr,
+static int sctp_v4_to_addr_param(const union inet_addr *addr,
 				 union sctp_addr_param *param)
 {
 	int length = sizeof(sctp_ipv4addr_param_t);
 
 	param->v4.param_hdr.type = SCTP_PARAM_IPV4_ADDRESS;
 	param->v4.param_hdr.length = htons(length);
-	param->v4.addr.s_addr = addr->v4.sin_addr.s_addr;
+	param->v4.addr.s_addr = addr->sin.sin_addr.s_addr;
 
 	return length;
 }
 
-/* Initialize a sctp_addr from a dst_entry. */
-static void sctp_v4_dst_saddr(union sctp_addr *saddr, struct flowi4 *fl4,
+/* Initialize a inet_addr from a dst_entry. */
+static void sctp_v4_dst_saddr(union inet_addr *saddr, struct flowi4 *fl4,
 			      __be16 port)
 {
-	saddr->v4.sin_family = AF_INET;
-	saddr->v4.sin_port = port;
-	saddr->v4.sin_addr.s_addr = fl4->saddr;
-}
-
-/* Compare two addresses exactly. */
-static int sctp_v4_cmp_addr(const union sctp_addr *addr1,
-			    const union sctp_addr *addr2)
-{
-	if (addr1->sa.sa_family != addr2->sa.sa_family)
-		return 0;
-	if (addr1->v4.sin_port != addr2->v4.sin_port)
-		return 0;
-	if (addr1->v4.sin_addr.s_addr != addr2->v4.sin_addr.s_addr)
-		return 0;
-
-	return 1;
-}
-
-/* Initialize addr struct to INADDR_ANY. */
-static void sctp_v4_inaddr_any(union sctp_addr *addr, __be16 port)
-{
-	addr->v4.sin_family = AF_INET;
-	addr->v4.sin_addr.s_addr = htonl(INADDR_ANY);
-	addr->v4.sin_port = port;
-}
-
-/* Is this a wildcard address? */
-static int sctp_v4_is_any(const union sctp_addr *addr)
-{
-	return htonl(INADDR_ANY) == addr->v4.sin_addr.s_addr;
+	saddr->sin.sin_family = AF_INET;
+	saddr->sin.sin_port = port;
+	saddr->sin.sin_addr.s_addr = fl4->saddr;
 }
 
 /* This function checks if the address is a valid address to be used for
@@ -344,7 +316,7 @@ static int sctp_v4_is_any(const union sctp_addr *addr)
  * Return 0 - If the address is a non-unicast or an illegal address.
  * Return 1 - If the address is a unicast.
  */
-static int sctp_v4_addr_valid(union sctp_addr *addr,
+static int sctp_v4_addr_valid(union inet_addr *addr,
 			      struct sctp_sock *sp,
 			      const struct sk_buff *skb)
 {
@@ -353,7 +325,7 @@ static int sctp_v4_addr_valid(union sctp_addr *addr,
 		return 0;
 
 	/* Is this a non-unicast address or a unusable SCTP address? */
-	if (IS_IPV4_UNUSABLE_ADDRESS(addr->v4.sin_addr.s_addr))
+	if (IS_IPV4_UNUSABLE_ADDRESS(addr->sin.sin_addr.s_addr))
 		return 0;
 
 	/* Is this a broadcast address? */
@@ -364,13 +336,13 @@ static int sctp_v4_addr_valid(union sctp_addr *addr,
 }
 
 /* Should this be available for binding?   */
-static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
+static int sctp_v4_available(union inet_addr *addr, struct sctp_sock *sp)
 {
 	struct net *net = sock_net(&sp->inet.sk);
-	int ret = inet_addr_type(net, addr->v4.sin_addr.s_addr);
+	int ret = inet_addr_type(net, addr->sin.sin_addr.s_addr);
 
 
-	if (addr->v4.sin_addr.s_addr != htonl(INADDR_ANY) &&
+	if (addr->sin.sin_addr.s_addr != htonl(INADDR_ANY) &&
 	   ret != RTN_LOCAL &&
 	   !sp->inet.freebind &&
 	   !sysctl_ip_nonlocal_bind)
@@ -399,20 +371,20 @@ static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
  * IPv4 scoping can be controlled through sysctl option
  * net.sctp.addr_scope_policy
  */
-static sctp_scope_t sctp_v4_scope(union sctp_addr *addr)
+static sctp_scope_t sctp_v4_scope(union inet_addr *addr)
 {
 	sctp_scope_t retval;
 
 	/* Check for unusable SCTP addresses. */
-	if (IS_IPV4_UNUSABLE_ADDRESS(addr->v4.sin_addr.s_addr)) {
+	if (IS_IPV4_UNUSABLE_ADDRESS(addr->sin.sin_addr.s_addr)) {
 		retval =  SCTP_SCOPE_UNUSABLE;
-	} else if (ipv4_is_loopback(addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_is_loopback(addr->sin.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_LOOPBACK;
-	} else if (ipv4_is_linklocal_169(addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_is_linklocal_169(addr->sin.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_LINK;
-	} else if (ipv4_is_private_10(addr->v4.sin_addr.s_addr) ||
-		   ipv4_is_private_172(addr->v4.sin_addr.s_addr) ||
-		   ipv4_is_private_192(addr->v4.sin_addr.s_addr)) {
+	} else if (ipv4_is_private_10(addr->sin.sin_addr.s_addr) ||
+		   ipv4_is_private_172(addr->sin.sin_addr.s_addr) ||
+		   ipv4_is_private_192(addr->sin.sin_addr.s_addr)) {
 		retval = SCTP_SCOPE_PRIVATE;
 	} else {
 		retval = SCTP_SCOPE_GLOBAL;
@@ -425,7 +397,7 @@ static sctp_scope_t sctp_v4_scope(union sctp_addr *addr)
  * addresses. If an association is passed, trys to get a dst entry with a
  * source address that matches an address in the bind address list.
  */
-static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
+static void sctp_v4_get_dst(struct sctp_transport *t, union inet_addr *saddr,
 				struct flowi *fl, struct sock *sk)
 {
 	struct sctp_association *asoc = t->asoc;
@@ -434,12 +406,12 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	struct sctp_bind_addr *bp;
 	struct sctp_sockaddr_entry *laddr;
 	struct dst_entry *dst = NULL;
-	union sctp_addr *daddr = &t->ipaddr;
-	union sctp_addr dst_saddr;
+	union inet_addr *daddr = &t->ipaddr;
+	union inet_addr dst_saddr;
 
 	memset(fl4, 0x0, sizeof(struct flowi4));
-	fl4->daddr  = daddr->v4.sin_addr.s_addr;
-	fl4->fl4_dport = daddr->v4.sin_port;
+	fl4->daddr  = daddr->sin.sin_addr.s_addr;
+	fl4->fl4_dport = daddr->sin.sin_port;
 	fl4->flowi4_proto = IPPROTO_SCTP;
 	if (asoc) {
 		fl4->flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
@@ -447,8 +419,8 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		fl4->fl4_sport = htons(asoc->base.bind_addr.port);
 	}
 	if (saddr) {
-		fl4->saddr = saddr->v4.sin_addr.s_addr;
-		fl4->fl4_sport = saddr->v4.sin_port;
+		fl4->saddr = saddr->sin.sin_addr.s_addr;
+		fl4->fl4_sport = saddr->sin.sin_port;
 	}
 
 	pr_debug("%s: dst:%pI4, src:%pI4 - ", __func__, &fl4->daddr,
@@ -477,7 +449,7 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 			    (laddr->state != SCTP_ADDR_SRC &&
 			    !asoc->src_out_of_asoc_ok))
 				continue;
-			if (sctp_v4_cmp_addr(&dst_saddr, &laddr->a))
+			if (inet_addr_equal_strict(&dst_saddr, &laddr->a))
 				goto out_unlock;
 		}
 		rcu_read_unlock();
@@ -498,8 +470,8 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 			continue;
 		if ((laddr->state == SCTP_ADDR_SRC) &&
 		    (AF_INET == laddr->a.sa.sa_family)) {
-			fl4->saddr = laddr->a.v4.sin_addr.s_addr;
-			fl4->fl4_sport = laddr->a.v4.sin_port;
+			fl4->saddr = laddr->a.sin.sin_addr.s_addr;
+			fl4->fl4_sport = laddr->a.sin.sin_port;
 			rt = ip_route_output_key(sock_net(sk), fl4);
 			if (!IS_ERR(rt)) {
 				dst = &rt->dst;
@@ -526,12 +498,12 @@ static void sctp_v4_get_saddr(struct sctp_sock *sk,
 			      struct sctp_transport *t,
 			      struct flowi *fl)
 {
-	union sctp_addr *saddr = &t->saddr;
+	union inet_addr *saddr = &t->saddr;
 	struct rtable *rt = (struct rtable *)t->dst;
 
 	if (rt) {
-		saddr->v4.sin_family = AF_INET;
-		saddr->v4.sin_addr.s_addr = fl->u.ip4.saddr;
+		saddr->sa.sa_family = AF_INET;
+		saddr->sin.sin_addr.s_addr = fl->u.ip4.saddr;
 	}
 }
 
@@ -565,7 +537,7 @@ static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
 
 	newinet = inet_sk(newsk);
 
-	newinet->inet_daddr = asoc->peer.primary_addr.v4.sin_addr.s_addr;
+	newinet->inet_daddr = asoc->peer.primary_addr.sin.sin_addr.s_addr;
 
 	sk_refcnt_debug_inc(newsk);
 
@@ -579,17 +551,11 @@ out:
 }
 
 /* Map address, empty for v4 family */
-static void sctp_v4_addr_v4map(struct sctp_sock *sp, union sctp_addr *addr)
+static void sctp_v4_addr_v4map(struct sctp_sock *sp, union inet_addr *addr)
 {
 	/* Empty */
 }
 
-/* Dump the v4 addr to the seq file. */
-static void sctp_v4_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
-{
-	seq_printf(seq, "%pI4 ", &addr->v4.sin_addr);
-}
-
 static void sctp_v4_ecn_capable(struct sock *sk)
 {
 	INET_ECN_xmit(sk);
@@ -614,11 +580,11 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
 		if (addrw->a.sa.sa_family == AF_INET6) {
 			struct in6_addr *in6;
 
-			if (ipv6_addr_type(&addrw->a.v6.sin6_addr) &
+			if (ipv6_addr_type(&addrw->a.sin6.sin6_addr) &
 			    IPV6_ADDR_LINKLOCAL)
 				goto free_next;
 
-			in6 = (struct in6_addr *)&addrw->a.v6.sin6_addr;
+			in6 = (struct in6_addr *)&addrw->a.sin6.sin6_addr;
 			if (ipv6_chk_addr(net, in6, NULL, 0) == 0 &&
 			    addrw->state == SCTP_ADDR_NEW) {
 				unsigned long timeo_val;
@@ -678,17 +644,8 @@ static struct sctp_sockaddr_entry *sctp_addr_wq_lookup(struct net *net,
 	struct sctp_sockaddr_entry *addrw;
 
 	list_for_each_entry(addrw, &net->sctp.addr_waitq, list) {
-		if (addrw->a.sa.sa_family != addr->a.sa.sa_family)
-			continue;
-		if (addrw->a.sa.sa_family == AF_INET) {
-			if (addrw->a.v4.sin_addr.s_addr ==
-			    addr->a.v4.sin_addr.s_addr)
-				return addrw;
-		} else if (addrw->a.sa.sa_family == AF_INET6) {
-			if (ipv6_addr_equal(&addrw->a.v6.sin6_addr,
-			    &addr->a.v6.sin6_addr))
-				return addrw;
-		}
+		if (inet_addr_equal(&addrw->a, &addr->a))
+			return addrw;
 	}
 	return NULL;
 }
@@ -759,9 +716,9 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 	case NETDEV_UP:
 		addr = kmalloc(sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
 		if (addr) {
-			addr->a.v4.sin_family = AF_INET;
-			addr->a.v4.sin_port = 0;
-			addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
+			addr->a.sa.sa_family = AF_INET;
+			addr->a.sin.sin_port = 0;
+			addr->a.sin.sin_addr.s_addr = ifa->ifa_local;
 			addr->valid = 1;
 			spin_lock_bh(&net->sctp.local_addr_lock);
 			list_add_tail_rcu(&addr->list, &net->sctp.local_addr_list);
@@ -774,7 +731,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 		list_for_each_entry_safe(addr, temp,
 					&net->sctp.local_addr_list, list) {
 			if (addr->a.sa.sa_family == AF_INET &&
-					addr->a.v4.sin_addr.s_addr ==
+					addr->a.sin.sin_addr.s_addr ==
 					ifa->ifa_local) {
 				sctp_addr_wq_mgmt(net, addr, SCTP_ADDR_DEL);
 				found = 1;
@@ -881,7 +838,7 @@ static void sctp_inet_event_msgname(struct sctp_ulpevent *event, char *msgname,
 		asoc = event->asoc;
 		sctp_inet_msgname(msgname, addr_len);
 		sin = (struct sockaddr_in *)msgname;
-		sinfrom = &asoc->peer.primary_addr.v4;
+		sinfrom = &asoc->peer.primary_addr.sin;
 		sin->sin_port = htons(asoc->peer.port);
 		sin->sin_addr.s_addr = sinfrom->sin_addr.s_addr;
 	}
@@ -908,17 +865,17 @@ static int sctp_inet_af_supported(sa_family_t family, struct sctp_sock *sp)
 }
 
 /* Address matching with wildcards allowed. */
-static int sctp_inet_cmp_addr(const union sctp_addr *addr1,
-			      const union sctp_addr *addr2,
+static int sctp_inet_cmp_addr(const union inet_addr *addr1,
+			      const union inet_addr *addr2,
 			      struct sctp_sock *opt)
 {
 	/* PF_INET only supports AF_INET addresses. */
 	if (addr1->sa.sa_family != addr2->sa.sa_family)
 		return 0;
-	if (htonl(INADDR_ANY) == addr1->v4.sin_addr.s_addr ||
-	    htonl(INADDR_ANY) == addr2->v4.sin_addr.s_addr)
+	if (htonl(INADDR_ANY) == addr1->sin.sin_addr.s_addr ||
+	    htonl(INADDR_ANY) == addr2->sin.sin_addr.s_addr)
 		return 1;
-	if (addr1->v4.sin_addr.s_addr == addr2->v4.sin_addr.s_addr)
+	if (addr1->sin.sin_addr.s_addr == addr2->sin.sin_addr.s_addr)
 		return 1;
 
 	return 0;
@@ -927,7 +884,7 @@ static int sctp_inet_cmp_addr(const union sctp_addr *addr1,
 /* Verify that provided sockaddr looks bindable.  Common verification has
  * already been taken care of.
  */
-static int sctp_inet_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
+static int sctp_inet_bind_verify(struct sctp_sock *opt, union inet_addr *addr)
 {
 	return sctp_v4_available(addr, opt);
 }
@@ -935,7 +892,7 @@ static int sctp_inet_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 /* Verify that sockaddr looks sendable.  Common verification has already
  * been taken care of.
  */
-static int sctp_inet_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
+static int sctp_inet_send_verify(struct sctp_sock *opt, union inet_addr *addr)
 {
 	return 1;
 }
@@ -1054,15 +1011,12 @@ static struct sctp_af sctp_af_inet = {
 	.to_sk_daddr	   = sctp_v4_to_sk_daddr,
 	.from_addr_param   = sctp_v4_from_addr_param,
 	.to_addr_param	   = sctp_v4_to_addr_param,
-	.cmp_addr	   = sctp_v4_cmp_addr,
+	.cmp_addr	   = inet_addr_equal_strict,
 	.addr_valid	   = sctp_v4_addr_valid,
-	.inaddr_any	   = sctp_v4_inaddr_any,
-	.is_any		   = sctp_v4_is_any,
 	.available	   = sctp_v4_available,
 	.scope		   = sctp_v4_scope,
 	.skb_iif	   = sctp_v4_skb_iif,
 	.is_ce		   = sctp_v4_is_ce,
-	.seq_dump_addr	   = sctp_v4_seq_dump_addr,
 	.ecn_capable	   = sctp_v4_ecn_capable,
 	.net_header_len	   = sizeof(struct iphdr),
 	.sockaddr_len	   = sizeof(struct sockaddr_in),
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 362ae6e..2560409 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -77,7 +77,7 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 					const __u8 *raw_addrs, int addrs_len);
 static int sctp_process_param(struct sctp_association *asoc,
 			      union sctp_params param,
-			      const union sctp_addr *peer_addr,
+			      const union inet_addr *peer_addr,
 			      gfp_t gfp);
 static void *sctp_addto_param(struct sctp_chunk *chunk, int len,
 			      const void *data);
@@ -1329,15 +1329,15 @@ nodata:
 }
 
 /* Set chunk->source and dest based on the IP header in chunk->skb.  */
-void sctp_init_addrs(struct sctp_chunk *chunk, union sctp_addr *src,
-		     union sctp_addr *dest)
+void sctp_init_addrs(struct sctp_chunk *chunk, union inet_addr *src,
+		     union inet_addr *dest)
 {
-	memcpy(&chunk->source, src, sizeof(union sctp_addr));
-	memcpy(&chunk->dest, dest, sizeof(union sctp_addr));
+	memcpy(&chunk->source, src, sizeof(union inet_addr));
+	memcpy(&chunk->dest, dest, sizeof(union inet_addr));
 }
 
 /* Extract the source address from a chunk.  */
-const union sctp_addr *sctp_source(const struct sctp_chunk *chunk)
+const union inet_addr *sctp_source(const struct sctp_chunk *chunk)
 {
 	/* If we have a known transport, use that.  */
 	if (chunk->transport) {
@@ -1741,7 +1741,7 @@ no_hmac:
 		goto fail;
 	}
 
-	if (chunk->sctp_hdr->source != bear_cookie->peer_addr.v4.sin_port ||
+	if (chunk->sctp_hdr->source != bear_cookie->peer_addr.sin.sin_port ||
 	    ntohs(chunk->sctp_hdr->dest) != bear_cookie->my_port) {
 		*error = -SCTP_IERROR_BAD_PORTS;
 		goto fail;
@@ -2269,7 +2269,7 @@ int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
  * FIXME:  This is an association method.
  */
 int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
-		      const union sctp_addr *peer_addr,
+		      const union inet_addr *peer_addr,
 		      sctp_init_chunk_t *peer_init, gfp_t gfp)
 {
 	struct net *net = sock_net(asoc->base.sk);
@@ -2277,7 +2277,7 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	struct sctp_transport *transport;
 	struct list_head *pos, *temp;
 	struct sctp_af *af;
-	union sctp_addr addr;
+	union inet_addr addr;
 	char *cookie;
 	int src_match = 0;
 
@@ -2466,11 +2466,11 @@ nomem:
  */
 static int sctp_process_param(struct sctp_association *asoc,
 			      union sctp_params param,
-			      const union sctp_addr *peer_addr,
+			      const union inet_addr *peer_addr,
 			      gfp_t gfp)
 {
 	struct net *net = sock_net(asoc->base.sk);
-	union sctp_addr addr;
+	union inet_addr addr;
 	int i;
 	__u16 sat;
 	int retval = 1;
@@ -2717,7 +2717,7 @@ __u32 sctp_generate_tsn(const struct sctp_endpoint *ep)
  * Address Parameter and other parameter will not be wrapped in this function
  */
 static struct sctp_chunk *sctp_make_asconf(struct sctp_association *asoc,
-					   union sctp_addr *addr,
+					   union inet_addr *addr,
 					   int vparam_len)
 {
 	sctp_addiphdr_t asconf;
@@ -2725,7 +2725,7 @@ static struct sctp_chunk *sctp_make_asconf(struct sctp_association *asoc,
 	int length = sizeof(asconf) + vparam_len;
 	union sctp_addr_param addrparam;
 	int addrlen;
-	struct sctp_af *af = sctp_get_af_specific(addr->v4.sin_family);
+	struct sctp_af *af = sctp_get_af_specific(addr->sin.sin_family);
 
 	addrlen = af->to_addr_param(addr, &addrparam);
 	if (!addrlen)
@@ -2772,7 +2772,7 @@ static struct sctp_chunk *sctp_make_asconf(struct sctp_association *asoc,
  *
  */
 struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
-					      union sctp_addr	      *laddr,
+					      union inet_addr	      *laddr,
 					      struct sockaddr	      *addrs,
 					      int		      addrcnt,
 					      __be16		      flags)
@@ -2780,7 +2780,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 	sctp_addip_param_t	param;
 	struct sctp_chunk	*retval;
 	union sctp_addr_param	addr_param;
-	union sctp_addr		*addr;
+	union inet_addr		*addr;
 	void			*addr_buf;
 	struct sctp_af		*af;
 	int			paramlen = sizeof(param);
@@ -2793,7 +2793,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 	addr_buf = addrs;
 	for (i = 0; i < addrcnt; i++) {
 		addr = addr_buf;
-		af = sctp_get_af_specific(addr->v4.sin_family);
+		af = sctp_get_af_specific(addr->sin.sin_family);
 		addr_param_len = af->to_addr_param(addr, &addr_param);
 
 		totallen += paramlen;
@@ -2821,7 +2821,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 	addr_buf = addrs;
 	for (i = 0; i < addrcnt; i++) {
 		addr = addr_buf;
-		af = sctp_get_af_specific(addr->v4.sin_family);
+		af = sctp_get_af_specific(addr->sin.sin_family);
 		addr_param_len = af->to_addr_param(addr, &addr_param);
 		param.param_hdr.type = flags;
 		param.param_hdr.length = htons(paramlen + addr_param_len);
@@ -2834,7 +2834,7 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
 	}
 	if (flags == SCTP_PARAM_ADD_IP && del_pickup) {
 		addr = asoc->asconf_addr_del_pending;
-		af = sctp_get_af_specific(addr->v4.sin_family);
+		af = sctp_get_af_specific(addr->sin.sin_family);
 		addr_param_len = af->to_addr_param(addr, &addr_param);
 		param.param_hdr.type = SCTP_PARAM_DEL_IP;
 		param.param_hdr.length = htons(paramlen + addr_param_len);
@@ -2861,14 +2861,14 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
  * Create an ASCONF chunk with Set Primary IP address parameter.
  */
 struct sctp_chunk *sctp_make_asconf_set_prim(struct sctp_association *asoc,
-					     union sctp_addr *addr)
+					     union inet_addr *addr)
 {
 	sctp_addip_param_t	param;
 	struct sctp_chunk 	*retval;
 	int 			len = sizeof(param);
 	union sctp_addr_param	addrparam;
 	int			addrlen;
-	struct sctp_af		*af = sctp_get_af_specific(addr->v4.sin_family);
+	struct sctp_af		*af = sctp_get_af_specific(addr->sin.sin_family);
 
 	addrlen = af->to_addr_param(addr, &addrparam);
 	if (!addrlen)
@@ -2977,7 +2977,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 {
 	struct sctp_transport *peer;
 	struct sctp_af *af;
-	union sctp_addr	addr;
+	union inet_addr	addr;
 	union sctp_addr_param *addr_param;
 
 	addr_param = (void *)asconf_param + sizeof(sctp_addip_param_t);
@@ -3011,7 +3011,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 	 * (note: wildcard is permitted and requires special handling so
 	 *  make sure we check for that)
 	 */
-	if (!af->is_any(&addr) && !af->addr_valid(&addr, NULL, asconf->skb))
+	if (!inet_addr_any(&addr) && !af->addr_valid(&addr, NULL, asconf->skb))
 		return SCTP_ERROR_DNS_FAILED;
 
 	switch (asconf_param->param_hdr.type) {
@@ -3020,7 +3020,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		 * If the address 0.0.0.0 or ::0 is provided, the source
 		 * address of the packet MUST be added.
 		 */
-		if (af->is_any(&addr))
+		if (inet_addr_any(&addr))
 			memcpy(&addr, &asconf->source, sizeof(addr));
 
 		/* ADDIP 4.3 D9) If an endpoint receives an ADD IP address
@@ -3063,7 +3063,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		 * addresses of the peer except	the source address of the
 		 * packet MUST be deleted.
 		 */
-		if (af->is_any(&addr)) {
+		if (inet_addr_any(&addr)) {
 			sctp_assoc_set_primary(asoc, asconf->transport);
 			sctp_assoc_del_nonprimary_peers(asoc,
 							asconf->transport);
@@ -3076,8 +3076,8 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		 * MAY mark the source address of the packet as its
 		 * primary.
 		 */
-		if (af->is_any(&addr))
-			memcpy(&addr.v4, sctp_source(asconf), sizeof(addr));
+		if (inet_addr_any(&addr))
+			memcpy(&addr.sin, sctp_source(asconf), sizeof(addr));
 
 		peer = sctp_assoc_lookup_paddr(asoc, &addr);
 		if (!peer)
@@ -3231,7 +3231,7 @@ static void sctp_asconf_param_success(struct sctp_association *asoc,
 				     sctp_addip_param_t *asconf_param)
 {
 	struct sctp_af *af;
-	union sctp_addr	addr;
+	union inet_addr	addr;
 	struct sctp_bind_addr *bp = &asoc->base.bind_addr;
 	union sctp_addr_param *addr_param;
 	struct sctp_transport *transport;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f6b7109..b7e5fd8 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1130,7 +1130,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
 					sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	union sctp_addr from_addr;
+	union inet_addr from_addr;
 	struct sctp_transport *link;
 	sctp_sender_hb_info_t *hbinfo;
 	unsigned long max_interval;
@@ -1156,17 +1156,8 @@ sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
 
 	/* This should never happen, but lets log it if so.  */
 	if (unlikely(!link)) {
-		if (from_addr.sa.sa_family == AF_INET6) {
-			net_warn_ratelimited("%s association %p could not find address %pI6\n",
-					     __func__,
-					     asoc,
-					     &from_addr.v6.sin6_addr);
-		} else {
-			net_warn_ratelimited("%s association %p could not find address %pI4\n",
-					     __func__,
-					     asoc,
-					     &from_addr.v4.sin_addr.s_addr);
-		}
+		net_warn_ratelimited("%s association %p could not find address %pIA\n",
+				     __func__, asoc, &from_addr);
 		return SCTP_DISPOSITION_DISCARD;
 	}
 
@@ -1199,7 +1190,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
 /* Helper function to send out an abort for the restart
  * condition.
  */
-static int sctp_sf_send_restart_abort(struct net *net, union sctp_addr *ssa,
+static int sctp_sf_send_restart_abort(struct net *net, union inet_addr *ssa,
 				      struct sctp_chunk *init,
 				      sctp_cmd_seq_t *commands)
 {
@@ -1209,7 +1200,7 @@ static int sctp_sf_send_restart_abort(struct net *net, union sctp_addr *ssa,
 	struct sctp_errhdr *errhdr;
 	struct sctp_endpoint *ep;
 	char buffer[sizeof(struct sctp_errhdr)+sizeof(union sctp_addr_param)];
-	struct sctp_af *af = sctp_get_af_specific(ssa->v4.sin_family);
+	struct sctp_af *af = sctp_get_af_specific(ssa->sin.sin_family);
 
 	/* Build the error on the stack.   We are way to malloc crazy
 	 * throughout the code today.
@@ -1249,7 +1240,7 @@ out:
 }
 
 static bool list_has_sctp_addr(const struct list_head *list,
-			       union sctp_addr *ipaddr)
+			       union inet_addr *ipaddr)
 {
 	struct sctp_transport *addr;
 
@@ -6047,7 +6038,7 @@ static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
 	/* Cache a route for the transport with the chunk's destination as
 	 * the source address.
 	 */
-	sctp_transport_route(transport, (union sctp_addr *)&chunk->dest,
+	sctp_transport_route(transport, (union inet_addr *)&chunk->dest,
 			     sctp_sk(net->sctp.ctl_sock));
 
 	packet = sctp_packet_init(&transport->packet, transport, sport, dport);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5e4402b..29243f4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -95,14 +95,14 @@ static int sctp_wait_for_accept(struct sock *sk, long timeo);
 static void sctp_wait_for_close(struct sock *sk, long timeo);
 static void sctp_destruct_sock(struct sock *sk);
 static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
-					union sctp_addr *addr, int len);
+					union inet_addr *addr, int len);
 static int sctp_bindx_add(struct sock *, struct sockaddr *, int);
 static int sctp_bindx_rem(struct sock *, struct sockaddr *, int);
 static int sctp_send_asconf_add_ip(struct sock *, struct sockaddr *, int);
 static int sctp_send_asconf_del_ip(struct sock *, struct sockaddr *, int);
 static int sctp_send_asconf(struct sctp_association *asoc,
 			    struct sctp_chunk *chunk);
-static int sctp_do_bind(struct sock *, union sctp_addr *, int);
+static int sctp_do_bind(struct sock *, union inet_addr *, int);
 static int sctp_autobind(struct sock *sk);
 static void sctp_sock_migrate(struct sock *, struct sock *,
 			      struct sctp_association *, sctp_socket_type_t);
@@ -179,7 +179,7 @@ static inline void sctp_set_owner_w(struct sctp_chunk *chunk)
 }
 
 /* Verify that this is a valid address. */
-static inline int sctp_verify_addr(struct sock *sk, union sctp_addr *addr,
+static inline int sctp_verify_addr(struct sock *sk, union inet_addr *addr,
 				   int len)
 {
 	struct sctp_af *af;
@@ -246,7 +246,7 @@ static struct sctp_transport *sctp_addr_id2transport(struct sock *sk,
 {
 	struct sctp_association *addr_asoc = NULL, *id_asoc = NULL;
 	struct sctp_transport *transport;
-	union sctp_addr *laddr = (union sctp_addr *)addr;
+	union inet_addr *laddr = (union inet_addr *)addr;
 
 	addr_asoc = sctp_endpoint_lookup_assoc(sctp_sk(sk)->ep,
 					       laddr,
@@ -260,7 +260,7 @@ static struct sctp_transport *sctp_addr_id2transport(struct sock *sk,
 		return NULL;
 
 	sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
-						(union sctp_addr *)addr);
+						(union inet_addr *)addr);
 
 	return transport;
 }
@@ -286,7 +286,7 @@ static int sctp_bind(struct sock *sk, struct sockaddr *addr, int addr_len)
 
 	/* Disallow binding twice. */
 	if (!sctp_sk(sk)->ep->base.bind_addr.port)
-		retval = sctp_do_bind(sk, (union sctp_addr *)addr,
+		retval = sctp_do_bind(sk, (union inet_addr *)addr,
 				      addr_len);
 	else
 		retval = -EINVAL;
@@ -296,11 +296,11 @@ static int sctp_bind(struct sock *sk, struct sockaddr *addr, int addr_len)
 	return retval;
 }
 
-static long sctp_get_port_local(struct sock *, union sctp_addr *);
+static long sctp_get_port_local(struct sock *, union inet_addr *);
 
 /* Verify this is a valid sockaddr. */
 static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
-					union sctp_addr *addr, int len)
+					union inet_addr *addr, int len)
 {
 	struct sctp_af *af;
 
@@ -310,7 +310,7 @@ static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
 
 	/* V4 mapped address are really of AF_INET family */
 	if (addr->sa.sa_family == AF_INET6 &&
-	    ipv6_addr_v4mapped(&addr->v6.sin6_addr)) {
+	    ipv6_addr_v4mapped(&addr->sin6.sin6_addr)) {
 		if (!opt->pf->af_supported(AF_INET, opt))
 			return NULL;
 	} else {
@@ -329,7 +329,7 @@ static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
 }
 
 /* Bind a local address either to an endpoint or to an association.  */
-static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
+static int sctp_do_bind(struct sock *sk, union inet_addr *addr, int len)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp = sctp_sk(sk);
@@ -347,7 +347,7 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 		return -EINVAL;
 	}
 
-	snum = ntohs(addr->v4.sin_port);
+	snum = ntohs(addr->sin.sin_port);
 
 	pr_debug("%s: sk:%p, new addr:%pIAc, port:%d, new port:%d, len:%d\n",
 		 __func__, sk, &addr->sa, bp->port, snum, len);
@@ -384,7 +384,7 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 	 * The function sctp_get_port_local() does duplicate address
 	 * detection.
 	 */
-	addr->v4.sin_port = htons(snum);
+	addr->sin.sin_port = htons(snum);
 	if ((ret = sctp_get_port_local(sk, addr))) {
 		return -EADDRINUSE;
 	}
@@ -478,7 +478,7 @@ static int sctp_bindx_add(struct sock *sk, struct sockaddr *addrs, int addrcnt)
 			goto err_bindx_add;
 		}
 
-		retval = sctp_do_bind(sk, (union sctp_addr *)sa_addr,
+		retval = sctp_do_bind(sk, (union inet_addr *)sa_addr,
 				      af->sockaddr_len);
 
 		addr_buf += af->sockaddr_len;
@@ -516,8 +516,8 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 	struct sctp_bind_addr		*bp;
 	struct sctp_chunk		*chunk;
 	struct sctp_sockaddr_entry	*laddr;
-	union sctp_addr			*addr;
-	union sctp_addr			saveaddr;
+	union inet_addr			*addr;
+	union inet_addr			saveaddr;
 	void				*addr_buf;
 	struct sctp_af			*af;
 	struct list_head		*p;
@@ -551,7 +551,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
 			addr = addr_buf;
-			af = sctp_get_af_specific(addr->v4.sin_family);
+			af = sctp_get_af_specific(addr->sin.sin_family);
 			if (!af) {
 				retval = -EINVAL;
 				goto out;
@@ -584,7 +584,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
 			addr = addr_buf;
-			af = sctp_get_af_specific(addr->v4.sin_family);
+			af = sctp_get_af_specific(addr->sin.sin_family);
 			memcpy(&saveaddr, addr, af->sockaddr_len);
 			retval = sctp_add_bind_addr(bp, &saveaddr,
 						    SCTP_ADDR_NEW, GFP_ATOMIC);
@@ -637,7 +637,7 @@ static int sctp_bindx_rem(struct sock *sk, struct sockaddr *addrs, int addrcnt)
 	struct sctp_bind_addr *bp = &ep->base.bind_addr;
 	int retval = 0;
 	void *addr_buf;
-	union sctp_addr *sa_addr;
+	union inet_addr *sa_addr;
 	struct sctp_af *af;
 
 	pr_debug("%s: sk:%p, addrs:%p, addrcnt:%d\n",
@@ -667,14 +667,14 @@ static int sctp_bindx_rem(struct sock *sk, struct sockaddr *addrs, int addrcnt)
 			goto err_bindx_rem;
 		}
 
-		if (sa_addr->v4.sin_port &&
-		    sa_addr->v4.sin_port != htons(bp->port)) {
+		if (sa_addr->sin.sin_port &&
+		    sa_addr->sin.sin_port != htons(bp->port)) {
 			retval = -EINVAL;
 			goto err_bindx_rem;
 		}
 
-		if (!sa_addr->v4.sin_port)
-			sa_addr->v4.sin_port = htons(bp->port);
+		if (!sa_addr->sin.sin_port)
+			sa_addr->sin.sin_port = htons(bp->port);
 
 		/* FIXME - There is probably a need to check if sk->sk_saddr and
 		 * sk->sk_rcv_addr are currently set to one of the addresses to
@@ -719,7 +719,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 	struct sctp_transport	*transport;
 	struct sctp_bind_addr	*bp;
 	struct sctp_chunk	*chunk;
-	union sctp_addr		*laddr;
+	union inet_addr		*laddr;
 	void			*addr_buf;
 	struct sctp_af		*af;
 	struct sctp_sockaddr_entry *saddr;
@@ -756,7 +756,7 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
 			laddr = addr_buf;
-			af = sctp_get_af_specific(laddr->v4.sin_family);
+			af = sctp_get_af_specific(laddr->sin.sin_family);
 			if (!af) {
 				retval = -EINVAL;
 				goto out;
@@ -776,31 +776,31 @@ static int sctp_send_asconf_del_ip(struct sock		*sk,
 		 * association.
 		 */
 		bp = &asoc->base.bind_addr;
-		laddr = sctp_find_unmatch_addr(bp, (union sctp_addr *)addrs,
+		laddr = sctp_find_unmatch_addr(bp, (union inet_addr *)addrs,
 					       addrcnt, sp);
 		if ((laddr == NULL) && (addrcnt == 1)) {
 			if (asoc->asconf_addr_del_pending)
 				continue;
 			asoc->asconf_addr_del_pending =
-			    kzalloc(sizeof(union sctp_addr), GFP_ATOMIC);
+			    kzalloc(sizeof(union inet_addr), GFP_ATOMIC);
 			if (asoc->asconf_addr_del_pending == NULL) {
 				retval = -ENOMEM;
 				goto out;
 			}
 			asoc->asconf_addr_del_pending->sa.sa_family =
 				    addrs->sa_family;
-			asoc->asconf_addr_del_pending->v4.sin_port =
+			asoc->asconf_addr_del_pending->sin.sin_port =
 				    htons(bp->port);
 			if (addrs->sa_family == AF_INET) {
 				struct sockaddr_in *sin;
 
 				sin = (struct sockaddr_in *)addrs;
-				asoc->asconf_addr_del_pending->v4.sin_addr.s_addr = sin->sin_addr.s_addr;
+				asoc->asconf_addr_del_pending->sin.sin_addr.s_addr = sin->sin_addr.s_addr;
 			} else if (addrs->sa_family == AF_INET6) {
 				struct sockaddr_in6 *sin6;
 
 				sin6 = (struct sockaddr_in6 *)addrs;
-				asoc->asconf_addr_del_pending->v6.sin6_addr = sin6->sin6_addr;
+				asoc->asconf_addr_del_pending->sin6.sin6_addr = sin6->sin6_addr;
 			}
 
 			pr_debug("%s: keep the last address asoc:%p %pIAc at %p\n",
@@ -830,7 +830,7 @@ skip_mkasconf:
 		addr_buf = addrs;
 		for (i = 0; i < addrcnt; i++) {
 			laddr = addr_buf;
-			af = sctp_get_af_specific(laddr->v4.sin_family);
+			af = sctp_get_af_specific(laddr->sin.sin_family);
 			list_for_each_entry(saddr, &bp->address_list, list) {
 				if (sctp_cmp_addr_exact(&saddr->a, laddr))
 					saddr->state = SCTP_ADDR_DEL;
@@ -862,12 +862,12 @@ out:
 int sctp_asconf_mgmt(struct sctp_sock *sp, struct sctp_sockaddr_entry *addrw)
 {
 	struct sock *sk = sctp_opt2sk(sp);
-	union sctp_addr *addr;
+	union inet_addr *addr;
 	struct sctp_af *af;
 
 	/* It is safe to write port space in caller. */
 	addr = &addrw->a;
-	addr->v4.sin_port = htons(sp->ep->base.bind_addr.port);
+	addr->sin.sin_port = htons(sp->ep->base.bind_addr.port);
 	af = sctp_get_af_specific(addr->sa.sa_family);
 	if (!af)
 		return -EINVAL;
@@ -1054,14 +1054,14 @@ static int __sctp_connect(struct sock* sk,
 	struct sctp_association *asoc = NULL;
 	struct sctp_association *asoc2;
 	struct sctp_transport *transport;
-	union sctp_addr to;
+	union inet_addr to;
 	struct sctp_af *af;
 	sctp_scope_t scope;
 	long timeo;
 	int err = 0;
 	int addrcnt = 0;
 	int walk_size = 0;
-	union sctp_addr *sa_addr = NULL;
+	union inet_addr *sa_addr = NULL;
 	void *addr_buf;
 	unsigned short port;
 	unsigned int f_flags = 0;
@@ -1099,7 +1099,7 @@ static int __sctp_connect(struct sock* sk,
 			goto out_free;
 		}
 
-		port = ntohs(sa_addr->v4.sin_port);
+		port = ntohs(sa_addr->sin.sin_port);
 
 		/* Save current address so we can work with it */
 		memcpy(&to, sa_addr, af->sockaddr_len);
@@ -1575,7 +1575,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct sctp_association *new_asoc=NULL, *asoc=NULL;
 	struct sctp_transport *transport, *chunk_tp;
 	struct sctp_chunk *chunk;
-	union sctp_addr to;
+	union inet_addr to;
 	struct sockaddr *msg_name = NULL;
 	struct sctp_sndrcvinfo default_sinfo;
 	struct sctp_sndrcvinfo *sinfo;
@@ -1617,7 +1617,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (!sctp_style(sk, UDP_HIGH_BANDWIDTH) && msg->msg_name) {
 		int msg_namelen = msg->msg_namelen;
 
-		err = sctp_verify_addr(sk, (union sctp_addr *)msg->msg_name,
+		err = sctp_verify_addr(sk, (union inet_addr *)msg->msg_name,
 				       msg_namelen);
 		if (err)
 			return err;
@@ -2483,7 +2483,7 @@ static int sctp_setsockopt_peer_addr_params(struct sock *sk,
 	/* If an address other than INADDR_ANY is specified, and
 	 * no transport is found, then the request is invalid.
 	 */
-	if (!sctp_is_any(sk, ( union sctp_addr *)&params.spp_address)) {
+	if (!inet_addr_any((union inet_addr *)&params.spp_address)) {
 		trans = sctp_addr_id2transport(sk, &params.spp_address,
 					       params.spp_assoc_id);
 		if (!trans)
@@ -3065,15 +3065,15 @@ static int sctp_setsockopt_peer_primary_addr(struct sock *sk, char __user *optva
 	if (!af)
 		return -EINVAL;
 
-	if (!af->addr_valid((union sctp_addr *)&prim.sspp_addr, sp, NULL))
+	if (!af->addr_valid((union inet_addr *)&prim.sspp_addr, sp, NULL))
 		return -EADDRNOTAVAIL;
 
-	if (!sctp_assoc_lookup_laddr(asoc, (union sctp_addr *)&prim.sspp_addr))
+	if (!sctp_assoc_lookup_laddr(asoc, (union inet_addr *)&prim.sspp_addr))
 		return -EADDRNOTAVAIL;
 
 	/* Create an ASCONF chunk with SET_PRIMARY parameter	*/
 	chunk = sctp_make_asconf_set_prim(asoc,
-					  (union sctp_addr *)&prim.sspp_addr);
+					  (union inet_addr *)&prim.sspp_addr);
 	if (!chunk)
 		return -ENOMEM;
 
@@ -3502,7 +3502,7 @@ static int sctp_setsockopt_paddr_thresholds(struct sock *sk,
 		return -EFAULT;
 
 
-	if (sctp_is_any(sk, (const union sctp_addr *)&val.spt_address)) {
+	if (inet_addr_any((const union inet_addr *)&val.spt_address)) {
 		asoc = sctp_id2assoc(sk, val.spt_assoc_id);
 		if (!asoc)
 			return -ENOENT;
@@ -4100,7 +4100,7 @@ static int sctp_getsockopt_sctp_status(struct sock *sk, int len,
 			transport->af_specific->sockaddr_len);
 	/* Map ipv4 address into v4-mapped-on-v6 address.  */
 	sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
-		(union sctp_addr *)&status.sstat_primary.spinfo_address);
+		(union inet_addr *)&status.sstat_primary.spinfo_address);
 	status.sstat_primary.spinfo_state = transport->state;
 	status.sstat_primary.spinfo_cwnd = transport->cwnd;
 	status.sstat_primary.spinfo_srtt = transport->srtt;
@@ -4455,7 +4455,7 @@ static int sctp_getsockopt_peer_addr_params(struct sock *sk, int len,
 	/* If an address other than INADDR_ANY is specified, and
 	 * no transport is found, then the request is invalid.
 	 */
-	if (!sctp_is_any(sk, ( union sctp_addr *)&params.spp_address)) {
+	if (!inet_addr_any((union inet_addr *)&params.spp_address)) {
 		trans = sctp_addr_id2transport(sk, &params.spp_address,
 					       params.spp_assoc_id);
 		if (!trans) {
@@ -4639,7 +4639,7 @@ static int sctp_getsockopt_peer_addrs(struct sock *sk, int len,
 	struct sctp_getaddrs getaddrs;
 	struct sctp_transport *from;
 	void __user *to;
-	union sctp_addr temp;
+	union inet_addr temp;
 	struct sctp_sock *sp = sctp_sk(sk);
 	int addrlen;
 	size_t space_left;
@@ -4686,7 +4686,7 @@ static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
 			    size_t space_left, int *bytes_copied)
 {
 	struct sctp_sockaddr_entry *addr;
-	union sctp_addr temp;
+	union inet_addr temp;
 	int cnt = 0;
 	int addrlen;
 	struct net *net = sock_net(sk);
@@ -4704,8 +4704,8 @@ static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
 		    (AF_INET == addr->a.sa.sa_family))
 			continue;
 		memcpy(&temp, &addr->a, sizeof(temp));
-		if (!temp.v4.sin_port)
-			temp.v4.sin_port = htons(port);
+		if (!temp.sin.sin_port)
+			temp.sin.sin_port = htons(port);
 
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
 								&temp);
@@ -4736,7 +4736,7 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 	struct sctp_getaddrs getaddrs;
 	struct sctp_sockaddr_entry *addr;
 	void __user *to;
-	union sctp_addr temp;
+	union inet_addr temp;
 	struct sctp_sock *sp = sctp_sk(sk);
 	int addrlen;
 	int err = 0;
@@ -4779,7 +4779,7 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 	if (sctp_list_single_entry(&bp->address_list)) {
 		addr = list_entry(bp->address_list.next,
 				  struct sctp_sockaddr_entry, list);
-		if (sctp_is_any(sk, &addr->a)) {
+		if (inet_addr_any(&addr->a)) {
 			cnt = sctp_copy_laddrs(sk, bp->port, addrs,
 						space_left, &bytes_copied);
 			if (cnt < 0) {
@@ -4858,7 +4858,7 @@ static int sctp_getsockopt_primary_addr(struct sock *sk, int len,
 		asoc->peer.primary_path->af_specific->sockaddr_len);
 
 	sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp,
-			(union sctp_addr *)&prim.ssp_addr);
+			(union inet_addr *)&prim.ssp_addr);
 
 	if (put_user(len, optlen))
 		return -EFAULT;
@@ -5611,7 +5611,7 @@ static int sctp_getsockopt_paddr_thresholds(struct sock *sk,
 	if (copy_from_user(&val, (struct sctp_paddrthlds __user *)optval, len))
 		return -EFAULT;
 
-	if (sctp_is_any(sk, (const union sctp_addr *)&val.spt_address)) {
+	if (inet_addr_any((const union inet_addr *)&val.spt_address)) {
 		asoc = sctp_id2assoc(sk, val.spt_assoc_id);
 		if (!asoc)
 			return -ENOENT;
@@ -5875,14 +5875,14 @@ static void sctp_unhash(struct sock *sk)
 static struct sctp_bind_bucket *sctp_bucket_create(
 	struct sctp_bind_hashbucket *head, struct net *, unsigned short snum);
 
-static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
+static long sctp_get_port_local(struct sock *sk, union inet_addr *addr)
 {
 	struct sctp_bind_hashbucket *head; /* hash list */
 	struct sctp_bind_bucket *pp;
 	unsigned short snum;
 	int ret;
 
-	snum = ntohs(addr->v4.sin_port);
+	snum = ntohs(addr->sin.sin_port);
 
 	pr_debug("%s: begins, snum:%d\n", __func__, snum);
 
@@ -6029,12 +6029,12 @@ fail:
  */
 static int sctp_get_port(struct sock *sk, unsigned short snum)
 {
-	union sctp_addr addr;
+	union inet_addr addr;
 	struct sctp_af *af = sctp_sk(sk)->pf->af;
 
 	/* Set up a dummy address struct from the sk. */
 	af->from_sk(&addr, sk);
-	addr.v4.sin_port = htons(snum);
+	addr.sin.sin_port = htons(snum);
 
 	/* Note: sk->sk_num gets filled in if ephemeral port request. */
 	return !!sctp_get_port_local(sk, &addr);
@@ -6270,6 +6270,16 @@ void sctp_put_port(struct sock *sk)
 	sctp_local_bh_enable();
 }
 
+static void sctp_inaddr_any(union inet_addr *addr, sa_family_t family, __be16 port)
+{
+	memset(addr, 0x00, sizeof(union inet_addr));
+	addr->sa.sa_family = family;
+	if (family == AF_INET)
+		addr->sin.sin_port = port;
+	else
+		addr->sin6.sin6_port = port;
+}
+
 /*
  * The system picks an ephemeral port and choose an address set equivalent
  * to binding with a wildcard address.
@@ -6278,7 +6288,7 @@ void sctp_put_port(struct sock *sk)
  */
 static int sctp_autobind(struct sock *sk)
 {
-	union sctp_addr autoaddr;
+	union inet_addr autoaddr;
 	struct sctp_af *af;
 	__be16 port;
 
@@ -6286,7 +6296,7 @@ static int sctp_autobind(struct sock *sk)
 	af = sctp_sk(sk)->pf->af;
 
 	port = htons(inet_sk(sk)->inet_num);
-	af->inaddr_any(&autoaddr, port);
+	sctp_inaddr_any(&autoaddr, af->sa_family, port);
 
 	return sctp_do_bind(sk, &autoaddr, af->sockaddr_len);
 }
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index bdbbc3f..a1c7de9 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -9,7 +9,7 @@
  *
  * This module provides the abstraction for an SCTP tranport representing
  * a remote transport address.  For local transport addresses, we just use
- * union sctp_addr.
+ * union inet_addr.
  *
  * This SCTP implementation is free software;
  * you can redistribute it and/or modify it under the terms of
@@ -61,13 +61,13 @@
 /* Initialize a new transport from provided memory.  */
 static struct sctp_transport *sctp_transport_init(struct net *net,
 						  struct sctp_transport *peer,
-						  const union sctp_addr *addr,
+						  const union inet_addr *addr,
 						  gfp_t gfp)
 {
 	/* Copy in the address.  */
 	peer->ipaddr = *addr;
 	peer->af_specific = sctp_get_af_specific(addr->sa.sa_family);
-	memset(&peer->saddr, 0, sizeof(union sctp_addr));
+	memset(&peer->saddr, 0, sizeof(union inet_addr));
 
 	peer->sack_generation = 0;
 
@@ -111,7 +111,7 @@ static struct sctp_transport *sctp_transport_init(struct net *net,
 
 /* Allocate and initialize a new transport.  */
 struct sctp_transport *sctp_transport_new(struct net *net,
-					  const union sctp_addr *addr,
+					  const union inet_addr *addr,
 					  gfp_t gfp)
 {
 	struct sctp_transport *transport;
@@ -273,7 +273,7 @@ void sctp_transport_update_pmtu(struct sock *sk, struct sctp_transport *t, u32 p
  * address.
  */
 void sctp_transport_route(struct sctp_transport *transport,
-			  union sctp_addr *saddr, struct sctp_sock *opt)
+			  union inet_addr *saddr, struct sctp_sock *opt)
 {
 	struct sctp_association *asoc = transport->asoc;
 	struct sctp_af *af = transport->af_specific;
@@ -281,7 +281,7 @@ void sctp_transport_route(struct sctp_transport *transport,
 	af->get_dst(transport, saddr, &transport->fl, sctp_opt2sk(opt));
 
 	if (saddr)
-		memcpy(&transport->saddr, saddr, sizeof(union sctp_addr));
+		memcpy(&transport->saddr, saddr, sizeof(union inet_addr));
 	else
 		af->get_saddr(opt, transport, &transport->fl);
 
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 44a45db..ce07757 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -350,7 +350,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_peer_addr_change(
 	/* Map ipv4 address into v4-mapped-on-v6 address.  */
 	sctp_get_pf_specific(asoc->base.sk->sk_family)->addr_v4map(
 					sctp_sk(asoc->base.sk),
-					(union sctp_addr *)&spc->spc_aaddr);
+					(union inet_addr *)&spc->spc_aaddr);
 
 	return event;
 
-- 
1.7.7.6
