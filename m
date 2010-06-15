From: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] net - IP_NODEFRAG option for IPv4 socket
Date: Tue, 15 Jun 2010 13:07:31 +0200
Message-ID: <1276600052-16499-2-git-send-email-jolsa@redhat.com>
References: <1276600052-16499-1-git-send-email-jolsa@redhat.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1276600052-16499-1-git-send-email-jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

hi,

this patch is implementing IP_NODEFRAG option for IPv4 socket.
The reason is, there's no other way to send out the packet with user
customized header of the reassembly part.

wbr,
jirka

Signed-off-by: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/in.h                  |    1 +
 include/net/inet_sock.h             |    3 ++-
 net/ipv4/af_inet.c                  |    2 ++
 net/ipv4/ip_sockglue.c              |    9 ++++++++-
 net/ipv4/netfilter/nf_defrag_ipv4.c |    5 +++++
 5 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 583c76f..41d88a4 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -85,6 +85,7 @@ struct in_addr {
 #define IP_RECVORIGDSTADDR   IP_ORIGDSTADDR
 
 #define IP_MINTTL       21
+#define IP_NODEFRAG     22
 
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 1653de5..1989cfd 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -137,7 +137,8 @@ struct inet_sock {
 				hdrincl:1,
 				mc_loop:1,
 				transparent:1,
-				mc_all:1;
+				mc_all:1,
+				nodefrag:1;
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist	*mc_list;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 551ce56..84d2c8e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -355,6 +355,8 @@ lookup_protocol:
 	inet = inet_sk(sk);
 	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;
 
+	inet->nodefrag = 0;
+
 	if (SOCK_RAW == sock->type) {
 		inet->inet_num = protocol;
 		if (IPPROTO_RAW == protocol)
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ce23178..d8196e1 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -449,7 +449,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			     (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
 			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT) |
-			     (1<<IP_MINTTL))) ||
+			     (1<<IP_MINTTL) | (1<<IP_NODEFRAG))) ||
 	    optname == IP_MULTICAST_TTL ||
 	    optname == IP_MULTICAST_ALL ||
 	    optname == IP_MULTICAST_LOOP ||
@@ -572,6 +572,13 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 		inet->hdrincl = val ? 1 : 0;
 		break;
+	case IP_NODEFRAG:
+		if (sk->sk_type != SOCK_RAW) {
+			err = -ENOPROTOOPT;
+			break;
+		}
+		inet->nodefrag = val ? 1 : 0;
+		break;
 	case IP_MTU_DISCOVER:
 		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_PROBE)
 			goto e_inval;
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index cb763ae..eab8de3 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -66,6 +66,11 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 					  const struct net_device *out,
 					  int (*okfn)(struct sk_buff *))
 {
+	struct inet_sock *inet = inet_sk(skb->sk);
+
+	if (inet && inet->nodefrag)
+		return NF_ACCEPT;
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #if !defined(CONFIG_NF_NAT) && !defined(CONFIG_NF_NAT_MODULE)
 	/* Previously seen (loopback)?  Ignore.  Do this before
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
