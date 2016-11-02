From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 2/3] ipv6: add IPV6_RECVFRAGSIZE cmsg
Date: Wed,  2 Nov 2016 11:02:17 -0400
Message-ID: <1478098938-124108-3-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: jdorfman@google.com, eric.dumazet@gmail.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35243 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755272AbcKBPC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:02:28 -0400
Received: by mail-qt0-f195.google.com with SMTP id m48so692553qta.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:02:27 -0700 (PDT)
In-Reply-To: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When reading a datagram or raw packet that arrived fragmented, expose
the maximum fragment size if recorded to allow applications to
estimate receive path MTU.

At this point, the field is only recorded when ipv6 connection
tracking is enabled. A follow-up patch will record this field also
in the ipv6 input path.

Tested using the test for IP_RECVFRAGSIZE plus

  ip netns exec to ip addr add dev veth1 fc07::1/64
  ip netns exec from ip addr add dev veth0 fc07::2/64

  ip netns exec to ./recv_cmsg_recvfragsize -6 -u -p 6000 &
  ip netns exec from nc -q 1 -u fc07::1 6000 < payload

Both with and without enabling connection tracking

  ip6tables -A INPUT -m state --state NEW -p udp -j LOG

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/ipv6.h     | 5 +++--
 include/uapi/linux/in6.h | 1 +
 net/ipv6/datagram.c      | 5 +++++
 net/ipv6/ipv6_sockglue.c | 8 ++++++++
 4 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index ca1ad9e..1afb6e8 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -229,8 +229,9 @@ struct ipv6_pinfo {
                                 rxflow:1,
 				rxtclass:1,
 				rxpmtu:1,
-				rxorigdstaddr:1;
-				/* 2 bits hole */
+				rxorigdstaddr:1,
+				recvfragsize:1;
+				/* 1 bits hole */
 		} bits;
 		__u16		all;
 	} rxopt;
diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index b39ea4f..46444f8 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -283,6 +283,7 @@ struct in6_flowlabel_req {
 #define IPV6_RECVORIGDSTADDR    IPV6_ORIGDSTADDR
 #define IPV6_TRANSPARENT        75
 #define IPV6_UNICAST_IF         76
+#define IPV6_RECVFRAGSIZE	77
 
 /*
  * Multicast Routing:
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 37874e2..620c79a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -715,6 +715,11 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 			put_cmsg(msg, SOL_IPV6, IPV6_ORIGDSTADDR, sizeof(sin6), &sin6);
 		}
 	}
+	if (np->rxopt.bits.recvfragsize && opt->frag_max_size) {
+		int val = opt->frag_max_size;
+
+		put_cmsg(msg, SOL_IPV6, IPV6_RECVFRAGSIZE, sizeof(val), &val);
+	}
 }
 
 void ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 636ec56..6c12678 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -868,6 +868,10 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		np->autoflowlabel = valbool;
 		retv = 0;
 		break;
+	case IPV6_RECVFRAGSIZE:
+		np->rxopt.bits.recvfragsize = valbool;
+		retv = 0;
+		break;
 	}
 
 	release_sock(sk);
@@ -1310,6 +1314,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = np->autoflowlabel;
 		break;
 
+	case IPV6_RECVFRAGSIZE:
+		val = np->rxopt.bits.recvfragsize;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
-- 
2.8.0.rc3.226.g39d4020
