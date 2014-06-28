From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 10/13] at86rf230: rework reset
	to trx_off state change
Date: Sat, 28 Jun 2014 20:33:48 +0200
Message-ID: <1403980431-6201-11-git-send-email-alex.aring@gmail.com>
References: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1403980431-6201-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 9829248..2220c74 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -44,6 +44,7 @@ struct at86rf230_local;
  * All timings are in us.
  */
 struct at86rf2xx_chip_data {
+	u16 t_reset_to_off;
 	u16 t_off_to_aack;
 	u16 t_off_to_tx_on;
 	u16 t_frame;
@@ -584,6 +585,16 @@ at86rf230_async_state_delay(void *context)
 			break;
 		}
 		break;
+	/* Default value, means RESET state */
+	case STATE_P_ON:
+		switch (ctx->to_state) {
+		case STATE_TRX_OFF:
+			usleep_range(c->t_reset_to_off, c->t_reset_to_off + 10);
+			goto change;
+		default:
+			break;
+		}
+		break;
 	default:
 		break;
 	}
@@ -1238,6 +1249,7 @@ static struct ieee802154_ops at86rf230_ops = {
 };
 
 static struct at86rf2xx_chip_data at86rf233_data = {
+	.t_reset_to_off = 26,
 	.t_off_to_aack = 80,
 	.t_off_to_tx_on = 80,
 	.t_frame = 4096,
@@ -1251,6 +1263,7 @@ static struct at86rf2xx_chip_data at86rf233_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf231_data = {
+	.t_reset_to_off = 37,
 	.t_off_to_aack = 110,
 	.t_off_to_tx_on = 110,
 	.t_frame = 4096,
@@ -1264,6 +1277,7 @@ static struct at86rf2xx_chip_data at86rf231_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf212_data = {
+	.t_reset_to_off = 26,
 	.t_off_to_aack = 200,
 	.t_off_to_tx_on = 200,
 	.t_frame = 4096,
@@ -1282,7 +1296,7 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	unsigned int dvdd;
 	u8 csma_seed[2];
 
-	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_FORCE_TRX_OFF);
+	rc = at86rf230_sync_state_change(lp, STATE_FORCE_TRX_OFF);
 	if (rc)
 		return rc;
 
-- 
2.0.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
