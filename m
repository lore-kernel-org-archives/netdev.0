From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Thu, 18 Apr 2013 23:54:08 +0200
Message-ID: <20130418215408.GA8944@electric-eye.fr.zoreil.com>
References: <jim_baxter@mentor.com>
 <1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
 <20130417224526.GA15093@electric-eye.fr.zoreil.com>
 <516FC886.7040303@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56608 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932207Ab3DRVyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 17:54:19 -0400
Content-Disposition: inline
In-Reply-To: <516FC886.7040303@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jim Baxter <jim_baxter@mentor.com> :
[...]
> What you mean by remove the "restart_required" variable, I only want a
> restart in certain situations? Am I misunderstanding you comment?

	bool b = false;

	if (pouet) {
		b = true;
		foo();
	}

	if (b)
		bar();

can be rewritten as

	if (pouet) {
		foo();
		bar();
	}
	
i.e. your code can be reformulated as:

static int fec_set_features(struct net_device *netdev,
	netdev_features_t features)
{
	struct fec_enet_private *fep = netdev_priv(netdev);
	netdev_features_t changed = features ^ netdev->features;

	netdev->features = features;

	/* Receive checksum has been changed */
	if (changed & NETIF_F_RXCSUM) {
		if (features & NETIF_F_RXCSUM)
			fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
		else
			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;

		if (netif_running(netdev)) {
			fec_stop(netdev);
			fec_restart(netdev, fep->phy_dev->duplex);
			netif_wake_queue(netdev);
		} else {
			fec_restart(netdev, fep->phy_dev->duplex);
		}
	}

	return 0;
}

-- 
Ueimor
