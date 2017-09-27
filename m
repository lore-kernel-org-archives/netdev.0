From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net-ipv6: add support for sockopt(SOL_IPV6, IPV6_FREEBIND)
Date: Tue, 26 Sep 2017 21:32:42 -0700
Message-ID: <20170927043242.151591-1-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35248 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965486AbdI0EdA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 00:33:00 -0400
Received: by mail-pg0-f68.google.com with SMTP id j16so8004798pga.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 21:33:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

So far we've been relying on sockopt(SOL_IP, IP_FREEBIND) being usable
even on IPv6 sockets.

However, it turns out it is perfectly reasonable to want to set freebind
on an AF_INET6 SOCK_RAW socket - but there is no way to set any SOL_IP
socket option on such a socket (they're all blindly errored out).

One use case for this is to allow spoofing src ip on a raw socket
via sendmsg cmsg.

Tested:
  built, and booted
  # python
  >>> import socket
  >>> SOL_IP = socket.SOL_IP
  >>> SOL_IPV6 = socket.IPPROTO_IPV6
  >>> IP_FREEBIND = 15
  >>> IPV6_FREEBIND = 78
  >>> s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM, 0)
  >>> s.getsockopt(SOL_IP, IP_FREEBIND)
  0
  >>> s.getsockopt(SOL_IPV6, IPV6_FREEBIND)
  0
  >>> s.setsockopt(SOL_IPV6, IPV6_FREEBIND, 1)
  >>> s.getsockopt(SOL_IP, IP_FREEBIND)
  1
  >>> s.getsockopt(SOL_IPV6, IPV6_FREEBIND)
  1

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 include/uapi/linux/in6.h |  1 +
 net/ipv6/ipv6_sockglue.c | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 46444f8fbee4..4f8f3eb0699f 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -284,6 +284,7 @@ struct in6_flowlabel_req {
 #define IPV6_TRANSPARENT        75
 #define IPV6_UNICAST_IF         76
 #define IPV6_RECVFRAGSIZE	77
+#define IPV6_FREEBIND		78
 
 /*
  * Multicast Routing:
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a5e466d4e093..b9404feabd78 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -377,6 +377,14 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = 0;
 		break;
 
+	case IPV6_FREEBIND:
+		if (optlen < sizeof(int))
+			goto e_inval;
+		/* we also don't have a separate freebind bit for IPV6 */
+		inet_sk(sk)->freebind = valbool;
+		retv = 0;
+		break;
+
 	case IPV6_RECVORIGDSTADDR:
 		if (optlen < sizeof(int))
 			goto e_inval;
@@ -1214,6 +1222,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = inet_sk(sk)->transparent;
 		break;
 
+	case IPV6_FREEBIND:
+		val = inet_sk(sk)->freebind;
+		break;
+
 	case IPV6_RECVORIGDSTADDR:
 		val = np->rxopt.bits.rxorigdstaddr;
 		break;
-- 
2.14.1.992.g2c7b836f3a-goog
