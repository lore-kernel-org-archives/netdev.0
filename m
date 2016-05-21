From: Shuyu Wei <wsy2220@gmail.com>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 22 May 2016 00:09:10 +0800
Message-ID: <20160521160910.GA14945@debian-dorm>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
 <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	David Miller <davem@davemloft.net>, wxt@rock-chips.com,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34568 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbcEUQJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 12:09:19 -0400
Received: by mail-qk0-f194.google.com with SMTP id i7so13668527qkd.1
        for <netdev@vger.kernel.org>; Sat, 21 May 2016 09:09:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160520003145.GA22420@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like I got it wrong in the first place.

priv->tx_buff is not for the device, so there's no need to move it.
The race has been fixed by commit c278c253f3d9, I forgot to check
it out. That's my fault.

I do find another problem. We need to use a barrier to make sure
skb_tx_timestamp() is called before setting the FOR_EMAC flag.

According to the comment(include/linux/skbuff.h):
>/**
> * skb_tx_timestamp() - Driver hook for transmit timestamping
> *
> * Ethernet MAC Drivers should call this function in their hard_xmit()
> * function immediately before giving the sk_buff to the MAC hardware.
> *
> * Specifically, one should make absolutely sure that this function is
> * called before TX completion of this packet can trigger.  Otherwise
> * the packet could potentially already be freed.
> *
> * @skb: A socket buffer.
> */

---

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a3a9392..c2447b0 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -686,6 +686,9 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 
        skb_tx_timestamp(skb);
 
+       /* Make sure timestamp is set */
+       smp_wmb();
+
        *info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
        /* Make sure info word is set */
