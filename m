From: "Baxter, Jim" <jim_baxter@mentor.com>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Tue, 23 May 2017 20:06:53 +0100
Message-ID: <97db8a45-55ec-b68f-6f88-e934f67d31fc@mentor.com>
References: <04bc5b49-9282-a6ca-2b95-fb8fc9750555@mentor.com>
 <20170522.115426.1239443379414364630.davem@davemloft.net>
 <1495528968.2174.2.camel@suse.com>
 <20170523.112625.33559883707681029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bjorn@mork.no>, <linux-usb@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:36638 "EHLO
        relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764279AbdEWTHC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:07:02 -0400
In-Reply-To: <20170523.112625.33559883707681029.davem@davemloft.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David S. Miller (davem@davemloft.net)
Sent: Tue, 23 May 2017 11:26:25 -0400 
> From: Oliver Neukum <oneukum@suse.com>
> Date: Tue, 23 May 2017 10:42:48 +0200
> 
>>
>> We could use a counter. After the first failure, do it once, after the
>> second twice and so on. And reset the counter as a higher order
>> allocation works. (just bound it somewhere)
> 
> So an exponential backoff, that might work.
> 

As an idea I have created this patch as an addition to the original patch
in this series.

Would this be acceptable?

At the moment I have capped the value at 10, does anyone think it needs to
be much higher then that?

Regards,
Jim


diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index c06d20f..0e40603 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -89,6 +89,8 @@ struct cdc_ncm_stats {
        CDC_NCM_SIMPLE_STAT(rx_ntbs),
 };
 
+#define CDC_NCM_LOW_MEM_MAX_CNT 10
+
 static int cdc_ncm_get_sset_count(struct net_device __always_unused *netdev, int sset)
 {
        switch (sset) {
@@ -1111,8 +1113,13 @@ struct sk_buff *
 
        /* allocate a new OUT skb */
        if (!skb_out) {
-               ctx->tx_curr_size = ctx->tx_max;
-               skb_out = alloc_skb(ctx->tx_curr_size, GFP_ATOMIC);
+               if (ctx->tx_low_mem_val == 0) {
+                       ctx->tx_curr_size = ctx->tx_max;
+                       skb_out = alloc_skb(ctx->tx_curr_size, GFP_ATOMIC);
+                       if (skb_out == NULL) {
+                               ctx->tx_low_mem_max_cnt = min(ctx->tx_low_mem_max_cnt + 1, CDC_NCM_LOW_MEM_MAX_CNT);
+                               ctx->tx_low_mem_val = ctx->tx_low_mem_max_cnt;
+               }
                if (skb_out == NULL) {
                        /* See if a very small allocation is possible.
                         * We will send this packet immediately and hope
@@ -1127,12 +1134,13 @@ struct sk_buff *
 
                        /* No allocation possible so we will abort */
                        if (skb_out == NULL) {
-                               if (skb != NULL) {
+                               if (skb) {
                                        dev_kfree_skb_any(skb);
                                        dev->net->stats.tx_dropped++;
                                }
                                goto exit_no_skb;
                        }
+                       ctx->tx_low_mem_val--;
                }
                /* fill out the initial 16-bit NTB header */
                nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 5162f38..25a0aed 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -118,6 +118,8 @@ struct cdc_ncm_ctx {
        u32 rx_max;
        u32 tx_max;
        u32 tx_curr_size;
+       u32 tx_low_mem_max_cnt;
+       u32 tx_low_mem_val;
        u32 max_datagram_size;
        u16 tx_max_datagrams;
        u16 tx_remainder;
