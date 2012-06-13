From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Tue, 12 Jun 2012 21:22:36 -0700 (PDT)
Message-ID: <20120612.212236.897121854594455904.davem@davemloft.net>
References: <20120611.160258.866525532025442350.davem@davemloft.net>
	<20120612114440.GM27795@secunet.com>
	<20120612.133333.527780673034196147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab2FMEWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 00:22:39 -0400
In-Reply-To: <20120612.133333.527780673034196147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 12 Jun 2012 13:33:33 -0700 (PDT)

> What we possibly could do is adjust the socket's IP_PMTUDISC_* setting
> from IP_PMTUDISC_WANT to IP_PMTUDISC_DONT in response to PMTU
> messages.
> 
> This seems to solve all the problems.  Individual RAW and UDP sockets
> get the behavior they did before, and route cache PMTU poisoning is
> less of an issue.

Here is an implementation of that idea:

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 8260ef7..61cb532 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -416,6 +416,16 @@ static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 	return inet_sk(__sk)->pinet6;
 }
 
+/* We don't want to update the routing tables because there is no way
+ * to validate the legitimacy of this PMTU event.  Instead, downgrade
+ * the PMTU setting of the socket.
+ */
+static inline void inet6_datagram_pmtu_event(struct ipv6_pinfo *np)
+{
+	if (np->pmtudisc == IP_PMTUDISC_WANT)
+		np->pmtudisc = IP_PMTUDISC_DONT;
+}
+
 static inline struct inet6_request_sock *
 			inet6_rsk(const struct request_sock *rsk)
 {
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ae17e13..2199afb 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -199,6 +199,16 @@ static inline void inet_sk_copy_descendant(struct sock *sk_to,
 }
 #endif
 
+/* We don't want to update the routing cache because there is no way
+ * to validate the legitimacy of this PMTU event.  Instead, downgrade
+ * the PMTU setting of the socket.
+ */
+static inline void inet_datagram_pmtu_event(struct inet_sock *inet)
+{
+	if (inet->pmtudisc == IP_PMTUDISC_WANT)
+		inet->pmtudisc = IP_PMTUDISC_DONT;
+}
+
 extern int inet_sk_rebuild_header(struct sock *sk);
 
 extern u32 inet_ehash_secret;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2c00e8b..c6becc1 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -374,6 +374,7 @@ void ping_err(struct sk_buff *skb, u32 info)
 			if (inet_sock->pmtudisc != IP_PMTUDISC_DONT) {
 				err = EMSGSIZE;
 				harderr = 1;
+				inet_datagram_pmtu_event(inet_sock);
 				break;
 			}
 			goto out;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 4032b81..ed24b05 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -244,6 +244,7 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 		if (code == ICMP_FRAG_NEEDED) {
 			harderr = inet->pmtudisc != IP_PMTUDISC_DONT;
 			err = EMSGSIZE;
+			inet_datagram_pmtu_event(inet);
 		}
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index eaca736..40cf013 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -618,6 +618,7 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 			if (inet->pmtudisc != IP_PMTUDISC_DONT) {
 				err = EMSGSIZE;
 				harderr = 1;
+				inet_datagram_pmtu_event(inet);
 				break;
 			}
 			goto out;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 93d6983..79e2f7a 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -328,9 +328,10 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 		return;
 
 	harderr = icmpv6_err_convert(type, code, &err);
-	if (type == ICMPV6_PKT_TOOBIG)
+	if (type == ICMPV6_PKT_TOOBIG) {
 		harderr = (np->pmtudisc == IPV6_PMTUDISC_DO);
-
+		inet6_datagram_pmtu_event(np);
+	}
 	if (np->recverr) {
 		u8 *payload = skb->data;
 		if (!inet->hdrincl)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f05099f..fb57815 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -481,6 +481,9 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
+	if (type == ICMPV6_PKT_TOOBIG)
+		inet6_datagram_pmtu_event(np);
+
 	if (!icmpv6_err_convert(type, code, &err) && !np->recverr)
 		goto out;
 
