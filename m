From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/3] net/sched: cls_flower: Support masking for matching on tcp/udp ports
Date: Tue, 13 Sep 2016 17:02:39 +0300
Message-ID: <1473775361-16547-2-git-send-email-ogerlitz@mellanox.com>
References: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36271 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751745AbcIMOCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:02:53 -0400
In-Reply-To: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the definitions for src/dst udp/tcp port masks and use
them when setting && dumping the relevant keys.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Paul Blakey <paulb@mellanox.com>
---
 include/uapi/linux/pkt_cls.h |  4 ++++
 net/sched/cls_flower.c       | 20 ++++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index f9c287c..60ea2a0 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -442,6 +442,10 @@ enum {
 	TCA_FLOWER_KEY_ENC_IPV6_DST,	/* struct in6_addr */
 	TCA_FLOWER_KEY_ENC_IPV6_DST_MASK,/* struct in6_addr */
 
+	TCA_FLOWER_KEY_TCP_SRC_MASK,	/* be16 */
+	TCA_FLOWER_KEY_TCP_DST_MASK,	/* be16 */
+	TCA_FLOWER_KEY_UDP_SRC_MASK,	/* be16 */
+	TCA_FLOWER_KEY_UDP_DST_MASK,	/* be16 */
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index b084b2a..027523c 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -335,6 +335,10 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK] = { .len = sizeof(struct in6_addr) },
 	[TCA_FLOWER_KEY_ENC_IPV6_DST]	= { .len = sizeof(struct in6_addr) },
 	[TCA_FLOWER_KEY_ENC_IPV6_DST_MASK] = { .len = sizeof(struct in6_addr) },
+	[TCA_FLOWER_KEY_TCP_SRC_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_TCP_DST_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_UDP_SRC_MASK]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_UDP_DST_MASK]	= { .type = NLA_U16 },
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -432,17 +436,17 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 
 	if (key->basic.ip_proto == IPPROTO_TCP) {
 		fl_set_key_val(tb, &key->tp.src, TCA_FLOWER_KEY_TCP_SRC,
-			       &mask->tp.src, TCA_FLOWER_UNSPEC,
+			       &mask->tp.src, TCA_FLOWER_KEY_TCP_SRC_MASK,
 			       sizeof(key->tp.src));
 		fl_set_key_val(tb, &key->tp.dst, TCA_FLOWER_KEY_TCP_DST,
-			       &mask->tp.dst, TCA_FLOWER_UNSPEC,
+			       &mask->tp.dst, TCA_FLOWER_KEY_TCP_DST_MASK,
 			       sizeof(key->tp.dst));
 	} else if (key->basic.ip_proto == IPPROTO_UDP) {
 		fl_set_key_val(tb, &key->tp.src, TCA_FLOWER_KEY_UDP_SRC,
-			       &mask->tp.src, TCA_FLOWER_UNSPEC,
+			       &mask->tp.src, TCA_FLOWER_KEY_UDP_SRC_MASK,
 			       sizeof(key->tp.src));
 		fl_set_key_val(tb, &key->tp.dst, TCA_FLOWER_KEY_UDP_DST,
-			       &mask->tp.dst, TCA_FLOWER_UNSPEC,
+			       &mask->tp.dst, TCA_FLOWER_KEY_UDP_DST_MASK,
 			       sizeof(key->tp.dst));
 	}
 
@@ -877,18 +881,18 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	if (key->basic.ip_proto == IPPROTO_TCP &&
 	    (fl_dump_key_val(skb, &key->tp.src, TCA_FLOWER_KEY_TCP_SRC,
-			     &mask->tp.src, TCA_FLOWER_UNSPEC,
+			     &mask->tp.src, TCA_FLOWER_KEY_TCP_SRC_MASK,
 			     sizeof(key->tp.src)) ||
 	     fl_dump_key_val(skb, &key->tp.dst, TCA_FLOWER_KEY_TCP_DST,
-			     &mask->tp.dst, TCA_FLOWER_UNSPEC,
+			     &mask->tp.dst, TCA_FLOWER_KEY_TCP_DST_MASK,
 			     sizeof(key->tp.dst))))
 		goto nla_put_failure;
 	else if (key->basic.ip_proto == IPPROTO_UDP &&
 		 (fl_dump_key_val(skb, &key->tp.src, TCA_FLOWER_KEY_UDP_SRC,
-				  &mask->tp.src, TCA_FLOWER_UNSPEC,
+				  &mask->tp.src, TCA_FLOWER_KEY_UDP_SRC_MASK,
 				  sizeof(key->tp.src)) ||
 		  fl_dump_key_val(skb, &key->tp.dst, TCA_FLOWER_KEY_UDP_DST,
-				  &mask->tp.dst, TCA_FLOWER_UNSPEC,
+				  &mask->tp.dst, TCA_FLOWER_KEY_UDP_DST_MASK,
 				  sizeof(key->tp.dst))))
 		goto nla_put_failure;
 
-- 
2.3.7
