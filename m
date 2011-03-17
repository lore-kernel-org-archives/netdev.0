From: Alex Dubov <oakad@yahoo.com>
Subject: [PATCH v2] gianfar: Fall back to software tcp/udp checksum on older
	controllers
Date: Wed, 16 Mar 2011 20:57:13 -0700 (PDT)
Message-ID: <598461.73809.qm@web37603.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net,
	mlcreech@gmail.com
To: linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

As specified by errata eTSEC49 of MPC8548 and errata eTSEC12 of MPC83xx,
older revisions of gianfar controllers will be unable to calculate a TCP/UDP
packet checksum for some alignments of the appropriate FCB. This patch checks
for FCB alignment on such controllers and falls back to software checksumming
if the alignment is known to be bad.

Signed-off-by: Alex Dubov <oakad@yahoo.com>
---
Can we, please, proceed with this patch?
The issue is badly annoying, breaking quite a few of the MPC8548 chips.

Changes for v2:
   - Make indentation slightly more consistent.
   - Replace bizarre switch-based condition with plain boring one.

 drivers/net/gianfar.c |   16 ++++++++++++++--
 drivers/net/gianfar.h |    1 +
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 5ed8f9f..3da19a5 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -950,6 +950,11 @@ static void gfar_detect_errata(struct gfar_private *priv)
 			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_A002;
 
+	/* MPC8313 Rev < 2.0, MPC8548 rev 2.0 */
+	if ((pvr == 0x80850010 && mod == 0x80b0 && rev < 0x0020) ||
+			(pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020))
+		priv->errata |= GFAR_ERRATA_12;
+
 	if (priv->errata)
 		dev_info(dev, "enabled errata workarounds, flags: 0x%x\n",
 			 priv->errata);
@@ -2156,8 +2161,15 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Set up checksumming */
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
 		fcb = gfar_add_fcb(skb);
-		lstatus |= BD_LFLAG(TXBD_TOE);
-		gfar_tx_checksum(skb, fcb);
+		/* as specified by errata */
+		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12)
+			     && ((unsigned long)fcb % 0x20) > 0x18)) {
+			__skb_pull(skb, GMAC_FCB_LEN);
+			skb_checksum_help(skb);
+		} else {
+			lstatus |= BD_LFLAG(TXBD_TOE);
+			gfar_tx_checksum(skb, fcb);
+		}
 	}
 
 	if (vlan_tx_tag_present(skb)) {
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 54de413..ec5d595 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1039,6 +1039,7 @@ enum gfar_errata {
 	GFAR_ERRATA_74		= 0x01,
 	GFAR_ERRATA_76		= 0x02,
 	GFAR_ERRATA_A002	= 0x04,
+	GFAR_ERRATA_12		= 0x08, /* a.k.a errata eTSEC49 */
 };
 
 /* Struct stolen almost completely (and shamelessly) from the FCC enet source
-- 
1.7.3.2
