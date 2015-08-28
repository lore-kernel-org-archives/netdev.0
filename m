From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 1/3] net: fib: move metrics parsing to a helper
Date: Fri, 28 Aug 2015 14:11:07 +0200
Message-ID: <1440763869-23067-2-git-send-email-fw@strlen.de>
References: <1440763869-23067-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57666 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751727AbbH1MLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 08:11:18 -0400
In-Reply-To: <1440763869-23067-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_create_info() is already quite large, so before adding more
code to the metrics section move that to a helper, similar to
ip6_convert_metrics.

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/fib_semantics.c | 71 ++++++++++++++++++++++++++++--------------------
 1 file changed, 41 insertions(+), 30 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1b2d011..88afbae 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -876,6 +876,44 @@ static bool fib_valid_prefsrc(struct fib_config *cfg, __be32 fib_prefsrc)
 	return true;
 }
 
+static int
+fib_convert_metrics(struct fib_info *fi, const struct fib_config *cfg)
+{
+	struct nlattr *nla;
+	int remaining;
+
+	if (!cfg->fc_mx)
+		return 0;
+
+	nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
+		int type = nla_type(nla);
+		u32 val;
+
+		if (!type)
+			continue;
+		if (type > RTAX_MAX)
+			return -EINVAL;
+
+		if (type == RTAX_CC_ALGO) {
+			char tmp[TCP_CA_NAME_MAX];
+
+			nla_strlcpy(tmp, nla, sizeof(tmp));
+			val = tcp_ca_get_key_by_name(tmp);
+			if (val == TCP_CA_UNSPEC)
+				return -EINVAL;
+		} else {
+			val = nla_get_u32(nla);
+		}
+		if (type == RTAX_ADVMSS && val > 65535 - 40)
+			val = 65535 - 40;
+		if (type == RTAX_MTU && val > 65535 - 15)
+			val = 65535 - 15;
+		fi->fib_metrics[type - 1] = val;
+	}
+
+	return 0;
+}
+
 struct fib_info *fib_create_info(struct fib_config *cfg)
 {
 	int err;
@@ -948,36 +986,9 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			goto failure;
 	} endfor_nexthops(fi)
 
-	if (cfg->fc_mx) {
-		struct nlattr *nla;
-		int remaining;
-
-		nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
-			int type = nla_type(nla);
-
-			if (type) {
-				u32 val;
-
-				if (type > RTAX_MAX)
-					goto err_inval;
-				if (type == RTAX_CC_ALGO) {
-					char tmp[TCP_CA_NAME_MAX];
-
-					nla_strlcpy(tmp, nla, sizeof(tmp));
-					val = tcp_ca_get_key_by_name(tmp);
-					if (val == TCP_CA_UNSPEC)
-						goto err_inval;
-				} else {
-					val = nla_get_u32(nla);
-				}
-				if (type == RTAX_ADVMSS && val > 65535 - 40)
-					val = 65535 - 40;
-				if (type == RTAX_MTU && val > 65535 - 15)
-					val = 65535 - 15;
-				fi->fib_metrics[type - 1] = val;
-			}
-		}
-	}
+	err = fib_convert_metrics(fi, cfg);
+	if (err)
+		goto failure;
 
 	if (cfg->fc_mp) {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-- 
2.0.5
