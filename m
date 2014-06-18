From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: fec: Don't clear IPV6 header checksum field when
	IP accelerator enable
Date: Wed, 18 Jun 2014 17:09:13 +0100
Message-ID: <20140618160913.GH32514@n2100.arm.linux.org.uk>
References: <1403051632-32113-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:34562 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751007AbaFRQJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 12:09:21 -0400
Content-Disposition: inline
In-Reply-To: <1403051632-32113-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2014 at 08:33:52AM +0800, Fugang Duan wrote:
> The commit 96c50caa5148 (net: fec: Enable IP header hardware checksum)
> enable HW IP header checksum for IPV4 and IPV6, which causes IPV6 TCP/UDP
> cannot work. (The issue is reported by Russell King)
> 
> For FEC IP header checksum function: Insert IP header checksum. This "IINS"
> bit is written by the user. If set, IP accelerator calculates the IP header
> checksum and overwrites the IINS corresponding header field with the calculated
> value. The checksum field must be cleared by user, otherwise the checksum
> always is 0xFFFF.
> 
> So the previous patch clear IP header checksum field regardless of IP frame
> type.
> 
> In fact, IP HW detect the packet as IPV6 type, even if the "IINS" bit is set,
> the IP accelerator is not triggered to calculates IPV6 header checksum because
> IPV6 frame format don't have checksum.
> 
> So this results in the IPV6 frame being corrupted.
> 
> The patch just add software detect the current packet type, if it is IPV6
> frame, it don't clear IP header checksum field.
> 
> Cc: Russell King <linux@arm.linux.org.uk>
> Reported-and-tested-by: Russell King <linux@arm.linux.org.uk>

Please use rmk+kernel@arm.linux.org.uk and drop the Cc line as I'm now
mentioned in these tags, thanks.

Secondly, there's another couple of bugs in the merged patches:

	net: fec: Add Scatter/gather support

+static int
+fec_enet_txq_submit_frag_skb(struct sk_buff *skb, struct net_device *ndev)
+{
...
+		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
...
+			goto dma_mapping_error;
... successful exit ...
+	return 0;
+
+dma_mapping_error:
... failure exit ...
+	return NETDEV_TX_OK;
+}

+static int fec_enet_txq_submit_skb(struct sk_buff *skb, struct net_device *ndev)
+{
...
+		ret = fec_enet_txq_submit_frag_skb(skb, ndev);
+		if (ret)
+			return ret;

Firstly, NETDEV_TX_OK is enumerated as value zero.  So, whatever happens
in fec_enet_txq_submit_frag_skb(), this function always returns zero
even if we have an error.  This would lead to the packet ring being
left in a confused state, with the header part of the packet sitting
in the ring without the LAST bit set, and then the next packet to be
submitted may cause the "packet" as seen by the hardware to be
completed with a LAST buffer.

Secondly, if fec_enet_txq_submit_skb() were to be fixed not to return
zero, this still doesn't help the situation much - where's the error
handling to clean up the header part of the packet?

I'm currently porting my FEC patch set on top of your patches which
were merged in the last window, which is causing me to notice various
problems such as the above, which annoyingly I had already addressed
in my version of SG support.  I'm working towards being able to post
them, but it's going to be something like a week of solid work on my
patches before I'm ready to do that.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
