From: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
Subject: [PATCH 2/3] ieee802154/at86rf230: Implement
	hardware address filter callback.
Date: Tue, 26 Mar 2013 22:41:30 +0000
Message-ID: <1364337691-20163-3-git-send-email-stefan@datenfreihafen.org>
References: <1364337691-20163-1-git-send-email-stefan@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364337691-20163-1-git-send-email-stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Implement the filter function to update short address, pan id and ieee
address on change. Allowing for hardware address filtering needed for
auto ACK.

Signed-off-by: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c |   47 ++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index fc1687e..2ff1f20 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -619,6 +619,52 @@ err:
 	return -EINVAL;
 }
 
+static int
+at86rf230_set_hw_addr_filt(struct ieee802154_dev *dev,
+			   struct ieee802154_hw_addr_filt *filt,
+			   unsigned long changed)
+{
+	struct at86rf230_local *lp = dev->priv;
+
+	if (changed & IEEE802515_AFILT_SADDR_CHANGED) {
+		dev_vdbg(&lp->spi->dev,
+			"at86rf230_set_hw_addr_filt called for saddr\n");
+		__at86rf230_write(lp, RG_SHORT_ADDR_0, filt->short_addr);
+		__at86rf230_write(lp, RG_SHORT_ADDR_1, filt->short_addr >> 8);
+	}
+
+	if (changed & IEEE802515_AFILT_PANID_CHANGED) {
+		dev_vdbg(&lp->spi->dev,
+			"at86rf230_set_hw_addr_filt called for pan id\n");
+		__at86rf230_write(lp, RG_PAN_ID_0, filt->pan_id);
+		__at86rf230_write(lp, RG_PAN_ID_1, filt->pan_id >> 8);
+	}
+
+	if (changed & IEEE802515_AFILT_IEEEADDR_CHANGED) {
+		dev_vdbg(&lp->spi->dev,
+			"at86rf230_set_hw_addr_filt called for IEEE addr\n");
+		at86rf230_write_subreg(lp, SR_IEEE_ADDR_0, filt->ieee_addr[7]);
+		at86rf230_write_subreg(lp, SR_IEEE_ADDR_1, filt->ieee_addr[6]);
+		at86rf230_write_subreg(lp, SR_IEEE_ADDR_2, filt->ieee_addr[5]);
+		at86rf230_write_subreg(lp, SR_IEEE_ADDR_3, filt->ieee_addr[4]);
+		at86rf230_write_subreg(lp, SR_IEEE_ADDR_4, filt->ieee_addr[3]);
+		at86rf230_write_subreg(lp, SR_IEEE_ADDR_5, filt->ieee_addr[2]);
+		at86rf230_write_subreg(lp, SR_IEEE_ADDR_6, filt->ieee_addr[1]);
+		at86rf230_write_subreg(lp, SR_IEEE_ADDR_7, filt->ieee_addr[0]);
+	}
+
+	if (changed & IEEE802515_AFILT_PANC_CHANGED) {
+		dev_vdbg(&lp->spi->dev,
+			"at86rf230_set_hw_addr_filt called for panc change\n");
+		if (filt->pan_coord)
+			at86rf230_write_subreg(lp, SR_AACK_I_AM_COORD, 1);
+		else
+			at86rf230_write_subreg(lp, SR_AACK_I_AM_COORD, 0);
+	}
+
+	return 0;
+}
+
 static struct ieee802154_ops at86rf230_ops = {
 	.owner = THIS_MODULE,
 	.xmit = at86rf230_xmit,
@@ -626,6 +672,7 @@ static struct ieee802154_ops at86rf230_ops = {
 	.set_channel = at86rf230_channel,
 	.start = at86rf230_start,
 	.stop = at86rf230_stop,
+	.set_hw_addr_filt = at86rf230_set_hw_addr_filt,
 };
 
 static void at86rf230_irqwork(struct work_struct *work)
-- 
1.7.10.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
