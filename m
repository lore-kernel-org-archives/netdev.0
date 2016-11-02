From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/3] ipv4: add IP_RECVFRAGSIZE cmsg
Date: Wed,  2 Nov 2016 11:02:16 -0400
Message-ID: <1478098938-124108-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: jdorfman@google.com, eric.dumazet@gmail.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35241 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755209AbcKBPC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:02:28 -0400
Received: by mail-qt0-f196.google.com with SMTP id m48so692542qta.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:02:27 -0700 (PDT)
In-Reply-To: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The IP stack records the largest fragment of a reassembled packet
in IPCB(skb)->frag_max_size. When reading a datagram or raw packet
that arrived fragmented, expose the value to allow applications to
estimate receive path MTU.

Tested:
  Sent data over a veth pair of which the source has a small mtu.
  Sent data using netcat, received using a dedicated process.

  Verified that the cmsg IP_RECVFRAGSIZE is returned only when
  data arrives fragmented, and in that cases matches the veth mtu.

    ip link add veth0 type veth peer name veth1

    ip netns add from
    ip netns add to

    ip link set dev veth1 netns to
    ip netns exec to ip addr add dev veth1 192.168.10.1/24
    ip netns exec to ip link set dev veth1 up

    ip link set dev veth0 netns from
    ip netns exec from ip addr add dev veth0 192.168.10.2/24
    ip netns exec from ip link set dev veth0 up
    ip netns exec from ip link set dev veth0 mtu 1300
    ip netns exec from ethtool -K veth0 ufo off

    dd if=/dev/zero bs=1 count=1400 2>/dev/null > payload

    ip netns exec to ./recv_cmsg_recvfragsize -4 -u -p 6000 &
    ip netns exec from nc -q 1 -u 192.168.10.1 6000 < payload

  using github.com/wdebruij/kerneltools/blob/master/tests/recvfragsize.c

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/inet_sock.h |  1 +
 include/uapi/linux/in.h |  1 +
 net/ipv4/ip_sockglue.c  | 26 ++++++++++++++++++++++++++
 3 files changed, 28 insertions(+)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 236a810..c9cff97 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -228,6 +228,7 @@ struct inet_sock {
 #define IP_CMSG_PASSSEC		BIT(5)
 #define IP_CMSG_ORIGDSTADDR	BIT(6)
 #define IP_CMSG_CHECKSUM	BIT(7)
+#define IP_CMSG_RECVFRAGSIZE	BIT(8)
 
 /**
  * sk_to_full_sk - Access to a full socket
diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index eaf9491..4e557f4 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -117,6 +117,7 @@ struct in_addr {
 #define IP_NODEFRAG     22
 #define IP_CHECKSUM	23
 #define IP_BIND_ADDRESS_NO_PORT	24
+#define IP_RECVFRAGSIZE	25
 
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b8a2d63..ecbaae2 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -97,6 +97,17 @@ static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
 	put_cmsg(msg, SOL_IP, IP_RETOPTS, opt->optlen, opt->__data);
 }
 
+static void ip_cmsg_recv_fragsize(struct msghdr *msg, struct sk_buff *skb)
+{
+	int val;
+
+	if (IPCB(skb)->frag_max_size == 0)
+		return;
+
+	val = IPCB(skb)->frag_max_size;
+	put_cmsg(msg, SOL_IP, IP_RECVFRAGSIZE, sizeof(val), &val);
+}
+
 static void ip_cmsg_recv_checksum(struct msghdr *msg, struct sk_buff *skb,
 				  int tlen, int offset)
 {
@@ -218,6 +229,9 @@ void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
 
 	if (flags & IP_CMSG_CHECKSUM)
 		ip_cmsg_recv_checksum(msg, skb, tlen, offset);
+
+	if (flags & IP_CMSG_RECVFRAGSIZE)
+		ip_cmsg_recv_fragsize(msg, skb);
 }
 EXPORT_SYMBOL(ip_cmsg_recv_offset);
 
@@ -614,6 +628,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_MULTICAST_LOOP:
 	case IP_RECVORIGDSTADDR:
 	case IP_CHECKSUM:
+	case IP_RECVFRAGSIZE:
 		if (optlen >= sizeof(int)) {
 			if (get_user(val, (int __user *) optval))
 				return -EFAULT;
@@ -726,6 +741,14 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			}
 		}
 		break;
+	case IP_RECVFRAGSIZE:
+		if (sk->sk_type != SOCK_RAW && sk->sk_type != SOCK_DGRAM)
+			goto e_inval;
+		if (val)
+			inet->cmsg_flags |= IP_CMSG_RECVFRAGSIZE;
+		else
+			inet->cmsg_flags &= ~IP_CMSG_RECVFRAGSIZE;
+		break;
 	case IP_TOS:	/* This sets both TOS and Precedence */
 		if (sk->sk_type == SOCK_STREAM) {
 			val &= ~INET_ECN_MASK;
@@ -1357,6 +1380,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_CHECKSUM:
 		val = (inet->cmsg_flags & IP_CMSG_CHECKSUM) != 0;
 		break;
+	case IP_RECVFRAGSIZE:
+		val = (inet->cmsg_flags & IP_CMSG_RECVFRAGSIZE) != 0;
+		break;
 	case IP_TOS:
 		val = inet->tos;
 		break;
-- 
2.8.0.rc3.226.g39d4020
