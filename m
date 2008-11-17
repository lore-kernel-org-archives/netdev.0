From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] filter: add SKF_AD_NLATTR_NEST to look for nested attributes
Date: Mon, 17 Nov 2008 09:31:37 +0100
Message-ID: <20081117083136.10840.70283.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SKF_AD_NLATTR allows us to find the first matching attribute in a
stream of netlink attributes from one offset to the end of the
netlink message. This is not suitable to look for a specific
matching inside a set of nested attributes.

For example, in ctnetlink messages, if we look for the CTA_V6_SRC
attribute in a message that talks about an IPv4 connection,
SKF_AD_NLATTR returns the offset of CTA_STATUS which has the same
value of CTA_V6_SRC but outside the nest. To differenciate
CTA_STATUS and CTA_V6_SRC, we would have to make assumptions on the
size of the attribute and the usual offset, resulting in horrible
BSF code.

This patch adds SKF_AD_NLATTR_NEST, which is a variant of
SKF_AD_NLATTR, that looks for an attribute inside the limits of
a nested attributes, but not further.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 include/linux/filter.h |    3 ++-
 net/core/filter.c      |   15 +++++++++++++++
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index b6ea9aa..1354aaf 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -122,7 +122,8 @@ struct sock_fprog	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_PKTTYPE 	4
 #define SKF_AD_IFINDEX 	8
 #define SKF_AD_NLATTR	12
-#define SKF_AD_MAX 	16
+#define SKF_AD_NLATTR_NEST	16
+#define SKF_AD_MAX	20
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index df37443..2f9c7ea 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -319,6 +319,21 @@ load_b:
 				A = 0;
 			continue;
 		}
+		case SKF_AD_NLATTR_NEST: {
+			struct nlattr *nla;
+
+			if (skb_is_nonlinear(skb))
+				return 0;
+			if (A > skb->len - sizeof(struct nlattr))
+				return 0;
+
+			nla = nla_find_nested((struct nlattr *)&skb->data[A],X);
+			if (nla)
+				A = (void *)nla - (void *)skb->data;
+			else
+				A = 0;
+			continue;
+		}
 		default:
 			return 0;
 		}

