From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 net-next 2/4] sh_eth: Add support for r7s72100
Date: Thu, 16 Jan 2014 09:49:43 +0900
Message-ID: <20140116004943.GF12550@verge.net.au>
References: <1389168152-9434-1-git-send-email-horms+renesas@verge.net.au>
 <1389168152-9434-3-git-send-email-horms+renesas@verge.net.au>
 <52CDBBE1.1010301@cogentembedded.com>
 <20140109050351.GE2132@verge.net.au>
 <52D70F12.9080800@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52D70F12.9080800@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 16, 2014 at 01:43:30AM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/09/2014 08:03 AM, Simon Horman wrote:
> 
> >>>This is a fast ethernet controller.
> 
> >>>Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> 
> >>[...]
> 
> >>>diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> >>>index 4b38533..cc6d4af 100644
> >>>--- a/drivers/net/ethernet/renesas/sh_eth.c
> >>>+++ b/drivers/net/ethernet/renesas/sh_eth.c
> >>>@@ -190,6 +190,59 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
> [...]
> >>>@@ -701,6 +762,35 @@ static struct sh_eth_cpu_data r8a7740_data = {
> >>>  	.shift_rd0	= 1,
> >>>  };
> >>>
> >>>+/* R7S72100 */
> >>>+static struct sh_eth_cpu_data r7s72100_data = {
> >>>+	.chip_reset	= sh_eth_chip_reset,
> >>>+	.set_duplex	= sh_eth_set_duplex,
> >>>+
> >>>+	.register_type	= SH_ETH_REG_FAST_RZ,
> >>>+
> >>>+	.ecsr_value	= ECSR_ICD,
> >>>+	.ecsipr_value	= ECSIPR_ICDIP,
> >>>+	.eesipr_value	= 0xff7f009f,
> >>>+
> >>>+	.tx_check	= EESR_TC1 | EESR_FTC,
> >>>+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
> >>>+			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
> >>>+			  EESR_TDE | EESR_ECI,
> >>>+	.fdr_value	= 0x0000070f,
> >>>+	.rmcr_value	= RMCR_RNC,
> >>>+
> >>>+	.apr		= 1,
> >>>+	.mpr		= 1,
> >>>+	.tpauser	= 1,
> >>>+	.hw_swap	= 1,
> >>>+	.rpadir		= 1,
> >>>+	.rpadir_value   = 2 << 16,
> >>>+	.no_trimd	= 1,
> >>>+	.tsu		= 1,
> >>>+	.shift_rd0	= 1,
> 
> >>    Perhaps this field should be renamed to something talking about
> >>check summing support (since bits 0..15 of RD0 contain a frame check
> >>sum for those SoCs). Or maybe it should be just merged with the
> >>'hw_crc' field...
> 
> >I have no feelings about that one way or another.
> 
>    Do you happen to have R8A7740 manual by chance? If so, does it
> talk about RX check summing support and using RD0 for that?

Yes and yes.

I have taken a quick look and the documentation for RX checksumming on the
R8A7740 appears to be very similar if not the same as that of the R7S72100.

In particular both refer to using the bottom 16 bits of RD0 as
containing the packet checksum.

> >But it seems to be orthogonal to this patch.
> 
>    Of course, was a note to self. :-)
> 
> [...]
> >>>@@ -880,6 +970,8 @@ static unsigned long sh_eth_get_edtrr_trns(struct sh_eth_private *mdp)
> >>>  {
> >>>  	if (sh_eth_is_gether(mdp))
> >>>  		return EDTRR_TRNS_GETHER;
> >>>+	else if (sh_eth_is_rz_fast_ether(mdp))
> >>>+		return EDTRR_TRNS_RZ_ETHER;
> 
> >>    I'd just merge this with the GEther case.
> 
> >Sure, but in that case should we change the name.
> >As both you and Magnus pointed out to me, the rz is not gigabit.
> 
>    See below.
> 
> >>>  	else
> >>>  		return EDTRR_TRNS_ETHER;
> >>>  }
> >>[...]
> >>>@@ -1062,7 +1155,8 @@ static void sh_eth_ring_format(struct net_device *ndev)
> >>>  		if (i == 0) {
> >>>  			/* Tx descriptor address set */
> >>>  			sh_eth_write(ndev, mdp->tx_desc_dma, TDLAR);
> >>>-			if (sh_eth_is_gether(mdp))
> >>>+			if (sh_eth_is_gether(mdp) ||
> >>>+			    sh_eth_is_rz_fast_ether(mdp))
> >>>  				sh_eth_write(ndev, mdp->tx_desc_dma, TDFAR);
> 
> >>    Hmm, TDFAR exists also on SH4 Ethers...
> 
> >Lets fix that separately.
> 
>    Of course, was just another not to self.
> 
> [...]
> >>>diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> >>>index 0fe35b7..0bcde90 100644
> >>>--- a/drivers/net/ethernet/renesas/sh_eth.h
> >>>+++ b/drivers/net/ethernet/renesas/sh_eth.h
> [...]
> >>>@@ -191,6 +192,7 @@ enum DMAC_M_BIT {
> >>>  /* EDTRR */
> >>>  enum DMAC_T_BIT {
> >>>  	EDTRR_TRNS_GETHER = 0x03,
> >>>+	EDTRR_TRNS_RZ_ETHER = 0x03,
> 
> >>    I doubt we need a special case here. You didn't introduce one for
> >>the software reset bits.
> 
> >True, but RZ is not Gigabit. So I think we either need two names
> >or to choose a more generic name.
> 
>    Well, R7S72100 manual calls these bits just TR[1:0]. Don't know
> what SoCs having Gigabit call it in the manuals...
> 
> >>>  	EDTRR_TRNS_ETHER = 0x01,
> 
>    R-Car manuals seem to call the bit TRNS (as well as the
> prehistoric SH manuals probably). Perhaps we could use that
> difference, TRNS vs TR, don't know...

Perhaps we should just leave it as-is, using EDTRR_TRNS_GETHER and
EDTRR_TRNS_RZ_ETHER, after all.

At least until we can think of a better names :)
