From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 09/11] sctp: move route updating for redirect to ndisc layer
Date: Thu, 12 Sep 2013 18:51:19 +0800
Message-ID: <52319CA7.8080809@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:43244 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752489Ab3ILKwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:52:14 -0400
In-Reply-To: <52319A6E.6090503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

In additon, when dealing with redirect message, it should
not report error message to user, and need to return
directly.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/sctp/input.c | 12 ------------
 net/sctp/ipv6.c  |  6 +++---
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 5f20686..0d2d4b7 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -413,18 +413,6 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
 	sctp_retransmit(&asoc->outqueue, t, SCTP_RTXR_PMTUD);
 }
 
-void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
-			struct sk_buff *skb)
-{
-	struct dst_entry *dst;
-
-	if (!t)
-		return;
-	dst = sctp_transport_dst_check(t);
-	if (dst)
-		dst->ops->redirect(dst, sk, skb);
-}
-
 /*
  * SCTP Implementer's Guide, 2.37 ICMP handling procedures
  *
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index da613ce..ee12d87 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -151,6 +151,9 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	int err;
 	struct net *net = dev_net(skb->dev);
 
+	if (type == NDISC_REDIRECT)
+		return;
+
 	idev = in6_dev_get(skb->dev);
 
 	/* Fix up skb to look at the embedded net header. */
@@ -181,9 +184,6 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 			goto out_unlock;
 		}
 		break;
-	case NDISC_REDIRECT:
-		sctp_icmp_redirect(sk, transport, skb);
-		break;
 	default:
 		break;
 	}
-- 
1.8.3.1
