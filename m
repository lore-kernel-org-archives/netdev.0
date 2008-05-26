From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Mon, 26 May 2008 12:39:51 -0700 (PDT)
Message-ID: <20080526.123951.260448303.davem@davemloft.net>
References: <4827E930.3000008@krogh.cc>
	<483B0986.70606@krogh.cc>
	<20080526.123338.161271834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, matheos.worku@sun.com
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49395
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754833AbYEZTj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 15:39:56 -0400
In-Reply-To: <20080526.123338.161271834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 26 May 2008 12:33:38 -0700 (PDT)

> From: Jesper Krogh <jesper@krogh.cc>
> Date: Mon, 26 May 2008 21:03:34 +0200
> 
> > Ok. Now I also hit it in production with the NFS-server, so this
> > is definately a real bug somewhere in the driver. Should I register it
> > at bugzilla?
> 
> Please feel free to do that.

BTW, I did stare at some of the transmit code of the NIU driver
while flying from Tokyo to Seattle a few hours ago, and I
found one possible theory on the transmit timeouts.

Can you try the patch below and let us know if the symptoms
continue?

[ Note to Matheos: The IRQ marking scheme of the NIU doesn't mesh
  well with how things work under Linux.  We really needs a
  "TX queue empty" interrupt status in order to handle all cases
  properly.  Otherwise we really cannot decide not mark some TX
  descriptors without potentially entering a deadlock condition.  ]

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 918f802..7ab7f8e 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6165,7 +6165,7 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	rp->tx_buffs[prod].mapping = mapping;
 
 	mrk = TX_DESC_SOP;
-	if (++rp->mark_counter == rp->mark_freq) {
+	if (1 /*++rp->mark_counter == rp->mark_freq*/) {
 		rp->mark_counter = 0;
 		mrk |= TX_DESC_MARK;
 		rp->mark_pending++;
