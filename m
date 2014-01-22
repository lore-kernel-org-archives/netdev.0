From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next v4] ipv6: enable anycast addresses as source addresses for datagrams
Date: Wed, 22 Jan 2014 07:42:37 +0100
Message-ID: <1390372958-3654-1-git-send-email-fx.lebail@yahoo.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.smtpout.orange.fr ([80.12.242.133]:32164 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbaAVHDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:03:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows to consider an anycast address valid as source address
when given via an IPV6_PKTINFO or IPV6_2292PKTINFO ancillary data item.
So, when sending a datagram with ancillary data, the unicast and anycast
addresses are handled in the same way.

- Adds ipv6_chk_acast_addr_src() to check if an anycast address is link-local
  on given interface or is global.
- Uses it in ip6_datagram_send_ctl().

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
v4: better style
v3: Consideration of Hannes's review (thanks!):
    - Uses only ipv6_chk_acast_addr (rcu_read_lock needed).

Typical usage :
A server uses IPV6_RECVPKTINFO socket option to get ancillary data with
recvmsg() and can use sendmsg() to reply with anycast adress as source address
in the same way it does for unicast.

 include/net/addrconf.h |    5 +++--
 net/ipv6/anycast.c     |   11 +++++++++++
 net/ipv6/datagram.c    |    4 +++-
 3 files changed, 17 insertions(+), 3 deletions(-)

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
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 5a80f15..2101832 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -383,6 +383,17 @@ bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 	return found;
 }
 
+/*	check if this anycast address is link-local on given interface or
+ *	is global
+ */
+bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
+			     const struct in6_addr *addr)
+{
+	return ipv6_chk_acast_addr(net,
+				   (ipv6_addr_type(addr) & IPV6_ADDR_LINKLOCAL ?
+				    dev : NULL),
+				   addr);
+}
 
 #ifdef CONFIG_PROC_FS
 struct ac6_iter_state {
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2f5e2f1..c3bf2d2 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -699,7 +699,9 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
 				if (!(inet_sk(sk)->freebind || inet_sk(sk)->transparent) &&
 				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
-						   strict ? dev : NULL, 0))
+						   strict ? dev : NULL, 0) &&
+				    !ipv6_chk_acast_addr_src(net, dev,
+							     &src_info->ipi6_addr))
 					err = -EINVAL;
 				else
 					fl6->saddr = src_info->ipi6_addr;
