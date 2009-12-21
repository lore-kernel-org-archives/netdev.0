From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [BUG] 2.6.33-rc1 gianfar error message
Date: Mon, 21 Dec 2009 14:19:20 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08F83@zin33exm22.fsl.freescale.net>
References: <20091220214447.GA10233@trillian.comsick.at> <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net> <20091221072704.GA12110@gibson.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>
To: "Michael Guntsche" <mike@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54863 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbZLUItZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 03:49:25 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBL8nOrq024574
	for <netdev@vger.kernel.org>; Mon, 21 Dec 2009 01:49:24 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nBL8sVvN012446
	for <netdev@vger.kernel.org>; Mon, 21 Dec 2009 02:54:32 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091221072704.GA12110@gibson.comsick.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: Michael Guntsche [mailto:mike@it-loops.com] 
>Sent: Monday, December 21, 2009 12:57 PM
>To: Kumar Gopalpet-B05799
>Cc: netdev
>Subject: Re: [BUG] 2.6.33-rc1 gianfar error message
>
>On 21 Dec 09 09:58, Kumar Gopalpet-B05799 wrote:
>> Hi Michael,
>> 
>> It looks like even we are enabling only single tx queue, some how it 
>> is trying to pick up tx queue 66.
>> 
>> Can you please let me know what is your test setup and, 
>please give me
>The hardware used is a Mikrotik Routerboard RB600a, which is 
>83xx based.
>It has three NICs two of them being gianfar devices.
>
>> the location from where you cloned this kernel. 
>The kernel used is vanilla 2.6.33-rc1 from git.kernel.org plus 
>the Board specific patches. The patches do not change anything 
>on the network or driver side, they just add ATA, nand and 
>board specific support to the kernel. If you want I can 
>provide a git repo for it.
>
>> Can you also share the dts file you were using ?
>Attached you will find the DTS file being used.
>
>Kind regards,
>Michael
>
>
Michael, 

Kindly try the following changes at your side and let me know the
results. I couldn't test this
as I don't have any TSEC device with me.

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index e0620d0..4577d90 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2470,10 +2470,11 @@ static int gfar_process_frame(struct net_device
*dev, struct sk_buff *skb,
        fcb = (struct rxfcb *)skb->data;

        /* Remove the FCB from the skb */
-       skb_set_queue_mapping(skb, fcb->rq);
        /* Remove the padded bytes, if there are any */
-       if (amount_pull)
+       if (amount_pull) {
+               skb_set_queue_mapping(skb, fcb->rq);
                skb_pull(skb, amount_pull);
+       }

        if (priv->rx_csum_enable)
                gfar_rx_checksum(skb, fcb);
@@ -2555,6 +2556,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q
*rx_queue, int rx_work_limit)
                                skb_put(skb, pkt_len);
                                rx_queue->stats.rx_bytes += pkt_len;

+                               skb_set_queue_mapping(skb,
rx_queue->qindex);
                                gfar_process_frame(dev, skb,
amount_pull);

                        } else {
--

