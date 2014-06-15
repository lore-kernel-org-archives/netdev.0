From: Nick Krause <xerofoify@gmail.com>
Subject: Re: [PATCH] Missing return check against Null for return value of netdev_alloc_dev_skb()
Date: Sun, 15 Jun 2014 16:27:23 -0400
Message-ID: <CAPDOMVgV8V8fPpZupwQaDERiK-0OMLt66LULR6Biw1=8LJhOKw@mail.gmail.com>
References: <1402805139-6363-1-git-send-email-xerofoify@gmail.com>
	<20140614.235300.1228145928404410306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: andriy.shevchenko@linux.intel.com, dvhart@linux.intel.com,
	jeffrey.t.kirsher@intel.com, ast@plumgrid.com, dborkman@redhat.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140614.235300.1228145928404410306.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 62b0d77a1430f74b7f5c008c5e8bec11604b33b0 Mon Sep 17 00:00:00 2001
From: Nick <xerofoify@gmail.com>
Date: Sun, 15 Jun 2014 16:16:14 -0400
Subject: [PATCHv2] Fixes return logic of function of pch_gbe_alloc_tx_buffers()
Here is the fixed patch changed return type of function to int in
order to use return -ENOMEM as with the function above it , seems to
fit , otherwise returns 0.
 Report if it breaks anything related to this driver.
Signed-off-by: Nick <xerofoify@gmail.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 704cf63..7d5efd7 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1500,7 +1500,7 @@ pch_gbe_alloc_rx_buffers_pool(struct
pch_gbe_adapter *adapter,
  * @adapter:   Board private structure
  * @tx_ring:   Tx descriptor ring
  */
-static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
+static int pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter
 struct pch_gbe_tx_ring *tx_ring)
 {
     struct pch_gbe_buffer *buffer_info;
@@ -1516,13 +1516,13 @@ static void pch_gbe_alloc_tx_buffers(struct
pch_gbe_adapter *adapter,
         buffer_info = &tx_ring->buffer_info[i];
         skb = netdev_alloc_skb(adapter->netdev, bufsz);
         if(!skb)
+            return -ENOMEM;
         skb_reserve(skb, PCH_GBE_DMA_ALIGN);
         buffer_info->skb = skb;
         tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
         tx_desc->gbec_status = (DSC_INIT16);
     }
-    return;
+    return 0;
 }

 /**
-- 
1.9.1
Thanks for the Comments,
Nick

On Sun, Jun 15, 2014 at 2:53 AM, David Miller <davem@davemloft.net> wrote:
> From: Nick <xerofoify@gmail.com>
> Date: Sun, 15 Jun 2014 00:05:39 -0400
>
>> Signed-off-by: Nick <xerofoify@gmail.com>
>> ---
>>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
>> index 73e6683..704cf63 100644
>> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
>> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
>> @@ -1515,6 +1515,8 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
>>       for (i = 0; i < tx_ring->count; i++) {
>>               buffer_info = &tx_ring->buffer_info[i];
>>               skb = netdev_alloc_skb(adapter->netdev, bufsz);
>> +             if (!skb)
>> +                     return NULL;
>
> You didn't even compile test this.
>
> The function has a void return type, you can't return NULL.
>
> Furthermore, you have to adjust things so that the caller knows that
> this operation failed, because the device cannot be brought up
> successfully unless all the TX buffer slots get allocated properly.
