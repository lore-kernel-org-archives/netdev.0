From: Murali Karicheri <m-karicheri2@ti.com>
Subject: net: netcp: regarding commit 899077: netcp: try to reduce type
 confusion in descriptors
Date: Mon, 22 Feb 2016 16:48:14 -0500
Message-ID: <56CB821E.7040809@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:48267 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742AbcBVVsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 16:48:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd,

As promised, here is what I found wrong with the commit 899077 that introduced a 
regression. With these changes, I am able to boot kernel without issues on K2 platforms.

>From the commit description, it appears that you are trying to make the driver do the right
thing if compiled for a 64 bit systems. Is it mandatory for all kernel drivers to be
64bit compliant? Similar question on supporting mixed endian in all kernel drivers.
Keystone can have SoC configured to be in big endian mode for peripherals and DSP. so that is
something we need to support if there is customer interest. Wondering why do one run BE kernel
binary on these platforms? Any reason? I saw some reference to that in past discussion on this
regression issue.

Murali


diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index c61d66d..ac35161 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -167,7 +167,7 @@ static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *des
 {
        desc->pad[0] = cpu_to_le32(pad0);
        desc->pad[1] = cpu_to_le32(pad1);
-       desc->pad[2] = cpu_to_le32(pad1);
+       desc->pad[2] = cpu_to_le32(pad2);
 }
 
 static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
@@ -870,8 +870,8 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
                }
                buf_len = PAGE_SIZE;
                dma = dma_map_page(netcp->dev, page, 0, buf_len, DMA_TO_DEVICE);
-               pad[0] = lower_32_bits(dma);
-               pad[1] = upper_32_bits(dma);
+               pad[0] = lower_32_bits((uintptr_t)page);
+               pad[1] = upper_32_bits((uintptr_t)page);
                pad[2] = 0;
        }
 
@@ -1194,9 +1194,9 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
        }
 
        set_words(&tmp, 1, &desc->packet_info);
-       tmp = lower_32_bits((uintptr_t)&skb);
+       tmp = lower_32_bits((uintptr_t)skb);
        set_words(&tmp, 1, &desc->pad[0]);
-       tmp = upper_32_bits((uintptr_t)&skb);
+       tmp = upper_32_bits((uintptr_t)skb);
        set_words(&tmp, 1, &desc->pad[1]);
 
        if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {

-- 
Murali Karicheri
Linux Kernel, Keystone
