From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Clean the ip_sockglue.c from some ugly ifdefs
Date: Thu, 01 Nov 2007 18:52:34 +0300
Message-ID: <4729F642.7000709@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33141 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753697AbXKAPwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 11:52:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The #idfed CONFIG_IP_MROUTE is sometimes places inside the if-s,
which looks completely bad. Similar ifdefs inside the functions
looks a bit better, but they are also not recommended to be used.

Provide an ifdef-ed ip_mroute_opt() helper to cleanup the code.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 7da2cee..200fbb2 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -128,6 +128,18 @@ struct igmpmsg
 #ifdef __KERNEL__
 #include <net/sock.h>
 
+#ifdef CONFIG_IP_MROUTE
+static inline int ip_mroute_opt(int opt)
+{
+	return (opt >= MRT_BASE) && (op <= MRT_BASE + 10);
+}
+#else
+static inline int ip_mroute_opt(int opt)
+{
+	return 0;
+}
+#endif
+
 extern int ip_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index f51f20e..82817e5 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -437,10 +437,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 
 	/* If optlen==0, it is equivalent to val == 0 */
 
-#ifdef CONFIG_IP_MROUTE
-	if (optname >= MRT_BASE && optname <= (MRT_BASE + 10))
+	if (ip_mroute_opt(optname))
 		return ip_mroute_setsockopt(sk,optname,optval,optlen);
-#endif
 
 	err = 0;
 	lock_sock(sk);
@@ -909,11 +907,9 @@ int ip_setsockopt(struct sock *sk, int level,
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IP_HDRINCL &&
-		optname != IP_IPSEC_POLICY && optname != IP_XFRM_POLICY
-#ifdef CONFIG_IP_MROUTE
-		&& (optname < MRT_BASE || optname > (MRT_BASE + 10))
-#endif
-	   ) {
+			optname != IP_IPSEC_POLICY &&
+			optname != IP_XFRM_POLICY &&
+			!ip_mroute_opt(optname)) {
 		lock_sock(sk);
 		err = nf_setsockopt(sk, PF_INET, optname, optval, optlen);
 		release_sock(sk);
@@ -935,11 +931,9 @@ int compat_ip_setsockopt(struct sock *sk, int level, int optname,
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IP_HDRINCL &&
-	    optname != IP_IPSEC_POLICY && optname != IP_XFRM_POLICY
-#ifdef CONFIG_IP_MROUTE
-	    && (optname < MRT_BASE || optname > (MRT_BASE + 10))
-#endif
-	   ) {
+			optname != IP_IPSEC_POLICY &&
+			optname != IP_XFRM_POLICY &&
+			!ip_mroute_opt(optname)) {
 		lock_sock(sk);
 		err = compat_nf_setsockopt(sk, PF_INET, optname,
 					   optval, optlen);
@@ -967,11 +961,8 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	if (level != SOL_IP)
 		return -EOPNOTSUPP;
 
-#ifdef CONFIG_IP_MROUTE
-	if (optname >= MRT_BASE && optname <= MRT_BASE+10) {
+	if (ip_mroute_opt(optname))
 		return ip_mroute_getsockopt(sk,optname,optval,optlen);
-	}
-#endif
 
 	if (get_user(len,optlen))
 		return -EFAULT;
@@ -1171,11 +1162,8 @@ int ip_getsockopt(struct sock *sk, int level,
 	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
-	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS
-#ifdef CONFIG_IP_MROUTE
-		&& (optname < MRT_BASE || optname > MRT_BASE+10)
-#endif
-	   ) {
+	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS &&
+			!ip_mroute_opt(optname)) {
 		int len;
 
 		if (get_user(len,optlen))
@@ -1200,11 +1188,8 @@ int compat_ip_getsockopt(struct sock *sk, int level, int optname,
 	int err = do_ip_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
-	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS
-#ifdef CONFIG_IP_MROUTE
-	    && (optname < MRT_BASE || optname > MRT_BASE+10)
-#endif
-	   ) {
+	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS &&
+			!ip_mroute_opt(optname)) {
 		int len;
 
 		if (get_user(len, optlen))
-- 
1.5.3.4

