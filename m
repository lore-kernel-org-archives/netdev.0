From: James Chapman <jchapman@katalix.com>
Subject: [PATCH v3 05/12] l2tp: Add L2TPv3 protocol support
Date: Tue, 30 Mar 2010 17:17:52 +0100
Message-ID: <20100330161751.9628.42373.stgit@bert.katalix.com>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:51115 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753379Ab0C3QRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 12:17:50 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 48440A620B0
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 17:18:09 +0100 (BST)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ls9wo-CyspMO for <netdev@vger.kernel.org>;
	Tue, 30 Mar 2010 17:17:53 +0100 (BST)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 249F0A62087
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 17:17:52 +0100 (BST)
In-Reply-To: <20100330161725.9628.69994.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The L2TPv3 protocol changes the layout of the L2TP packet
header. Tunnel and session ids change from 16-bit to 32-bit values,
data sequence numbers change from 16-bit to 24-bit values and PPP-specific
fields are moved into protocol-specific subheaders.

Although this patch introduces L2TPv3 protocol support, there are no
userspace interfaces to create L2TPv3 sessions yet.

Signed-off-by: James Chapman <jchapman@katalix.com>
Reviewed-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/l2tp/Kconfig     |   25 ++
 net/l2tp/l2tp_core.c |  574 ++++++++++++++++++++++++++++++++++++++------------
 net/l2tp/l2tp_core.h |   54 ++++-
 net/l2tp/l2tp_ppp.c  |    5 
 4 files changed, 508 insertions(+), 150 deletions(-)

diff --git a/net/l2tp/Kconfig b/net/l2tp/Kconfig
index ec88c5c..d60758d 100644
--- a/net/l2tp/Kconfig
+++ b/net/l2tp/Kconfig
@@ -19,6 +19,10 @@ menuconfig L2TP
 	  connections. L2TP is also used as a VPN protocol, popular
 	  with home workers to connect to their offices.
 
+	  L2TPv3 allows other protocols as well as PPP to be carried
+	  over L2TP tunnels. L2TPv3 is defined in RFC 3931
+	  <http://www.ietf.org/rfc/rfc3931.txt>.
+
 	  The kernel component handles only L2TP data packets: a
 	  userland daemon handles L2TP the control protocol (tunnel
 	  and session setup). One such daemon is OpenL2TP
@@ -26,3 +30,24 @@ menuconfig L2TP
 
 	  If you don't need L2TP, say N. To compile all L2TP code as
 	  modules, choose M here.
+
+config L2TP_V3
+	bool "L2TPv3 support (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && L2TP
+	help
+	  Layer Two Tunneling Protocol Version 3
+
+	  From RFC 3931 <http://www.ietf.org/rfc/rfc3931.txt>.
+
+	  The Layer Two Tunneling Protocol (L2TP) provides a dynamic
+	  mechanism for tunneling Layer 2 (L2) "circuits" across a
+	  packet-oriented data network (e.g., over IP).  L2TP, as
+	  originally defined in RFC 2661, is a standard method for
+	  tunneling Point-to-Point Protocol (PPP) [RFC1661] sessions.
+	  L2TP has since been adopted for tunneling a number of other
+	  L2 protocols, including ATM, Frame Relay, HDLC and even raw
+	  ethernet frames.
+
+	  If you are connecting to L2TPv3 equipment, or you want to
+	  tunnel raw ethernet frames using L2TP, say Y here. If
+	  unsure, say N.
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 0c1a3b7..1ed7cce 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -66,6 +66,7 @@
 
 #define L2TP_HDR_VER_MASK  0x000F
 #define L2TP_HDR_VER_2	   0x0002
+#define L2TP_HDR_VER_3	   0x0003
 
 /* L2TPv3 default L2-specific sublayer */
 #define L2TP_SLFLAG_S	   0x40000000
@@ -86,7 +87,7 @@
 /* Private data stored for received packets in the skb.
  */
 struct l2tp_skb_cb {
-	u16			ns;
+	u32			ns;
 	u16			has_seq;
 	u16			length;
 	unsigned long		expires;
@@ -102,6 +103,8 @@ static unsigned int l2tp_net_id;
 struct l2tp_net {
 	struct list_head l2tp_tunnel_list;
 	rwlock_t l2tp_tunnel_list_lock;
+	struct hlist_head l2tp_session_hlist[L2TP_HASH_SIZE_2];
+	rwlock_t l2tp_session_hlist_lock;
 };
 
 static inline struct l2tp_net *l2tp_pernet(struct net *net)
@@ -111,6 +114,40 @@ static inline struct l2tp_net *l2tp_pernet(struct net *net)
 	return net_generic(net, l2tp_net_id);
 }
 
+/* Session hash global list for L2TPv3.
+ * The session_id SHOULD be random according to RFC3931, but several
+ * L2TP implementations use incrementing session_ids.  So we do a real
+ * hash on the session_id, rather than a simple bitmask.
+ */
+static inline struct hlist_head *
+l2tp_session_id_hash_2(struct l2tp_net *pn, u32 session_id)
+{
+	return &pn->l2tp_session_hlist[hash_32(session_id, L2TP_HASH_BITS_2)];
+
+}
+
+/* Lookup a session by id in the global session list
+ */
+static struct l2tp_session *l2tp_session_find_2(struct net *net, u32 session_id)
+{
+	struct l2tp_net *pn = l2tp_pernet(net);
+	struct hlist_head *session_list =
+		l2tp_session_id_hash_2(pn, session_id);
+	struct l2tp_session *session;
+	struct hlist_node *walk;
+
+	read_lock_bh(&pn->l2tp_session_hlist_lock);
+	hlist_for_each_entry(session, walk, session_list, global_hlist) {
+		if (session->session_id == session_id) {
+			read_unlock_bh(&pn->l2tp_session_hlist_lock);
+			return session;
+		}
+	}
+	read_unlock_bh(&pn->l2tp_session_hlist_lock);
+
+	return NULL;
+}
+
 /* Session hash list.
  * The session_id SHOULD be random according to RFC2661, but several
  * L2TP implementations (Cisco and Microsoft) use incrementing
@@ -125,13 +162,20 @@ l2tp_session_id_hash(struct l2tp_tunnel *tunnel, u32 session_id)
 
 /* Lookup a session by id
  */
-struct l2tp_session *l2tp_session_find(struct l2tp_tunnel *tunnel, u32 session_id)
+struct l2tp_session *l2tp_session_find(struct net *net, struct l2tp_tunnel *tunnel, u32 session_id)
 {
-	struct hlist_head *session_list =
-		l2tp_session_id_hash(tunnel, session_id);
+	struct hlist_head *session_list;
 	struct l2tp_session *session;
 	struct hlist_node *walk;
 
+	/* In L2TPv3, session_ids are unique over all tunnels and we
+	 * sometimes need to look them up before we know the
+	 * tunnel.
+	 */
+	if (tunnel == NULL)
+		return l2tp_session_find_2(net, session_id);
+
+	session_list = l2tp_session_id_hash(tunnel, session_id);
 	read_lock_bh(&tunnel->hlist_lock);
 	hlist_for_each_entry(session, walk, session_list, hlist) {
 		if (session->session_id == session_id) {
@@ -222,7 +266,7 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 {
 	struct sk_buff *skbp;
 	struct sk_buff *tmp;
-	u16 ns = L2TP_SKB_CB(skb)->ns;
+	u32 ns = L2TP_SKB_CB(skb)->ns;
 
 	spin_lock_bh(&session->reorder_q.lock);
 	skb_queue_walk_safe(&session->reorder_q, skbp, tmp) {
@@ -263,6 +307,11 @@ static void l2tp_recv_dequeue_skb(struct l2tp_session *session, struct sk_buff *
 	if (L2TP_SKB_CB(skb)->has_seq) {
 		/* Bump our Nr */
 		session->nr++;
+		if (tunnel->version == L2TP_HDR_VER_2)
+			session->nr &= 0xffff;
+		else
+			session->nr &= 0xffffff;
+
 		PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
 		       "%s: updated nr to %hu\n", session->name, session->nr);
 	}
@@ -295,8 +344,8 @@ static void l2tp_recv_dequeue(struct l2tp_session *session)
 			session->stats.rx_seq_discards++;
 			session->stats.rx_errors++;
 			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-			       "%s: oos pkt %hu len %d discarded (too old), "
-			       "waiting for %hu, reorder_q_len=%d\n",
+			       "%s: oos pkt %u len %d discarded (too old), "
+			       "waiting for %u, reorder_q_len=%d\n",
 			       session->name, L2TP_SKB_CB(skb)->ns,
 			       L2TP_SKB_CB(skb)->length, session->nr,
 			       skb_queue_len(&session->reorder_q));
@@ -310,8 +359,8 @@ static void l2tp_recv_dequeue(struct l2tp_session *session)
 		if (L2TP_SKB_CB(skb)->has_seq) {
 			if (L2TP_SKB_CB(skb)->ns != session->nr) {
 				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-				       "%s: holding oos pkt %hu len %d, "
-				       "waiting for %hu, reorder_q_len=%d\n",
+				       "%s: holding oos pkt %u len %d, "
+				       "waiting for %u, reorder_q_len=%d\n",
 				       session->name, L2TP_SKB_CB(skb)->ns,
 				       L2TP_SKB_CB(skb)->length, session->nr,
 				       skb_queue_len(&session->reorder_q));
@@ -356,100 +405,73 @@ static inline int l2tp_verify_udp_checksum(struct sock *sk,
 	return __skb_checksum_complete(skb);
 }
 
-/* Internal UDP receive frame. Do the real work of receiving an L2TP data frame
- * here. The skb is not on a list when we get here.
- * Returns 0 if the packet was a data packet and was successfully passed on.
- * Returns 1 if the packet was not a good data packet and could not be
- * forwarded.  All such packets are passed up to userspace to deal with.
+/* Do receive processing of L2TP data frames. We handle both L2TPv2
+ * and L2TPv3 data frames here.
+ *
+ * L2TPv2 Data Message Header
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |T|L|x|x|S|x|O|P|x|x|x|x|  Ver  |          Length (opt)         |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |           Tunnel ID           |           Session ID          |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |             Ns (opt)          |             Nr (opt)          |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |      Offset Size (opt)        |    Offset pad... (opt)
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Data frames are marked by T=0. All other fields are the same as
+ * those in L2TP control frames.
+ *
+ * L2TPv3 Data Message Header
+ *
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                      L2TP Session Header                      |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                      L2-Specific Sublayer                     |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                        Tunnel Payload                      ...
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * L2TPv3 Session Header Over IP
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                           Session ID                          |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |               Cookie (optional, maximum 64 bits)...
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *                                                                 |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * L2TPv3 L2-Specific Sublayer Format
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |x|S|x|x|x|x|x|x|              Sequence Number                  |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Cookie value, sublayer format and offset (pad) are negotiated with
+ * the peer when the session is set up. Unlike L2TPv2, we do not need
+ * to parse the packet header to determine if optional fields are
+ * present.
+ *
+ * Caller must already have parsed the frame and determined that it is
+ * a data (not control) frame before coming here. Fields up to the
+ * session-id have already been parsed and ptr points to the data
+ * after the session-id.
  */
-int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
-		       int (*payload_hook)(struct sk_buff *skb))
+void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
+		      unsigned char *ptr, unsigned char *optr, u16 hdrflags,
+		      int length, int (*payload_hook)(struct sk_buff *skb))
 {
-	struct l2tp_session *session = NULL;
-	unsigned char *ptr, *optr;
-	u16 hdrflags;
-	u32 tunnel_id, session_id;
-	int length;
+	struct l2tp_tunnel *tunnel = session->tunnel;
 	int offset;
-	u16 version;
-	u16 ns, nr;
-
-	if (tunnel->sock && l2tp_verify_udp_checksum(tunnel->sock, skb))
-		goto discard_bad_csum;
-
-	/* UDP always verifies the packet length. */
-	__skb_pull(skb, sizeof(struct udphdr));
-
-	/* Short packet? */
-	if (!pskb_may_pull(skb, L2TP_HDR_SIZE_SEQ)) {
-		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
-		       "%s: recv short packet (len=%d)\n", tunnel->name, skb->len);
-		goto error;
-	}
-
-	/* Point to L2TP header */
-	optr = ptr = skb->data;
-
-	/* Trace packet contents, if enabled */
-	if (tunnel->debug & L2TP_MSG_DATA) {
-		length = min(32u, skb->len);
-		if (!pskb_may_pull(skb, length))
-			goto error;
-
-		printk(KERN_DEBUG "%s: recv: ", tunnel->name);
-
-		offset = 0;
-		do {
-			printk(" %02X", ptr[offset]);
-		} while (++offset < length);
-
-		printk("\n");
-	}
-
-	/* Get L2TP header flags */
-	hdrflags = ntohs(*(__be16 *)ptr);
-
-	/* Check protocol version */
-	version = hdrflags & L2TP_HDR_VER_MASK;
-	if (version != tunnel->version) {
-		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
-		       "%s: recv protocol version mismatch: got %d expected %d\n",
-		       tunnel->name, version, tunnel->version);
-		goto error;
-	}
-
-	/* Get length of L2TP packet */
-	length = skb->len;
-
-	/* If type is control packet, it is handled by userspace. */
-	if (hdrflags & L2TP_HDRFLAG_T) {
-		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_DEBUG,
-		       "%s: recv control packet, len=%d\n", tunnel->name, length);
-		goto error;
-	}
-
-	/* Skip flags */
-	ptr += 2;
-
-	/* If length is present, skip it */
-	if (hdrflags & L2TP_HDRFLAG_L)
-		ptr += 2;
-
-	/* Extract tunnel and session ID */
-	tunnel_id = ntohs(*(__be16 *) ptr);
-	ptr += 2;
-	session_id = ntohs(*(__be16 *) ptr);
-	ptr += 2;
-
-	/* Find the session context */
-	session = l2tp_session_find(tunnel, session_id);
-	if (!session) {
-		/* Not found? Pass to userspace to deal with */
-		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
-		       "%s: no session found (%hu/%hu). Passing up.\n",
-		       tunnel->name, tunnel_id, session_id);
-		goto error;
-	}
+	u32 ns, nr;
 
 	/* The ref count is increased since we now hold a pointer to
 	 * the session. Take care to decrement the refcnt when exiting
@@ -459,6 +481,18 @@ int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	if (session->ref)
 		(*session->ref)(session);
 
+	/* Parse and check optional cookie */
+	if (session->peer_cookie_len > 0) {
+		if (memcmp(ptr, &session->peer_cookie[0], session->peer_cookie_len)) {
+			PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
+			       "%s: cookie mismatch (%u/%u). Discarding.\n",
+			       tunnel->name, tunnel->tunnel_id, session->session_id);
+			session->stats.rx_cookie_discards++;
+			goto discard;
+		}
+		ptr += session->peer_cookie_len;
+	}
+
 	/* Handle the optional sequence numbers. Sequence numbers are
 	 * in different places for L2TPv2 and L2TPv3.
 	 *
@@ -468,21 +502,40 @@ int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	 */
 	ns = nr = 0;
 	L2TP_SKB_CB(skb)->has_seq = 0;
-	if (hdrflags & L2TP_HDRFLAG_S) {
-		ns = (u16) ntohs(*(__be16 *) ptr);
-		ptr += 2;
-		nr = ntohs(*(__be16 *) ptr);
-		ptr += 2;
+	if (tunnel->version == L2TP_HDR_VER_2) {
+		if (hdrflags & L2TP_HDRFLAG_S) {
+			ns = ntohs(*(__be16 *) ptr);
+			ptr += 2;
+			nr = ntohs(*(__be16 *) ptr);
+			ptr += 2;
 
-		/* Store L2TP info in the skb */
-		L2TP_SKB_CB(skb)->ns = ns;
-		L2TP_SKB_CB(skb)->has_seq = 1;
+			/* Store L2TP info in the skb */
+			L2TP_SKB_CB(skb)->ns = ns;
+			L2TP_SKB_CB(skb)->has_seq = 1;
 
-		PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-		       "%s: recv data ns=%hu, nr=%hu, session nr=%hu\n",
-		       session->name, ns, nr, session->nr);
+			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
+			       "%s: recv data ns=%u, nr=%u, session nr=%u\n",
+			       session->name, ns, nr, session->nr);
+		}
+	} else if (session->l2specific_type == L2TP_L2SPECTYPE_DEFAULT) {
+		u32 l2h = ntohl(*(__be32 *) ptr);
+
+		if (l2h & 0x40000000) {
+			ns = l2h & 0x00ffffff;
+
+			/* Store L2TP info in the skb */
+			L2TP_SKB_CB(skb)->ns = ns;
+			L2TP_SKB_CB(skb)->has_seq = 1;
+
+			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
+			       "%s: recv data ns=%u, session nr=%u\n",
+			       session->name, ns, session->nr);
+		}
 	}
 
+	/* Advance past L2-specific header, if present */
+	ptr += session->l2specific_len;
+
 	if (L2TP_SKB_CB(skb)->has_seq) {
 		/* Received a packet with sequence numbers. If we're the LNS,
 		 * check if we sre sending sequence numbers and if not,
@@ -493,6 +546,7 @@ int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 			       "%s: requested to enable seq numbers by LNS\n",
 			       session->name);
 			session->send_seq = -1;
+			l2tp_session_set_header_len(session, tunnel->version);
 		}
 	} else {
 		/* No sequence numbers.
@@ -516,6 +570,7 @@ int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 			       "%s: requested to disable seq numbers by LNS\n",
 			       session->name);
 			session->send_seq = 0;
+			l2tp_session_set_header_len(session, tunnel->version);
 		} else if (session->send_seq) {
 			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_WARNING,
 			       "%s: recv data has no seq numbers when required. "
@@ -525,11 +580,19 @@ int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 		}
 	}
 
-	/* If offset bit set, skip it. */
-	if (hdrflags & L2TP_HDRFLAG_O) {
-		offset = ntohs(*(__be16 *)ptr);
-		ptr += 2 + offset;
-	}
+	/* Session data offset is handled differently for L2TPv2 and
+	 * L2TPv3. For L2TPv2, there is an optional 16-bit value in
+	 * the header. For L2TPv3, the offset is negotiated using AVPs
+	 * in the session setup control protocol.
+	 */
+	if (tunnel->version == L2TP_HDR_VER_2) {
+		/* If offset bit set, skip it. */
+		if (hdrflags & L2TP_HDRFLAG_O) {
+			offset = ntohs(*(__be16 *)ptr);
+			ptr += 2 + offset;
+		}
+	} else
+		ptr += session->offset;
 
 	offset = ptr - optr;
 	if (!pskb_may_pull(skb, offset))
@@ -568,8 +631,8 @@ int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 			if (L2TP_SKB_CB(skb)->ns != session->nr) {
 				session->stats.rx_seq_discards++;
 				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-				       "%s: oos pkt %hu len %d discarded, "
-				       "waiting for %hu, reorder_q_len=%d\n",
+				       "%s: oos pkt %u len %d discarded, "
+				       "waiting for %u, reorder_q_len=%d\n",
 				       session->name, L2TP_SKB_CB(skb)->ns,
 				       L2TP_SKB_CB(skb)->length, session->nr,
 				       skb_queue_len(&session->reorder_q));
@@ -590,7 +653,7 @@ int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 
 	l2tp_session_dec_refcount(session);
 
-	return 0;
+	return;
 
 discard:
 	session->stats.rx_errors++;
@@ -600,6 +663,111 @@ discard:
 		(*session->deref)(session);
 
 	l2tp_session_dec_refcount(session);
+}
+EXPORT_SYMBOL(l2tp_recv_common);
+
+/* Internal UDP receive frame. Do the real work of receiving an L2TP data frame
+ * here. The skb is not on a list when we get here.
+ * Returns 0 if the packet was a data packet and was successfully passed on.
+ * Returns 1 if the packet was not a good data packet and could not be
+ * forwarded.  All such packets are passed up to userspace to deal with.
+ */
+int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
+		       int (*payload_hook)(struct sk_buff *skb))
+{
+	struct l2tp_session *session = NULL;
+	unsigned char *ptr, *optr;
+	u16 hdrflags;
+	u32 tunnel_id, session_id;
+	int offset;
+	u16 version;
+	int length;
+
+	if (tunnel->sock && l2tp_verify_udp_checksum(tunnel->sock, skb))
+		goto discard_bad_csum;
+
+	/* UDP always verifies the packet length. */
+	__skb_pull(skb, sizeof(struct udphdr));
+
+	/* Short packet? */
+	if (!pskb_may_pull(skb, L2TP_HDR_SIZE_SEQ)) {
+		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
+		       "%s: recv short packet (len=%d)\n", tunnel->name, skb->len);
+		goto error;
+	}
+
+	/* Point to L2TP header */
+	optr = ptr = skb->data;
+
+	/* Trace packet contents, if enabled */
+	if (tunnel->debug & L2TP_MSG_DATA) {
+		length = min(32u, skb->len);
+		if (!pskb_may_pull(skb, length))
+			goto error;
+
+		printk(KERN_DEBUG "%s: recv: ", tunnel->name);
+
+		offset = 0;
+		do {
+			printk(" %02X", ptr[offset]);
+		} while (++offset < length);
+
+		printk("\n");
+	}
+
+	/* Get L2TP header flags */
+	hdrflags = ntohs(*(__be16 *) ptr);
+
+	/* Check protocol version */
+	version = hdrflags & L2TP_HDR_VER_MASK;
+	if (version != tunnel->version) {
+		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
+		       "%s: recv protocol version mismatch: got %d expected %d\n",
+		       tunnel->name, version, tunnel->version);
+		goto error;
+	}
+
+	/* Get length of L2TP packet */
+	length = skb->len;
+
+	/* If type is control packet, it is handled by userspace. */
+	if (hdrflags & L2TP_HDRFLAG_T) {
+		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_DEBUG,
+		       "%s: recv control packet, len=%d\n", tunnel->name, length);
+		goto error;
+	}
+
+	/* Skip flags */
+	ptr += 2;
+
+	if (tunnel->version == L2TP_HDR_VER_2) {
+		/* If length is present, skip it */
+		if (hdrflags & L2TP_HDRFLAG_L)
+			ptr += 2;
+
+		/* Extract tunnel and session ID */
+		tunnel_id = ntohs(*(__be16 *) ptr);
+		ptr += 2;
+		session_id = ntohs(*(__be16 *) ptr);
+		ptr += 2;
+	} else {
+		ptr += 2;	/* skip reserved bits */
+		tunnel_id = tunnel->tunnel_id;
+		session_id = ntohl(*(__be32 *) ptr);
+		ptr += 4;
+	}
+
+	/* Find the session context */
+	session = l2tp_session_find(tunnel->l2tp_net, tunnel, session_id);
+	if (!session) {
+		/* Not found? Pass to userspace to deal with */
+		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
+		       "%s: no session found (%u/%u). Passing up.\n",
+		       tunnel->name, tunnel_id, session_id);
+		goto error;
+	}
+
+	l2tp_recv_common(session, skb, ptr, optr, hdrflags, length, payload_hook);
 
 	return 0;
 
@@ -655,11 +823,11 @@ EXPORT_SYMBOL_GPL(l2tp_udp_encap_recv);
 
 /* Build an L2TP header for the session into the buffer provided.
  */
-static void l2tp_build_l2tpv2_header(struct l2tp_tunnel *tunnel,
-				     struct l2tp_session *session,
-				     void *buf)
+static int l2tp_build_l2tpv2_header(struct l2tp_session *session, void *buf)
 {
+	struct l2tp_tunnel *tunnel = session->tunnel;
 	__be16 *bufp = buf;
+	__be16 *optr = buf;
 	u16 flags = L2TP_HDR_VER_2;
 	u32 tunnel_id = tunnel->peer_tunnel_id;
 	u32 session_id = session->peer_session_id;
@@ -675,19 +843,51 @@ static void l2tp_build_l2tpv2_header(struct l2tp_tunnel *tunnel,
 		*bufp++ = htons(session->ns);
 		*bufp++ = 0;
 		session->ns++;
+		session->ns &= 0xffff;
 		PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-		       "%s: updated ns to %hu\n", session->name, session->ns);
+		       "%s: updated ns to %u\n", session->name, session->ns);
 	}
+
+	return bufp - optr;
 }
 
-void l2tp_build_l2tp_header(struct l2tp_session *session, void *buf)
+static int l2tp_build_l2tpv3_header(struct l2tp_session *session, void *buf)
 {
-	struct l2tp_tunnel *tunnel = session->tunnel;
+	char *bufp = buf;
+	char *optr = bufp;
+	u16 flags = L2TP_HDR_VER_3;
+
+	/* Setup L2TP header. */
+	*((__be16 *) bufp) = htons(flags);
+	bufp += 2;
+	*((__be16 *) bufp) = 0;
+	bufp += 2;
+	*((__be32 *) bufp) = htonl(session->peer_session_id);
+	bufp += 4;
+	if (session->cookie_len) {
+		memcpy(bufp, &session->cookie[0], session->cookie_len);
+		bufp += session->cookie_len;
+	}
+	if (session->l2specific_len) {
+		if (session->l2specific_type == L2TP_L2SPECTYPE_DEFAULT) {
+			u32 l2h = 0;
+			if (session->send_seq) {
+				l2h = 0x40000000 | session->ns;
+				session->ns++;
+				session->ns &= 0xffffff;
+				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
+				       "%s: updated ns to %u\n", session->name, session->ns);
+			}
 
-	BUG_ON(tunnel->version != L2TP_HDR_VER_2);
-	l2tp_build_l2tpv2_header(tunnel, session, buf);
+			*((__be32 *) bufp) = htonl(l2h);
+		}
+		bufp += session->l2specific_len;
+	}
+	if (session->offset)
+		bufp += session->offset;
+
+	return bufp - optr;
 }
-EXPORT_SYMBOL_GPL(l2tp_build_l2tp_header);
 
 int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb, size_t data_len)
 {
@@ -698,7 +898,7 @@ int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb, size_t dat
 	/* Debug */
 	if (session->send_seq)
 		PRINTK(session->debug, L2TP_MSG_DATA, KERN_DEBUG,
-		       "%s: send %Zd bytes, ns=%hu\n", session->name,
+		       "%s: send %Zd bytes, ns=%u\n", session->name,
 		       data_len, session->ns - 1);
 	else
 		PRINTK(session->debug, L2TP_MSG_DATA, KERN_DEBUG,
@@ -784,7 +984,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	skb->truesize += new_headroom - old_headroom;
 
 	/* Setup L2TP header */
-	l2tp_build_l2tp_header(session, __skb_push(skb, hdr_len));
+	session->build_header(session, __skb_push(skb, hdr_len));
 	udp_len = sizeof(struct udphdr) + hdr_len + data_len;
 
 	/* Setup UDP header */
@@ -795,7 +995,6 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	uh->source = inet->inet_sport;
 	uh->dest = inet->inet_dport;
 	uh->len = htons(udp_len);
-
 	uh->check = 0;
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
@@ -915,6 +1114,14 @@ again:
 
 			write_unlock_bh(&tunnel->hlist_lock);
 
+			if (tunnel->version != L2TP_HDR_VER_2) {
+				struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
+
+				write_lock_bh(&pn->l2tp_session_hlist_lock);
+				hlist_del_init(&session->global_hlist);
+				write_unlock_bh(&pn->l2tp_session_hlist_lock);
+			}
+
 			if (session->session_close != NULL)
 				(*session->session_close)(session);
 
@@ -1001,9 +1208,6 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 		goto err;
 	}
 
-	if (version != L2TP_HDR_VER_2)
-		goto err;
-
 	tunnel = kzalloc(sizeof(struct l2tp_tunnel), GFP_KERNEL);
 	if (tunnel == NULL) {
 		err = -ENOMEM;
@@ -1081,6 +1285,15 @@ void l2tp_session_free(struct l2tp_session *session)
 		hlist_del_init(&session->hlist);
 		write_unlock_bh(&tunnel->hlist_lock);
 
+		/* Unlink from the global hash if not L2TPv2 */
+		if (tunnel->version != L2TP_HDR_VER_2) {
+			struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
+
+			write_lock_bh(&pn->l2tp_session_hlist_lock);
+			hlist_del_init(&session->global_hlist);
+			write_unlock_bh(&pn->l2tp_session_hlist_lock);
+		}
+
 		if (session->session_id != 0)
 			atomic_dec(&l2tp_session_count);
 
@@ -1099,6 +1312,22 @@ void l2tp_session_free(struct l2tp_session *session)
 }
 EXPORT_SYMBOL_GPL(l2tp_session_free);
 
+/* We come here whenever a session's send_seq, cookie_len or
+ * l2specific_len parameters are set.
+ */
+void l2tp_session_set_header_len(struct l2tp_session *session, int version)
+{
+	if (version == L2TP_HDR_VER_2) {
+		session->hdr_len = 6;
+		if (session->send_seq)
+			session->hdr_len += 4;
+	} else {
+		session->hdr_len = 8 + session->cookie_len + session->l2specific_len + session->offset;
+	}
+
+}
+EXPORT_SYMBOL_GPL(l2tp_session_set_header_len);
+
 struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunnel, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
 {
 	struct l2tp_session *session;
@@ -1110,6 +1339,7 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 
 		session->session_id = session_id;
 		session->peer_session_id = peer_session_id;
+		session->nr = 1;
 
 		sprintf(&session->name[0], "sess %u/%u",
 			tunnel->tunnel_id, session->session_id);
@@ -1117,20 +1347,36 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 		skb_queue_head_init(&session->reorder_q);
 
 		INIT_HLIST_NODE(&session->hlist);
+		INIT_HLIST_NODE(&session->global_hlist);
 
 		/* Inherit debug options from tunnel */
 		session->debug = tunnel->debug;
 
 		if (cfg) {
+			session->pwtype = cfg->pw_type;
 			session->debug = cfg->debug;
-			session->hdr_len = cfg->hdr_len;
 			session->mtu = cfg->mtu;
 			session->mru = cfg->mru;
 			session->send_seq = cfg->send_seq;
 			session->recv_seq = cfg->recv_seq;
 			session->lns_mode = cfg->lns_mode;
+			session->reorder_timeout = cfg->reorder_timeout;
+			session->offset = cfg->offset;
+			session->l2specific_type = cfg->l2specific_type;
+			session->l2specific_len = cfg->l2specific_len;
+			session->cookie_len = cfg->cookie_len;
+			memcpy(&session->cookie[0], &cfg->cookie[0], cfg->cookie_len);
+			session->peer_cookie_len = cfg->peer_cookie_len;
+			memcpy(&session->peer_cookie[0], &cfg->peer_cookie[0], cfg->peer_cookie_len);
 		}
 
+		if (tunnel->version == L2TP_HDR_VER_2)
+			session->build_header = l2tp_build_l2tpv2_header;
+		else
+			session->build_header = l2tp_build_l2tpv3_header;
+
+		l2tp_session_set_header_len(session, tunnel->version);
+
 		/* Bump the reference count. The session context is deleted
 		 * only when this drops to zero.
 		 */
@@ -1146,6 +1392,16 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 			       l2tp_session_id_hash(tunnel, session_id));
 		write_unlock_bh(&tunnel->hlist_lock);
 
+		/* And to the global session list if L2TPv3 */
+		if (tunnel->version != L2TP_HDR_VER_2) {
+			struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
+
+			write_lock_bh(&pn->l2tp_session_hlist_lock);
+			hlist_add_head(&session->global_hlist,
+				       l2tp_session_id_hash_2(pn, session_id));
+			write_unlock_bh(&pn->l2tp_session_hlist_lock);
+		}
+
 		/* Ignore management session in session count value */
 		if (session->session_id != 0)
 			atomic_inc(&l2tp_session_count);
@@ -1289,6 +1545,7 @@ static void l2tp_seq_tunnel_show(struct seq_file *m, void *v)
 		seq_printf(m, " source port %hu, dest port %hu\n",
 			   ntohs(inet->inet_sport), ntohs(inet->inet_dport));
 	}
+	seq_printf(m, " L2TPv%d\n", tunnel->version);
 	seq_printf(m, " %d sessions, refcnt %d/%d\n", session_count,
 		   tunnel->sock ? atomic_read(&tunnel->sock->sk_refcnt) : 0,
 		   atomic_read(&tunnel->ref_count));
@@ -1310,17 +1567,46 @@ static void l2tp_seq_session_show(struct seq_file *m, void *v)
 {
 	struct l2tp_session *session = v;
 
-	seq_printf(m, "  SESSION %u, peer %u\n", session->session_id, session->peer_session_id);
+	seq_printf(m, "  SESSION %u, peer %u, %s\n", session->session_id,
+		   session->peer_session_id,
+		   session->pwtype == L2TP_PWTYPE_ETH ? "ETH" :
+		   session->pwtype == L2TP_PWTYPE_PPP ? "PPP" :
+		   "");
 	if (session->send_seq || session->recv_seq)
 		seq_printf(m, "   nr %hu, ns %hu\n", session->nr, session->ns);
 	seq_printf(m, "   refcnt %d\n", atomic_read(&session->ref_count));
-	seq_printf(m, "   config %d/%d/%c/%c/%s %08x %u\n",
+	seq_printf(m, "   config %d/%d/%c/%c/%s/%s %08x %u\n",
 		   session->mtu, session->mru,
 		   session->recv_seq ? 'R' : '-',
 		   session->send_seq ? 'S' : '-',
+		   session->data_seq == 1 ? "IPSEQ" :
+		   session->data_seq == 2 ? "DATASEQ" : "-",
 		   session->lns_mode ? "LNS" : "LAC",
 		   session->debug,
 		   jiffies_to_msecs(session->reorder_timeout));
+	seq_printf(m, "   offset %hu l2specific %hu/%hu\n",
+		   session->offset, session->l2specific_type, session->l2specific_len);
+	if (session->cookie_len) {
+		seq_printf(m, "   cookie %02x%02x%02x%02x",
+			   session->cookie[0], session->cookie[1],
+			   session->cookie[2], session->cookie[3]);
+		if (session->cookie_len == 8)
+			seq_printf(m, "%02x%02x%02x%02x",
+				   session->cookie[4], session->cookie[5],
+				   session->cookie[6], session->cookie[7]);
+		seq_printf(m, "\n");
+	}
+	if (session->peer_cookie_len) {
+		seq_printf(m, "   peer cookie %02x%02x%02x%02x",
+			   session->peer_cookie[0], session->peer_cookie[1],
+			   session->peer_cookie[2], session->peer_cookie[3]);
+		if (session->peer_cookie_len == 8)
+			seq_printf(m, "%02x%02x%02x%02x",
+				   session->peer_cookie[4], session->peer_cookie[5],
+				   session->peer_cookie[6], session->peer_cookie[7]);
+		seq_printf(m, "\n");
+	}
+
 	seq_printf(m, "   %hu/%hu tx %llu/%llu/%llu rx %llu/%llu/%llu\n",
 		   session->nr, session->ns,
 		   (unsigned long long)session->stats.tx_packets,
@@ -1342,11 +1628,15 @@ static int l2tp_seq_show(struct seq_file *m, void *v)
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(m, "L2TP driver info, " L2TP_DRV_VERSION "\n");
 		seq_puts(m, "TUNNEL ID, peer ID from IP to IP\n");
+		seq_puts(m, " L2TPv2/L2TPv3\n");
 		seq_puts(m, " sessions session-count, refcnt refcnt/sk->refcnt\n");
 		seq_puts(m, " debug tx-pkts/bytes/errs rx-pkts/bytes/errs\n");
-		seq_puts(m, "  SESSION ID, peer ID\n");
+		seq_puts(m, "  SESSION ID, peer ID, PWTYPE\n");
 		seq_puts(m, "   refcnt cnt\n");
-		seq_puts(m, "   mtu/mru/rcvseq/sendseq/lns debug reorderto\n");
+		seq_puts(m, "   offset OFFSET l2specific TYPE/LEN\n");
+		seq_puts(m, "   [ cookie ]\n");
+		seq_puts(m, "   [ peer cookie ]\n");
+		seq_puts(m, "   config mtu/mru/rcvseq/sendseq/dataseq/lns debug reorderto\n");
 		seq_puts(m, "   nr/ns tx-pkts/bytes/errs rx-pkts/bytes/errs\n");
 
 		seq_printf(m, "tunnels %d sessions %d\n", atomic_read(&l2tp_tunnel_count), atomic_read(&l2tp_session_count));
@@ -1396,6 +1686,7 @@ static __net_init int l2tp_init_net(struct net *net)
 	struct l2tp_net *pn;
 	struct proc_dir_entry *pde;
 	int err;
+	int hash;
 
 	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
 	if (!pn)
@@ -1404,6 +1695,11 @@ static __net_init int l2tp_init_net(struct net *net)
 	INIT_LIST_HEAD(&pn->l2tp_tunnel_list);
 	rwlock_init(&pn->l2tp_tunnel_list_lock);
 
+	for (hash = 0; hash < L2TP_HASH_SIZE_2; hash++)
+		INIT_HLIST_HEAD(&pn->l2tp_session_hlist[hash]);
+
+	rwlock_init(&pn->l2tp_session_hlist_lock);
+
 	err = net_assign_generic(net, l2tp_net_id, pn);
 	if (err)
 		goto out;
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 80ce1ce..87a06b2 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -15,9 +15,14 @@
 #define L2TP_TUNNEL_MAGIC	0x42114DDA
 #define L2TP_SESSION_MAGIC	0x0C04EB7D
 
+/* Per tunnel, session hash table size */
 #define L2TP_HASH_BITS	4
 #define L2TP_HASH_SIZE	(1 << L2TP_HASH_BITS)
 
+/* System-wide, session hash table size */
+#define L2TP_HASH_BITS_2	8
+#define L2TP_HASH_SIZE_2	(1 << L2TP_HASH_BITS_2)
+
 /* Debug message categories for the DEBUG socket option */
 enum {
 	L2TP_MSG_DEBUG		= (1 << 0),	/* verbose debug (if
@@ -28,6 +33,21 @@ enum {
 	L2TP_MSG_DATA		= (1 << 3),	/* data packets */
 };
 
+enum l2tp_pwtype {
+	L2TP_PWTYPE_NONE = 0x0000,
+	L2TP_PWTYPE_ETH_VLAN = 0x0004,
+	L2TP_PWTYPE_ETH = 0x0005,
+	L2TP_PWTYPE_PPP = 0x0007,
+	L2TP_PWTYPE_PPP_AC = 0x0008,
+	L2TP_PWTYPE_IP = 0x000b,
+	__L2TP_PWTYPE_MAX
+};
+
+enum l2tp_l2spec_type {
+	L2TP_L2SPECTYPE_NONE,
+	L2TP_L2SPECTYPE_DEFAULT,
+};
+
 struct sk_buff;
 
 struct l2tp_stats {
@@ -39,6 +59,7 @@ struct l2tp_stats {
 	u64			rx_seq_discards;
 	u64			rx_oos_packets;
 	u64			rx_errors;
+	u64			rx_cookie_discards;
 };
 
 struct l2tp_tunnel;
@@ -47,6 +68,7 @@ struct l2tp_tunnel;
  * packets and transmit outgoing ones.
  */
 struct l2tp_session_cfg {
+	enum l2tp_pwtype	pw_type;
 	unsigned		data_seq:2;	/* data sequencing level
 						 * 0 => none, 1 => IP only,
 						 * 2 => all
@@ -60,12 +82,17 @@ struct l2tp_session_cfg {
 						 * control of LNS. */
 	int			debug;		/* bitmask of debug message
 						 * categories */
-	int			offset;		/* offset to payload */
+	u16			offset;		/* offset to payload */
+	u16			l2specific_len;	/* Layer 2 specific length */
+	u16			l2specific_type; /* Layer 2 specific type */
+	u8			cookie[8];	/* optional cookie */
+	int			cookie_len;	/* 0, 4 or 8 bytes */
+	u8			peer_cookie[8];	/* peer's cookie */
+	int			peer_cookie_len; /* 0, 4 or 8 bytes */
 	int			reorder_timeout; /* configured reorder timeout
 						  * (in jiffies) */
 	int			mtu;
 	int			mru;
-	int			hdr_len;
 };
 
 struct l2tp_session {
@@ -76,8 +103,17 @@ struct l2tp_session {
 						 * context */
 	u32			session_id;
 	u32			peer_session_id;
-	u16			nr;		/* session NR state (receive) */
-	u16			ns;		/* session NR state (send) */
+	u8			cookie[8];
+	int			cookie_len;
+	u8			peer_cookie[8];
+	int			peer_cookie_len;
+	u16			offset;		/* offset from end of L2TP header
+						   to beginning of data */
+	u16			l2specific_len;
+	u16			l2specific_type;
+	u16			hdr_len;
+	u32			nr;		/* session NR state (receive) */
+	u32			ns;		/* session NR state (send) */
 	struct sk_buff_head	reorder_q;	/* receive reorder queue */
 	struct hlist_node	hlist;		/* Hash list node */
 	atomic_t		ref_count;
@@ -100,9 +136,11 @@ struct l2tp_session {
 						  * (in jiffies) */
 	int			mtu;
 	int			mru;
-	int			hdr_len;
+	enum l2tp_pwtype	pwtype;
 	struct l2tp_stats	stats;
+	struct hlist_node	global_hlist;	/* Global hash list node */
 
+	int (*build_header)(struct l2tp_session *session, void *buf);
 	void (*recv_skb)(struct l2tp_session *session, struct sk_buff *skb, int data_len);
 	void (*session_close)(struct l2tp_session *session);
 	void (*ref)(struct l2tp_session *session);
@@ -134,7 +172,6 @@ struct l2tp_tunnel {
 	char			name[20];	/* for logging */
 	int			debug;		/* bitmask of debug message
 						 * categories */
-	int			hdr_len;
 	struct l2tp_stats	stats;
 
 	struct list_head	list;		/* Keep a list of all tunnels */
@@ -182,7 +219,7 @@ out:
 	return tunnel;
 }
 
-extern struct l2tp_session *l2tp_session_find(struct l2tp_tunnel *tunnel, u32 session_id);
+extern struct l2tp_session *l2tp_session_find(struct net *net, struct l2tp_tunnel *tunnel, u32 session_id);
 extern struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth, int *skipped);
 extern struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id);
 extern struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth, int *skipped);
@@ -191,14 +228,15 @@ extern int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_i
 extern struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunnel, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg);
 extern void l2tp_tunnel_free(struct l2tp_tunnel *tunnel);
 extern void l2tp_session_free(struct l2tp_session *session);
+extern void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb, unsigned char *ptr, unsigned char *optr, u16 hdrflags, int length, int (*payload_hook)(struct sk_buff *skb));
 extern int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb, int (*payload_hook)(struct sk_buff *skb));
 extern int l2tp_udp_encap_recv(struct sock *sk, struct sk_buff *skb);
 
-extern void l2tp_build_l2tp_header(struct l2tp_session *session, void *buf);
 extern int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb, size_t data_len);
 extern int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len);
 extern void l2tp_tunnel_destruct(struct sock *sk);
 extern void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
+extern void l2tp_session_set_header_len(struct l2tp_session *session, int version);
 
 /* Tunnel reference counts. Incremented per session that is added to
  * the tunnel.
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 8f78c27..dc27543 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -684,7 +684,7 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 
 	/* Check that this session doesn't already exist */
 	error = -EEXIST;
-	session = l2tp_session_find(tunnel, sp->pppol2tp.s_session);
+	session = l2tp_session_find(sock_net(sk), tunnel, sp->pppol2tp.s_session);
 	if (session != NULL)
 		goto end;
 
@@ -692,7 +692,6 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	 * headers.
 	 */
 	cfg.mtu = cfg.mru = 1500 - PPPOL2TP_HEADER_OVERHEAD;
-	cfg.hdr_len = PPPOL2TP_L2TP_HDR_SIZE_NOSEQ;
 	cfg.debug = tunnel->debug;
 
 	/* Allocate and initialize a new session context. */
@@ -1016,7 +1015,7 @@ static int pppol2tp_tunnel_ioctl(struct l2tp_tunnel *tunnel,
 		if (stats.session_id != 0) {
 			/* resend to session ioctl handler */
 			struct l2tp_session *session =
-				l2tp_session_find(tunnel, stats.session_id);
+				l2tp_session_find(sock_net(sk), tunnel, stats.session_id);
 			if (session != NULL)
 				err = pppol2tp_session_ioctl(session, cmd, arg);
 			else

