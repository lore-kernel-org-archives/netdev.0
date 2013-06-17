From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: sctp: get rid of t_new macro for kzalloc
Date: Mon, 17 Jun 2013 11:40:04 +0200
Message-ID: <1371462005-19310-2-git-send-email-dborkman@redhat.com>
References: <1371462005-19310-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868Ab3FQJkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 05:40:13 -0400
In-Reply-To: <1371462005-19310-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

t_new rather obfuscates things where everyone else is using actual
function names instead of that macro, so replace it with kzalloc,
which is the function t_new wraps.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/sctp.h | 3 ---
 net/sctp/associola.c    | 2 +-
 net/sctp/bind_addr.c    | 2 +-
 net/sctp/endpointola.c  | 3 ++-
 net/sctp/ipv6.c         | 2 +-
 net/sctp/protocol.c     | 2 +-
 net/sctp/transport.c    | 2 +-
 7 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index cd89510..b9f136a 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -575,9 +575,6 @@ for (pos = chunk->subh.fwdtsn_hdr->skip;\
 /* Round an int up to the next multiple of 4.  */
 #define WORD_ROUND(s) (((s)+3)&~3)
 
-/* Make a new instance of type.  */
-#define t_new(type, flags)	kzalloc(sizeof(type), flags)
-
 /* Compare two timevals.  */
 #define tv_lt(s, t) \
    (s.tv_sec < t.tv_sec || (s.tv_sec == t.tv_sec && s.tv_usec < t.tv_usec))
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 756025c..bf6e6bd 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -355,7 +355,7 @@ struct sctp_association *sctp_association_new(const struct sctp_endpoint *ep,
 {
 	struct sctp_association *asoc;
 
-	asoc = t_new(struct sctp_association, gfp);
+	asoc = kzalloc(sizeof(*asoc), gfp);
 	if (!asoc)
 		goto fail;
 
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 41145fe..64977ea 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -162,7 +162,7 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
 	struct sctp_sockaddr_entry *addr;
 
 	/* Add the address to the bind address list.  */
-	addr = t_new(struct sctp_sockaddr_entry, gfp);
+	addr = kzalloc(sizeof(*addr), gfp);
 	if (!addr)
 		return -ENOMEM;
 
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 5fbd7bc..a8b2674 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -192,9 +192,10 @@ struct sctp_endpoint *sctp_endpoint_new(struct sock *sk, gfp_t gfp)
 	struct sctp_endpoint *ep;
 
 	/* Build a local endpoint. */
-	ep = t_new(struct sctp_endpoint, gfp);
+	ep = kzalloc(sizeof(*ep), gfp);
 	if (!ep)
 		goto fail;
+
 	if (!sctp_endpoint_init(ep, sk, gfp))
 		goto fail_init;
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index fffc7b6..4f3e13b 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -402,7 +402,7 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 	read_lock_bh(&in6_dev->lock);
 	list_for_each_entry(ifp, &in6_dev->addr_list, if_list) {
 		/* Add the address to the local list.  */
-		addr = t_new(struct sctp_sockaddr_entry, GFP_ATOMIC);
+		addr = kzalloc(sizeof(*addr), GFP_ATOMIC);
 		if (addr) {
 			addr->a.v6.sin6_family = AF_INET6;
 			addr->a.v6.sin6_port = 0;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index eaee00c..fad7d1b 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -153,7 +153,7 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
 
 	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
 		/* Add the address to the local list.  */
-		addr = t_new(struct sctp_sockaddr_entry, GFP_ATOMIC);
+		addr = kzalloc(sizeof(*addr), GFP_ATOMIC);
 		if (addr) {
 			addr->a.v4.sin_family = AF_INET;
 			addr->a.v4.sin_port = 0;
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 098f1d5f..5d3c71b 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -116,7 +116,7 @@ struct sctp_transport *sctp_transport_new(struct net *net,
 {
 	struct sctp_transport *transport;
 
-	transport = t_new(struct sctp_transport, gfp);
+	transport = kzalloc(sizeof(*transport), gfp);
 	if (!transport)
 		goto fail;
 
-- 
1.7.11.7
