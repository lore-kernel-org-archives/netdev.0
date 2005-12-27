From: Eugene Surovegin <ebs@ebshome.net>
Subject: [PATCH] PPC44x EMAC driver: disable TX status deferral in
	half-duplex mode
Date: Tue, 27 Dec 2005 12:36:41 -0800
Message-ID: <20051227203641.GA22988@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Disable TX status deferral (EMACx_MR[MWSW=001]) in half-duplex mode.
I have two reports when EMAC stops transmitting when connected to a 
hub. TX ring debug printouts show complete mess when this happens, 
probably hardware collision handling doesn't work quite well in this 
mode.

This is relevant only for SoCs with EMAC4 core (440GX, 440SP, 440SPe).
Tested on 440GX.

Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
---

 ibm_emac.h      |    3 ++-
 ibm_emac_core.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ibm_emac/ibm_emac.h b/drivers/net/ibm_emac/ibm_emac.h
index 644edbf..c2dae60 100644
--- a/drivers/net/ibm_emac/ibm_emac.h
+++ b/drivers/net/ibm_emac/ibm_emac.h
@@ -110,6 +110,7 @@ struct emac_regs {
 #define EMAC_MR1_TFS_2K			0x00080000
 #define EMAC_MR1_TR0_MULT		0x00008000
 #define EMAC_MR1_JPSM			0x00000000
+#define EMAC_MR1_MWSW_001		0x00000000
 #define EMAC_MR1_BASE(opb)		(EMAC_MR1_TFS_2K | EMAC_MR1_TR0_MULT)
 #else
 #define EMAC_MR1_RFS_4K			0x00180000
@@ -130,7 +131,7 @@ struct emac_regs {
 					 (freq) <= 83  ? EMAC_MR1_OBCI_83 : \
 					 (freq) <= 100 ? EMAC_MR1_OBCI_100 : EMAC_MR1_OBCI_100P)
 #define EMAC_MR1_BASE(opb)		(EMAC_MR1_TFS_2K | EMAC_MR1_TR | \
-					 EMAC_MR1_MWSW_001 | EMAC_MR1_OBCI(opb))
+					 EMAC_MR1_OBCI(opb))
 #endif
 
 /* EMACx_TMR0 */
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 1da8a66..591c586 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -408,7 +408,7 @@ static int emac_configure(struct ocp_ene
 	/* Mode register */
 	r = EMAC_MR1_BASE(emac_opb_mhz()) | EMAC_MR1_VLE | EMAC_MR1_IST;
 	if (dev->phy.duplex == DUPLEX_FULL)
-		r |= EMAC_MR1_FDE;
+		r |= EMAC_MR1_FDE | EMAC_MR1_MWSW_001;
 	dev->stop_timeout = STOP_TIMEOUT_10;
 	switch (dev->phy.speed) {
 	case SPEED_1000:
