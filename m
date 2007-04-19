From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] Revert "[NET] Do pmtu check in transport layer"
Date: Wed, 18 Apr 2007 21:07:42 -0400
Message-ID: <11769448642649-git-send-email-jheffner@psc.edu>
References: <11746948063923-git-send-email-jheffner@psc.edu> <11769448643248-git-send-email-jheffner@psc.edu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	John Heffner <jheffner@psc.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:51445 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030980AbXDSBHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 21:07:49 -0400
In-Reply-To: <11769448643248-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 87e927a0583bd4a8ba9e97cd75b58d8aa1c76e37.

This idea does not work, as pointed at by Patrick McHardy.

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 net/ipv4/ip_output.c  |    4 +---
 net/ipv4/raw.c        |    8 +++-----
 net/ipv6/ip6_output.c |   11 +++++------
 net/ipv6/raw.c        |    7 ++-----
 4 files changed, 11 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 79e71ee..34606ef 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -810,9 +810,7 @@ int ip_append_data(struct sock *sk,
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
-	if (inet->cork.length + length > 0xFFFF - fragheaderlen ||
-	    (inet->pmtudisc >= IP_PMTUDISC_DO &&
-	     inet->cork.length + length > mtu)) {
+	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu-exthdrlen);
 		return -EMSGSIZE;
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index c60aadf..24d7c9f 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -271,12 +271,10 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	struct iphdr *iph;
 	struct sk_buff *skb;
 	int err;
-	int mtu;
 
-	mtu = inet->pmtudisc == IP_PMTUDISC_DO ? dst_mtu(&rt->u.dst) :
-	                                         rt->u.dst.dev->mtu;
-	if (length > mtu) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
+	if (length > rt->u.dst.dev->mtu) {
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport,
+			       rt->u.dst.dev->mtu);
 		return -EMSGSIZE;
 	}
 	if (flags&MSG_PROBE)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b8e307a..4cfdad4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1079,12 +1079,11 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	fragheaderlen = sizeof(struct ipv6hdr) + rt->u.dst.nfheader_len + (opt ? opt->opt_nflen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
-	if ((mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN &&
-	     inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) ||
-	    (np->pmtudisc >= IPV6_PMTUDISC_DO &&
-	     inet->cork.length + length > mtu)) {
-		ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
-		return -EMSGSIZE;
+	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
+		if (inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
+			ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
+			return -EMSGSIZE;
+		}
 	}
 
 	/*
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index f4cd90b..f65fcd7 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -558,12 +558,9 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	struct sk_buff *skb;
 	unsigned int hh_len;
 	int err;
-	int mtu;
 
-	mtu = np->pmtudisc == IPV6_PMTUDISC_DO ? dst_mtu(&rt->u.dst) :
-	                                         rt->u.dst.dev->mtu;
-	if (length > mtu) {
-		ipv6_local_error(sk, EMSGSIZE, fl, mtu);
+	if (length > rt->u.dst.dev->mtu) {
+		ipv6_local_error(sk, EMSGSIZE, fl, rt->u.dst.dev->mtu);
 		return -EMSGSIZE;
 	}
 	if (flags&MSG_PROBE)
-- 
1.5.1.rc3.30.ga8f4-dirty

