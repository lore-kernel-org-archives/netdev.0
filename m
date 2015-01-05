From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v3 3/4] ip: Add offset parameter to ip_cmsg_recv
Date: Mon,  5 Jan 2015 13:56:16 -0800
Message-ID: <1420494977-15026-4-git-send-email-therbert@google.com>
References: <1420494977-15026-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:45259 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbbAEV4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:56:38 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so3221485igj.10
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 13:56:37 -0800 (PST)
In-Reply-To: <1420494977-15026-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ip_cmsg_recv_offset function which takes an offset argument
that indicates the starting offset in skb where data is being received
from. This will be useful in the case of UDP and provided checksum
to user space.

ip_cmsg_recv is an inline call to ip_cmsg_recv_offset with offset of
zero.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip.h       | 7 ++++++-
 net/ipv4/ip_sockglue.c | 5 +++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0bb6207..0e5a0ba 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -537,7 +537,7 @@ int ip_options_rcv_srr(struct sk_buff *skb);
  */
 
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb);
-void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
+void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb, int offset);
 int ip_cmsg_send(struct net *net, struct msghdr *msg,
 		 struct ipcm_cookie *ipc, bool allow_ipv6);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
@@ -557,6 +557,11 @@ void ip_icmp_error(struct sock *sk, struct sk_buff *skb, int err, __be16 port,
 void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
 		    u32 info);
 
+static inline void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
+{
+	ip_cmsg_recv_offset(msg, skb, 0);
+}
+
 bool icmp_global_allow(void);
 extern int sysctl_icmp_msgs_per_sec;
 extern int sysctl_icmp_msgs_burst;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 80f7856..513d506 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -136,7 +136,8 @@ static void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
 	put_cmsg(msg, SOL_IP, IP_ORIGDSTADDR, sizeof(sin), &sin);
 }
 
-void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
+void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
+			 int offset)
 {
 	struct inet_sock *inet = inet_sk(skb->sk);
 	unsigned int flags = inet->cmsg_flags;
@@ -194,7 +195,7 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 		ip_cmsg_recv_dstaddr(msg, skb);
 
 }
-EXPORT_SYMBOL(ip_cmsg_recv);
+EXPORT_SYMBOL(ip_cmsg_recv_offset);
 
 int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
 		 bool allow_ipv6)
-- 
2.2.0.rc0.207.ga3a616c
