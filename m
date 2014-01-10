From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next] IPv6: enable bind() to assign an anycast address
Date: Fri, 10 Jan 2014 19:12:24 +0100
Message-ID: <1389377544-3119-1-git-send-email-fx.lebail@yahoo.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.smtpout.orange.fr ([80.12.242.133]:34419 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbaAJSay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:30:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Add ipv6_chk_acast_addr_src() to check if an anycast address is link-local
  on given interface or is global (on any interface).
- Use it in inet6_bind().

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
Tested with link-local and global anycast addresses.
Tested with SOCK_DGRAM socket, bind and UDP traffic OK.
Tested with SOCK_STREAM socket, bind OK, traffic need another change.

 include/net/addrconf.h |    5 +++--
 net/ipv6/af_inet6.c    |    4 +++-
 net/ipv6/anycast.c     |   11 +++++++++++
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
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c921d5d..68b81e9 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -347,7 +347,9 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
 				if (!(inet->freebind || inet->transparent) &&
 				    !ipv6_chk_addr(net, &addr->sin6_addr,
-						   dev, 0)) {
+						   dev, 0) &&
+				    !ipv6_chk_acast_addr_src(net, dev,
+							     &addr->sin6_addr)) {
 					err = -EADDRNOTAVAIL;
 					goto out_unlock;
 				}
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
