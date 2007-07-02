From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.22-rc6: local_bh_enable warning
Date: Mon, 02 Jul 2007 16:08:28 +0200
Message-ID: <468906DC.3010709@trash.net>
References: <20070630170853.GA17467@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010400040202080007030208"
Cc: netfilter-devel@lists.netfilter.org,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50850 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbXGBOIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 10:08:45 -0400
In-Reply-To: <20070630170853.GA17467@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010400040202080007030208
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Russell King wrote:
> Having upgraded from 2.6.16 to 2.6.22-rc6, I'm now seeing the following.
> 
> Looks like netfilter is calling local_bh_enable() with IRQs disabled,
> which would appear to be illegal.  Thankfully, this is a warn-once
> warning.
> 
> WARNING: at /home/rmk/git/linux-2.6-rmk/kernel/softirq.c:138 local_bh_enable()
> [...]
> [<c01447fc>] (nf_conntrack_destroy+0x0/0x2c) from [<c012c05c>] (__kfree_skb+0xd0/0x100)
> [<c012bf8c>] (__kfree_skb+0x0/0x100) from [<c012c0d8>] (kfree_skb+0x4c/0x50)
>  r5:c12a3800 r4:00000300
> [<c012c08c>] (kfree_skb+0x0/0x50) from [<bf03cbb0>] (el3_start_xmit+0xb8/0xd0 [3c589_cs])
> [<bf03caf8>] (el3_start_xmit+0x0/0xd0 [3c589_cs]) from [<c01324dc>] (dev_hard_start_xmit+0x1a8/0x244)
>  r7:c12a3800 r6:c1a9aa00 r5:c1a9aa00 r4:c12a3800
> [<c0132334>] (dev_hard_start_xmit+0x0/0x244) from [<c013fcc0>] (__qdisc_run+0xb0/0x198)


Thats a bug in the 3c589_cs driver. Patch attached.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------010400040202080007030208
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 143ae2f..503f268 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -629,9 +629,9 @@ static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	outw(SetTxThreshold + 1536, ioaddr + EL3_CMD);
     }
 
-    dev_kfree_skb(skb);
     pop_tx_status(dev);
     spin_unlock_irqrestore(&priv->lock, flags);    
+    dev_kfree_skb(skb);
     
     return 0;
 }

--------------010400040202080007030208--
