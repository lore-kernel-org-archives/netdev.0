From: Jim Baxter <jim_baxter@mentor.com>
Subject: [PATCH V2 0/1] Reduce cdc_ncm memory use when kernel memory low
Date: Wed, 28 Jun 2017 21:35:28 +0100
Message-ID: <1498682129-9129-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jim_baxter@mentor.com>,
        =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
        David Laight <David.Laight@ACULAB.COM>
To: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:53807 "EHLO
        relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdF1Ufg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 16:35:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem
-------

We are using an ARM embedded platform and require 16KiB NTB's to allow for fast
data transfer. Unfortunately we have found that there are times after
running the kernel for a while and transferring a lot of data over the CDC-NCM
connection that it can become harder to find 16KiB pages of memory for
allocation.
This results in a disconnection of the NCM Gadget attached to the host platform.

We are running with reduced buffers to not cross over into the 32KiB page
boundary by setting the buffer sizes to:
tx_max=16000
rx_max=16000


Analysis
--------

We identified through investigation that the lack of 16KiB pages would be short
lived as the kernel would compact the buddy list soon after the failure which 
results in pages being available within seconds.

Solution
--------

In order to avoid disconnections I implemented a patch that will attempt to
use a 2048 Byte minimum size NTB if the allocation of the maximum size NTB
fails.
This allows the connection to limp along until the memory has been recovered
which was usually between 1 and 4 NTB's on our heavy traffic system.
The algorithm will wait for an increasing number of small allocations each
time we have a failure to not burden a system short on memory.

---

V1: Sent to linux-usb for review.
V2: Added code to increase amount of time spent making small allocations to
    reduce the burden on the system.

This is the diff between Version 1 and 2 of the patches.

-- File: drivers/net/usb/cdc_ncm.c
41c51,60
< @@ -1055,10 +1055,10 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
---
> @@ -89,6 +89,8 @@ struct cdc_ncm_stats {
>  	CDC_NCM_SIMPLE_STAT(rx_ntbs),
>  };
>  
> +#define CDC_NCM_LOW_MEM_MAX_CNT 10
> +
>  static int cdc_ncm_get_sset_count(struct net_device __always_unused *netdev, int sset)
>  {
>  	switch (sset) {
> @@ -1055,10 +1057,10 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
59,60c78,91
< +		ctx->tx_curr_size = ctx->tx_max;
< +		skb_out = alloc_skb(ctx->tx_curr_size, GFP_ATOMIC);
---
> +		if (ctx->tx_low_mem_val == 0) {
> +			ctx->tx_curr_size = ctx->tx_max;
> +			skb_out = alloc_skb(ctx->tx_curr_size, GFP_ATOMIC);
> +			/* If the memory allocation fails we will wait longer
> +			 * each time before attempting another full size
> +			 * allocation again to not overload the system
> +			 * further.
> +			 */
> +			if (skb_out == NULL) {
> +				ctx->tx_low_mem_max_cnt = min(ctx->tx_low_mem_max_cnt + 1,
> +							      (unsigned)CDC_NCM_LOW_MEM_MAX_CNT);
> +				ctx->tx_low_mem_val = ctx->tx_low_mem_max_cnt;
> +			}
> +		}
84a116
> +			ctx->tx_low_mem_val--;

-- File: include/linux/usb/cdc_ncm.h
130a163,164
> +	u32 tx_low_mem_max_cnt;
> +	u32 tx_low_mem_val;


Jim Baxter (1):
  net: cdc_ncm: Reduce memory use when kernel memory low

 drivers/net/usb/cdc_ncm.c   | 54 +++++++++++++++++++++++++++++++++++----------
 include/linux/usb/cdc_ncm.h |  3 +++
 2 files changed, 45 insertions(+), 12 deletions(-)

-- 
1.9.1
