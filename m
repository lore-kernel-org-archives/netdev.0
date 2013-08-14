From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next 1/2] ipv4: IP_TOS and IP_TTL can be specified as ancillary data
Date: Wed, 14 Aug 2013 17:48:38 +0200
Message-ID: <92ffe52615a79259cd7cc120e504a9cf41dd546e.1376494031.git.ffusco@redhat.com>
References: <cover.1376494030.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41600 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759105Ab3HNPso (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 11:48:44 -0400
In-Reply-To: <cover.1376494030.git.ffusco@redhat.com>
In-Reply-To: <cover.1376494030.git.ffusco@redhat.com>
References: <cover.1376494030.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the IP_TTL and IP_TOS values passed from userspace to
be stored in the ipcm_cookie struct.

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 include/net/ip.h       |  3 +++
 net/ipv4/ip_sockglue.c | 20 +++++++++++++++++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index a68f838..bf63936 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -54,6 +54,9 @@ static inline unsigned int ip_hdrlen(const struct sk_buff *skb)
 struct ipcm_cookie {
 	__be32			addr;
 	int			oif;
+	__s16			ttl;
+	__s16			tos;
+	__u32			priority;
 	struct ip_options_rcu	*opt;
 	__u8			tx_flags;
 };
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index d9c4f11..56e3445 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -189,7 +189,7 @@ EXPORT_SYMBOL(ip_cmsg_recv);
 
 int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 {
-	int err;
+	int err, val;
 	struct cmsghdr *cmsg;
 
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
@@ -215,6 +215,24 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 			ipc->addr = info->ipi_spec_dst.s_addr;
 			break;
 		}
+		case IP_TTL:
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int)))
+				return -EINVAL;
+			val = *(int *)CMSG_DATA(cmsg);
+			if (val < 1 || val > 255)
+				return -EINVAL;
+			ipc->ttl = val;
+			break;
+		case IP_TOS:
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int)))
+				return -EINVAL;
+			val = *(int *)CMSG_DATA(cmsg);
+			if (val < 0 || val > 255)
+				return -EINVAL;
+			ipc->tos = val;
+			ipc->priority = rt_tos2priority(ipc->tos);
+			break;
+
 		default:
 			return -EINVAL;
 		}
-- 
1.8.3.1
