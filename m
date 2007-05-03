From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: 2.6.20.7 mss negotiation and path mtu discovery mostly
 broken?
Date: Thu, 03 May 2007 16:24:20 -0700
Message-ID: <1178234660.4887.3.camel@dell>
References: <7CCD07160348804497EF29E9EA5560D7020F6212@exchtewks2.starentnetworks.com>
 <7CCD07160348804497EF29E9EA5560D7020F6213@exchtewks2.starentnetworks.com>
 <20070425.131602.18289973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bristuccia@starentnetworks.com, "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1365 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767456AbXECWhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 18:37:14 -0400
In-Reply-To: <20070425.131602.18289973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-25 at 13:16 -0700, David Miller wrote:
> From: "Ristuccia, Brian" <bristuccia@starentnetworks.com>
> Date: Wed, 25 Apr 2007 16:11:51 -0400
> 
> > > I'm seeing a 
> > > problem where the kernel attempts to send packets with a MSS 
> > > larger than the one negotiated when the TCP connection is 
> > > established. Even after ICMP "can't fragment" messages 
> > > arrive, the kernel still attempts to increase the MSS rather 
> > > aggressively. The end result is extremely poor throughput 
> > > when sending to a network with a smaller MTU. 
> > 
> > I've tracked this problem to the TSO feature in the bnx2 driver. Turning
> > off TSO with "ethtool -K eth1 tso off" seems to work around the problem.
> > It appears that the bnx2 device is not using the correct mss when
> > performing segmentation offload. 
> 
> Thanks for narrowing it down like that.
> 
> Michael can you have a look?  Is the bnx2 firmware using the MTU
> setting in the device and ignoring the passed in MSS or something
> like that?
> 

This should fix it.  I will send this and other selected BNX2 fixes to
stable as well.  Thanks.

[BNX2]: Fix TSO problem with small MSS.

Remove the check for skb->len greater than MTU when doing TSO.  When
the destination has a smaller MSS than the source, a TSO packet may
be smaller than the MTU at the source and we still need to process it
as a TSO packet.

Thanks to Brian Ristuccia <bristuccia@starentnetworks.com> for
reporting the problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 605347f..88b33c6 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4836,8 +4836,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan_tag_flags |=
 			(TX_BD_FLAGS_VLAN_TAG | (vlan_tx_tag_get(skb) << 16));
 	}
-	if ((mss = skb_shinfo(skb)->gso_size) &&
-		(skb->len > (bp->dev->mtu + ETH_HLEN))) {
+	if ((mss = skb_shinfo(skb)->gso_size)) {
 		u32 tcp_opt_len, ip_tcp_len;
 		struct iphdr *iph;
 


