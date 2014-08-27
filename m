From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: Sending undersized ARP packets with VXLAN L3 interface
Date: Wed, 27 Aug 2014 13:52:03 -0400
Message-ID: <53FE1AC3.5030409@gmail.com>
References: <CAMYYbY79hOVA5b22-gmLJTNQwprdfwa_QxKqveuwNhJMcXv9tA@mail.gmail.com> <CAHA+R7Ok6K_9U6RCZkSLCuVXtFG4Zs60FQKFZMu-v2yK581hog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	Martin Rusko <martin.rusko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:37890 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbaH0RwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 13:52:08 -0400
Received: by mail-qg0-f45.google.com with SMTP id f51so596049qge.4
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 10:52:07 -0700 (PDT)
In-Reply-To: <CAHA+R7Ok6K_9U6RCZkSLCuVXtFG4Zs60FQKFZMu-v2yK581hog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2014 01:28 PM, Cong Wang wrote:
> On Wed, Aug 27, 2014 at 10:06 AM, Martin Rusko <martin.rusko@gmail.com> wrote:
>>
>> I'm wondering, where is the proper place to fix this. Should
>> arp_create() function allocate skb big enough to produce ethernet
>> frame with at least minimum size? Or is it somewhere in NIC drivers
>> where small packets are padded with zeros?
>
> Drivers do that, for example e1000:
>
>         /* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
>          * packets may get corrupted during padding by HW.
>          * To WA this issue, pad all small packets manually.
>          */
>         if (skb->len < ETH_ZLEN) {
>                 if (skb_pad(skb, ETH_ZLEN - skb->len))
>                         return NETDEV_TX_OK;
>                 skb->len = ETH_ZLEN;
>                 skb_set_tail_pointer(skb, ETH_ZLEN);
>         }


I think vxlan needs something like this:

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Wed, 27 Aug 2014 13:39:32 -0400
Subject: [PATCH] vxlan: Pad short ethernet frames.

If sending short ethernet frames from the vxlan device, pad
them to minimum size so they can be forwarded after decapsulation.

Reported-by: Martin Rusko <martin.rusko@gmail.com>
Signed-off-by: Vladislav Yasevich <vyasevich@gmail.com>
---
 drivers/net/vxlan.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1fb7b37..48267d4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1939,6 +1939,14 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct
net_device *dev)
 #endif
 	}

+	/* Pad short frames so they can be forwarded after decapsulation */
+	if (skb->len < ETH_ZLEN) {
+		if (skb_pad(skb, ETH_ZLEN - skb->len))
+			return NETDEV_TX_OK;
+		skb->len = ETH_ZLEN;
+		skb_set_tail_pointer(skb, ETH_ZLEN);
+	}
+
 	f = vxlan_find_mac(vxlan, eth->h_dest);
 	did_rsc = false;

-- 
1.9.3
