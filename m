From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] net/route: enforce hoplimit max value
Date: Fri, 13 May 2016 18:33:41 +0200
Message-ID: <4a951826f558b10f62ce4338cb2620b6fc886ba5.1463154659.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbcEMQd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 12:33:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when creating or updating a route, no check is performed
in both ipv4 and ipv6 code to the hoplimit value.

The caller can i.e. set hoplimit to 256, and when such route will
 be used, packets will be sent with hoplimit/ttl equal to 0.

This commit adds checks for the RTAX_HOPLIMIT value, in both ipv4
ipv6 route code, substituting any value greater than 255 with 255.

This is consistent with what is currently done for ADVMSS and MTU
in the ipv4 code.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/fib_semantics.c | 2 ++
 net/ipv6/route.c         | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d97268e..2b68418 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -975,6 +975,8 @@ fib_convert_metrics(struct fib_info *fi, const struct fib_config *cfg)
 			val = 65535 - 40;
 		if (type == RTAX_MTU && val > 65535 - 15)
 			val = 65535 - 15;
+		if (type == RTAX_HOPLIMIT && val > 255)
+			val = 255;
 		if (type == RTAX_FEATURES && (val & ~RTAX_FEATURE_MASK))
 			return -EINVAL;
 		fi->fib_metrics[type - 1] = val;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d916d6a..6f32944 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1750,6 +1750,8 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 		} else {
 			val = nla_get_u32(nla);
 		}
+		if (type == RTAX_HOPLIMIT && val > 255)
+			val = 255;
 		if (type == RTAX_FEATURES && (val & ~RTAX_FEATURE_MASK))
 			goto err;
 
-- 
1.8.3.1
