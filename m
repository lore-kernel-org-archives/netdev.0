From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH v2 4/4] 6lowpan: handle
	dev_queue_xmit() error code properly
Date: Wed,  3 Apr 2013 10:00:58 -0400
Message-ID: <1364997658-16498-5-git-send-email-alan@signal11.us>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
	<1364997658-16498-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364997658-16498-1-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

dev_queue_xmit() will return a positive value if the packet could not be
queued, often because the real network device (in our case the mac802154
wpan device) has its queue stopped.  lowpan_xmit() should handle the
positive return code (for the debug statement) and return that value to
the higher layer so the higher layer will retry sending the packet.

Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index e1b4580..55e1fd5 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1139,10 +1139,10 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 error:
 	dev_kfree_skb(skb);
 out:
-	if (err < 0)
+	if (err)
 		pr_debug("ERROR: xmit failed\n");
 
-	return (err < 0 ? NETDEV_TX_BUSY : NETDEV_TX_OK);
+	return (err < 0) ? NET_XMIT_DROP : err;
 }
 
 static struct wpan_phy *lowpan_get_phy(const struct net_device *dev)
-- 
1.7.11.2


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
