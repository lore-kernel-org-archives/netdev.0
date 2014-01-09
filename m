From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next] IPv6: add option to use anycast addresses as source addresses for datagrams
Date: Thu,  9 Jan 2014 14:45:23 +0100
Message-ID: <1389275123-3305-1-git-send-email-fx.lebail@yahoo.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp04.smtpout.orange.fr ([80.12.242.126]:35750 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045AbaAIODT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:03:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows to follow a recommandation of RFC4942.

- Add IPV6_ANYCAST_SRC_DGRAM socket option to control the use of anycast
  addresses as source addresses for datagrams, with Advanced Sockets API
  (RFC3542).
- Add anycast_src_dgram sockopt flag.
- Add ipv6_chk_acast_addr_src() to check if address is link-local on
  given interface or is global on any interface.
- Use them in ip6_datagram_send_ctl(), do_ipv6_setsockopt() and
  do_ipv6_getsockopt()

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
 include/linux/ipv6.h     |    3 ++-
 include/net/addrconf.h   |    5 +++--
 include/uapi/linux/in6.h |    1 +
 net/ipv6/anycast.c       |   11 +++++++++++
 net/ipv6/datagram.c      |    5 ++++-
 net/ipv6/ipv6_sockglue.c |   11 +++++++++++
 6 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7e1ded0..cf3069b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -197,7 +197,8 @@ struct ipv6_pinfo {
 						 * 010: prefer public address
 						 * 100: prefer care-of address
 						 */
-				dontfrag:1;
+				dontfrag:1,
+				anycast_src_dgram:1;
 	__u8			min_hopcount;
 	__u8			tclass;
 	__be32			rcv_flowinfo;
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 66c4a44..50e39a8 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -205,8 +205,9 @@ void ipv6_sock_ac_close(struct sock *sk);
 int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
 int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
 bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
-				const struct in6_addr *addr);
-
+			 const struct in6_addr *addr);
+bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
+			     const struct in6_addr *addr);
 
 /* Device notifier */
 int register_inet6addr_notifier(struct notifier_block *nb);
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index f94f1d0..e8851c0 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -182,6 +182,7 @@ enum {
 #define IPV6_V6ONLY		26
 #define IPV6_JOIN_ANYCAST	27
 #define IPV6_LEAVE_ANYCAST	28
+#define IPV6_ANYCAST_SRC_DGRAM	29
 
 /* IPV6_MTU_DISCOVER values */
 #define IPV6_PMTUDISC_DONT		0
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 5a80f15..9f25dda 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -383,6 +383,17 @@ bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 	return found;
 }
 
+/*	check if address is link-local on given interface
+ *	or is global on any interface
+ */
+bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
+			     const struct in6_addr *addr)
+{
+	if (ipv6_addr_type(addr) & IPV6_ADDR_LINKLOCAL)
+		return ipv6_chk_acast_dev(dev, addr);
+	else
+		return ipv6_chk_acast_addr(net, NULL, addr);
+}
 
 #ifdef CONFIG_PROC_FS
 struct ac6_iter_state {
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 6983058..6396da5 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -669,7 +669,10 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
 				if (!(inet_sk(sk)->freebind || inet_sk(sk)->transparent) &&
 				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
-						   strict ? dev : NULL, 0))
+						   strict ? dev : NULL, 0) &&
+				    !(inet6_sk(sk)->anycast_src_dgram &&
+				      ipv6_chk_acast_addr_src(net, dev,
+							      &src_info->ipi6_addr)))
 					err = -EINVAL;
 				else
 					fl6->saddr = src_info->ipi6_addr;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index af0ecb9..f96680f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -834,6 +834,13 @@ pref_skip_coa:
 		np->dontfrag = valbool;
 		retv = 0;
 		break;
+
+	case IPV6_ANYCAST_SRC_DGRAM:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		np->anycast_src_dgram = valbool;
+		retv = 0;
+		break;
 	}
 
 	release_sock(sk);
@@ -1271,6 +1278,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->dontfrag;
 		break;
 
+	case IPV6_ANYCAST_SRC_DGRAM:
+		val = np->anycast_src_dgram;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
