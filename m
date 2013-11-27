From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: 8139cp: fix a BUG_ON triggered by wrong bytes_compl
Date: Tue, 26 Nov 2013 20:35:03 -0800
Message-ID: <1385526903.5352.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385525270-56580-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, dwmw2@infradead.org,
	dave.taht@bufferbloat.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:57448 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952Ab3K0EfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 23:35:06 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so9529937pbb.31
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 20:35:05 -0800 (PST)
In-Reply-To: <1385525270-56580-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-27 at 12:07 +0800, Yang Yingliang wrote:
> Using iperf to send packets(GSO mode is on), a bug is triggered:
> 

> When a skb has frags, bytes_compl plus skb->len nr_frags times in cp_tx().
> It's not the correct value(actually, it should plus skb->len once) and it
> will trigger the BUG_ON(bytes_compl > num_queued - dql->num_completed).Use
> txd->opts1 which stores the real length of a frag in cp_start_xmit() to
> calculate bytes_compl.
> pkts_compl also has a wrong value, fix it too.
> 
> It's introduced by commit 871f0d4c("8139cp: enable bql").
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  drivers/net/ethernet/realtek/8139cp.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index f2a2128..3b837f0 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -664,7 +664,7 @@ static void cp_tx (struct cp_private *cp)
>  	while (tx_tail != tx_head) {
>  		struct cp_desc *txd = cp->tx_ring + tx_tail;
>  		struct sk_buff *skb;
> -		u32 status;
> +		u32 status, flags;
>  
>  		rmb();
>  		status = le32_to_cpu(txd->opts1);
> @@ -678,8 +678,10 @@ static void cp_tx (struct cp_private *cp)
>  				 le32_to_cpu(txd->opts1) & 0xffff,
>  				 PCI_DMA_TODEVICE);
>  
> -		bytes_compl += skb->len;
> -		pkts_compl++;
> +		flags = le32_to_cpu(txd->opts1);

Why not using 'status' here, its the same value.

> +		bytes_compl += (flags & 0xffff);
> +		if (flags & FirstFrag)
> +			pkts_compl++;
>  
>  		if (status & LastFrag) {
>  			if (status & (TxError | TxFIFOUnder)) {

I dont know, this seems a bit convoluted and dangerous, as
cp_start_xmit() did :

netdev_sent_queue(dev, skb->len);

So I would just use :

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index f2a2128165dd..4a935a966e28 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -678,8 +678,6 @@ static void cp_tx (struct cp_private *cp)
 				 le32_to_cpu(txd->opts1) & 0xffff,
 				 PCI_DMA_TODEVICE);
 
-		bytes_compl += skb->len;
-		pkts_compl++;
 
 		if (status & LastFrag) {
 			if (status & (TxError | TxFIFOUnder)) {
@@ -702,6 +700,8 @@ static void cp_tx (struct cp_private *cp)
 				netif_dbg(cp, tx_done, cp->dev,
 					  "tx done, slot %d\n", tx_tail);
 			}
+			bytes_compl += skb->len;
+			pkts_compl++;
 			dev_kfree_skb_irq(skb);
 		}
 
