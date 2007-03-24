From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 1/3] [NET] Do pmtu check in transport layer
Date: Fri, 23 Mar 2007 20:06:44 -0400
Message-ID: <11746948063923-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:59461 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbXCXAp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 20:45:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check the pmtu check at the transport layer (for UDP, ICMP and raw), and
send a local error if socket is PMTUDISC_DO and packet is too big.  This is
actually a pure bugfix for ipv6.  For ipv4, it allows us to do pmtu checks
in the same way as for ipv6.

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 net/ipv4/ip_output.c  |    4 +++-
 net/ipv4/raw.c        |    8 +++++---
 net/ipv6/ip6_output.c |   11 ++++++-----
 net/ipv6/raw.c        |    7 +++++--
 4 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d096332..593acf7 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -822,7 +822,9 @@ int ip_append_data(struct sock *sk,
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
-	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
+	if (inet->cork.length + length > 0xFFFF - fragheaderlen ||
+	    (inet->pmtudisc >= IP_PMTUDISC_DO &&
+	     inet->cork.length + length > mtu)) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu-exthdrlen);
 		return -EMSGSIZE;
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 87e9c16..f252f4e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -271,10 +271,12 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
 	struct iphdr *iph;
 	struct sk_buff *skb;
 	int err;
+	int mtu;
 
-	if (length > rt->u.dst.dev->mtu) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport,
-			       rt->u.dst.dev->mtu);
+	mtu = inet->pmtudisc == IP_PMTUDISC_DO ? dst_mtu(&rt->u.dst) :
+	                                         rt->u.dst.dev->mtu;
+	if (length > mtu) {
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
 		return -EMSGSIZE;
 	}
 	if (flags&MSG_PROBE)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3055169..711dfc3 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1044,11 +1044,12 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	fragheaderlen = sizeof(struct ipv6hdr) + rt->u.dst.nfheader_len + (opt ? opt->opt_nflen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
-	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
-		if (inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
-			ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
-			return -EMSGSIZE;
-		}
+	if ((mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN &&
+	     inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) ||
+	    (np->pmtudisc >= IPV6_PMTUDISC_DO &&
+	     inet->cork.length + length > mtu)) {
+		ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
+		return -EMSGSIZE;
 	}
 
 	/*
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 306d5d8..75db277 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -556,9 +556,12 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	struct sk_buff *skb;
 	unsigned int hh_len;
 	int err;
+	int mtu;
 
-	if (length > rt->u.dst.dev->mtu) {
-		ipv6_local_error(sk, EMSGSIZE, fl, rt->u.dst.dev->mtu);
+	mtu = np->pmtudisc == IPV6_PMTUDISC_DO ? dst_mtu(&rt->u.dst) :
+	                                         rt->u.dst.dev->mtu;
+	if (length > mtu) {
+		ipv6_local_error(sk, EMSGSIZE, fl, mtu);
 		return -EMSGSIZE;
 	}
 	if (flags&MSG_PROBE)
-- 
1.5.0.2.gc260-dirty

