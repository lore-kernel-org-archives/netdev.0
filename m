From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH 2/6] mac802154: Move xmit_attemps to
	stack
Date: Tue,  2 Apr 2013 14:47:57 -0400
Message-ID: <1364928481-1813-3-git-send-email-alan@signal11.us>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364928481-1813-1-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

There's no reason to have it in the work struct anymore.

Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
---
 net/mac802154/tx.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index fbf937c..a248246 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -39,12 +39,12 @@ struct xmit_work {
 	struct mac802154_priv *priv;
 	u8 chan;
 	u8 page;
-	u8 xmit_attempts;
 };
 
 static void mac802154_xmit_worker(struct work_struct *work)
 {
 	struct xmit_work *xw = container_of(work, struct xmit_work, work);
+	u8 xmit_attempts = 0;
 	int res;
 
 	mutex_lock(&xw->priv->phy->pib_lock);
@@ -61,7 +61,7 @@ static void mac802154_xmit_worker(struct work_struct *work)
 
 	do {
 		res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
-		if (res && ++xw->xmit_attempts >= MAC802154_MAX_XMIT_ATTEMPTS) {
+		if (res && ++xmit_attempts >= MAC802154_MAX_XMIT_ATTEMPTS) {
 			pr_debug("transmission failed for %d times",
 				 MAC802154_MAX_XMIT_ATTEMPTS);
 			break;
@@ -113,7 +113,6 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 	work->priv = priv;
 	work->page = page;
 	work->chan = chan;
-	work->xmit_attempts = 0;
 
 	queue_work(priv->dev_workqueue, &work->work);
 
-- 
1.7.11.2


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
