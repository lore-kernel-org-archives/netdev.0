From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Fri, 19 Apr 2013 09:45:26 +0100
Message-ID: <51710426.5020402@mentor.com>
References: <jim_baxter@mentor.com> <1366229278-7528-1-git-send-email-jim_baxter@mentor.com> <20130417224526.GA15093@electric-eye.fr.zoreil.com> <516FC886.7040303@mentor.com> <20130418215408.GA8944@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:63588 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757304Ab3DSIpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 04:45:31 -0400
In-Reply-To: <20130418215408.GA8944@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/04/13 22:54, Francois Romieu wrote:
> Jim Baxter <jim_baxter@mentor.com> :
> [...]
>> What you mean by remove the "restart_required" variable, I only want a
>> restart in certain situations? Am I misunderstanding you comment?
> 
> 	bool b = false;
> 
> 	if (pouet) {
> 		b = true;
> 		foo();
> 	}
> 
> 	if (b)
> 		bar();
> 
> can be rewritten as
> 
> 	if (pouet) {
> 		foo();
> 		bar();
> 	}
> 	
> i.e. your code can be reformulated as:
> 
> static int fec_set_features(struct net_device *netdev,
> 	netdev_features_t features)
> {
> 	struct fec_enet_private *fep = netdev_priv(netdev);
> 	netdev_features_t changed = features ^ netdev->features;
> 
> 	netdev->features = features;
> 
> 	/* Receive checksum has been changed */
> 	if (changed & NETIF_F_RXCSUM) {
> 		if (features & NETIF_F_RXCSUM)
> 			fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
> 		else
> 			fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
> 
> 		if (netif_running(netdev)) {
> 			fec_stop(netdev);
> 			fec_restart(netdev, fep->phy_dev->duplex);
> 			netif_wake_queue(netdev);
> 		} else {
> 			fec_restart(netdev, fep->phy_dev->duplex);
> 		}
> 	}
> 
> 	return 0;
> }
> 

Thank you, I understand your point now. I was thinking ahead too far, in
case something else needed to restart in set_features. Best to make that
change later if required.

Jim
