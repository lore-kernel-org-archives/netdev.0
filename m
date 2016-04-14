From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V3 00/16] net: fec: cleanup and fixes
Date: Thu, 14 Apr 2016 08:39:04 -0700
Message-ID: <570FB998.2080900@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
 <87h9f4ebvp.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com, andrew@lunn.ch, stillcompiling@gmail.com,
	arnd@arndb.de, sergei.shtylyov@cogentembedded.com,
	gerg@uclinux.org, fabio.estevam@nxp.com, johannes@sipsolutions.net,
	l.stach@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	tremyfr@gmail.com
To: Holger Schurig <holgerschurig@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35887 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755379AbcDNPjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 11:39:06 -0400
Received: by mail-pf0-f179.google.com with SMTP id e128so46997061pfe.3
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 08:39:05 -0700 (PDT)
In-Reply-To: <87h9f4ebvp.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/14/2016 3:13 AM, Holger Schurig wrote:
> Do you guys that work with the FEC driver ever run with
> CONFIG_DMA_API_DEBUG enabled?
> 
> I ask this Because I get this error when it's turned on when I do some
> "rsync" transfer to my device:
> 
> [   58.420980] ------------[ cut here ]------------
> [   58.425667] WARNING: CPU: 0 PID: 377 at /home/schurig/d/mkarm/linux-4.5/lib/dma-debug.c:1096 check_unmap+0x9d0/0xab8()
> [   58.436405] fec 2188000.ethernet: DMA-API: device driver tries to free DMA memory it has not allocated [device address=0x0000000000000000] [size=66 bytes]
> [   58.450248] Modules linked in: bnep usbhid imx_sdma flexcan btusb btrtl btbcm btintel smsc95xx usbnet mii bluetooth
> [   58.460882] CPU: 0 PID: 377 Comm: sshd Tainted: G        W       4.5.1 #3
> [   58.467671] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
> [   58.474199] Backtrace: 
> [   58.476675] [<c0012a24>] (dump_backtrace) from [<c0012c20>] (show_stack+0x18/0x1c)
> [   58.484244]  r6:60000113 r5:c05a96c0 r4:00000000 r3:00000000
> [   58.489964] [<c0012c08>] (show_stack) from [<c01dbc4c>] (dump_stack+0x9c/0xb0)
> [   58.497197] [<c01dbbb0>] (dump_stack) from [<c001f558>] (warn_slowpath_common+0x8c/0xbc)
> [   58.505286]  r6:c01f9c74 r5:00000009 r4:ee9f17f8 r3:c0596da4
> [   58.511002] [<c001f4cc>] (warn_slowpath_common) from [<c001f5c0>] (warn_slowpath_fmt+0x38/0x40)
> [   58.519698]  r8:00000042 r7:00000001 r6:00000000 r5:00000000 r4:c050c020
> [   58.526470] [<c001f58c>] (warn_slowpath_fmt) from [<c01f9c74>] (check_unmap+0x9d0/0xab8)
> [   58.534559]  r3:c0520e6c r2:c050c020
> [   58.538159]  r4:00000000
> [   58.540710] [<c01f92a4>] (check_unmap) from [<c01f9de0>] (debug_dma_unmap_page+0x84/0x8c)
> [   58.548886]  r10:ef2ec000 r9:f09e5fa0 r8:ef0ef810 r7:00000001 r6:00000000 r5:00000042
> [   58.556780]  r4:00000001
> [   58.559336] [<c01f9d5c>] (debug_dma_unmap_page) from [<c02cdf00>] (fec_txq+0x140/0x31c)
> [   58.567338]  r8:ef0ef810 r7:00000000 r6:00000000 r5:00000000 r4:ef2c6000
> [   58.574108] [<c02cddc0>] (fec_txq) from [<c02ce2f4>] (fec_enet_napi_q1+0x98/0xe8)
> [   58.581589]  r10:08000000 r9:ef2ec580 r8:00000000 r7:00000040 r6:00000000 r5:ef2ec000


I think I've already fixed this, but I've only submitted once.

commit 466cb4a2e5583d2e18470f30d5948edcf4b947f5
Author: Troy Kisky <troy.kisky@boundarydevices.com>
Date:   Wed Jan 20 12:52:10 2016 -0700

    net: fec: update dirty_tx even if no skb

    If dirty_tx isn't updated, then dma_unmap_single
    will be called twice.

    Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 452be9c..150a90a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1243,10 +1243,8 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_priv_tx_q *txq)
                                         fec16_to_cpu(bdp->cbd_datlen),
                                         DMA_TO_DEVICE);
                bdp->cbd_bufaddr = cpu_to_fec32(0);
-               if (!skb) {
-                       bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
-                       continue;
-               }
+               if (!skb)
+                       goto skb_done;

                /* Check for errors. */
                if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
@@ -1285,7 +1283,7 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_priv_tx_q *txq)

                /* Free the sk buffer associated with this last transmit */
                dev_kfree_skb_any(skb);
-
+skb_done:
                /* Make sure the update to bdp and tx_skbuff are performed
                 * before dirty_tx
                 */
