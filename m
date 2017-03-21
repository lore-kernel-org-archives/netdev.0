From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v2 3/5] net-next: ethernet: mediatek: add CDM able to
 recognize the tag for DSA
Date: Tue, 21 Mar 2017 17:35:08 +0800
Message-ID: <1490088910-19405-4-git-send-email-sean.wang@mediatek.com>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: <andrew-g2DYL2Zd6BY@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>, <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1490088910-19405-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

The patch adds the setup for allowing CDM can recognize these packets with
carrying port-distinguishing tag. Otherwise, these tagging packets will be
handled incorrectly by CDM. The setup is working out for general untag
packets as well.

Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Signed-off-by: Landen Chao <Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 6 ++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 9e75768..c21ed99 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1846,6 +1846,12 @@ static int mtk_hw_init(struct mtk_eth *eth)
 	/* GE2, Force 1000M/FD, FC ON */
 	mtk_w32(eth, MAC_MCR_FIXED_LINK, MTK_MAC_MCR(1));
 
+	/* Indicates CDM to parse the MTK special tag from CPU
+	 * which also is working out for untag packets.
+	 */
+	val = mtk_r32(eth, MTK_CDMQ_IG_CTRL);
+	mtk_w32(eth, val | MTK_CDMQ_STAG_EN, MTK_CDMQ_IG_CTRL);
+
 	/* Enable RX VLan Offloading */
 	mtk_w32(eth, 1, MTK_CDMP_EG_CTRL);
 
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 99b1c8e..996024d 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -70,6 +70,10 @@
 /* Frame Engine Interrupt Grouping Register */
 #define MTK_FE_INT_GRP		0x20
 
+/* CDMP Ingress Control Register */
+#define MTK_CDMQ_IG_CTRL	0x1400
+#define MTK_CDMQ_STAG_EN	BIT(0)
+
 /* CDMP Exgress Control Register */
 #define MTK_CDMP_EG_CTRL	0x404
 
-- 
1.9.1
