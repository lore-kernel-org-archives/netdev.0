From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 8/8] ieee802154: add proper
	length checks to header creations
Date: Fri, 14 Mar 2014 16:23:33 +0100
Message-ID: <1394810613-5657-9-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1394810613-5657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394810613-5657-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Have mac802154 header_ops.create fail with -EMSGSIZE if the length
passed will be too large to fit a frame. Since 6lowpan will ensure that
no packet payload will be too large, pass a length of 0 there. 802.15.4
dgram sockets will also return -EMSGSIZE on payloads larger than the
device MTU instead of -EINVAL.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 net/ieee802154/6lowpan_rtnl.c |    2 +-
 net/ieee802154/dgram.c        |    2 +-
 net/mac802154/wpan.c          |    3 +++
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 26d4c4c..a7bc65d 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -141,7 +141,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 	}
 
 	return dev_hard_header(skb, lowpan_dev_info(dev)->real_dev,
-			type, (void *)&da, (void *)&sa, skb->len);
+			type, (void *)&da, (void *)&sa, 0);
 }
 
 static int lowpan_give_skb_to_devices(struct sk_buff *skb,
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 55f2dc4..4c47154 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -233,7 +233,7 @@ static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 	if (size > mtu) {
 		pr_debug("size = %Zu, mtu = %u\n", size, mtu);
-		err = -EINVAL;
+		err = -EMSGSIZE;
 		goto out_dev;
 	}
 
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index b614266..80cbee1 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -150,6 +150,9 @@ static int mac802154_header_create(struct sk_buff *skb,
 	skb_reset_mac_header(skb);
 	skb->mac_len = hlen;
 
+	if (hlen + len + 2 > dev->mtu)
+		return -EMSGSIZE;
+
 	return hlen;
 }
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
