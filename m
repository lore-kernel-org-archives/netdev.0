From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Mon, 18 Feb 2008 17:04:06 -0800
Message-ID: <1203383046.13495.87.camel@dell>
References: <47BA0984.2070306@cybernetics.com>
 <1203381120.13495.78.camel@dell>
 <20080218.163554.74130592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tonyb@cybernetics.com, herbert@gondor.apana.org.au,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3617 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766AbYBSBBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 20:01:43 -0500
In-Reply-To: <20080218.163554.74130592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-18 at 16:35 -0800, David Miller wrote:

> One consequence of Herbert's change is that the chip will see a
> different datastream.  The initial skb->data linear area will be
> smaller, and the transition to the fragmented area of pages will be
> quicker.
> 

I see.  Perhaps when we get to the end of the data-stream, there is a
tiny frag that the chip cannot handle.  That's the only thing I can
think of.

Please try this patch to see if the problem goes away.  This will
disable SG on 5701 so we always get linear SKBs.

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index db606b6..bb37e76 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12717,6 +12717,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	} else
 		tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)
+		dev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_SG);
+
 	/* flow control autonegotiation is default behavior */
 	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
 	tp->link_config.flowctrl = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;


