From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH 1/6] mac802154: Immediately retry
	sending failed packets
Date: Tue,  2 Apr 2013 14:47:56 -0400
Message-ID: <1364928481-1813-2-git-send-email-alan@signal11.us>
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

When ops->xmit() fails, immediately retry. Previously the packet was sent
to the back of the workqueue.

Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
---
 net/mac802154/tx.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 4e09d07..fbf937c 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -59,19 +59,18 @@ static void mac802154_xmit_worker(struct work_struct *work)
 		}
 	}
 
-	res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
+	do {
+		res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
+		if (res && ++xw->xmit_attempts >= MAC802154_MAX_XMIT_ATTEMPTS) {
+			pr_debug("transmission failed for %d times",
+				 MAC802154_MAX_XMIT_ATTEMPTS);
+			break;
+		}
+	} while (res);
 
 out:
 	mutex_unlock(&xw->priv->phy->pib_lock);
 
-	if (res) {
-		if (xw->xmit_attempts++ < MAC802154_MAX_XMIT_ATTEMPTS) {
-			queue_work(xw->priv->dev_workqueue, &xw->work);
-			return;
-		} else
-			pr_debug("transmission failed for %d times",
-				 MAC802154_MAX_XMIT_ATTEMPTS);
-	}
 
 	dev_kfree_skb(xw->skb);
 
-- 
1.7.11.2


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
