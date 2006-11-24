From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][3/7] inter address family ipsec tunnel
Date: Fri, 24 Nov 2006 14:38:31 +0900
Message-ID: <20061124143831.00f4e4af.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:18905 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S934371AbWKXFnz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:43:55 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds pfkeyv2 interface of the family.

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

---
 net/key/af_key.c |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 4e18309..33a2ed5 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1767,11 +1767,11 @@ #endif
 
 	/* addresses present only in tunnel mode */
 	if (t->mode == XFRM_MODE_TUNNEL) {
-		switch (xp->family) {
+		struct sockaddr *sa;
+		sa = (struct sockaddr *)(rq+1);
+		switch(sa->sa_family) {
 		case AF_INET:
-			sin = (void*)(rq+1);
-			if (sin->sin_family != AF_INET)
-				return -EINVAL;
+			sin = (struct sockaddr_in*)sa;
 			t->saddr.a4 = sin->sin_addr.s_addr;
 			sin++;
 			if (sin->sin_family != AF_INET)
@@ -1780,9 +1780,7 @@ #endif
 			break;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		case AF_INET6:
-			sin6 = (void *)(rq+1);
-			if (sin6->sin6_family != AF_INET6)
-				return -EINVAL;
+			sin6 = (struct sockaddr_in6*)sa;
 			memcpy(t->saddr.a6, &sin6->sin6_addr, sizeof(struct in6_addr));
 			sin6++;
 			if (sin6->sin6_family != AF_INET6)
@@ -1793,6 +1791,7 @@ #endif
 		default:
 			return -EINVAL;
 		}
+		t->encap_family = sa->sa_family;
 	}
 	/* No way to set this via kame pfkey */
 	t->aalgos = t->ealgos = t->calgos = ~0;
@@ -1830,18 +1829,25 @@ static inline int pfkey_xfrm_policy2sec_
 
 static int pfkey_xfrm_policy2msg_size(struct xfrm_policy *xp)
 {
+	struct xfrm_tmpl *t;
 	int sockaddr_size = pfkey_sockaddr_size(xp->family);
-	int socklen = (xp->family == AF_INET ?
-		       sizeof(struct sockaddr_in) :
-		       sizeof(struct sockaddr_in6));
+	int socklen = 0;
+	int i;
+
+	for (i=0; i<xp->xfrm_nr; i++) {
+		t = xp->xfrm_vec + i;
+		socklen += (t->encap_family == AF_INET ?
+			    sizeof(struct sockaddr_in) :
+			    sizeof(struct sockaddr_in6));
+	}
 
 	return sizeof(struct sadb_msg) +
 		(sizeof(struct sadb_lifetime) * 3) +
 		(sizeof(struct sadb_address) * 2) + 
 		(sockaddr_size * 2) +
 		sizeof(struct sadb_x_policy) +
-		(xp->xfrm_nr * (sizeof(struct sadb_x_ipsecrequest) +
-				(socklen * 2))) +
+		(xp->xfrm_nr * sizeof(struct sadb_x_ipsecrequest)) +
+		(socklen * 2) +
 		pfkey_xfrm_policy2sec_ctx_size(xp);
 }
 
@@ -1999,7 +2005,9 @@ #endif
 
 		req_size = sizeof(struct sadb_x_ipsecrequest);
 		if (t->mode == XFRM_MODE_TUNNEL)
-			req_size += 2*socklen;
+			req_size += ((t->encap_family == AF_INET ?
+		       		     sizeof(struct sockaddr_in) :
+		       		     sizeof(struct sockaddr_in6)) * 2);
 		else
 			size -= 2*socklen;
 		rq = (void*)skb_put(skb, req_size);
@@ -2015,7 +2023,7 @@ #endif
 			rq->sadb_x_ipsecrequest_level = IPSEC_LEVEL_USE;
 		rq->sadb_x_ipsecrequest_reqid = t->reqid;
 		if (t->mode == XFRM_MODE_TUNNEL) {
-			switch (xp->family) {
+			switch (t->encap_family) {
 			case AF_INET:
 				sin = (void*)(rq+1);
 				sin->sin_family = AF_INET;
