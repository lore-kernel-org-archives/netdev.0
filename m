From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] MACB: Set PHY address in kernel parameters
Date: Wed, 31 Mar 2010 12:03:13 +0200
Message-ID: <20100331100313.GA4053@psychotron.lab.eng.brq.redhat.com>
References: <1270021902-6556-1-git-send-email-anders.darander@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Erik Waling <erik.waling@konftel.com>,
	Patrick McHardy <kaber@trash.net>,
	Anders Darander <ad@datarespons.se>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anders Darander <anders.darander@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1270021902-6556-1-git-send-email-anders.darander@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Mar 31, 2010 at 09:51:42AM CEST, anders.darander@gmail.com wrote:
>From: Anders Darander <ad@datarespons.se>
>
>Add the possibility to set the phy address. This is needed if an integrated
>switch is connected to the MAC, as it is often the case that the highest port
>is the one connected to the MAC of the MCU.
>
>E.g. in the case of the Micrel KSZ8873, port 3 is the one to connect to the
>MCU, thus, the MAC needs to connect to phy address 0x03, instead of the first
>phy found.
>
>Signed-off-by: Anders Darander <ad@datarespons.se>
>---
> drivers/net/macb.c |   14 +++++++++++++-
> 1 files changed, 13 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/macb.c b/drivers/net/macb.c
>index c8a18a6..9b4e301 100644
>--- a/drivers/net/macb.c
>+++ b/drivers/net/macb.c
>@@ -53,6 +53,14 @@
> #define MACB_RX_INT_FLAGS	(MACB_BIT(RCOMP) | MACB_BIT(RXUBR)	\
> 				 | MACB_BIT(ISR_ROVR))
> 
>+/*
>+ * Setup PHY probeing
>+ */
>+
>+static int phy_addr = PHY_MAX_ADDR;
>+module_param(phy_addr, ushort, 0);
>+MODULE_PARAM_DESC(phy_addr, "PHY address connected to the MACB");
>+
> static void __macb_set_hwaddr(struct macb *bp)
> {
> 	u32 bottom;
>@@ -193,7 +201,11 @@ static int macb_mii_probe(struct net_device *dev)
> 	struct eth_platform_data *pdata;
> 	int ret;
> 
>-	phydev = phy_find_first(bp->mii_bus);
>+	if (phy_addr >= PHY_MAX_ADDRESS)
>+		phydev = phy_find_first(bp->mii_bus);
>+	else
>+		phydev = bp->mii_bus->phy_map[phy_addr];
>+
> 	if (!phydev) {
> 		printk (KERN_ERR "%s: no PHY found\n", dev->name);
> 		return -1;
>-- 
>1.7.0.3
>

This is really ugly :( Should be done differently, more general. I've been
thinking about this for a while. Maybe the solution is to integrate the switch
into DSA subsystem. See net/dsa. Not sure though...

Jirka
