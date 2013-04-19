From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v4 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Fri, 19 Apr 2013 17:20:17 +0100
Message-ID: <1366388417.2716.6.camel@bwh-desktop.uk.solarflarecom.com>
References: <Jim Baxter <jim_baxter@mentor.com>
	  <1366384215-21441-1-git-send-email-jim_baxter@mentor.com>
	 <1366385681.2716.1.camel@bwh-desktop.uk.solarflarecom.com>
	 <51716DE5.1070605@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36662 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967726Ab3DSQUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 12:20:21 -0400
In-Reply-To: <51716DE5.1070605@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 17:16 +0100, Jim Baxter wrote:
> On 19/04/13 16:34, Ben Hutchings wrote:
> > On Fri, 2013-04-19 at 16:10 +0100, Jim Baxter wrote:
> >> Enables hardware generation of IP header and
> >> protocol specific checksums for transmitted
> >> packets.
> >>
> >> Enabled hardware discarding of received packets with
> >> invalid IP header or protocol specific checksums.
> >>
> >> The feature is enabled by default but can be
> >> enabled/disabled by ethtool.
> >>
> >> Signed-off-by: Fugang Duan <B38611@freescale.com>
> >> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> >> ---
> >>
> >> - Added IPV6 support.
> > [...]
> >> @@ -1439,6 +1496,14 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
> >>  		if (fep->bufdesc_ex) {
> >>  			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
> >>  			ebdp->cbd_esc = BD_ENET_TX_INT;
> >> +
> >> +			/* Enable protocol checksum flags
> >> +			 * We do not bother with the IP Checksum bits as they
> >> +			 * are done by the kernel
> >> +			 */
> >> +			if (ndev->features &
> >> +					(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
> >> +				ebdp->cbd_esc |= BD_ENET_TX_PINS;
> >>  		}
> >>  
> >>  		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
> > [...]
> > 
> > This condition needs to be based on skb->ip_summed.
> > 
> > Ben.
> > 
> 
> 
> These buffers are setup when the network driver is opened
> (fec_enet_open), with the same settings as the transmit buffers.
> 
> Thinking about it, they should probably not be set here and only set
> during the fec_enet_start_xmit() function.

Right.  Even when TX checksum offload is enabled, the kernel might not
want you to offload TX checksums for every packet.  For example, if your
interface is part of a bridge, packets should be forwarded even if they
have a bad layer-4 checksum on RX, and the checksum must not be
'corrected' on TX.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
