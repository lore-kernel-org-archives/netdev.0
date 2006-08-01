From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Tue, 1 Aug 2006 11:33:18 -0400
Message-ID: <20060801153313.GD29208@tuxdriver.com>
References: <20060728213841.GA14235@electric-eye.fr.zoreil.com> <11544451353553-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:34316 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030362AbWHAPdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 11:33:53 -0400
To: Steve Glendinning <steve.glendinning@smsc.com>
Content-Disposition: inline
In-Reply-To: <11544451353553-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 04:12:15PM +0100, Steve Glendinning wrote:
> > > Attached is a driver patch for SMSC911x family of ethernet chips,
> > > generated against 2.6.18-rc1 sources. There's a similar driver in the
> > > tree; this one has been tested by SMSC on all flavors of the chip and
> > > claimed to be efficient.
> >
> > Updated after feedback from Stephen Hemminger.
> >
> > Driver updated to also support LAN921x family.  Workarounds added for
> > known hardware issues.
> 
> Many improvements following feedback from Stephen Hemminger and
> Francois Romieu:
>  - Tasklet removed, NAPI poll used instead
>  - Multiple device support
>  - style fixes & minor improvements

<snip>

> +/* waits for MAC not busy, with timeout.  Assumes MacPhyAccessLock has
> + * already been acquired */
> +static int smsc911x_mac_notbusy(struct smsc911x_data *pdata)
> +{
> +	int i;
> +
> +	for (i = 0; i < 40; i++) {
> +		if ((smsc911x_reg_read(pdata, MAC_CSR_CMD)
> +		     & MAC_CSR_CMD_CSR_BUSY_) == 0) {
> +			return 1;
> +		}
> +	}
> +	SMSC_WARNING("Timed out waiting for MAC not BUSY. "
> +		     "MAC_CSR_CMD: 0x%08X", smsc911x_reg_read(pdata,
> +							      MAC_CSR_CMD));
> +	return 0;
> +}

How is the length of this timeout controlled?  IOW, what prevents
it from being too short when the Omegatron 128 running at 10GHz hits
the market?  Are you relying on the MII clock rate?

<snip>

> +/* Gets a phy register, phy_lock must be acquired before calling */
> +static unsigned int
> +smsc911x_phy_read(struct smsc911x_data *pdata, unsigned int index)
> +{
> +	unsigned int addr;
> +	unsigned int result = 0xFFFF;
> +	int i;
> +
> +	/* Confirm MII not busy */
> +	if (unlikely
> +	    ((smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_) != 0)) {
> +		SMSC_WARNING("MII is busy in smsc911x_phy_read???");
> +		return 0;
> +	}
> +
> +	/* Set the address, index & direction (read from PHY) */
> +	addr = (((pdata->phy_address) & 0x1F) << 11)
> +	    | ((index & 0x1F) << 6);
> +	smsc911x_mac_write(pdata, MII_ACC, addr);
> +
> +	/* Wait for read to complete w/ timeout */
> +	for (i = 0; i < 100; i++) {
> +		/* See if MII is finished yet */
> +		if ((smsc911x_mac_read(pdata, MII_ACC)
> +		     & MII_ACC_MII_BUSY_) == 0) {
> +			result = smsc911x_mac_read(pdata, MII_DATA);
> +			return result;
> +		}
> +	}
> +	SMSC_WARNING("Timed out waiting for MII write to finish");

Ditto?

<snip>

> +/* Sets a phy register, phy_lock must be acquired before calling */
> +static void smsc911x_phy_write(struct smsc911x_data *pdata,
> +			       unsigned int index, unsigned int val)
> +{
> +	unsigned int addr;
> +	int i;
> +
> +	/* Confirm MII not busy */
> +	if (unlikely
> +	    ((smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_) != 0)) {
> +		SMSC_WARNING("MII is busy in smsc911x_write_phy???");
> +		return;
> +	}
> +
> +	/* Put the data to write in the MAC */
> +	smsc911x_mac_write(pdata, MII_DATA, val);
> +
> +	/* Set the address, index & direction (write to PHY) */
> +	addr = (((pdata->phy_address) & 0x1F) << 11) |
> +	    ((index & 0x1F) << 6) | MII_ACC_MII_WRITE_;
> +	smsc911x_mac_write(pdata, MII_ACC, addr);
> +
> +	/* Wait for write to complete w/ timeout */
> +	for (i = 0; i < 100; i++) {
> +		/* See if MII is finished yet */
> +		if ((smsc911x_mac_read(pdata, MII_ACC)
> +		     & MII_ACC_MII_BUSY_) == 0)
> +			return;
> +	}
> +	SMSC_WARNING("Timed out waiting for MII write to finish");
> +}

Ditto?

> +/* Autodetects and initialises external phy for SMSC9115 and SMSC9117 flavors.
> + * If something goes wrong, returns -ENODEV to revert back to internal phy.
> + * Performed at initialisation only, phy_lock already acquired. */
> +static int smsc911x_phy_initialise_external(struct smsc911x_data *pdata)
> +{
> +	unsigned int address;
> +	unsigned int hwcfg;
> +	unsigned int phyid1;
> +	unsigned int phyid2;
> +
> +	hwcfg = smsc911x_reg_read(pdata, HW_CFG);
> +
> +	/* External phy is requested, supported, and detected */
> +	if (hwcfg & HW_CFG_EXT_PHY_DET_) {
> +
> +		/* Attempt to switch to external phy for auto-detecting
> +		 * its address. Assuming tx and rx are stopped because
> +		 * smsc911x_phy_initialise is called before
> +		 * smsc911x_rx_initialise and tx_initialise.
> +		 */
> +
> +		/* Disable phy clocks to the MAC */
> +		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
> +		hwcfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
> +		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> +		udelay(10);	/* Enough time for clocks to stop */
> +
> +		/* Switch to external phy */
> +		hwcfg |= HW_CFG_EXT_PHY_EN_;
> +		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> +
> +		/* Enable phy clocks to the MAC */
> +		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
> +		hwcfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
> +		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> +		udelay(10);	/* Enough time for clocks to restart */
> +
> +		hwcfg |= HW_CFG_SMI_SEL_;
> +		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
> +
> +		/* Auto-detect PHY */
> +		for (address = 0; address <= 31; address++) {
> +			pdata->phy_address = address;
> +			phyid1 = smsc911x_phy_read(pdata, MII_PHYSID1);
> +			phyid2 = smsc911x_phy_read(pdata, MII_PHYSID2);
> +			if ((phyid1 != 0xFFFFU) || (phyid2 != 0xFFFFU)) {
> +				SMSC_TRACE("Detected PHY at address = "
> +					   "0x%02X = %d", address, address);
> +				break;
> +			}
> +		}

Does this need the magic "for (addr=1; addr <=32; addr++)" trick that
has become idiomatic for PHY discovery in our drivers?

<snip>

> --- /dev/null
> +++ b/drivers/net/smsc911x.h

<snip>

> +/* SMSC911x registers and bitfields */
> +#define RX_DATA_FIFO					0x00
> +
> +#define TX_DATA_FIFO					0x20
> +#define TX_CMD_A_ON_COMP_				0x80000000
> +#define TX_CMD_A_BUF_END_ALGN_				0x03000000
> +#define TX_CMD_A_4_BYTE_ALGN_				0x00000000
> +#define TX_CMD_A_16_BYTE_ALGN_				0x01000000
> +#define TX_CMD_A_32_BYTE_ALGN_				0x02000000
> +#define TX_CMD_A_DATA_OFFSET_				0x001F0000
> +#define TX_CMD_A_FIRST_SEG_				0x00002000
> +#define TX_CMD_A_LAST_SEG_				0x00001000
> +#define TX_CMD_A_BUF_SIZE_				0x000007FF
> +#define TX_CMD_B_PKT_TAG_				0xFFFF0000
> +#define TX_CMD_B_ADD_CRC_DISABLE_			0x00002000
> +#define TX_CMD_B_DISABLE_PADDING_			0x00001000
> +#define TX_CMD_B_PKT_BYTE_LENGTH_			0x000007FF

Looks like something went haywire w/ your tabbing in this file...?

Your style overall is very nice and easy to read.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
