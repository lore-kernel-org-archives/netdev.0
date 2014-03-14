From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2 5/8] mac802154: use header operations to create/parse headers
Date: Fri, 14 Mar 2014 21:24:01 +0100
Message-ID: <1394828644-19898-6-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1394828644-19898-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:52622 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791AbaCNUYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 16:24:10 -0400
In-Reply-To: <1394828644-19898-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the operations on 802.15.4 header structs introduced in a previous
patch to create and parse all headers in the mac802154 stack. This patch
reduces code duplication between different parts of the mac802154 stack
that needed information from headers, and also fixes a few bugs that
seem to have gone unnoticed until now:

 * 802.15.4 dgram sockets would return a slightly incorrect value for
   the SIOCINQ ioctl
 * mac802154 would not drop frames with the "security enabled" bit set,
   even though it does not support security, in violation of the
   standard

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 include/net/ieee802154_netdev.h |  10 +-
 net/ieee802154/6lowpan_rtnl.c   |  16 +-
 net/ieee802154/af802154.h       |   5 +-
 net/ieee802154/af_ieee802154.c  |  22 +--
 net/ieee802154/dgram.c          |  60 ++++----
 net/ieee802154/raw.c            |  14 +-
 net/mac802154/mib.c             |  10 +-
 net/mac802154/wpan.c            | 321 +++++++++++-----------------------------
 8 files changed, 154 insertions(+), 304 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index c3fc33a..8e7f690 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -216,23 +216,17 @@ static inline struct ieee802154_mac_cb *mac_cb(struct sk_buff *skb)
 
 #define MAC_CB_FLAG_ACKREQ		(1 << 3)
 #define MAC_CB_FLAG_SECEN		(1 << 4)
-#define MAC_CB_FLAG_INTRAPAN		(1 << 5)
 
-static inline int mac_cb_is_ackreq(struct sk_buff *skb)
+static inline bool mac_cb_is_ackreq(struct sk_buff *skb)
 {
 	return mac_cb(skb)->flags & MAC_CB_FLAG_ACKREQ;
 }
 
-static inline int mac_cb_is_secen(struct sk_buff *skb)
+static inline bool mac_cb_is_secen(struct sk_buff *skb)
 {
 	return mac_cb(skb)->flags & MAC_CB_FLAG_SECEN;
 }
 
-static inline int mac_cb_is_intrapan(struct sk_buff *skb)
-{
-	return mac_cb(skb)->flags & MAC_CB_FLAG_INTRAPAN;
-}
-
 static inline int mac_cb_type(struct sk_buff *skb)
 {
 	return mac_cb(skb)->flags & MAC_CB_FLAG_TYPEMASK;
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index c23349d..678564c 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -91,7 +91,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 {
 	const u8 *saddr = _saddr;
 	const u8 *daddr = _daddr;
-	struct ieee802154_addr_sa sa, da;
+	struct ieee802154_addr sa, da;
 
 	/* TODO:
 	 * if this package isn't ipv6 one, where should it be routed?
@@ -119,10 +119,10 @@ static int lowpan_header_create(struct sk_buff *skb,
 	mac_cb(skb)->seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 
 	/* prepare wpan address data */
-	sa.addr_type = IEEE802154_ADDR_LONG;
-	sa.pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
+	sa.mode = IEEE802154_ADDR_LONG;
+	sa.pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
+	sa.extended_addr = ieee802154_devaddr_from_raw(saddr);
 
-	memcpy(&(sa.hwaddr), saddr, 8);
 	/* intra-PAN communications */
 	da.pan_id = sa.pan_id;
 
@@ -130,11 +130,11 @@ static int lowpan_header_create(struct sk_buff *skb,
 	 * corresponding short address
 	 */
 	if (lowpan_is_addr_broadcast(daddr)) {
-		da.addr_type = IEEE802154_ADDR_SHORT;
-		da.short_addr = IEEE802154_ADDR_BROADCAST;
+		da.mode = IEEE802154_ADDR_SHORT;
+		da.short_addr = cpu_to_le16(IEEE802154_ADDR_BROADCAST);
 	} else {
-		da.addr_type = IEEE802154_ADDR_LONG;
-		memcpy(&(da.hwaddr), daddr, IEEE802154_ADDR_LEN);
+		da.mode = IEEE802154_ADDR_LONG;
+		da.extended_addr = ieee802154_devaddr_from_raw(daddr);
 
 		/* request acknowledgment */
 		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
diff --git a/net/ieee802154/af802154.h b/net/ieee802154/af802154.h
index 331d15c..8330a09 100644
--- a/net/ieee802154/af802154.h
+++ b/net/ieee802154/af802154.h
@@ -25,12 +25,13 @@
 #define AF802154_H
 
 struct sk_buff;
-struct net_devce;
+struct net_device;
+struct ieee802154_addr;
 extern struct proto ieee802154_raw_prot;
 extern struct proto ieee802154_dgram_prot;
 void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb);
 int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb);
 struct net_device *ieee802154_get_dev(struct net *net,
-		struct ieee802154_addr_sa *addr);
+				      const struct ieee802154_addr *addr);
 
 #endif
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 973cb11..be44a86 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -43,25 +43,27 @@
 /*
  * Utility function for families
  */
-struct net_device *ieee802154_get_dev(struct net *net,
-		struct ieee802154_addr_sa *addr)
+struct net_device*
+ieee802154_get_dev(struct net *net, const struct ieee802154_addr *addr)
 {
 	struct net_device *dev = NULL;
 	struct net_device *tmp;
 	__le16 pan_id, short_addr;
+	u8 hwaddr[IEEE802154_ADDR_LEN];
 
-	switch (addr->addr_type) {
+	switch (addr->mode) {
 	case IEEE802154_ADDR_LONG:
+		ieee802154_devaddr_to_raw(hwaddr, addr->extended_addr);
 		rcu_read_lock();
-		dev = dev_getbyhwaddr_rcu(net, ARPHRD_IEEE802154, addr->hwaddr);
+		dev = dev_getbyhwaddr_rcu(net, ARPHRD_IEEE802154, hwaddr);
 		if (dev)
 			dev_hold(dev);
 		rcu_read_unlock();
 		break;
 	case IEEE802154_ADDR_SHORT:
-		if (addr->pan_id == IEEE802154_PANID_BROADCAST ||
-		    addr->short_addr == IEEE802154_ADDR_UNDEF ||
-		    addr->short_addr == IEEE802154_ADDR_UNDEF)
+		if (addr->pan_id == cpu_to_le16(IEEE802154_PANID_BROADCAST) ||
+		    addr->short_addr == cpu_to_le16(IEEE802154_ADDR_UNDEF) ||
+		    addr->short_addr == cpu_to_le16(IEEE802154_ADDR_UNDEF))
 			break;
 
 		rtnl_lock();
@@ -74,8 +76,8 @@ struct net_device *ieee802154_get_dev(struct net *net,
 			short_addr =
 				ieee802154_mlme_ops(tmp)->get_short_addr(tmp);
 
-			if (le16_to_cpu(pan_id) == addr->pan_id &&
-			    le16_to_cpu(short_addr) == addr->short_addr) {
+			if (pan_id == addr->pan_id &&
+			    short_addr == addr->short_addr) {
 				dev = tmp;
 				dev_hold(dev);
 				break;
@@ -86,7 +88,7 @@ struct net_device *ieee802154_get_dev(struct net *net,
 		break;
 	default:
 		pr_warning("Unsupported ieee802154 address type: %d\n",
-				addr->addr_type);
+				addr->mode);
 		break;
 	}
 
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 9df3a1d94..0a926c6 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -41,8 +41,8 @@ static DEFINE_RWLOCK(dgram_lock);
 struct dgram_sock {
 	struct sock sk;
 
-	struct ieee802154_addr_sa src_addr;
-	struct ieee802154_addr_sa dst_addr;
+	struct ieee802154_addr src_addr;
+	struct ieee802154_addr dst_addr;
 
 	unsigned int bound:1;
 	unsigned int want_ack:1;
@@ -73,10 +73,10 @@ static int dgram_init(struct sock *sk)
 {
 	struct dgram_sock *ro = dgram_sk(sk);
 
-	ro->dst_addr.addr_type = IEEE802154_ADDR_LONG;
-	ro->dst_addr.pan_id = 0xffff;
+	ro->dst_addr.mode = IEEE802154_ADDR_LONG;
+	ro->dst_addr.pan_id = cpu_to_le16(IEEE802154_ADDR_BROADCAST);
 	ro->want_ack = 1;
-	memset(&ro->dst_addr.hwaddr, 0xff, sizeof(ro->dst_addr.hwaddr));
+	memset(&ro->dst_addr.extended_addr, 0xff, IEEE802154_ADDR_LEN);
 	return 0;
 }
 
@@ -88,6 +88,7 @@ static void dgram_close(struct sock *sk, long timeout)
 static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
 {
 	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
+	struct ieee802154_addr haddr;
 	struct dgram_sock *ro = dgram_sk(sk);
 	int err = -EINVAL;
 	struct net_device *dev;
@@ -102,7 +103,8 @@ static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
 	if (addr->family != AF_IEEE802154)
 		goto out;
 
-	dev = ieee802154_get_dev(sock_net(sk), &addr->addr);
+	ieee802154_addr_from_sa(&haddr, &addr->addr);
+	dev = ieee802154_get_dev(sock_net(sk), &haddr);
 	if (!dev) {
 		err = -ENODEV;
 		goto out;
@@ -113,7 +115,7 @@ static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
 		goto out_put;
 	}
 
-	memcpy(&ro->src_addr, &addr->addr, sizeof(struct ieee802154_addr_sa));
+	ro->src_addr = haddr;
 
 	ro->bound = 1;
 	err = 0;
@@ -149,8 +151,7 @@ static int dgram_ioctl(struct sock *sk, int cmd, unsigned long arg)
 			 * of this packet since that is all
 			 * that will be read.
 			 */
-			/* FIXME: parse the header for more correct value */
-			amount = skb->len - (3+8+8);
+			amount = skb->len - ieee802154_hdr_length(skb);
 		}
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		return put_user(amount, (int __user *)arg);
@@ -181,7 +182,7 @@ static int dgram_connect(struct sock *sk, struct sockaddr *uaddr,
 		goto out;
 	}
 
-	memcpy(&ro->dst_addr, &addr->addr, sizeof(struct ieee802154_addr_sa));
+	ieee802154_addr_from_sa(&ro->dst_addr, &addr->addr);
 
 out:
 	release_sock(sk);
@@ -194,8 +195,8 @@ static int dgram_disconnect(struct sock *sk, int flags)
 
 	lock_sock(sk);
 
-	ro->dst_addr.addr_type = IEEE802154_ADDR_LONG;
-	memset(&ro->dst_addr.hwaddr, 0xff, sizeof(ro->dst_addr.hwaddr));
+	ro->dst_addr.mode = IEEE802154_ADDR_LONG;
+	memset(&ro->dst_addr.extended_addr, 0xff, IEEE802154_ADDR_LEN);
 
 	release_sock(sk);
 
@@ -336,40 +337,43 @@ static int dgram_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	return NET_RX_SUCCESS;
 }
 
-static inline int ieee802154_match_sock(u8 *hw_addr, u16 pan_id,
-		u16 short_addr, struct dgram_sock *ro)
+static inline bool
+ieee802154_match_sock(__le64 hw_addr, __le16 pan_id, __le16 short_addr,
+		      struct dgram_sock *ro)
 {
 	if (!ro->bound)
-		return 1;
+		return true;
 
-	if (ro->src_addr.addr_type == IEEE802154_ADDR_LONG &&
-	    !memcmp(ro->src_addr.hwaddr, hw_addr, IEEE802154_ADDR_LEN))
-		return 1;
+	if (ro->src_addr.mode == IEEE802154_ADDR_LONG &&
+	    hw_addr == ro->src_addr.extended_addr)
+		return true;
 
-	if (ro->src_addr.addr_type == IEEE802154_ADDR_SHORT &&
-		     pan_id == ro->src_addr.pan_id &&
-		     short_addr == ro->src_addr.short_addr)
-		return 1;
+	if (ro->src_addr.mode == IEEE802154_ADDR_SHORT &&
+	    pan_id == ro->src_addr.pan_id &&
+	    short_addr == ro->src_addr.short_addr)
+		return true;
 
-	return 0;
+	return false;
 }
 
 int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
 {
 	struct sock *sk, *prev = NULL;
 	int ret = NET_RX_SUCCESS;
-	u16 pan_id, short_addr;
+	__le16 pan_id, short_addr;
+	__le64 hw_addr;
 
 	/* Data frame processing */
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
-	pan_id = le16_to_cpu(ieee802154_mlme_ops(dev)->get_pan_id(dev));
-	short_addr = le16_to_cpu(ieee802154_mlme_ops(dev)->get_short_addr(dev));
+	pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
+	short_addr = ieee802154_mlme_ops(dev)->get_short_addr(dev);
+	hw_addr = ieee802154_devaddr_from_raw(dev->dev_addr);
 
 	read_lock(&dgram_lock);
 	sk_for_each(sk, &dgram_head) {
-		if (ieee802154_match_sock(dev->dev_addr, pan_id, short_addr,
-					dgram_sk(sk))) {
+		if (ieee802154_match_sock(hw_addr, pan_id, short_addr,
+					  dgram_sk(sk))) {
 			if (prev) {
 				struct sk_buff *clone;
 				clone = skb_clone(skb, GFP_ATOMIC);
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 41f538b..e5258cf 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -28,6 +28,7 @@
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <net/af_ieee802154.h>
+#include <net/ieee802154_netdev.h>
 
 #include "af802154.h"
 
@@ -55,21 +56,24 @@ static void raw_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
-static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int len)
+static int raw_bind(struct sock *sk, struct sockaddr *_uaddr, int len)
 {
-	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
+	struct ieee802154_addr addr;
+	struct sockaddr_ieee802154 *uaddr = (struct sockaddr_ieee802154 *)_uaddr;
 	int err = 0;
 	struct net_device *dev = NULL;
 
-	if (len < sizeof(*addr))
+	if (len < sizeof(*uaddr))
 		return -EINVAL;
 
-	if (addr->family != AF_IEEE802154)
+	uaddr = (struct sockaddr_ieee802154 *)_uaddr;
+	if (uaddr->family != AF_IEEE802154)
 		return -EINVAL;
 
 	lock_sock(sk);
 
-	dev = ieee802154_get_dev(sock_net(sk), &addr->addr);
+	ieee802154_addr_from_sa(&addr, &uaddr->addr);
+	dev = ieee802154_get_dev(sock_net(sk), &addr);
 	if (!dev) {
 		err = -ENODEV;
 		goto out;
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index ba5abdc..153bd1d 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -26,6 +26,7 @@
 #include <net/mac802154.h>
 #include <net/ieee802154_netdev.h>
 #include <net/wpan-phy.h>
+#include <net/ieee802154_netdev.h>
 
 #include "mac802154.h"
 
@@ -115,13 +116,12 @@ void mac802154_dev_set_ieee_addr(struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
 	struct mac802154_priv *mac = priv->hw;
-	__le64 addr;
 
-	addr = ieee802154_devaddr_from_raw(dev->dev_addr);
-	priv->extended_addr = addr;
+	priv->extended_addr = ieee802154_devaddr_from_raw(dev->dev_addr);
 
-	if (mac->ops->set_hw_addr_filt && mac->hw.hw_filt.ieee_addr != addr) {
-		mac->hw.hw_filt.ieee_addr = addr;
+	if (mac->ops->set_hw_addr_filt &&
+	    mac->hw.hw_filt.ieee_addr != priv->extended_addr) {
+		mac->hw.hw_filt.ieee_addr = priv->extended_addr;
 		set_hw_addr_filt(dev, IEEE802515_AFILT_IEEEADDR_CHANGED);
 	}
 }
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 43e886b..051ed46 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -35,35 +35,6 @@
 
 #include "mac802154.h"
 
-static inline int mac802154_fetch_skb_u8(struct sk_buff *skb, u8 *val)
-{
-	if (unlikely(!pskb_may_pull(skb, 1)))
-		return -EINVAL;
-
-	*val = skb->data[0];
-	skb_pull(skb, 1);
-
-	return 0;
-}
-
-static inline int mac802154_fetch_skb_u16(struct sk_buff *skb, u16 *val)
-{
-	if (unlikely(!pskb_may_pull(skb, 2)))
-		return -EINVAL;
-
-	*val = skb->data[0] | (skb->data[1] << 8);
-	skb_pull(skb, 2);
-
-	return 0;
-}
-
-static inline void mac802154_haddr_copy_swap(u8 *dest, const u8 *src)
-{
-	int i;
-	for (i = 0; i < IEEE802154_ADDR_LEN; i++)
-		dest[IEEE802154_ADDR_LEN - i - 1] = src[i];
-}
-
 static int
 mac802154_wpan_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -134,25 +105,21 @@ static int mac802154_wpan_mac_addr(struct net_device *dev, void *p)
 static int mac802154_header_create(struct sk_buff *skb,
 				   struct net_device *dev,
 				   unsigned short type,
-				   const void *_daddr,
-				   const void *_saddr,
+				   const void *daddr,
+				   const void *saddr,
 				   unsigned len)
 {
-	const struct ieee802154_addr_sa *saddr = _saddr;
-	const struct ieee802154_addr_sa *daddr = _daddr;
-	struct ieee802154_addr_sa dev_addr;
+	struct ieee802154_hdr hdr;
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-	int pos = 2;
-	u8 head[MAC802154_FRAME_HARD_HEADER_LEN];
-	u16 fc;
+	int hlen;
 
 	if (!daddr)
 		return -EINVAL;
 
-	head[pos++] = mac_cb(skb)->seq; /* DSN/BSN */
-	fc = mac_cb_type(skb);
-	if (mac_cb_is_ackreq(skb))
-		fc |= IEEE802154_FC_ACK_REQ;
+	memset(&hdr.fc, 0, sizeof(hdr.fc));
+	hdr.fc.type = mac_cb_type(skb);
+	hdr.fc.security_enabled = mac_cb_is_secen(skb);
+	hdr.fc.ack_request = mac_cb_is_ackreq(skb);
 
 	if (!saddr) {
 		spin_lock_bh(&priv->mib_lock);
@@ -160,161 +127,45 @@ static int mac802154_header_create(struct sk_buff *skb,
 		if (priv->short_addr == cpu_to_le16(IEEE802154_ADDR_BROADCAST) ||
 		    priv->short_addr == cpu_to_le16(IEEE802154_ADDR_UNDEF) ||
 		    priv->pan_id == cpu_to_le16(IEEE802154_PANID_BROADCAST)) {
-			dev_addr.addr_type = IEEE802154_ADDR_LONG;
-			memcpy(dev_addr.hwaddr, dev->dev_addr,
-			       IEEE802154_ADDR_LEN);
+			hdr.source.mode = IEEE802154_ADDR_LONG;
+			hdr.source.extended_addr = priv->extended_addr;
 		} else {
-			dev_addr.addr_type = IEEE802154_ADDR_SHORT;
-			dev_addr.short_addr = le16_to_cpu(priv->short_addr);
+			hdr.source.mode = IEEE802154_ADDR_SHORT;
+			hdr.source.short_addr = priv->short_addr;
 		}
 
-		dev_addr.pan_id = le16_to_cpu(priv->pan_id);
-		saddr = &dev_addr;
+		hdr.source.pan_id = priv->pan_id;
 
 		spin_unlock_bh(&priv->mib_lock);
+	} else {
+		hdr.source = *(const struct ieee802154_addr *)saddr;
 	}
 
-	if (daddr->addr_type != IEEE802154_ADDR_NONE) {
-		fc |= (daddr->addr_type << IEEE802154_FC_DAMODE_SHIFT);
-
-		head[pos++] = daddr->pan_id & 0xff;
-		head[pos++] = daddr->pan_id >> 8;
-
-		if (daddr->addr_type == IEEE802154_ADDR_SHORT) {
-			head[pos++] = daddr->short_addr & 0xff;
-			head[pos++] = daddr->short_addr >> 8;
-		} else {
-			mac802154_haddr_copy_swap(head + pos, daddr->hwaddr);
-			pos += IEEE802154_ADDR_LEN;
-		}
-	}
-
-	if (saddr->addr_type != IEEE802154_ADDR_NONE) {
-		fc |= (saddr->addr_type << IEEE802154_FC_SAMODE_SHIFT);
-
-		if ((saddr->pan_id == daddr->pan_id) &&
-		    (saddr->pan_id != IEEE802154_PANID_BROADCAST)) {
-			/* PANID compression/intra PAN */
-			fc |= IEEE802154_FC_INTRA_PAN;
-		} else {
-			head[pos++] = saddr->pan_id & 0xff;
-			head[pos++] = saddr->pan_id >> 8;
-		}
+	hdr.dest = *(const struct ieee802154_addr *)daddr;
 
-		if (saddr->addr_type == IEEE802154_ADDR_SHORT) {
-			head[pos++] = saddr->short_addr & 0xff;
-			head[pos++] = saddr->short_addr >> 8;
-		} else {
-			mac802154_haddr_copy_swap(head + pos, saddr->hwaddr);
-			pos += IEEE802154_ADDR_LEN;
-		}
-	}
-
-	head[0] = fc;
-	head[1] = fc >> 8;
+	hlen = ieee802154_hdr_push(skb, &hdr);
+	if (hlen < 0)
+		return -EINVAL;
 
-	memcpy(skb_push(skb, pos), head, pos);
 	skb_reset_mac_header(skb);
-	skb->mac_len = pos;
+	skb->mac_len = hlen;
 
-	return pos;
+	return hlen;
 }
 
 static int
 mac802154_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
-	const u8 *hdr = skb_mac_header(skb);
-	const u8 *tail = skb_tail_pointer(skb);
-	struct ieee802154_addr_sa *addr = (struct ieee802154_addr_sa *)haddr;
-	u16 fc;
-	int da_type;
-
-	if (hdr + 3 > tail)
-		goto malformed;
-
-	fc = hdr[0] | (hdr[1] << 8);
+	struct ieee802154_hdr hdr;
+	struct ieee802154_addr *addr = (struct ieee802154_addr *)haddr;
 
-	hdr += 3;
-
-	da_type = IEEE802154_FC_DAMODE(fc);
-	addr->addr_type = IEEE802154_FC_SAMODE(fc);
-
-	switch (da_type) {
-	case IEEE802154_ADDR_NONE:
-		if (fc & IEEE802154_FC_INTRA_PAN)
-			goto malformed;
-		break;
-	case IEEE802154_ADDR_LONG:
-		if (fc & IEEE802154_FC_INTRA_PAN) {
-			if (hdr + 2 > tail)
-				goto malformed;
-			addr->pan_id = hdr[0] | (hdr[1] << 8);
-			hdr += 2;
-		}
-
-		if (hdr + IEEE802154_ADDR_LEN > tail)
-			goto malformed;
-
-		hdr += IEEE802154_ADDR_LEN;
-		break;
-	case IEEE802154_ADDR_SHORT:
-		if (fc & IEEE802154_FC_INTRA_PAN) {
-			if (hdr + 2 > tail)
-				goto malformed;
-			addr->pan_id = hdr[0] | (hdr[1] << 8);
-			hdr += 2;
-		}
-
-		if (hdr + 2 > tail)
-			goto malformed;
-
-		hdr += 2;
-		break;
-	default:
-		goto malformed;
-
-	}
-
-	switch (addr->addr_type) {
-	case IEEE802154_ADDR_NONE:
-		break;
-	case IEEE802154_ADDR_LONG:
-		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
-			if (hdr + 2 > tail)
-				goto malformed;
-			addr->pan_id = hdr[0] | (hdr[1] << 8);
-			hdr += 2;
-		}
-
-		if (hdr + IEEE802154_ADDR_LEN > tail)
-			goto malformed;
-
-		mac802154_haddr_copy_swap(addr->hwaddr, hdr);
-		hdr += IEEE802154_ADDR_LEN;
-		break;
-	case IEEE802154_ADDR_SHORT:
-		if (!(fc & IEEE802154_FC_INTRA_PAN)) {
-			if (hdr + 2 > tail)
-				goto malformed;
-			addr->pan_id = hdr[0] | (hdr[1] << 8);
-			hdr += 2;
-		}
-
-		if (hdr + 2 > tail)
-			goto malformed;
-
-		addr->short_addr = hdr[0] | (hdr[1] << 8);
-		hdr += 2;
-		break;
-	default:
-		goto malformed;
+	if (ieee802154_hdr_peek_addrs(skb, &hdr) < 0) {
+		pr_debug("malformed packet\n");
+		return 0;
 	}
 
-	return sizeof(struct ieee802154_addr_sa);
-
-malformed:
-	pr_debug("malformed packet\n");
-	return 0;
+	*addr = hdr.source;
+	return sizeof(*addr);
 }
 
 static netdev_tx_t
@@ -462,88 +313,82 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 	}
 }
 
-static int mac802154_parse_frame_start(struct sk_buff *skb)
+static void mac802154_print_addr(const char *name,
+				 const struct ieee802154_addr *addr)
 {
-	u8 *head = skb->data;
-	u16 fc;
-
-	if (mac802154_fetch_skb_u16(skb, &fc) ||
-	    mac802154_fetch_skb_u8(skb, &(mac_cb(skb)->seq)))
-		goto err;
+	if (addr->mode == IEEE802154_ADDR_NONE)
+		pr_debug("%s not present\n", name);
 
-	pr_debug("fc: %04x dsn: %02x\n", fc, head[2]);
+	pr_debug("%s PAN ID: %04x\n", name, le16_to_cpu(addr->pan_id));
+	if (addr->mode == IEEE802154_ADDR_SHORT) {
+		pr_debug("%s is short: %04x\n", name,
+			 le16_to_cpu(addr->short_addr));
+	} else {
+		u64 hw = swab64((__force u64) addr->extended_addr);
 
-	mac_cb(skb)->flags = IEEE802154_FC_TYPE(fc);
-	mac_cb(skb)->sa.addr_type = IEEE802154_FC_SAMODE(fc);
-	mac_cb(skb)->da.addr_type = IEEE802154_FC_DAMODE(fc);
+		pr_debug("%s is hardware: %8phC\n", name, &hw);
+	}
+}
 
-	if (fc & IEEE802154_FC_INTRA_PAN)
-		mac_cb(skb)->flags |= MAC_CB_FLAG_INTRAPAN;
+static int mac802154_parse_frame_start(struct sk_buff *skb)
+{
+	struct ieee802154_hdr hdr;
+	int hlen;
 
-	if (mac_cb(skb)->da.addr_type != IEEE802154_ADDR_NONE) {
-		if (mac802154_fetch_skb_u16(skb, &(mac_cb(skb)->da.pan_id)))
-			goto err;
+	hlen = ieee802154_hdr_pull(skb, &hdr);
+	if (hlen < 0)
+		return -EINVAL;
 
-		/* source PAN id compression */
-		if (mac_cb_is_intrapan(skb))
-			mac_cb(skb)->sa.pan_id = mac_cb(skb)->da.pan_id;
+	skb->mac_len = hlen;
 
-		pr_debug("dest PAN addr: %04x\n", mac_cb(skb)->da.pan_id);
+	pr_debug("fc: %04x dsn: %02x\n", le16_to_cpup((__le16 *)&hdr.fc),
+		 hdr.seq);
 
-		if (mac_cb(skb)->da.addr_type == IEEE802154_ADDR_SHORT) {
-			u16 *da = &(mac_cb(skb)->da.short_addr);
+	mac_cb(skb)->flags = hdr.fc.type;
 
-			if (mac802154_fetch_skb_u16(skb, da))
-				goto err;
+	ieee802154_addr_to_sa(&mac_cb(skb)->sa, &hdr.source);
+	ieee802154_addr_to_sa(&mac_cb(skb)->da, &hdr.dest);
 
-			pr_debug("destination address is short: %04x\n",
-				 mac_cb(skb)->da.short_addr);
-		} else {
-			if (!pskb_may_pull(skb, IEEE802154_ADDR_LEN))
-				goto err;
+	if (hdr.fc.ack_request)
+		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
+	if (hdr.fc.security_enabled)
+		mac_cb(skb)->flags |= MAC_CB_FLAG_SECEN;
 
-			mac802154_haddr_copy_swap(mac_cb(skb)->da.hwaddr,
-						  skb->data);
-			skb_pull(skb, IEEE802154_ADDR_LEN);
+	mac802154_print_addr("destination", &hdr.dest);
+	mac802154_print_addr("source", &hdr.source);
 
-			pr_debug("destination address is hardware\n");
-		}
-	}
+	if (hdr.fc.security_enabled) {
+		u64 key;
 
-	if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE) {
-		/* non PAN-compression, fetch source address id */
-		if (!(mac_cb_is_intrapan(skb))) {
-			u16 *sa_pan = &(mac_cb(skb)->sa.pan_id);
+		pr_debug("seclevel %i\n", hdr.sec.level);
 
-			if (mac802154_fetch_skb_u16(skb, sa_pan))
-				goto err;
-		}
-
-		pr_debug("source PAN addr: %04x\n", mac_cb(skb)->da.pan_id);
-
-		if (mac_cb(skb)->sa.addr_type == IEEE802154_ADDR_SHORT) {
-			u16 *sa = &(mac_cb(skb)->sa.short_addr);
-
-			if (mac802154_fetch_skb_u16(skb, sa))
-				goto err;
+		switch (hdr.sec.key_id_mode) {
+		case IEEE802154_SCF_KEY_IMPLICIT:
+			pr_debug("implicit key\n");
+			break;
 
-			pr_debug("source address is short: %04x\n",
-				 mac_cb(skb)->sa.short_addr);
-		} else {
-			if (!pskb_may_pull(skb, IEEE802154_ADDR_LEN))
-				goto err;
+		case IEEE802154_SCF_KEY_INDEX:
+			pr_debug("key %02x\n", hdr.sec.key_id);
+			break;
 
-			mac802154_haddr_copy_swap(mac_cb(skb)->sa.hwaddr,
-						  skb->data);
-			skb_pull(skb, IEEE802154_ADDR_LEN);
+		case IEEE802154_SCF_KEY_SHORT_INDEX:
+			pr_debug("key %04x:%04x %02x\n",
+				 le32_to_cpu(hdr.sec.short_src) >> 16,
+				 le32_to_cpu(hdr.sec.short_src) & 0xffff,
+				 hdr.sec.key_id);
+			break;
 
-			pr_debug("source address is hardware\n");
+		case IEEE802154_SCF_KEY_HW_INDEX:
+			key = swab64((__force u64) hdr.sec.extended_src);
+			pr_debug("key source %8phC %02x\n", &key,
+				 hdr.sec.key_id);
+			break;
 		}
+
+		return -EINVAL;
 	}
 
 	return 0;
-err:
-	return -EINVAL;
 }
 
 void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
-- 
1.9.0
