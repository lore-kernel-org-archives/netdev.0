From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH 4/4] ieee802154: remove seq member of mac_cb
Date: Mon,  3 Mar 2014 13:59:07 +0100
Message-ID: <1393851547-27876-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:59643 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721AbaCCM7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 07:59:25 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s23CxMEk019501
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2014 13:59:22 +0100
In-Reply-To: <1393851547-27876-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The seq member is only used to initialize the sequence number field of
the 802.15.4 header. This field has relevance only for low-level
functionality like frame acknowledgement and is of no importance to
upper layers. Upper layers should not be allowed to set this field at
all.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 include/net/ieee802154_netdev.h |    1 -
 net/ieee802154/6lowpan_rtnl.c   |    1 -
 net/ieee802154/dgram.c          |    1 -
 net/mac802154/wpan.c            |    2 +-
 4 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index bc14665..503cb9f 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -85,7 +85,6 @@ struct ieee802154_frag_info {
 struct ieee802154_mac_cb {
 	u8 lqi;
 	u8 flags;
-	u8 seq;
 	struct ieee802154_frag_info frag_info;
 };
 
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index b413e4e..7ebc300 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -117,7 +117,6 @@ static int lowpan_header_create(struct sk_buff *skb,
 	 * this isn't implemented in mainline yet, so currently we assign 0xff
 	 */
 	mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
-	mac_cb(skb)->seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 
 	/* prepare wpan address data */
 	sa.addr_type = IEEE802154_ADDR_LONG;
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 5fcb817..6480510 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -253,7 +253,6 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (ro->want_ack)
 		mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
 
-	mac_cb(skb)->seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &ro->dst_addr,
 			ro->bound ? &ro->src_addr : NULL, size);
 	if (err < 0)
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 1ebe0e3..b7e47ac 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -111,7 +111,7 @@ static int mac802154_header_create(struct sk_buff *skb,
 		return -EINVAL;
 
 	hdr.fc = mac_cb_type(skb);
-	hdr.seq = mac_cb(skb)->seq;
+	hdr.seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
 	if (mac_cb_is_ackreq(skb))
 		hdr.fc |= IEEE802154_FC_ACK_REQ;
 	if (mac_cb_is_secen(skb))
-- 
1.7.9.5
