From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: Don't clear IPV6 header checksum field when	IP
 accelerator enable
Date: Thu, 19 Jun 2014 02:03:50 +0000
Message-ID: <2dffdcf9cf0044219f421e05a43b070f@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1403051632-32113-1-git-send-email-b38611@freescale.com>
 <20140618160913.GH32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0212.outbound.protection.outlook.com ([207.46.163.212]:37651
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756638AbaFSCEL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 22:04:11 -0400
In-Reply-To: <20140618160913.GH32514@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk> Data: Thursday, June 19, 2014 12:09 AM
>To: Duan Fugang-B38611
>Cc: davem@davemloft.net; netdev@vger.kernel.org
>Subject: Re: [PATCH] net: fec: Don't clear IPV6 header checksum field when
>IP accelerator enable
[...]
>Secondly, there's another couple of bugs in the merged patches:
>
>	net: fec: Add Scatter/gather support
>
>+static int
>+fec_enet_txq_submit_frag_skb(struct sk_buff *skb, struct net_device
>+*ndev) {
>...
>+		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
>...
>+			goto dma_mapping_error;
>... successful exit ...
>+	return 0;
>+
>+dma_mapping_error:
>... failure exit ...
>+	return NETDEV_TX_OK;
>+}
>
>+static int fec_enet_txq_submit_skb(struct sk_buff *skb, struct
>+net_device *ndev) {
>...
>+		ret = fec_enet_txq_submit_frag_skb(skb, ndev);
>+		if (ret)
>+			return ret;
>
>Firstly, NETDEV_TX_OK is enumerated as value zero.  So, whatever happens
>in fec_enet_txq_submit_frag_skb(), this function always returns zero even
>if we have an error.  This would lead to the packet ring being left in a
>confused state, with the header part of the packet sitting in the ring
>without the LAST bit set, and then the next packet to be submitted may
>cause the "packet" as seen by the hardware to be completed with a LAST
>buffer.
>
>Secondly, if fec_enet_txq_submit_skb() were to be fixed not to return zero,
>this still doesn't help the situation much - where's the error handling to
>clean up the header part of the packet?
>
For error handle, it is trouble. So .fec_enet_txq_submit_skb() return non-zero when dma mapping error,
And continue to dmp unmapping the header part of the packet.
I see some driver don't process dma mapping error like drivers/net/ethernet/marvell/mv643xx_eth.c.

>I'm currently porting my FEC patch set on top of your patches which were
>merged in the last window, which is causing me to notice various problems
>such as the above, which annoyingly I had already addressed in my version
>of SG support.  I'm working towards being able to post them, but it's
>going to be something like a week of solid work on my patches before I'm
>ready to do that.
>
If your SG patch is better than this, you can submit one patch to convert this to yours.
I believe there have better method for this, but I had done overninght test on this patch.
