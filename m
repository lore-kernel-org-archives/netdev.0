From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v5 net-next 2/4] sh_eth: Add support for r7s72100
Date: Thu, 16 Jan 2014 09:14:51 +0900
Message-ID: <20140116001451.GB12550@verge.net.au>
References: <1389766341-14001-1-git-send-email-horms+renesas@verge.net.au>
 <1389766341-14001-3-git-send-email-horms+renesas@verge.net.au>
 <52D70B03.9040506@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52D70B03.9040506@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 16, 2014 at 01:26:11AM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/15/2014 09:12 AM, Simon Horman wrote:
> 
> >This is a fast ethernet controller.
> 
>    I have to say it's not exact enough patch description: R7S72100
> is not Ethernet controller itself, it's a SoC containing the
> Ethernet controller.

I will update the text to the following:

The r7s72100 SoC includes a fast ethernet controller.

> 
> >Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> 
> >---
> >v5
> >* As suggested by Sergei Shtylyov
> >   - Do not use sh_eth_chip_reset_r8a7740 as it accesses non-existent
> >     RMII registers. Instead use sh_eth_chip_reset.
> >   - Do not use sh_eth_set_rate_gether as it accesses non-existent registers.
> >   - Do not use reserved LCHNG bit of ECSR
> >   - Do not use reserved LCHNGIP bit of ECSIPR
> >   - Document that R8A779x also needs a 16 bit shift of the RFS bits
> >   - Do not document that the R7S72100 has GECMR, it does not
> 
>   The above change list was moved from v2 section and doesn't match
> the real changes done in v5. ;-)

I'll fix that up so that when its automatically discarded by git
it can rest in peace in /dev/null.

> 
> >v4
> >* As requested by David Miller
> >   - Use a boolean for the return value of sh_eth_is_rz_fast_ether()
> >   - Correct coding style in sh_eth_get_stats()
> 
> >v3
> >* No change
> 
> >v2
> >* As suggested by Magnus Damm and Sergei Shtylyov
> >   - r7s72100 ethernet is not gigabit so do not refer to it as such
> 
> >* As suggested by Magnus Damm
> >   - As RZ specific register layout rather than using the gigabit layout
> >     which includes registers that do not exist on this chip.
> >---
> >  drivers/net/ethernet/renesas/sh_eth.c | 126 ++++++++++++++++++++++++++++++++--
> >  drivers/net/ethernet/renesas/sh_eth.h |   3 +-
> >  2 files changed, 121 insertions(+), 8 deletions(-)
> 
> >diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> >index 4f5cfad..a7a0555 100644
> >--- a/drivers/net/ethernet/renesas/sh_eth.c
> >+++ b/drivers/net/ethernet/renesas/sh_eth.c
> >@@ -190,6 +190,64 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
> >  	[TRIMD]		= 0x027c,
> >  };
> >
> >+static const u16 sh_eth_offset_fast_rz[SH_ETH_MAX_REGISTER_OFFSET] = {
> 
>    Shouldn't this map precede R-Car one since this SoC is newer the
> same way you've reordered *enum* values, etc.? Sorry for not
> noticing in the previous review...

I will move it, thanks.

> [...]
> >+	[ARSTR]		= 0x0000,
> >+	[TSU_CTRST]	= 0x0004,
> >+	[TSU_VTAG0]	= 0x0058,
> >+	[TSU_ADSBSY]	= 0x0060,
> >+	[TSU_TEN]	= 0x0064,
> >+	[TXNLCR0]	= 0x0080,
> >+	[TXALCR0]	= 0x0084,
> >+	[RXNLCR0]	= 0x0088,
> >+	[RXALCR0]	= 0x008C,
> 
>    Well, the above counter register subgroup stands out from the
> TSU_* registers in the Gigabit mapping, not sure if we should follow
> that. These registers are not currently used anyway...

I will add a blank line.

> 
> >+	[TSU_ADRH0]	= 0x0100,
> >+	[TSU_ADRL0]	= 0x0104,
> >+	[TSU_ADRH31]	= 0x01f8,
> >+	[TSU_ADRL31]	= 0x01fc,
> >+};
> >+
> >  static const u16 sh_eth_offset_fast_sh4[SH_ETH_MAX_REGISTER_OFFSET] = {
> >  	[ECMR]		= 0x0100,
> >  	[RFLR]		= 0x0108,
> >@@ -318,6 +376,14 @@ static bool sh_eth_is_gether(struct sh_eth_private *mdp)
> >  		return false;
> >  }
> >
> >+static bool sh_eth_is_rz_fast_ether(struct sh_eth_private *mdp)
> >+{
> >+	if (mdp->reg_offset == sh_eth_offset_fast_rz)
> >+		return true;
> >+	else
> >+		return false;
> 
>    Perhaps you should compress the above functions to one-liners as
> Joe has suggested. Or I/you could do it in a separate patch...

Will do, Joe's suggestion is a good one.

> 
> >+}
> >+
> >  static void sh_eth_select_mii(struct net_device *ndev)
> >  {
> >  	u32 value = 0x0;
> [...]
> >@@ -1309,9 +1409,9 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
> >
> >  		/* In case of almost all GETHER/ETHERs, the Receive Frame State
> >  		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
> >-		 * bit 0. However, in case of the R8A7740's GETHER, the RFS
> >-		 * bits are from bit 25 to bit 16. So, the driver needs right
> >-		 * shifting by 16.
> >+		 * bit 0. However, in case of the R8A7740, R8A779x and
> 
>    Small nit: comma needed before "and" as far as I know English grammar.

To be honest I don't think it is. But I'll add one for you.

> 
> >+		 * R7S72100 the RFS bits are from bit 25 to bit 16. So, the
> >+		 * driver needs right shifting by 16.
> >  		 */
> >  		if (mdp->cd->shift_rd0)
> >  			desc_status >>= 16;
> 
>    Other than that, this looks fine now, you can add my:
> 
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Thanks.
