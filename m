From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] merge sctp_opt with sctp_sock
Date: Sat, 15 Jan 2005 02:52:13 -0200
Message-ID: <41E8A17D.9040307@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040302060905050501040809"
Cc: Networking Team <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        Sridhar Samudrala <sri@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040302060905050501040809
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David, Sridhar,

	Please take a look and if its acceptable pull from:

bk://kernel.bkbits.net/acme/connection_sock-2.6

	The tricky bit here is that SCTP, to keep the existing logic,
needs a way to copy only its private area from one sock to another, so
I introduced a generic inet_sk_copy_descendant, that knows about the
inet (v4/v6) layout (wrt inet_sock and inet6_pinfo), using this and
sk->sk_prot->slab_obj_size we can copy the inet_sock descendant
private area generically.

Best Regards,

- Arnaldo

--------------040302060905050501040809
Content-Type: text/plain;
 name="sctp_sock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sctp_sock.patch"

===================================================================


ChangeSet@1.2334, 2005-01-15 02:32:54-02:00, acme@toy.ghostprotocols.net
  [SCTP] merge sctp_sock with sctp_opt
  
  No need for two structs, follow the new inet_sock layout style.
  
  Also introduce inet_sk_copy_descendant, to copy just the inet_sock
  descendant specific area from one sock to another.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 include/linux/ip.h         |   14 +++++++++
 include/linux/ipv6.h       |   11 +++++++
 include/net/sctp/sctp.h    |   19 -------------
 include/net/sctp/structs.h |   44 +++++++++++++++++++++---------
 net/sctp/associola.c       |    8 ++---
 net/sctp/bind_addr.c       |    4 +-
 net/sctp/chunk.c           |    2 -
 net/sctp/endpointola.c     |    2 -
 net/sctp/ipv6.c            |   20 +++++++-------
 net/sctp/output.c          |    4 +-
 net/sctp/protocol.c        |   16 +++++------
 net/sctp/sm_make_chunk.c   |    2 -
 net/sctp/socket.c          |   64 ++++++++++++++++++++++-----------------------
 net/sctp/transport.c       |    2 -
 net/sctp/ulpqueue.c        |    3 --
 15 files changed, 120 insertions(+), 95 deletions(-)


diff -Nru a/include/linux/ip.h b/include/linux/ip.h
--- a/include/linux/ip.h	2005-01-15 02:43:18 -02:00
+++ b/include/linux/ip.h	2005-01-15 02:43:18 -02:00
@@ -158,6 +158,20 @@
 	return (struct inet_sock *)sk;
 }
 
+static inline void __inet_sk_copy_descendant(struct sock *sk_to,
+					     const struct sock *sk_from,
+					     const int ancestor_size)
+{
+	memcpy(inet_sk(sk_to) + 1, inet_sk(sk_from) + 1,
+	       sk_from->sk_prot->slab_obj_size - ancestor_size);
+}
+#if !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE))
+static inline void inet_sk_copy_descendant(struct sock *sk_to,
+					   const struct sock *sk_from)
+{
+	__inet_sk_copy_descendant(sk_to, sk_from, sizeof(struct inet_sock));
+}
+#endif
 #endif
 
 struct iphdr {
diff -Nru a/include/linux/ipv6.h b/include/linux/ipv6.h
--- a/include/linux/ipv6.h	2005-01-15 02:43:18 -02:00
+++ b/include/linux/ipv6.h	2005-01-15 02:43:18 -02:00
@@ -282,6 +282,17 @@
 	return &((struct raw6_sock *)__sk)->raw6;
 }
 
+static inline void inet_sk_copy_descendant(struct sock *sk_to,
+					   const struct sock *sk_from)
+{
+	int ancestor_size = sizeof(struct inet_sock);
+
+	if (sk_from->sk_family == PF_INET6)
+		ancestor_size += sizeof(struct ipv6_pinfo);
+
+	__inet_sk_copy_descendant(sk_to, sk_from, ancestor_size);
+}
+
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
 #define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
 #else
diff -Nru a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h	2005-01-15 02:43:18 -02:00
+++ b/include/net/sctp/sctp.h	2005-01-15 02:43:18 -02:00
@@ -423,7 +423,7 @@
 }
 
 /* Break down data chunks at this point.  */
-static inline int sctp_frag_point(const struct sctp_opt *sp, int pmtu)
+static inline int sctp_frag_point(const struct sctp_sock *sp, int pmtu)
 {
 	int frag = pmtu;
 
@@ -575,23 +575,6 @@
 	h ^= vtag;
 	return (h & (sctp_assoc_hashsize-1));
 }
-
-/* WARNING: Do not change the layout of the members in sctp_sock! */
-struct sctp_sock {
-	struct inet_sock  inet;
-	struct sctp_opt	  sctp;
-};
-
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-struct sctp6_sock {
-	struct inet_sock  inet;
-	struct sctp_opt	  sctp;
-	struct ipv6_pinfo inet6;
-};
-#endif /* CONFIG_IPV6 */
-
-#define sctp_sk(__sk) (&((struct sctp_sock *)__sk)->sctp)
-#define sctp_opt2sk(__sp) &container_of(__sp, struct sctp_sock, sctp)->inet.sk
 
 /* Is a socket of this style? */
 #define sctp_style(sk, style) __sctp_style((sk), (SCTP_SOCKET_##style))
diff -Nru a/include/net/sctp/structs.h b/include/net/sctp/structs.h
--- a/include/net/sctp/structs.h	2005-01-15 02:43:18 -02:00
+++ b/include/net/sctp/structs.h	2005-01-15 02:43:18 -02:00
@@ -58,6 +58,7 @@
 #include <linux/socket.h>	/* linux/in.h needs this!!    */
 #include <linux/in.h>		/* We get struct sockaddr_in. */
 #include <linux/in6.h>		/* We get struct in6_addr     */
+#include <linux/ipv6.h>
 #include <asm/param.h>		/* We get MAXHOSTNAMELEN.     */
 #include <asm/atomic.h>		/* This gets us atomic counters.  */
 #include <linux/skbuff.h>	/* We need sk_buff_head. */
@@ -84,7 +85,6 @@
 struct sctp_outq;
 struct sctp_bind_addr;
 struct sctp_ulpq;
-struct sctp_opt;
 struct sctp_ep_common;
 struct sctp_ssnmap;
 
@@ -234,7 +234,9 @@
 } sctp_socket_type_t;
 
 /* Per socket SCTP information. */
-struct sctp_opt {
+struct sctp_sock {
+	/* inet_sock has to be the first member of sctp_sock */
+	struct inet_sock inet;
 	/* What kind of a socket is this? */
 	sctp_socket_type_t type;
 
@@ -272,6 +274,22 @@
 	struct sk_buff_head pd_lobby;
 };
 
+static inline struct sctp_sock *sctp_sk(const struct sock *sk)
+{
+       return (struct sctp_sock *)sk;
+}
+
+static inline struct sock *sctp_opt2sk(const struct sctp_sock *sp)
+{
+       return (struct sock *)sp;
+}
+
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+struct sctp6_sock {
+       struct sctp_sock  sctp;
+       struct ipv6_pinfo inet6;
+};
+#endif /* CONFIG_IPV6 */
 
 
 /* This is our APPLICATION-SPECIFIC state cookie.
@@ -487,12 +505,12 @@
 	int		(*to_addr_param) (const union sctp_addr *,
 					  union sctp_addr_param *); 
 	int		(*addr_valid)	(union sctp_addr *,
-					 struct sctp_opt *);
+					 struct sctp_sock *);
 	sctp_scope_t	(*scope) (union sctp_addr *);
 	void		(*inaddr_any)	(union sctp_addr *, unsigned short);
 	int		(*is_any)	(const union sctp_addr *);
 	int		(*available)	(union sctp_addr *,
-					 struct sctp_opt *);
+					 struct sctp_sock *);
 	int		(*skb_iif)	(const struct sk_buff *sk);
 	int		(*is_ce)	(const struct sk_buff *sk);
 	void		(*seq_dump_addr)(struct seq_file *seq,
@@ -510,16 +528,16 @@
 struct sctp_pf {
 	void (*event_msgname)(struct sctp_ulpevent *, char *, int *);
 	void (*skb_msgname)  (struct sk_buff *, char *, int *);
-	int  (*af_supported) (sa_family_t, struct sctp_opt *);
+	int  (*af_supported) (sa_family_t, struct sctp_sock *);
 	int  (*cmp_addr) (const union sctp_addr *,
 			  const union sctp_addr *,
-			  struct sctp_opt *);
-	int  (*bind_verify) (struct sctp_opt *, union sctp_addr *);
-	int  (*send_verify) (struct sctp_opt *, union sctp_addr *);
-	int  (*supported_addrs)(const struct sctp_opt *, __u16 *);
+			  struct sctp_sock *);
+	int  (*bind_verify) (struct sctp_sock *, union sctp_addr *);
+	int  (*send_verify) (struct sctp_sock *, union sctp_addr *);
+	int  (*supported_addrs)(const struct sctp_sock *, __u16 *);
 	struct sock *(*create_accept_sk) (struct sock *sk,
 					  struct sctp_association *asoc);
-	void (*addr_v4map) (struct sctp_opt *, union sctp_addr *);
+	void (*addr_v4map) (struct sctp_sock *, union sctp_addr *);
 	struct sctp_af *af;
 };
 
@@ -922,7 +940,7 @@
 void sctp_transport_set_owner(struct sctp_transport *,
 			      struct sctp_association *);
 void sctp_transport_route(struct sctp_transport *, union sctp_addr *,
-			  struct sctp_opt *);
+			  struct sctp_sock *);
 void sctp_transport_pmtu(struct sctp_transport *);
 void sctp_transport_free(struct sctp_transport *);
 void sctp_transport_reset_timers(struct sctp_transport *);
@@ -1071,11 +1089,11 @@
 		       int gfp);
 int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
 int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
-			 struct sctp_opt *);
+			 struct sctp_sock *);
 union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
 					const union sctp_addr	*addrs,
 					int			addrcnt,
-					struct sctp_opt		*opt);
+					struct sctp_sock	*opt);
 union sctp_params sctp_bind_addrs_to_raw(const struct sctp_bind_addr *bp,
 					 int *addrs_len, int gfp);
 int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw, int len,
diff -Nru a/net/sctp/associola.c b/net/sctp/associola.c
--- a/net/sctp/associola.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/associola.c	2005-01-15 02:43:18 -02:00
@@ -73,7 +73,7 @@
 					  sctp_scope_t scope,
 					  int gfp)
 {
-	struct sctp_opt *sp;
+	struct sctp_sock *sp;
 	int i;
 
 	/* Retrieve the SCTP per socket area.  */
@@ -434,7 +434,7 @@
 					   int gfp)
 {
 	struct sctp_transport *peer;
-	struct sctp_opt *sp;
+	struct sctp_sock *sp;
 	unsigned short port;
 
 	sp = sctp_sk(asoc->base.sk);
@@ -886,7 +886,7 @@
 /* This routine moves an association from its old sk to a new sk.  */
 void sctp_assoc_migrate(struct sctp_association *assoc, struct sock *newsk)
 {
-	struct sctp_opt *newsp = sctp_sk(newsk);
+	struct sctp_sock *newsp = sctp_sk(newsk);
 	struct sock *oldsk = assoc->base.sk;
 
 	/* Delete the association from the old endpoint's list of
@@ -1059,7 +1059,7 @@
 	}
 
 	if (pmtu) {
-		struct sctp_opt *sp = sctp_sk(asoc->base.sk);
+		struct sctp_sock *sp = sctp_sk(asoc->base.sk);
 		asoc->pmtu = pmtu;
 		asoc->frag_point = sctp_frag_point(sp, pmtu);
 	}
diff -Nru a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
--- a/net/sctp/bind_addr.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/bind_addr.c	2005-01-15 02:43:18 -02:00
@@ -293,7 +293,7 @@
 /* Does this contain a specified address?  Allow wildcarding. */
 int sctp_bind_addr_match(struct sctp_bind_addr *bp, 
 			 const union sctp_addr *addr,
-			 struct sctp_opt *opt)
+			 struct sctp_sock *opt)
 {
 	struct sctp_sockaddr_entry *laddr;
 	struct list_head *pos;
@@ -313,7 +313,7 @@
 union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
 					const union sctp_addr	*addrs,
 					int			addrcnt,
-					struct sctp_opt		*opt)
+					struct sctp_sock	*opt)
 {
 	struct sctp_sockaddr_entry	*laddr;
 	union sctp_addr			*addr;
diff -Nru a/net/sctp/chunk.c b/net/sctp/chunk.c
--- a/net/sctp/chunk.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/chunk.c	2005-01-15 02:43:18 -02:00
@@ -77,7 +77,7 @@
 {
 	struct list_head *pos, *temp;
 	struct sctp_chunk *chunk;
-	struct sctp_opt *sp;
+	struct sctp_sock *sp;
 	struct sctp_ulpevent *ev;
 	struct sctp_association *asoc = NULL;
 	int error = 0, notify;
diff -Nru a/net/sctp/endpointola.c b/net/sctp/endpointola.c
--- a/net/sctp/endpointola.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/endpointola.c	2005-01-15 02:43:18 -02:00
@@ -69,7 +69,7 @@
 static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 						struct sock *sk, int gfp)
 {
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	memset(ep, 0, sizeof(struct sctp_endpoint));
 
 	/* Initialize the base structure. */
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/ipv6.c	2005-01-15 02:43:18 -02:00
@@ -502,7 +502,7 @@
 }
 
 /* Should this be available for binding?   */
-static int sctp_v6_available(union sctp_addr *addr, struct sctp_opt *sp)
+static int sctp_v6_available(union sctp_addr *addr, struct sctp_sock *sp)
 {
 	int type;
 	struct in6_addr *in6 = (struct in6_addr *)&addr->v6.sin6_addr;
@@ -531,14 +531,14 @@
  * Return 0 - If the address is a non-unicast or an illegal address.
  * Return 1 - If the address is a unicast.
  */
-static int sctp_v6_addr_valid(union sctp_addr *addr, struct sctp_opt *sp)
+static int sctp_v6_addr_valid(union sctp_addr *addr, struct sctp_sock *sp)
 {
 	int ret = ipv6_addr_type(&addr->v6.sin6_addr);
 
 	/* Support v4-mapped-v6 address. */
 	if (ret == IPV6_ADDR_MAPPED) {
 		/* Note: This routine is used in input, so v4-mapped-v6
-		 * are disallowed here when there is no sctp_opt.
+		 * are disallowed here when there is no sctp_sock.
 		 */
 		if (!sp || !sp->v4mapped)
 			return 0;
@@ -616,7 +616,7 @@
 	newsk->sk_shutdown = sk->sk_shutdown;
 
 	newsctp6sk = (struct sctp6_sock *)newsk;
-	newsctp6sk->inet.pinet6 = &newsctp6sk->inet6;
+	inet_sk(newsk)->pinet6 = &newsctp6sk->inet6;
 
 	newinet = inet_sk(newsk);
 	newnp = inet6_sk(newsk);
@@ -661,7 +661,7 @@
 }
 
 /* Map v4 address to mapped v6 address */
-static void sctp_v6_addr_v4map(struct sctp_opt *sp, union sctp_addr *addr)
+static void sctp_v6_addr_v4map(struct sctp_sock *sp, union sctp_addr *addr)
 {
 	if (sp->v4mapped && AF_INET == addr->sa.sa_family)
 		sctp_v4_map_v6(addr);
@@ -766,7 +766,7 @@
 }
 
 /* Do we support this AF? */
-static int sctp_inet6_af_supported(sa_family_t family, struct sctp_opt *sp)
+static int sctp_inet6_af_supported(sa_family_t family, struct sctp_sock *sp)
 {
 	switch (family) {
 	case AF_INET6:
@@ -786,7 +786,7 @@
  */
 static int sctp_inet6_cmp_addr(const union sctp_addr *addr1,
 			       const union sctp_addr *addr2,
-			       struct sctp_opt *opt)
+			       struct sctp_sock *opt)
 {
 	struct sctp_af *af1, *af2;
 
@@ -808,7 +808,7 @@
 /* Verify that the provided sockaddr looks bindable.   Common verification,
  * has already been taken care of.
  */
-static int sctp_inet6_bind_verify(struct sctp_opt *opt, union sctp_addr *addr)
+static int sctp_inet6_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 {
 	struct sctp_af *af;
 
@@ -838,7 +838,7 @@
 /* Verify that the provided sockaddr looks bindable.   Common verification,
  * has already been taken care of.
  */
-static int sctp_inet6_send_verify(struct sctp_opt *opt, union sctp_addr *addr)
+static int sctp_inet6_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
 {
 	struct sctp_af *af = NULL;
 
@@ -872,7 +872,7 @@
  * addresses.
  * Returns number of addresses supported.
  */
-static int sctp_inet6_supported_addrs(const struct sctp_opt *opt,
+static int sctp_inet6_supported_addrs(const struct sctp_sock *opt,
 				      __u16 *types)
 {
 	types[0] = SCTP_PARAM_IPV4_ADDRESS;
diff -Nru a/net/sctp/output.c b/net/sctp/output.c
--- a/net/sctp/output.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/output.c	2005-01-15 02:43:18 -02:00
@@ -110,7 +110,7 @@
 	packet->destination_port = dport;
 	skb_queue_head_init(&packet->chunks);
 	if (asoc) {
-		struct sctp_opt *sp = sctp_sk(asoc->base.sk);	
+		struct sctp_sock *sp = sctp_sk(asoc->base.sk);	
 		overhead = sp->pf->af->net_header_len; 
 	} else {
 		overhead = sizeof(struct ipv6hdr);
@@ -534,7 +534,7 @@
 	struct sctp_transport *transport = packet->transport;
 	__u32 max_burst_bytes;
 	struct sctp_association *asoc = transport->asoc;
-	struct sctp_opt *sp = sctp_sk(asoc->base.sk);
+	struct sctp_sock *sp = sctp_sk(asoc->base.sk);
 	struct sctp_outq *q = &asoc->outqueue;
 
 	/* RFC 2960 6.1  Transmission of DATA Chunks
diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/protocol.c	2005-01-15 02:43:18 -02:00
@@ -364,7 +364,7 @@
  * Return 0 - If the address is a non-unicast or an illegal address.
  * Return 1 - If the address is a unicast.
  */
-static int sctp_v4_addr_valid(union sctp_addr *addr, struct sctp_opt *sp)
+static int sctp_v4_addr_valid(union sctp_addr *addr, struct sctp_sock *sp)
 {
 	/* Is this a non-unicast address or a unusable SCTP address? */
 	if (IS_IPV4_UNUSABLE_ADDRESS(&addr->v4.sin_addr.s_addr))
@@ -374,7 +374,7 @@
 }
 
 /* Should this be available for binding?   */
-static int sctp_v4_available(union sctp_addr *addr, struct sctp_opt *sp)
+static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
 {
 	int ret = inet_addr_type(addr->v4.sin_addr.s_addr);
 
@@ -608,7 +608,7 @@
 }
 
 /* Map address, empty for v4 family */
-static void sctp_v4_addr_v4map(struct sctp_opt *sp, union sctp_addr *addr)
+static void sctp_v4_addr_v4map(struct sctp_sock *sp, union sctp_addr *addr)
 {
 	/* Empty */
 }
@@ -745,7 +745,7 @@
 }
 
 /* Do we support this AF? */
-static int sctp_inet_af_supported(sa_family_t family, struct sctp_opt *sp)
+static int sctp_inet_af_supported(sa_family_t family, struct sctp_sock *sp)
 {
 	/* PF_INET only supports AF_INET addresses. */
 	return (AF_INET == family);
@@ -754,7 +754,7 @@
 /* Address matching with wildcards allowed. */
 static int sctp_inet_cmp_addr(const union sctp_addr *addr1,
 			      const union sctp_addr *addr2,
-			      struct sctp_opt *opt)
+			      struct sctp_sock *opt)
 {
 	/* PF_INET only supports AF_INET addresses. */
 	if (addr1->sa.sa_family != addr2->sa.sa_family)
@@ -771,7 +771,7 @@
 /* Verify that provided sockaddr looks bindable.  Common verification has
  * already been taken care of.
  */
-static int sctp_inet_bind_verify(struct sctp_opt *opt, union sctp_addr *addr)
+static int sctp_inet_bind_verify(struct sctp_sock *opt, union sctp_addr *addr)
 {
 	return sctp_v4_available(addr, opt);
 }
@@ -779,7 +779,7 @@
 /* Verify that sockaddr looks sendable.  Common verification has already
  * been taken care of.
  */
-static int sctp_inet_send_verify(struct sctp_opt *opt, union sctp_addr *addr)
+static int sctp_inet_send_verify(struct sctp_sock *opt, union sctp_addr *addr)
 {
 	return 1;
 }
@@ -787,7 +787,7 @@
 /* Fill in Supported Address Type information for INIT and INIT-ACK
  * chunks.  Returns number of addresses supported.
  */
-static int sctp_inet_supported_addrs(const struct sctp_opt *opt,
+static int sctp_inet_supported_addrs(const struct sctp_sock *opt,
 				     __u16 *types)
 {
 	types[0] = SCTP_PARAM_IPV4_ADDRESS;
diff -Nru a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
--- a/net/sctp/sm_make_chunk.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/sm_make_chunk.c	2005-01-15 02:43:18 -02:00
@@ -181,7 +181,7 @@
 	size_t chunksize;
 	struct sctp_chunk *retval = NULL;
 	int num_types, addrs_len = 0;
-	struct sctp_opt *sp;
+	struct sctp_sock *sp;
 	sctp_supported_addrs_param_t sat;
 	__u16 types[2];
 	sctp_adaption_ind_param_t aiparam;
diff -Nru a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/socket.c	2005-01-15 02:43:18 -02:00
@@ -93,7 +93,7 @@
 static int sctp_wait_for_connect(struct sctp_association *, long *timeo_p);
 static int sctp_wait_for_accept(struct sock *sk, long timeo);
 static void sctp_wait_for_close(struct sock *sk, long timeo);
-static struct sctp_af *sctp_sockaddr_af(struct sctp_opt *opt,
+static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
 					union sctp_addr *addr, int len);
 static int sctp_bindx_add(struct sock *, struct sockaddr *, int);
 static int sctp_bindx_rem(struct sock *, struct sockaddr *, int);
@@ -269,7 +269,7 @@
 static long sctp_get_port_local(struct sock *, union sctp_addr *);
 
 /* Verify this is a valid sockaddr. */
-static struct sctp_af *sctp_sockaddr_af(struct sctp_opt *opt,
+static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
 					union sctp_addr *addr, int len)
 {
 	struct sctp_af *af;
@@ -294,7 +294,7 @@
 /* Bind a local address either to an endpoint or to an association.  */
 SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 {
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
 	struct sctp_bind_addr *bp = &ep->base.bind_addr;
 	struct sctp_af *af;
@@ -467,7 +467,7 @@
 				   struct sockaddr	*addrs,
 				   int 			addrcnt)
 {
-	struct sctp_opt			*sp;
+	struct sctp_sock		*sp;
 	struct sctp_endpoint		*ep;
 	struct sctp_association		*asoc;
 	struct sctp_bind_addr		*bp;
@@ -572,7 +572,7 @@
  */
 int sctp_bindx_rem(struct sock *sk, struct sockaddr *addrs, int addrcnt)
 {
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
 	int cnt;
 	struct sctp_bind_addr *bp = &ep->base.bind_addr;
@@ -656,7 +656,7 @@
 				   struct sockaddr	*addrs,
 				   int			addrcnt)
 {
-	struct sctp_opt		*sp;
+	struct sctp_sock	*sp;
 	struct sctp_endpoint	*ep;
 	struct sctp_association	*asoc;
 	struct sctp_bind_addr	*bp;
@@ -1051,7 +1051,7 @@
 SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			     struct msghdr *msg, size_t msg_len)
 {
-	struct sctp_opt *sp;
+	struct sctp_sock *sp;
 	struct sctp_endpoint *ep;
 	struct sctp_association *new_asoc=NULL, *asoc=NULL;
 	struct sctp_transport *transport, *chunk_tp;
@@ -1492,7 +1492,7 @@
 			     int flags, int *addr_len)
 {
 	struct sctp_ulpevent *event = NULL;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	struct sk_buff *skb;
 	int copied;
 	int err = 0;
@@ -1637,7 +1637,7 @@
 static int sctp_setsockopt_autoclose(struct sock *sk, char __user *optval,
 					    int optlen)
 {
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	/* Applicable to UDP-style socket only */
 	if (sctp_style(sk, TCP))
@@ -1779,7 +1779,7 @@
 static int sctp_setsockopt_initmsg(struct sock *sk, char __user *optval, int optlen)
 {
 	struct sctp_initmsg sinit;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	if (optlen != sizeof(struct sctp_initmsg))
 		return -EINVAL;
@@ -1817,7 +1817,7 @@
 {
 	struct sctp_sndrcvinfo info;
 	struct sctp_association *asoc;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	if (optlen != sizeof(struct sctp_sndrcvinfo))
 		return -EINVAL;
@@ -1934,7 +1934,7 @@
 		/* If there is no association or the association-id = 0
 		 * set the values to the endpoint.
 		 */
-		struct sctp_opt *sp = sctp_sk(sk);
+		struct sctp_sock *sp = sctp_sk(sk);
 
 		if (rtoinfo.srto_initial != 0)
 			sp->rtoinfo.srto_initial = rtoinfo.srto_initial;
@@ -1987,7 +1987,7 @@
 		}
 	} else {
 		/* Set the values to the endpoint */
-		struct sctp_opt *sp = sctp_sk(sk);
+		struct sctp_sock *sp = sctp_sk(sk);
 
 		if (assocparams.sasoc_asocmaxrxt != 0)
 			sp->assocparams.sasoc_asocmaxrxt =
@@ -2012,7 +2012,7 @@
 static int sctp_setsockopt_mappedv4(struct sock *sk, char __user *optval, int optlen)
 {
 	int val;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	if (optlen < sizeof(int))
 		return -EINVAL;
@@ -2040,7 +2040,7 @@
 {
 	struct sctp_association *asoc;
 	struct list_head *pos;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	int val;
 
 	if (optlen < sizeof(int))
@@ -2074,7 +2074,7 @@
 static int sctp_setsockopt_peer_primary_addr(struct sock *sk, char __user *optval,
 					     int optlen)
 {
-	struct sctp_opt		*sp;
+	struct sctp_sock	*sp;
 	struct sctp_endpoint	*ep;
 	struct sctp_association	*asoc = NULL;
 	struct sctp_setpeerprim	prim;
@@ -2269,7 +2269,7 @@
 SCTP_STATIC int sctp_connect(struct sock *sk, struct sockaddr *uaddr,
 			     int addr_len)
 {
-	struct sctp_opt *sp;
+	struct sctp_sock *sp;
 	struct sctp_endpoint *ep;
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
@@ -2390,7 +2390,7 @@
  */
 SCTP_STATIC struct sock *sctp_accept(struct sock *sk, int flags, int *err)
 {
-	struct sctp_opt *sp;
+	struct sctp_sock *sp;
 	struct sctp_endpoint *ep;
 	struct sock *newsk = NULL;
 	struct sctp_association *asoc;
@@ -2453,7 +2453,7 @@
 SCTP_STATIC int sctp_init_sock(struct sock *sk)
 {
 	struct sctp_endpoint *ep;
-	struct sctp_opt *sp;
+	struct sctp_sock *sp;
 
 	SCTP_DEBUG_PRINTK("sctp_init_sock(sk: %p)\n", sk);
 
@@ -3007,7 +3007,7 @@
 	struct sctp_transport *from;
 	void __user *to;
 	union sctp_addr temp;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	int addrlen;
 
 	if (len != sizeof(struct sctp_getaddrs))
@@ -3164,7 +3164,7 @@
 	struct sctp_sockaddr_entry *addr;
 	void __user *to;
 	union sctp_addr temp;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	int addrlen;
 	rwlock_t *addr_lock;
 	int err = 0;
@@ -3250,7 +3250,7 @@
 {
 	struct sctp_prim prim;
 	struct sctp_association *asoc;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	if (len != sizeof(struct sctp_prim))
 		return -EINVAL;
@@ -3329,7 +3329,7 @@
 {
 	struct sctp_sndrcvinfo info;
 	struct sctp_association *asoc;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	if (len != sizeof(struct sctp_sndrcvinfo))
 		return -EINVAL;
@@ -3423,7 +3423,7 @@
 		rtoinfo.srto_min = jiffies_to_msecs(asoc->rto_min);
 	} else {
 		/* Values corresponding to the endpoint. */
-		struct sctp_opt *sp = sctp_sk(sk);
+		struct sctp_sock *sp = sctp_sk(sk);
 
 		rtoinfo.srto_initial = sp->rtoinfo.srto_initial;
 		rtoinfo.srto_max = sp->rtoinfo.srto_max;
@@ -3489,7 +3489,7 @@
 		assocparams.sasoc_number_peer_destinations = cnt;
 	} else {
 		/* Values corresponding to the endpoint */
-		struct sctp_opt *sp = sctp_sk(sk);
+		struct sctp_sock *sp = sctp_sk(sk);
 
 		assocparams.sasoc_asocmaxrxt = sp->assocparams.sasoc_asocmaxrxt;
 		assocparams.sasoc_peer_rwnd = sp->assocparams.sasoc_peer_rwnd;
@@ -3524,7 +3524,7 @@
 				    char __user *optval, int __user *optlen)
 {
 	int val;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	if (len < sizeof(int))
 		return -EINVAL;
@@ -3876,7 +3876,7 @@
  */
 SCTP_STATIC int sctp_seqpacket_listen(struct sock *sk, int backlog)
 {
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
 
 	/* Only UDP style sockets that are not peeled off are allowed to
@@ -3925,7 +3925,7 @@
  */
 SCTP_STATIC int sctp_stream_listen(struct sock *sk, int backlog)
 {
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
 
 	/* If backlog is zero, disable listening. */
@@ -4026,7 +4026,7 @@
 unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
 {
 	struct sock *sk = sock->sk;
-	struct sctp_opt *sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 	unsigned int mask;
 
 	poll_wait(file, sk->sk_sleep, wait);
@@ -4654,8 +4654,8 @@
 			      struct sctp_association *assoc,
 			      sctp_socket_type_t type)
 {
-	struct sctp_opt *oldsp = sctp_sk(oldsk);
-	struct sctp_opt *newsp = sctp_sk(newsk);
+	struct sctp_sock *oldsp = sctp_sk(oldsk);
+	struct sctp_sock *newsp = sctp_sk(newsk);
 	struct sctp_bind_bucket *pp; /* hash list port iterator */
 	struct sctp_endpoint *newep = newsp->ep;
 	struct sk_buff *skb, *tmp;
@@ -4667,7 +4667,7 @@
 	newsk->sk_sndbuf = oldsk->sk_sndbuf;
 	newsk->sk_rcvbuf = oldsk->sk_rcvbuf;
 	/* Brute force copy old sctp opt. */
-	memcpy(newsp, oldsp, sizeof(struct sctp_opt));
+	inet_sk_copy_descendant(newsk, oldsk);
 
 	/* Restore the ep value that was overwritten with the above structure
 	 * copy.
diff -Nru a/net/sctp/transport.c b/net/sctp/transport.c
--- a/net/sctp/transport.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/transport.c	2005-01-15 02:43:18 -02:00
@@ -237,7 +237,7 @@
  * address.
  */
 void sctp_transport_route(struct sctp_transport *transport,
-			  union sctp_addr *saddr, struct sctp_opt *opt)
+			  union sctp_addr *saddr, struct sctp_sock *opt)
 {
 	struct sctp_association *asoc = transport->asoc;
 	struct sctp_af *af = transport->af_specific;
diff -Nru a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
--- a/net/sctp/ulpqueue.c	2005-01-15 02:43:18 -02:00
+++ b/net/sctp/ulpqueue.c	2005-01-15 02:43:18 -02:00
@@ -138,8 +138,7 @@
  */
 int sctp_clear_pd(struct sock *sk)
 {
-	struct sctp_opt *sp;
-	sp = sctp_sk(sk);
+	struct sctp_sock *sp = sctp_sk(sk);
 
 	sp->pd_mode = 0;
 	if (!skb_queue_empty(&sp->pd_lobby)) {


--------------040302060905050501040809--
