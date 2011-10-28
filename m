From: Joe Perches <joe@perches.com>
Subject: Re: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161
 Ethernet driver
Date: Fri, 28 Oct 2011 05:56:25 +0300
Message-ID: <1319770585.2529.21.camel@Joe-Laptop>
References: <1319009213-20627-1-git-send-email-cloud.ren@atheros.com>
	 <20111019222140.GA9937@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: cloud.ren@atheros.com, davem@davemloft.net,
	Luis.Rodriguez@atheros.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111019222140.GA9937@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-10-20 at 00:21 +0200, Francois Romieu wrote:
> cloud.ren@atheros.com <cloud.ren@atheros.com> :
> > diff --git a/drivers/net/ethernet/atheros/alx/alf_hw.c b/drivers/net/ethernet/atheros/alx/alf_hw.c
[]
> > +	if (en) { /* enable */
> > +		MEM_W32(ctx, L1F_RXQ0, rxq | L1F_RXQ0_EN);
> > +		MEM_W32(ctx, L1F_TXQ0, txq | L1F_TXQ0_EN);
> > +		if (0 != (en_ctrl & LX_MACSPEED_1000)) {
> > +			FIELD_SETL(mac, L1F_MAC_CTRL_SPEED,
> > +			    L1F_MAC_CTRL_SPEED_1000);
> > +		} else {
> > +			FIELD_SETL(mac, L1F_MAC_CTRL_SPEED,
> > +			    L1F_MAC_CTRL_SPEED_10_100);
> > +		}
> > +		if (0 != (en_ctrl & LX_MACDUPLEX_FULL)) {
> > +			mac |= L1F_MAC_CTRL_FULLD;
> > +		} else {
> > +			mac &= ~L1F_MAC_CTRL_FULLD;
> > +		}
> > +		/* rx filter */
> > +		if (0 != (en_ctrl & LX_FLT_PROMISC)) {
> > +			mac |= L1F_MAC_CTRL_PROMISC_EN;
> > +		} else {
> > +			mac &= ~L1F_MAC_CTRL_PROMISC_EN;
> > +		}
> > +		if (0 != (en_ctrl & LX_FLT_MULTI_ALL)) {
> > +			mac |= L1F_MAC_CTRL_MULTIALL_EN;
> > +		} else {
> > +			mac &= ~L1F_MAC_CTRL_MULTIALL_EN;
> > +		}
> > +		if (0 != (en_ctrl & LX_FLT_BROADCAST)) {
> > +			mac |= L1F_MAC_CTRL_BRD_EN;
> > +		} else {
> > +			mac &= ~L1F_MAC_CTRL_BRD_EN;
> > +		}
> Code duplication. Who cares ?

Maybe add a macro like:

#define mac_ctrl(mac, ctrl, flag, bit)		\
do {						\
	if ((ctrl) & (flag))			\
		mac |= (bit);			\
	else					\
		mac &= ~(bit);			\
} while (0)

so these become

	mac_ctrl(mac, en_ctrl, LX_MACDUPLEX_FULL, L1F_MAC_CTRL_FULLD);
	mac_ctrl(mac, en_ctrl, LX_FLT_PROMISC, L1F_MAC_CTRL_PROMISC_EN);
	mac_ctrl(mac, en_ctrl, LX_FLT_MULTI_ALL, L1F_MAC_CTRL_MULTIALL_EN);
	mac_ctrl(mac, en_ctrl, LX_FLT_BROADCAST, L1F_MAC_CTRL_BRD_EN);
	mac_ctrl(mac, en_ctrl, LX_FLT_DIRECT, L1F_MAC_CTRL_RX_EN);
	mac_ctrl(mac, en_ctrl, LX_FC_TXEN, L1F_MAC_CTRL_TXFC_EN);
	mac_ctrl(mac, en_ctrl, LX_FC_RXEN, L1F_MAC_CTRL_RXFC_EN);
	etc.

Or maybe add mac, en_ctrl and L1F_MAC_CTRL_ to the macro if you
really want to shorten it up.

	mac_ctrl(MACDUPLEX_FULL, FULLD);
	mac_ctrl(FLT_PROMISC, PROMISC_EN);
	mac_ctrl(FLT_MULTI_ALL, MULTIALL_EN);
	etc.

> It may make some sense to move these ~60 loc in a xyz_enable_something
> method...

2 macros?
