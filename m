From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH 3/4] ieee802154: remove addresses from mac_cb
Date: Mon,  3 Mar 2014 13:59:06 +0100
Message-ID: <1393851547-27876-4-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:59645 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881AbaCCM7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 07:59:25 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s23CxLBf019491
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2014 13:59:22 +0100
In-Reply-To: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mac802154 stack itself does not strictly require these fields: the
tx path never even touches them, and this patch modifies the rx path to
explicitly carry a parsed header.

One notable user of these fields was 6lowpan, which accessed them after
the skb had been passed to it through dev_queue_xmit. 6lowpan was
changed to peek the addresses from a given skb.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 include/net/ieee802154_netdev.h |    2 --
 net/ieee802154/6lowpan_rtnl.c   |   12 ++++-----
 net/ieee802154/dgram.c          |    5 +++-
 net/ieee802154/reassembly.c     |    5 +++-
 net/mac802154/wpan.c            |   57 +++++++++++++++++++--------------------
 5 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 18d2ff2..bc14665 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -84,8 +84,6 @@ struct ieee802154_frag_info {
  */
 struct ieee802154_mac_cb {
 	u8 lqi;
-	struct ieee802154_addr sa;
-	struct ieee802154_addr da;
 	u8 flags;
 	u8 seq;
 	struct ieee802154_frag_info frag_info;
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index c7bd8b5..b413e4e 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -52,6 +52,7 @@
 #include <net/af_ieee802154.h>
 #include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
+#include <net/mac802154.h>
 #include <net/ipv6.h>
 
 #include "reassembly.h"
@@ -171,7 +172,7 @@ static int lowpan_give_skb_to_devices(struct sk_buff *skb,
 static int process_data(struct sk_buff *skb)
 {
 	u8 iphc0, iphc1;
-	const struct ieee802154_addr *_saddr, *_daddr;
+	struct ieee802154_hdr hdr;
 
 	raw_dump_table(__func__, "raw skb data dump", skb->data, skb->len);
 	/* at least two bytes will be used for the encoding */
@@ -184,12 +185,11 @@ static int process_data(struct sk_buff *skb)
 	if (lowpan_fetch_skb_u8(skb, &iphc1))
 		goto drop;
 
-	_saddr = &mac_cb(skb)->sa;
-	_daddr = &mac_cb(skb)->da;
+	ieee802154_hdr_peek_addrs(skb, &hdr);
 
-	return lowpan_process_data(skb, skb->dev, (u8 *)_saddr->hwaddr,
-				_saddr->addr_type, IEEE802154_ADDR_LEN,
-				(u8 *)_daddr->hwaddr, _daddr->addr_type,
+	return lowpan_process_data(skb, skb->dev, hdr.source.hwaddr,
+				hdr.source.addr_type, IEEE802154_ADDR_LEN,
+				hdr.dest.hwaddr, hdr.dest.addr_type,
 				IEEE802154_ADDR_LEN, iphc0, iphc1,
 				lowpan_give_skb_to_devices);
 
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 1846c1f..5fcb817 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -30,6 +30,7 @@
 #include <net/af_ieee802154.h>
 #include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
+#include <net/mac802154.h>
 
 #include <asm/ioctls.h>
 
@@ -291,6 +292,7 @@ static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
 	struct sk_buff *skb;
+	struct ieee802154_hdr hdr;
 	DECLARE_SOCKADDR(struct sockaddr_ieee802154 *, saddr, msg->msg_name);
 
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
@@ -311,8 +313,9 @@ static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (saddr) {
+		ieee802154_hdr_peek_addrs(skb, &hdr);
 		saddr->family = AF_IEEE802154;
-		saddr->addr = mac_cb(skb)->sa;
+		saddr->addr = hdr.source;
 		*addr_len = sizeof(*saddr);
 	}
 
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index eb5995e..6885886 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -23,6 +23,7 @@
 #include <linux/slab.h>
 #include <linux/export.h>
 
+#include <net/mac802154.h>
 #include <net/ieee802154_netdev.h>
 #include <net/ipv6.h>
 #include <net/inet_frag.h>
@@ -354,6 +355,7 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 	struct lowpan_frag_queue *fq;
 	struct net *net = dev_net(skb->dev);
 	struct ieee802154_frag_info *frag_info = &mac_cb(skb)->frag_info;
+	struct ieee802154_hdr hdr;
 	int err;
 
 	err = lowpan_get_frag_info(skb, frag_type, frag_info);
@@ -365,7 +367,8 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 
 	inet_frag_evictor(&net->ieee802154_lowpan.frags, &lowpan_frags, false);
 
-	fq = fq_find(net, frag_info, &mac_cb(skb)->sa, &mac_cb(skb)->da);
+	ieee802154_hdr_peek_addrs(skb, &hdr);
+	fq = fq_find(net, frag_info, &hdr.source, &hdr.dest);
 	if (fq != NULL) {
 		int ret;
 		spin_lock(&fq->q.lock);
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index e25f98c..1ebe0e3 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -246,15 +246,16 @@ static int mac802154_process_data(struct net_device *dev, struct sk_buff *skb)
 }
 
 static int
-mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
+mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb,
+		      const struct ieee802154_hdr *hdr)
 {
 	pr_debug("getting packet via slave interface %s\n", sdata->dev->name);
 
 	spin_lock_bh(&sdata->mib_lock);
 
-	switch (mac_cb(skb)->da.addr_type) {
+	switch (hdr->dest.addr_type) {
 	case IEEE802154_ADDR_NONE:
-		if (mac_cb(skb)->sa.addr_type != IEEE802154_ADDR_NONE)
+		if (hdr->source.addr_type != IEEE802154_ADDR_NONE)
 			/* FIXME: check if we are PAN coordinator */
 			skb->pkt_type = PACKET_OTHERHOST;
 		else
@@ -262,23 +263,22 @@ mac802154_subif_frame(struct mac802154_sub_if_data *sdata, struct sk_buff *skb)
 			skb->pkt_type = PACKET_HOST;
 		break;
 	case IEEE802154_ADDR_LONG:
-		if (mac_cb(skb)->da.pan_id != sdata->pan_id &&
-		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
+		if (hdr->dest.pan_id != sdata->pan_id &&
+		    hdr->dest.pan_id != IEEE802154_PANID_BROADCAST)
 			skb->pkt_type = PACKET_OTHERHOST;
-		else if (!memcmp(mac_cb(skb)->da.hwaddr, sdata->dev->dev_addr,
+		else if (!memcmp(hdr->dest.hwaddr, sdata->dev->dev_addr,
 				 IEEE802154_ADDR_LEN))
 			skb->pkt_type = PACKET_HOST;
 		else
 			skb->pkt_type = PACKET_OTHERHOST;
 		break;
 	case IEEE802154_ADDR_SHORT:
-		if (mac_cb(skb)->da.pan_id != sdata->pan_id &&
-		    mac_cb(skb)->da.pan_id != IEEE802154_PANID_BROADCAST)
+		if (hdr->dest.pan_id != sdata->pan_id &&
+		    hdr->dest.pan_id != IEEE802154_PANID_BROADCAST)
 			skb->pkt_type = PACKET_OTHERHOST;
-		else if (mac_cb(skb)->da.short_addr == sdata->short_addr)
+		else if (hdr->dest.short_addr == sdata->short_addr)
 			skb->pkt_type = PACKET_HOST;
-		else if (mac_cb(skb)->da.short_addr ==
-					IEEE802154_ADDR_BROADCAST)
+		else if (hdr->dest.short_addr == IEEE802154_ADDR_BROADCAST)
 			skb->pkt_type = PACKET_BROADCAST;
 		else
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -322,9 +322,9 @@ static void mac802154_print_addr(const char *name,
 	}
 }
 
-static int mac802154_parse_frame_start(struct sk_buff *skb)
+static int mac802154_parse_frame_start(struct sk_buff *skb,
+				       struct ieee802154_hdr *hdr)
 {
-	struct ieee802154_hdr hdr;
 	int hlen;
 
 	hlen = ieee802154_hdr_pull(skb, hdr);
@@ -335,22 +335,20 @@ static int mac802154_parse_frame_start(struct sk_buff *skb)
 
 	pr_debug("fc: %04x dsn: %02x\n", hdr->fc, hdr->seq);
 
-	mac_cb(skb)->flags = IEEE802154_FC_TYPE(hdr.fc);
-	mac_cb(skb)->sa = hdr.source;
-	mac_cb(skb)->da = hdr.dest;
+	mac_cb(skb)->flags = IEEE802154_FC_TYPE(hdr->fc);
 
-	if (hdr.fc & IEEE802154_FC_SECEN)
+	if (hdr->fc & IEEE802154_FC_SECEN)
 		mac_cb(skb)->flags |= MAC_CB_FLAG_SECEN;
 
-	mac802154_print_addr("destination", &hdr.dest);
-	mac802154_print_addr("source", &hdr.source);
+	mac802154_print_addr("destination", &hdr->dest);
+	mac802154_print_addr("source", &hdr->source);
 
-	if (hdr.fc & IEEE802154_FC_SECEN) {
+	if (hdr->fc & IEEE802154_FC_SECEN) {
 		const u8 *key;
 
-		pr_debug("sc %02x\n", hdr.sec.sc);
+		pr_debug("sc %02x\n", hdr->sec.sc);
 
-		switch (IEEE802154_SCF_KEY_ID_MODE(hdr.sec.sc)) {
+		switch (IEEE802154_SCF_KEY_ID_MODE(hdr->sec.sc)) {
 		case IEEE802154_SCF_KEY_IMPLICIT:
 			pr_debug("implicit key\n");
 			break;
@@ -360,17 +358,17 @@ static int mac802154_parse_frame_start(struct sk_buff *skb)
 
 		case IEEE802154_SCF_KEY_SHORT_INDEX:
 			pr_debug("key %04x:%04x %02x\n",
-				 hdr.sec.key_source.pan.pan_id,
-				 hdr.sec.key_source.pan.short_addr,
-				 hdr.sec.key_id);
+				 hdr->sec.key_source.pan.pan_id,
+				 hdr->sec.key_source.pan.short_addr,
+				 hdr->sec.key_id);
 			break;
 
 		case IEEE802154_SCF_KEY_HW_INDEX:
-			key = hdr.sec.key_source.hw;
+			key = hdr->sec.key_source.hw;
 			pr_debug("key source %02x:%02x:%02x:%02x:%02x:%02x:"
 				 "%02x:%02x %02x\n", key[0], key[1], key[2],
 				 key[3], key[4], key[5], key[6], key[7],
-				 hdr.sec.key_id);
+				 hdr->sec.key_id);
 			break;
 		}
 	}
@@ -383,8 +381,9 @@ void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 	int ret;
 	struct sk_buff *sskb;
 	struct mac802154_sub_if_data *sdata;
+	struct ieee802154_hdr hdr;
 
-	ret = mac802154_parse_frame_start(skb);
+	ret = mac802154_parse_frame_start(skb, &hdr);
 	if (ret) {
 		pr_debug("got invalid frame\n");
 		return;
@@ -397,7 +396,7 @@ void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 
 		sskb = skb_clone(skb, GFP_ATOMIC);
 		if (sskb)
-			mac802154_subif_frame(sdata, sskb);
+			mac802154_subif_frame(sdata, sskb, &hdr);
 	}
 	rcu_read_unlock();
 }
-- 
1.7.9.5
