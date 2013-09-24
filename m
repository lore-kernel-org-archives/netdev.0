From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next v3 1/2] ipv4: IP_TOS and IP_TTL can be specified as ancillary data
Date: Tue, 24 Sep 2013 15:43:08 +0200
Message-ID: <8353a5692a8d948c7c99159b6d4c7c4313c17c15.1379944642.git.ffusco@redhat.com>
References: <cover.1379944641.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23477 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354Ab3IXNnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 09:43:13 -0400
In-Reply-To: <cover.1379944641.git.ffusco@redhat.com>
In-Reply-To: <cover.1379944641.git.ffusco@redhat.com>
References: <cover.1379944641.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the IP_TTL and IP_TOS values passed from userspace to
be stored in the ipcm_cookie struct. Three fields are added to the struct:

- the TTL, expressed as __u8.
  The allowed values are in the [1-255].
  A value of 0 means that the TTL is not specified.

- the TOS, expressed as __s16.
  The allowed values are in the range [0,255].
  A value of -1 means that the TOS is not specified.

- the priority, expressed as a char and computed when
  handling the ancillary data.

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 v1->v2
  - changed the icmp_cookie ttl field from __s16 to __u8.
    A value of 0 means that the TTL has not been specified
  - to tos field is still __s16. The user can specify
    values in the range 0-255 included, therefore I use
    a value of -1 as a flag saying that the value has
    not been specified
  - the priority it is now a char instead of a __u32, 
    which is the return type of rt_tos2priority
  - improved commit message
 v1->v2
  - no code changes, rebase to net-next

 include/net/ip.h       |  3 +++
 net/ipv4/ip_sockglue.c | 20 +++++++++++++++++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index c1f192b..0135f38 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -56,6 +56,9 @@ struct ipcm_cookie {
 	int			oif;
 	struct ip_options_rcu	*opt;
 	__u8			tx_flags;
+	__u8			ttl;
+	__s16			tos;
+	char			priority;
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
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
