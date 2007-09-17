From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [RFT] sky2: receive hang check
Date: Mon, 17 Sep 2007 12:08:36 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0709171206180.17234@wlug.westbo.se>
References: <20070912161957.701eddff@oldman>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mjufs.se ([85.195.4.233]:55412 "EHLO wlug.westbo.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414AbXIQKjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 06:39:47 -0400
In-Reply-To: <20070912161957.701eddff@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007, Stephen Hemminger wrote:

> -/* Check for lost IRQ once a second */
> +static void sky2_rx_check(struct net_device *dev)
> +{
> +	struct sky2_port *sky2 = netdev_priv(dev);
> +	struct sky2_hw *hw = sky2->hw;
> +	unsigned port = sky2->port;
> +	unsigned rxq = rxqaddr[port];
> +	u32 mac_rp = sky2_read32(hw, SK_REG(port, RX_GMF_RP));
> +	u8 mac_lev = sky2_read8(hw, SK_REG(port, RX_GMF_RLEV));
> +	u8 fifo_rp = sky2_read8(hw, Q_ADDR(rxq, Q_RP));
> +	u8 fifo_lev = sky2_read8(hw, Q_ADDR(rxq, Q_RL));
> +
> +	/* If not idle and MAC or PCI is stuck */
> +	if (sky2->check.last != dev->last_rx &&

Don't you want == here? You want to run the rest of this test when no 
packets has been received for a while.

> +	    ((mac_rp == sky2->check.mac_rp &&
> +		     mac_lev != 0 && mac_lev >= sky2->check.mac_lev) ||
> +		    /* Check if the PCI RX hang */
> +		    (fifo_rp == sky2->check.fifo_rp &&
> +		     fifo_lev != 0 && fifo_lev >= sky2->check.fifo_lev))) {
> +
> +		pr_info(PFX "%s: receiver hang detected\n", dev->name);
> +		schedule_work(&hw->restart_work);
> +	}
> +
> +	sky2->check.last = dev->last_rx;
> +	sky2->check.mac_rp = mac_rp;
> +	sky2->check.mac_lev = mac_lev;
> +	sky2->check.fifo_rp = fifo_rp;
> +	sky2->check.fifo_lev = fifo_lev;
> +}

/Martin
