From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 3/4] fib, fib6: reject invalid feature bits
Date: Mon, 31 Aug 2015 15:58:46 +0200
Message-ID: <dc1d5ac80bd59a891ed2ce16040f154fd93e1d00.1441027533.git.daniel@iogearbox.net>
References: <cover.1441027533.git.daniel@iogearbox.net>
Cc: fw@strlen.de, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34939 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbbHaN6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 09:58:53 -0400
In-Reply-To: <cover.1441027533.git.daniel@iogearbox.net>
In-Reply-To: <cover.1441027533.git.daniel@iogearbox.net>
References: <cover.1441027533.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Feature bits that are invalid should not be accepted by the kernel,
only the lower 4 bits may be configured, but not the remaining ones.
Even from these 4, 2 of them are unused.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/rtnetlink.h | 11 +++++++----
 net/ipv4/fib_semantics.c       |  2 ++
 net/ipv6/route.c               |  2 ++
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 0d3d3cc..7020247 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -418,10 +418,13 @@ enum {
 
 #define RTAX_MAX (__RTAX_MAX - 1)
 
-#define RTAX_FEATURE_ECN	0x00000001
-#define RTAX_FEATURE_SACK	0x00000002
-#define RTAX_FEATURE_TIMESTAMP	0x00000004
-#define RTAX_FEATURE_ALLFRAG	0x00000008
+#define RTAX_FEATURE_ECN	(1 << 0)
+#define RTAX_FEATURE_SACK	(1 << 1)
+#define RTAX_FEATURE_TIMESTAMP	(1 << 2)
+#define RTAX_FEATURE_ALLFRAG	(1 << 3)
+
+#define RTAX_FEATURE_MASK	(RTAX_FEATURE_ECN | RTAX_FEATURE_SACK | \
+				 RTAX_FEATURE_TIMESTAMP | RTAX_FEATURE_ALLFRAG)
 
 struct rta_session {
 	__u8	proto;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 88afbae..115a08e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -908,6 +908,8 @@ fib_convert_metrics(struct fib_info *fi, const struct fib_config *cfg)
 			val = 65535 - 40;
 		if (type == RTAX_MTU && val > 65535 - 15)
 			val = 65535 - 15;
+		if (type == RTAX_FEATURES && (val & ~RTAX_FEATURE_MASK))
+			return -EINVAL;
 		fi->fib_metrics[type - 1] = val;
 	}
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0261b72..8771530 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1728,6 +1728,8 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 		} else {
 			val = nla_get_u32(nla);
 		}
+		if (type == RTAX_FEATURES && (val & ~RTAX_FEATURE_MASK))
+			goto err;
 
 		mp[type - 1] = val;
 		__set_bit(type - 1, mxc->mx_valid);
-- 
1.9.3
