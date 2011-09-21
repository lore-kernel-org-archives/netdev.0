From: Michael Riesch <michael@riesch.at>
Subject: [patch] usbnet: add timestamping support
Date: Wed, 21 Sep 2011 12:11:51 +0200
Message-ID: <20110921121151.Horde.2_LlPML8999Oebhn0-QlTpA@webmail.df.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed; DelSp=Yes
Cc: davem@davemloft.net, Oliver Neukum <oneukum@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.25]:48043 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002Ab1IUKRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 06:17:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to make USB-to-Ethernet-adapters (depending on usbnet) support
time stamping, the "skb_defer_rx_timestamp" and "skb_tx_timestamp"
function calls are added.

I considered to put these calls between #ifdef's to make them dependent
on CONFIG_NETWORK_PHY_TIMESTAMPING. I decided not to do so because except
the check whether the current packet is a PTP packet (and this check
should be fast) no overhead occurs. But let me know your opinion about
that one.

Looking forward to your comments,
Michael

Signed-off-by: Michael Riesch <michael@riesch.at>
---
  drivers/net/usb/usbnet.c |    6 ++++++
  1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ce395fe..cdb9588 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -238,6 +238,10 @@ void usbnet_skb_return (struct usbnet *dev,  
struct sk_buff *skb)
          netif_dbg(dev, rx_status, dev->net, "< rx, len %zu, type 0x%x\n",
                    skb->len + sizeof (struct ethhdr), skb->protocol);
          memset (skb->cb, 0, sizeof (struct skb_data));
+
+        if (skb_defer_rx_timestamp(skb))
+                return;
+
          status = netif_rx (skb);
          if (status != NET_RX_SUCCESS)
                  netif_dbg(dev, rx_err, dev->net,
@@ -1053,6 +1057,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
          unsigned long                flags;
          int retval;

+        skb_tx_timestamp(skb);
+
          // some devices want funky USB-level framing, for
          // win32 driver (usually) and/or hardware quirks
          if (info->tx_fixup) {
-- 
1.7.0.4
