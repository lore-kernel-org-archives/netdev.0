From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH net v2 0/2] net: ethoc: Error path and transmit fixes
Date: Tue, 12 Jul 2016 16:51:10 +0300
Message-ID: <20160712135109.GB19495@octofox.metropolis>
References: <1468280155-13152-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	colin.king@canonical.com, tklauser@distanz.ch,
	thierry.reding@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33750 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbcGLNvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 09:51:14 -0400
Received: by mail-lf0-f67.google.com with SMTP id f93so974033lfi.0
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 06:51:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468280155-13152-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Jul 11, 2016 at 04:35:53PM -0700, Florian Fainelli wrote:
> This patch series contains two patches for the ethoc driver while testing on a
> TS-7300 board where ethoc is provided by an on-board FPGA.
> 
> First patch was cooked after chasing crashes with invalid resources passed to
> the driver.
> 
> Second patch was cooked after seeing that an interface configured with IP
> 192.168.2.2 was sending ARP packets for 192.168.0.0, no wonder why it could not
> work.

I can see opencores intrerface sending ARP packets shorter than 64 bytes,
but I couldn't reproduce truncation that affects packet contents on my
hardware.

> I don't have access to any other platform using an ethoc interface so
> it could be good to some testing on Xtensa for instance.

I've tested success and error paths affected by this series with the
following additional change on top of it:

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index ca678d4..8c94f45 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -862,7 +862,7 @@ static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb_put_padto(skb, ETHOC_ZLEN)) {
 		dev->stats.tx_errors++;
-		goto out;
+		return NETDEV_TX_OK;
 	}
 
 	if (unlikely(skb->len > ETHOC_BUFSIZ)) {

Without it the interface becomes non-functional after the first error
in skb_put_padto.

Tested-by: Max Filippov <jcmvbkbc@gmail.com>
Reviewed-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max
