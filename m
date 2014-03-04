From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next v4 4/4] ieee802154: remove seq
	member of mac_cb
Date: Tue,  4 Mar 2014 15:34:48 +0100
Message-ID: <1393943688-24221-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1393943688-24221-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1393943688-24221-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The seq member is only used to initialize the sequence number field of
the 802.15.4 header. This field has relevance only for low-level
functionality like frame acknowledgement and is of no importance to
upper layers. Upper layers should not be allowed to set this field at
all.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Tested-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/ieee802154_netdev.h |    1 -
 net/ieee802154/6lowpan_rtnl.c   |    1 -
 net/ieee802154/dgram.c          |    1 -
 net/mac802154/wpan.c            |    2 +-
 4 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index d23a300..cee7f22 100644
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
index 9077c6f..5845503 100644
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


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
