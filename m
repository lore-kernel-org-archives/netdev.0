From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 1/2] ravb: Add tx and rx clock internal delays
 mode of APSR
Date: Fri, 27 Jan 2017 17:49:21 +0100
Message-ID: <20170127164921.GB7336@verge.net.au>
References: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
 <1485515090-7570-2-git-send-email-horms+renesas@verge.net.au>
 <813af981-9a1b-8e45-1fed-788047ab26b5@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <813af981-9a1b-8e45-1fed-788047ab26b5@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2017 at 03:42:05PM +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 01/27/2017 02:04 PM, Simon Horman wrote:
> 
> >From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >
> >This patch enables tx and rx clock internal delay modes (TDM and RDM).
> >
> >This is to address a failure in the case of 1Gbps communication using the
> >by salvator-x board with the KSZ9031RNX phy. This has been reported to
> >occur with both the r8a7795 (H3) and r8a7796 (M3-W) SoCs.
> >
> >With this change APSR internal delay modes are enabled for
> >"rgmii-id", "rgmii-rxid" and "rgmii-txid" phy modes as follows:
> >
> >phy mode   | ASPR delay mode
> >-----------+----------------
> >rgmii-id   | TDM and RDM
> >rgmii-rxid | RDM
> >rgmii-txid | TDM
> >
> >Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> >
> >---
> >v1 [Simon Horman]
> >- Combined patches
> >- Reworded changelog
> >
> >v0 [Kazuya Mizuguchi]
> >---
> > drivers/net/ethernet/renesas/ravb.h      | 10 ++++++++++
> > drivers/net/ethernet/renesas/ravb_main.c | 29 +++++++++++++++++++++++++++++
> > 2 files changed, 39 insertions(+)
> >
> >diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
> >index f1109661a533..d7c91d48cc48 100644
> >--- a/drivers/net/ethernet/renesas/ravb.h
> >+++ b/drivers/net/ethernet/renesas/ravb.h
> [...]
> >@@ -248,6 +249,15 @@ enum ESR_BIT {
> > 	ESR_EIL		= 0x00001000,
> > };
> >
> >+/* APSR */
> >+enum APSR_BIT {
> >+	APSR_MEMS		= 0x00000002,
> 
>    Not documented in the revision 0.5 of the gen3 manual...

It is in version 0.53 of the documentation but I think it can be dropped
from this patch as its unused.

> >+	APSR_CMSW		= 0x00000010,

I think the above can also be dropped as it is unused.

> >+	APSR_DM			= 0x00006000,
> 
>    ... and neither this field. Are these documented in the latter revs?

This one is not. I can ask Mizuguchi-san to confirm it exists (with himself).

> >+	APSR_DM_RDM		= 0x00002000,
> >+	APSR_DM_TDM		= 0x00004000,
> >+};
> >+
> > /* RCR */
> > enum RCR_BIT {
> > 	RCR_EFFS	= 0x00000001,
> >diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> >index 89ac1e3f6175..9fb4c04c5885 100644
> >--- a/drivers/net/ethernet/renesas/ravb_main.c
> >+++ b/drivers/net/ethernet/renesas/ravb_main.c
> >@@ -1904,6 +1904,29 @@ static void ravb_set_config_mode(struct net_device *ndev)
> > 	}
> > }
> >
> >+static void ravb_set_delay_mode(struct net_device *ndev)
> >+{
> >+	struct ravb_private *priv = netdev_priv(ndev);
> >+
> >+	if (priv->chip_id != RCAR_GEN2) {
> >+		switch (priv->phy_interface) {
> >+		case PHY_INTERFACE_MODE_RGMII_ID:
> >+			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_RDM |
> >+				   APSR_DM_TDM);
> >+			break;
> >+		case PHY_INTERFACE_MODE_RGMII_RXID:
> >+			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_RDM);
> >+			break;
> >+		case PHY_INTERFACE_MODE_RGMII_TXID:
> >+			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_TDM);
> >+			break;
> >+		default:
> >+			ravb_modify(ndev, APSR, APSR_DM, 0);
> >+			break;
> >+		}
> 
>    How about doing ravb_modify() only once?

Something like this?

		int set = 0;

		if (priv->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
		    priv->phy_interface == PHY_INTERFACE_MODE_RGMII_RXID)
		    set |= APSR_DM_RDM;

		if (priv->phy_interface == PHY_INTERFACE_MODE_RGMII_ID ||
		    priv->phy_interface == PHY_INTERFACE_MODE_RGMII_TXID)
		    set |= APSR_DM_TDM;

		ravb_modify(ndev, APSR, APSR_DM, set);

I don't really see any advantage to it but I can change things around
however you like.
