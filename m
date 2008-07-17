From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 1/1] ipv6: remove unused parameter from ip6_ra_control
Date: Thu, 17 Jul 2008 16:46:48 +0400
Message-ID: <1216298808-8640-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39019 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754289AbYGQMps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 08:45:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h       |    4 +---
 net/ipv6/ipv6_sockglue.c |    7 ++-----
 net/ipv6/raw.c           |    2 +-
 3 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c2c3649..2d5c185 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -221,9 +221,7 @@ static inline void fl6_sock_release(struct ip6_flowlabel *fl)
 		atomic_dec(&fl->users);
 }
 
-extern int 			ip6_ra_control(struct sock *sk, int sel,
-					       void (*destructor)(struct sock *));
-
+extern int 			ip6_ra_control(struct sock *sk, int sel);
 
 extern int			ipv6_parse_hopopts(struct sk_buff *skb);
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 030c0c9..8c6ea07 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -59,7 +59,7 @@ DEFINE_SNMP_STAT(struct ipstats_mib, ipv6_statistics) __read_mostly;
 struct ip6_ra_chain *ip6_ra_chain;
 DEFINE_RWLOCK(ip6_ra_lock);
 
-int ip6_ra_control(struct sock *sk, int sel, void (*destructor)(struct sock *))
+int ip6_ra_control(struct sock *sk, int sel)
 {
 	struct ip6_ra_chain *ra, *new_ra, **rap;
 
@@ -81,8 +81,6 @@ int ip6_ra_control(struct sock *sk, int sel, void (*destructor)(struct sock *))
 			*rap = ra->next;
 			write_unlock_bh(&ip6_ra_lock);
 
-			if (ra->destructor)
-				ra->destructor(sk);
 			sock_put(sk);
 			kfree(ra);
 			return 0;
@@ -94,7 +92,6 @@ int ip6_ra_control(struct sock *sk, int sel, void (*destructor)(struct sock *))
 	}
 	new_ra->sk = sk;
 	new_ra->sel = sel;
-	new_ra->destructor = destructor;
 	new_ra->next = ra;
 	*rap = new_ra;
 	sock_hold(sk);
@@ -632,7 +629,7 @@ done:
 	case IPV6_ROUTER_ALERT:
 		if (optlen < sizeof(int))
 			goto e_inval;
-		retv = ip6_ra_control(sk, val, NULL);
+		retv = ip6_ra_control(sk, val);
 		break;
 	case IPV6_MTU_DISCOVER:
 		if (optlen < sizeof(int))
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 34cfb3f..01d4767 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1157,7 +1157,7 @@ static int rawv6_ioctl(struct sock *sk, int cmd, unsigned long arg)
 static void rawv6_close(struct sock *sk, long timeout)
 {
 	if (inet_sk(sk)->num == IPPROTO_RAW)
-		ip6_ra_control(sk, -1, NULL);
+		ip6_ra_control(sk, -1);
 	ip6mr_sk_done(sk);
 	sk_common_release(sk);
 }
-- 
1.5.3.rc5

