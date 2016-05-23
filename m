From: Alexander Aring <aar@pengutronix.de>
Subject: [RFC 09/12] ipv6: export several functions
Date: Mon, 23 May 2016 21:22:05 +0200
Message-ID: <1464031328-17524-10-git-send-email-aar@pengutronix.de>
References: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
Cc: kernel@pengutronix.de, marcel@holtmann.org,
	jukka.rissanen@linux.intel.com, hannes@stressinduktion.org,
	stefan@osg.samsung.com, mcr@sandelman.ca, werner@almesberger.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <aar@pengutronix.de>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59512 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbcEWTXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 15:23:12 -0400
In-Reply-To: <1464031328-17524-1-git-send-email-aar@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports some neighbour discovery functions which can be used
by 6lowpan neighbour discovery ops functionality then.

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Alexander Aring <aar@pengutronix.de>
---
 include/net/addrconf.h |  7 +++++++
 include/net/ndisc.h    | 12 ++++++++++++
 net/ipv6/addrconf.c    | 15 +++++++--------
 net/ipv6/ndisc.c       | 14 +++-----------
 4 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index b1774eb..f5d2230 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -97,6 +97,13 @@ void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
 void addrconf_add_linklocal(struct inet6_dev *idev,
 			    const struct in6_addr *addr, u32 flags);
 
+void addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
+				  const struct prefix_info *pinfo,
+				  struct inet6_dev *in6_dev,
+				  const struct in6_addr *addr, int addr_type,
+				  u32 addr_flags, bool sllao, bool tokenized,
+				  __u32 valid_lft, u32 prefered_lft);
+
 static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
 {
 	if (dev->addr_len != ETH_ALEN)
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index e4a711e..c92ebdb 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -53,6 +53,15 @@ enum {
 
 #include <net/neighbour.h>
 
+/* Set to 3 to get tracing... */
+#define ND_DEBUG 1
+
+#define ND_PRINTK(val, level, fmt, ...)				\
+do {								\
+	if (val <= ND_DEBUG)					\
+		net_##level##_ratelimited(fmt, ##__VA_ARGS__);	\
+} while (0)
+
 struct ctl_table;
 struct inet6_dev;
 struct net_device;
@@ -115,6 +124,9 @@ struct ndisc_options *ndisc_parse_options(const struct net_device *dev,
 					  u8 *opt, int opt_len,
 					  struct ndisc_options *ndopts);
 
+void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
+			    int data_len, int pad);
+
 /*
  * Return the padding between the option length and the start of the
  * link addr.  Currently only IP-over-InfiniBand needs this, although
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4506cac..aeea54e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2333,14 +2333,12 @@ static bool is_addr_mode_generate_stable(struct inet6_dev *idev)
 	       idev->addr_gen_mode == IN6_ADDR_GEN_MODE_RANDOM;
 }
 
-static void addrconf_prefix_rcv_add_addr(struct net *net,
-					 struct net_device *dev,
-					 const struct prefix_info *pinfo,
-					 struct inet6_dev *in6_dev,
-					 const struct in6_addr *addr,
-					 int addr_type, u32 addr_flags,
-					 bool sllao, bool tokenized,
-					 __u32 valid_lft, u32 prefered_lft)
+void addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
+				  const struct prefix_info *pinfo,
+				  struct inet6_dev *in6_dev,
+				  const struct in6_addr *addr, int addr_type,
+				  u32 addr_flags, bool sllao, bool tokenized,
+				  __u32 valid_lft, u32 prefered_lft)
 {
 	struct inet6_ifaddr *ifp = ipv6_get_ifaddr(net, addr, dev, 1);
 	int create = 0, update_lft = 0;
@@ -2430,6 +2428,7 @@ static void addrconf_prefix_rcv_add_addr(struct net *net,
 		addrconf_verify();
 	}
 }
+EXPORT_SYMBOL_GPL(addrconf_prefix_rcv_add_addr);
 
 void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 {
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 99fd53c..d30f241 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -73,15 +73,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 
-/* Set to 3 to get tracing... */
-#define ND_DEBUG 1
-
-#define ND_PRINTK(val, level, fmt, ...)				\
-do {								\
-	if (val <= ND_DEBUG)					\
-		net_##level##_ratelimited(fmt, ##__VA_ARGS__);	\
-} while (0)
-
 static u32 ndisc_hash(const void *pkey,
 		      const struct net_device *dev,
 		      __u32 *hash_rnd);
@@ -150,8 +141,8 @@ struct neigh_table nd_tbl = {
 };
 EXPORT_SYMBOL_GPL(nd_tbl);
 
-static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
-				   int data_len, int pad)
+void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
+			    int data_len, int pad)
 {
 	int space = ndisc_opt_addr_space(data_len, pad);
 	u8 *opt = skb_put(skb, space);
@@ -170,6 +161,7 @@ static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
 	if (space > 0)
 		memset(opt, 0, space);
 }
+EXPORT_SYMBOL_GPL(ndisc_fill_addr_option);
 
 static inline void ndisc_dev_fill_addr_option(struct sk_buff *skb, int type,
 					      const struct net_device *dev)
-- 
2.8.2
