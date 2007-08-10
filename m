From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH for 2.6.24] SCTP: Rewrite of sctp buffer management code
Date: Fri, 10 Aug 2007 16:46:03 -0400
Message-ID: <46BCCE8B.2050605@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	"lksctp-developers@lists.sourceforge.net"
	<lksctp-developers@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:60994 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933301AbXHJUqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:46:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces autotuning to the sctp buffer management code
similar to the TCP.  The buffer space can be grown if the advertised
receive window still has room.  This might happen if small message
sizes are used, which is common in telecom environmens.
New tunables are introduced that provide limits to buffer growth
and memory pressure is entered if to much buffer spaces is used.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

 include/net/sctp/sctp.h |    5 +++
 net/sctp/endpointola.c  |    1
 net/sctp/protocol.c     |   32 +++++++++++++++++++++
 net/sctp/sm_statefuns.c |   73 +++++++++++-------------------------------------
 net/sctp/socket.c       |   67 ++++++++++++++++++++++++++++++++++++--------
 net/sctp/sysctl.c       |   33 +++++++++++++++++++++
 net/sctp/ulpevent.c     |   18 +++++++++++
 net/sctp/ulpqueue.c     |    1
 8 files changed, 163 insertions(+), 67 deletions(-)
---
 net/sctp/socket.c |   68 ++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 55 insertions(+), 13 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 01c6364..03579d5 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -106,25 +106,41 @@ static int sctp_autobind(struct sock *sk);
 static void sctp_sock_migrate(struct sock *, struct sock *,
 			      struct sctp_association *, sctp_socket_type_t);
 static char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;
+extern int sysctl_sctp_mem[3];
+extern int sysctl_sctp_rmem[3];
+extern int sysctl_sctp_wmem[3];
 
+int sctp_memory_pressure;
+atomic_t sctp_memory_allocated;
+atomic_t sctp_sockets_allocated;
+
+static void sctp_enter_memory_pressure(void)
+{
+	sctp_memory_pressure = 1;
+}
+ 
 /* Get the sndbuf space available at the time on the association.  */
 static inline int sctp_wspace(struct sctp_association *asoc)
 {
-	struct sock *sk = asoc->base.sk;
-	int amt = 0;
+ 	int amt;
 
-	if (asoc->ep->sndbuf_policy) {
-		/* make sure that no association uses more than sk_sndbuf */
-		amt = sk->sk_sndbuf - asoc->sndbuf_used;
+	if (asoc->ep->sndbuf_policy)
+		amt = asoc->sndbuf_used;
+	else
+		amt = atomic_read(&asoc->base.sk->sk_wmem_alloc);
+
+	if (amt >= asoc->base.sk->sk_sndbuf) {
+		if (asoc->base.sk->sk_userlocks & SOCK_SNDBUF_LOCK)
+			amt = 0;
+		else {
+			amt = sk_stream_wspace(asoc->base.sk);
+			if (amt < 0)
+				amt = 0;
+		}
 	} else {
-		/* do socket level accounting */
-		amt = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
+ 		amt = asoc->base.sk->sk_sndbuf - amt;
 	}
-
-	if (amt < 0)
-		amt = 0;
-
-	return amt;
+  	return amt;
 }
 
 /* Increment the used sndbuf space count of the corresponding association by
@@ -155,6 +171,7 @@ static inline void sctp_set_owner_w(struct sctp_chunk *chunk)
 				sizeof(struct sctp_chunk);
 
 	atomic_add(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
+	sk_charge_skb(sk, chunk->skb);
 }
 
 /* Verify that this is a valid address. */
@@ -3314,6 +3331,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->hmac = NULL;
 
 	SCTP_DBG_OBJCNT_INC(sock);
+	atomic_inc(&sctp_sockets_allocated);
 	return 0;
 }
 
@@ -3327,7 +3345,7 @@ SCTP_STATIC int sctp_destroy_sock(struct sock *sk)
 	/* Release our hold on the endpoint. */
 	ep = sctp_sk(sk)->ep;
 	sctp_endpoint_free(ep);
-
+	atomic_dec(&sctp_sockets_allocated);
 	return 0;
 }
 
@@ -5747,6 +5765,12 @@ static void sctp_wfree(struct sk_buff *skb)
 
 	atomic_sub(sizeof(struct sctp_chunk), &sk->sk_wmem_alloc);
 
+	/*
+	 * This undoes what is done via sk_charge_skb
+	 */
+	sk->sk_wmem_queued   -= skb->truesize;
+	sk->sk_forward_alloc += skb->truesize;
+
 	sock_wfree(skb);
 	__sctp_write_space(asoc);
 
@@ -5764,6 +5788,11 @@ void sctp_sock_rfree(struct sk_buff *skb)
 	struct sctp_ulpevent *event = sctp_skb2event(skb);
 
 	atomic_sub(event->rmem_len, &sk->sk_rmem_alloc);
+
+	/*
+	 * Mimic the behavior of sk_stream_rfree
+	 */
+	sk->sk_forward_alloc += event->rmem_len;
 }
 
 
@@ -6153,6 +6182,7 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	sctp_release_sock(newsk);
 }
 
+
 /* This proto struct describes the ULP interface for SCTP.  */
 struct proto sctp_prot = {
 	.name        =	"SCTP",
@@ -6175,6 +6205,12 @@ struct proto sctp_prot = {
 	.unhash      =	sctp_unhash,
 	.get_port    =	sctp_get_port,
 	.obj_size    =  sizeof(struct sctp_sock),
+	.sysctl_mem  =  sysctl_sctp_mem,
+	.sysctl_rmem =  sysctl_sctp_rmem,
+	.sysctl_wmem =  sysctl_sctp_wmem,
+	.memory_pressure = &sctp_memory_pressure,
+	.enter_memory_pressure = sctp_enter_memory_pressure,
+	.memory_allocated = &sctp_memory_allocated,
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -6199,5 +6235,11 @@ struct proto sctpv6_prot = {
 	.unhash		= sctp_unhash,
 	.get_port	= sctp_get_port,
 	.obj_size	= sizeof(struct sctp6_sock),
+	.sysctl_mem	= sysctl_sctp_mem,
+	.sysctl_rmem	= sysctl_sctp_rmem,
+	.sysctl_wmem	= sysctl_sctp_wmem,
+	.memory_pressure = &sctp_memory_pressure,
+	.enter_memory_pressure = sctp_enter_memory_pressure,
+	.memory_allocated = &sctp_memory_allocated,
 };
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
-- 
1.5.2.4

