From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Wed, 2 Aug 2006 20:23:40 +0100
Message-ID: <OF9CB563CF.865D1AC6-ON802571BE.006924E4-802571BE.006A884B@smsc.com>
References: <20060801153313.GD29208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bahadir Balban <Bahadir.Balban@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:44306 "EHLO smsc.com")
	by vger.kernel.org with ESMTP id S932150AbWHBTYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 15:24:05 -0400
In-Reply-To: <20060801153313.GD29208@tuxdriver.com>
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Thanks for all your feedback.

> > +/* waits for MAC not busy, with timeout.  Assumes MacPhyAccessLock 
has
> > + * already been acquired */
> > +static int smsc911x_mac_notbusy(struct smsc911x_data *pdata)
> > +{
> > +            int i;
> > +
> > +            for (i = 0; i < 40; i++) {
> > +                            if ((smsc911x_reg_read(pdata, 
MAC_CSR_CMD)
> > +                                 & MAC_CSR_CMD_CSR_BUSY_) == 0) {
> > +                                            return 1;
> > +                            }
> > +            }
> > +            SMSC_WARNING("Timed out waiting for MAC not BUSY. "
> > +                                 "MAC_CSR_CMD: 0x%08X", 
smsc911x_reg_read(pdata,
> > +                                  MAC_CSR_CMD));
> > +            return 0;
> > +}
> 
> How is the length of this timeout controlled?  IOW, what prevents
> it from being too short when the Omegatron 128 running at 10GHz hits
> the market?  Are you relying on the MII clock rate?

The LAN911x and LAN921x devices uses an SRAM-like bus interface with a 
minimum cycle time of 45ns, so smsc_reg_read() and smsc_reg_write() are 
guaranteed to take at least 45ns.  The MAC operates a little slower, but 
the operation shouldn't take longer than 225ns (5 read cycles).

The PHY is accessed via slave registers in the MAC (which then relays the 
command over mii), so its timeout works in the same way.

The timeouts are only there to prevent total lockup if the hardware fails, 
if the part is working it should take nowhere near 40 iterations.


> > +                            /* Auto-detect PHY */
> > +                            for (address = 0; address <= 31; 
address++) {
> > +                                            pdata->phy_address = 
address;
> > +                                            phyid1 = 
smsc911x_phy_read(pdata, MII_PHYSID1);
> > +                                            phyid2 = 
smsc911x_phy_read(pdata, MII_PHYSID2);
> > +                                            if ((phyid1 != 0xFFFFU) 
|| (phyid2 != 0xFFFFU)) {
> > + SMSC_TRACE("Detected PHY at address = "
> > +     "0x%02X = %d", address, address);
> > +                                                            break;
> > +                                            }
> > +                            }
> 
> Does this need the magic "for (addr=1; addr <=32; addr++)" trick that
> has become idiomatic for PHY discovery in our drivers?

I don't understand the question - surely 32 is not a valid PHY address?


> > +/* SMSC911x registers and bitfields */
> > +#define RX_DATA_FIFO                        0x00
> > +
> > +#define TX_DATA_FIFO                        0x20
> > +#define TX_CMD_A_ON_COMP_   0x80000000
> > +#define TX_CMD_A_BUF_END_ALGN_              0x03000000
> > +#define TX_CMD_A_4_BYTE_ALGN_               0x00000000
> > +#define TX_CMD_A_16_BYTE_ALGN_              0x01000000
> > +#define TX_CMD_A_32_BYTE_ALGN_              0x02000000
> > +#define TX_CMD_A_DATA_OFFSET_               0x001F0000
> > +#define TX_CMD_A_FIRST_SEG_                 0x00002000
> > +#define TX_CMD_A_LAST_SEG_          0x00001000
> > +#define TX_CMD_A_BUF_SIZE_          0x000007FF
> > +#define TX_CMD_B_PKT_TAG_   0xFFFF0000
> > +#define TX_CMD_B_ADD_CRC_DISABLE_  0x00002000
> > +#define TX_CMD_B_DISABLE_PADDING_  0x00001000
> > +#define TX_CMD_B_PKT_BYTE_LENGTH_  0x000007FF
> 
> Looks like something went haywire w/ your tabbing in this file...?

Its just the "+ " in the patch, once applied it looks quite pretty!

Best Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com


