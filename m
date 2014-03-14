From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 1/8] ieee802154: rename struct ieee802154_addr to *_sa
Date: Fri, 14 Mar 2014 16:23:26 +0100
Message-ID: <1394810613-5657-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1394810613-5657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:59337 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427AbaCNPXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 11:23:41 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s2EFNama002871
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 16:23:36 +0100
In-Reply-To: <1394810613-5657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct as currently defined uses host byte order for some fields,
and most big endian/EUI display byte order for other fields. Inside the
stack, endianness should ideally match network byte order where possible
to minimize the number of byteswaps done in critical paths, but this
patch does not address this; it is only preparatory.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/fakehard.c |   14 +++++++-------
 include/net/af_ieee802154.h       |    4 ++--
 include/net/ieee802154_netdev.h   |   12 ++++++------
 include/net/nl802154.h            |    6 +++---
 net/ieee802154/6lowpan_rtnl.c     |    4 ++--
 net/ieee802154/af802154.h         |    2 +-
 net/ieee802154/af_ieee802154.c    |    2 +-
 net/ieee802154/dgram.c            |    8 ++++----
 net/ieee802154/nl-mac.c           |   12 ++++++------
 net/ieee802154/reassembly.c       |    6 +++---
 net/ieee802154/reassembly.h       |   15 ++++++++-------
 net/mac802154/mac_cmd.c           |    2 +-
 net/mac802154/wpan.c              |   10 +++++-----
 13 files changed, 49 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index bf0d55e..06a400f 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -119,7 +119,7 @@ static u8 fake_get_dsn(const struct net_device *dev)
  *       802.15.4-2006 document.
  */
 static int fake_assoc_req(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 channel, u8 page, u8 cap)
+		struct ieee802154_addr_sa *addr, u8 channel, u8 page, u8 cap)
 {
 	struct wpan_phy *phy = fake_to_phy(dev);
 
@@ -149,7 +149,7 @@ static int fake_assoc_req(struct net_device *dev,
  *       802.15.4-2006 document.
  */
 static int fake_assoc_resp(struct net_device *dev,
-		struct ieee802154_addr *addr, u16 short_addr, u8 status)
+		struct ieee802154_addr_sa *addr, u16 short_addr, u8 status)
 {
 	return 0;
 }
@@ -167,7 +167,7 @@ static int fake_assoc_resp(struct net_device *dev,
  *       document, with the reason described in 7.3.3.2.
  */
 static int fake_disassoc_req(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 reason)
+		struct ieee802154_addr_sa *addr, u8 reason)
 {
 	return ieee802154_nl_disassoc_confirm(dev, IEEE802154_SUCCESS);
 }
@@ -191,10 +191,10 @@ static int fake_disassoc_req(struct net_device *dev,
  * Note: This is in section 7.5.2.3 of the IEEE 802.15.4-2006
  * document, with 7.3.8 describing coordinator realignment.
  */
-static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
-				u8 channel, u8 page,
-				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
-				u8 coord_realign)
+static int fake_start_req(struct net_device *dev,
+			  struct ieee802154_addr_sa *addr, u8 channel, u8 page,
+			  u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
+			  u8 coord_realign)
 {
 	struct wpan_phy *phy = fake_to_phy(dev);
 
diff --git a/include/net/af_ieee802154.h b/include/net/af_ieee802154.h
index 75e64c7..f79ae2a 100644
--- a/include/net/af_ieee802154.h
+++ b/include/net/af_ieee802154.h
@@ -36,7 +36,7 @@ enum {
 /* address length, octets */
 #define IEEE802154_ADDR_LEN	8
 
-struct ieee802154_addr {
+struct ieee802154_addr_sa {
 	int addr_type;
 	u16 pan_id;
 	union {
@@ -51,7 +51,7 @@ struct ieee802154_addr {
 
 struct sockaddr_ieee802154 {
 	sa_family_t family; /* AF_IEEE802154 */
-	struct ieee802154_addr addr;
+	struct ieee802154_addr_sa addr;
 };
 
 /* get/setsockopt */
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 97b2e34..53937cd 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -41,8 +41,8 @@ struct ieee802154_frag_info {
  */
 struct ieee802154_mac_cb {
 	u8 lqi;
-	struct ieee802154_addr sa;
-	struct ieee802154_addr da;
+	struct ieee802154_addr_sa sa;
+	struct ieee802154_addr_sa da;
 	u8 flags;
 	u8 seq;
 	struct ieee802154_frag_info frag_info;
@@ -95,16 +95,16 @@ struct ieee802154_mlme_ops {
 	/* The following fields are optional (can be NULL). */
 
 	int (*assoc_req)(struct net_device *dev,
-			struct ieee802154_addr *addr,
+			struct ieee802154_addr_sa *addr,
 			u8 channel, u8 page, u8 cap);
 	int (*assoc_resp)(struct net_device *dev,
-			struct ieee802154_addr *addr,
+			struct ieee802154_addr_sa *addr,
 			u16 short_addr, u8 status);
 	int (*disassoc_req)(struct net_device *dev,
-			struct ieee802154_addr *addr,
+			struct ieee802154_addr_sa *addr,
 			u8 reason);
 	int (*start_req)(struct net_device *dev,
-			struct ieee802154_addr *addr,
+			struct ieee802154_addr_sa *addr,
 			u8 channel, u8 page, u8 bcn_ord, u8 sf_ord,
 			u8 pan_coord, u8 blx, u8 coord_realign);
 	int (*scan_req)(struct net_device *dev,
diff --git a/include/net/nl802154.h b/include/net/nl802154.h
index 99d2ba1..06ead97 100644
--- a/include/net/nl802154.h
+++ b/include/net/nl802154.h
@@ -22,7 +22,7 @@
 #define IEEE802154_NL_H
 
 struct net_device;
-struct ieee802154_addr;
+struct ieee802154_addr_sa;
 
 /**
  * ieee802154_nl_assoc_indic - Notify userland of an association request.
@@ -37,7 +37,7 @@ struct ieee802154_addr;
  * Note: This is in section 7.3.1 of the IEEE 802.15.4-2006 document.
  */
 int ieee802154_nl_assoc_indic(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 cap);
+		struct ieee802154_addr_sa *addr, u8 cap);
 
 /**
  * ieee802154_nl_assoc_confirm - Notify userland of association.
@@ -65,7 +65,7 @@ int ieee802154_nl_assoc_confirm(struct net_device *dev,
  * Note: This is in section 7.3.3 of the IEEE 802.15.4 document.
  */
 int ieee802154_nl_disassoc_indic(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 reason);
+		struct ieee802154_addr_sa *addr, u8 reason);
 
 /**
  * ieee802154_nl_disassoc_confirm - Notify userland of disassociation
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 48a8f52..331180e 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -91,7 +91,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 {
 	const u8 *saddr = _saddr;
 	const u8 *daddr = _daddr;
-	struct ieee802154_addr sa, da;
+	struct ieee802154_addr_sa sa, da;
 
 	/* TODO:
 	 * if this package isn't ipv6 one, where should it be routed?
@@ -171,7 +171,7 @@ static int lowpan_give_skb_to_devices(struct sk_buff *skb,
 static int process_data(struct sk_buff *skb)
 {
 	u8 iphc0, iphc1;
-	const struct ieee802154_addr *_saddr, *_daddr;
+	const struct ieee802154_addr_sa *_saddr, *_daddr;
 
 	raw_dump_table(__func__, "raw skb data dump", skb->data, skb->len);
 	/* at least two bytes will be used for the encoding */
diff --git a/net/ieee802154/af802154.h b/net/ieee802154/af802154.h
index b1ec525..331d15c 100644
--- a/net/ieee802154/af802154.h
+++ b/net/ieee802154/af802154.h
@@ -31,6 +31,6 @@ extern struct proto ieee802154_dgram_prot;
 void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb);
 int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb);
 struct net_device *ieee802154_get_dev(struct net *net,
-		struct ieee802154_addr *addr);
+		struct ieee802154_addr_sa *addr);
 
 #endif
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index a56ab9c..a8db341 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -44,7 +44,7 @@
  * Utility function for families
  */
 struct net_device *ieee802154_get_dev(struct net *net,
-		struct ieee802154_addr *addr)
+		struct ieee802154_addr_sa *addr)
 {
 	struct net_device *dev = NULL;
 	struct net_device *tmp;
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 1846c1f..405fdf9 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -41,8 +41,8 @@ static DEFINE_RWLOCK(dgram_lock);
 struct dgram_sock {
 	struct sock sk;
 
-	struct ieee802154_addr src_addr;
-	struct ieee802154_addr dst_addr;
+	struct ieee802154_addr_sa src_addr;
+	struct ieee802154_addr_sa dst_addr;
 
 	unsigned int bound:1;
 	unsigned int want_ack:1;
@@ -113,7 +113,7 @@ static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
 		goto out_put;
 	}
 
-	memcpy(&ro->src_addr, &addr->addr, sizeof(struct ieee802154_addr));
+	memcpy(&ro->src_addr, &addr->addr, sizeof(struct ieee802154_addr_sa));
 
 	ro->bound = 1;
 	err = 0;
@@ -181,7 +181,7 @@ static int dgram_connect(struct sock *sk, struct sockaddr *uaddr,
 		goto out;
 	}
 
-	memcpy(&ro->dst_addr, &addr->addr, sizeof(struct ieee802154_addr));
+	memcpy(&ro->dst_addr, &addr->addr, sizeof(struct ieee802154_addr_sa));
 
 out:
 	release_sock(sk);
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index ba5c1e0..7ae93e1 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -40,7 +40,7 @@
 #include "ieee802154.h"
 
 int ieee802154_nl_assoc_indic(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 cap)
+		struct ieee802154_addr_sa *addr, u8 cap)
 {
 	struct sk_buff *msg;
 
@@ -99,7 +99,7 @@ nla_put_failure:
 EXPORT_SYMBOL(ieee802154_nl_assoc_confirm);
 
 int ieee802154_nl_disassoc_indic(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 reason)
+		struct ieee802154_addr_sa *addr, u8 reason)
 {
 	struct sk_buff *msg;
 
@@ -304,7 +304,7 @@ static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
 int ieee802154_associate_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	struct ieee802154_addr addr;
+	struct ieee802154_addr_sa addr;
 	u8 page;
 	int ret = -EOPNOTSUPP;
 
@@ -351,7 +351,7 @@ out:
 int ieee802154_associate_resp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	struct ieee802154_addr addr;
+	struct ieee802154_addr_sa addr;
 	int ret = -EOPNOTSUPP;
 
 	if (!info->attrs[IEEE802154_ATTR_STATUS] ||
@@ -383,7 +383,7 @@ out:
 int ieee802154_disassociate_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	struct ieee802154_addr addr;
+	struct ieee802154_addr_sa addr;
 	int ret = -EOPNOTSUPP;
 
 	if ((!info->attrs[IEEE802154_ATTR_DEST_HW_ADDR] &&
@@ -425,7 +425,7 @@ out:
 int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
-	struct ieee802154_addr addr;
+	struct ieee802154_addr_sa addr;
 
 	u8 channel, bcn_ord, sf_ord;
 	u8 page;
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 1dae199..f08b37a 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -36,8 +36,8 @@ static int lowpan_frag_reasm(struct lowpan_frag_queue *fq,
 			     struct sk_buff *prev, struct net_device *dev);
 
 static unsigned int lowpan_hash_frag(__be16 tag, u16 d_size,
-				     const struct ieee802154_addr *saddr,
-				     const struct ieee802154_addr *daddr)
+				     const struct ieee802154_addr_sa *saddr,
+				     const struct ieee802154_addr_sa *daddr)
 {
 	u32 c;
 
@@ -103,7 +103,7 @@ out:
 
 static inline struct lowpan_frag_queue *
 fq_find(struct net *net, const struct ieee802154_frag_info *frag_info,
-	const struct ieee802154_addr *src, const struct ieee802154_addr *dst)
+	const struct ieee802154_addr_sa *src, const struct ieee802154_addr_sa *dst)
 {
 	struct inet_frag_queue *q;
 	struct lowpan_create_arg arg;
diff --git a/net/ieee802154/reassembly.h b/net/ieee802154/reassembly.h
index 055518b..895721a 100644
--- a/net/ieee802154/reassembly.h
+++ b/net/ieee802154/reassembly.h
@@ -6,8 +6,8 @@
 struct lowpan_create_arg {
 	__be16 tag;
 	u16 d_size;
-	const struct ieee802154_addr *src;
-	const struct ieee802154_addr *dst;
+	const struct ieee802154_addr_sa *src;
+	const struct ieee802154_addr_sa *dst;
 };
 
 /* Equivalent of ipv4 struct ip
@@ -17,11 +17,11 @@ struct lowpan_frag_queue {
 
 	__be16			tag;
 	u16			d_size;
-	struct ieee802154_addr	saddr;
-	struct ieee802154_addr	daddr;
+	struct ieee802154_addr_sa	saddr;
+	struct ieee802154_addr_sa	daddr;
 };
 
-static inline u32 ieee802154_addr_hash(const struct ieee802154_addr *a)
+static inline u32 ieee802154_addr_hash(const struct ieee802154_addr_sa *a)
 {
 	switch (a->addr_type) {
 	case IEEE802154_ADDR_LONG:
@@ -34,8 +34,9 @@ static inline u32 ieee802154_addr_hash(const struct ieee802154_addr *a)
 	}
 }
 
-static inline bool ieee802154_addr_addr_equal(const struct ieee802154_addr *a1,
-				   const struct ieee802154_addr *a2)
+static inline bool
+ieee802154_addr_addr_equal(const struct ieee802154_addr_sa *a1,
+			   const struct ieee802154_addr_sa *a2)
 {
 	if (a1->pan_id != a2->pan_id)
 		return false;
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index a99910d..e079c57 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -34,7 +34,7 @@
 #include "mac802154.h"
 
 static int mac802154_mlme_start_req(struct net_device *dev,
-				    struct ieee802154_addr *addr,
+				    struct ieee802154_addr_sa *addr,
 				    u8 channel, u8 page,
 				    u8 bcn_ord, u8 sf_ord,
 				    u8 pan_coord, u8 blx,
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 372d8a2..b2bc3f0 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -132,9 +132,9 @@ static int mac802154_header_create(struct sk_buff *skb,
 				   const void *_saddr,
 				   unsigned len)
 {
-	const struct ieee802154_addr *saddr = _saddr;
-	const struct ieee802154_addr *daddr = _daddr;
-	struct ieee802154_addr dev_addr;
+	const struct ieee802154_addr_sa *saddr = _saddr;
+	const struct ieee802154_addr_sa *daddr = _daddr;
+	struct ieee802154_addr_sa dev_addr;
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 	int pos = 2;
 	u8 head[MAC802154_FRAME_HARD_HEADER_LEN];
@@ -219,7 +219,7 @@ mac802154_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
 	const u8 *hdr = skb_mac_header(skb);
 	const u8 *tail = skb_tail_pointer(skb);
-	struct ieee802154_addr *addr = (struct ieee802154_addr *)haddr;
+	struct ieee802154_addr_sa *addr = (struct ieee802154_addr_sa *)haddr;
 	u16 fc;
 	int da_type;
 
@@ -304,7 +304,7 @@ mac802154_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 		goto malformed;
 	}
 
-	return sizeof(struct ieee802154_addr);
+	return sizeof(struct ieee802154_addr_sa);
 
 malformed:
 	pr_debug("malformed packet\n");
-- 
1.7.9.5
