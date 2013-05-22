From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH beta 1] 1/3] mrf24j40: Move
	INIT_COMPLETION() to before packet transmission
Date: Tue, 21 May 2013 22:01:18 -0400
Message-ID: <1369188080-8904-2-git-send-email-alan@signal11.us>
References: <CAO+c-UVJQJbmmmCS4hxAEYHKa8gEU1Bs=y+Rv_A75UHeBZxc+w@mail.gmail.com>
	<1369188080-8904-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1369188080-8904-1-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This avoids a race condition where complete(tx_complete) could be called
before tx_complete is initialized.

Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
---
 drivers/net/ieee802154/mrf24j40.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 556151d..0ea2a5a 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -345,6 +345,8 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
 	if (ret)
 		goto err;
 
+	INIT_COMPLETION(devrec->tx_complete);
+
 	/* Set TXNTRIG bit of TXNCON to send packet */
 	ret = read_short_reg(devrec, REG_TXNCON, &val);
 	if (ret)
@@ -355,8 +357,6 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
 		val |= 0x4;
 	write_short_reg(devrec, REG_TXNCON, val);
 
-	INIT_COMPLETION(devrec->tx_complete);
-
 	/* Wait for the device to send the TX complete interrupt. */
 	ret = wait_for_completion_interruptible_timeout(
 						&devrec->tx_complete,
-- 
1.7.11.2


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
