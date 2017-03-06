From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] vrf: Fix use-after-free in vrf_xmit
Date: Mon,  6 Mar 2017 08:53:04 -0800
Message-ID: <1488819184-12641-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33249 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932114AbdCFR6A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 12:58:00 -0500
Received: by mail-pf0-f178.google.com with SMTP id w189so63275606pfb.0
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 09:57:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KASAN detected a use-after-free:

[  269.467067] BUG: KASAN: use-after-free in vrf_xmit+0x7f1/0x827 [vrf] at addr ffff8800350a21c0
[  269.467067] Read of size 4 by task ssh/1879
[  269.467067] CPU: 1 PID: 1879 Comm: ssh Not tainted 4.10.0+ #249
[  269.467067] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  269.467067] Call Trace:
[  269.467067]  dump_stack+0x81/0xb6
[  269.467067]  kasan_object_err+0x21/0x78
[  269.467067]  kasan_report+0x2f7/0x450
[  269.467067]  ? vrf_xmit+0x7f1/0x827 [vrf]
[  269.467067]  ? ip_output+0xa4/0xdb
[  269.467067]  __asan_load4+0x6b/0x6d
[  269.467067]  vrf_xmit+0x7f1/0x827 [vrf]
...

Which corresponds to the skb access after xmit handling. Fix by saving
skb->len and using the saved value to update stats.

Fixes: 193125dbd8eb2 ("net: Introduce VRF device driver")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 22379da63400..fea687f35b5a 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -340,6 +340,7 @@ static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
 
 static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	int len = skb->len;
 	netdev_tx_t ret = is_ip_tx_frame(skb, dev);
 
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
@@ -347,7 +348,7 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		u64_stats_update_begin(&dstats->syncp);
 		dstats->tx_pkts++;
-		dstats->tx_bytes += skb->len;
+		dstats->tx_bytes += len;
 		u64_stats_update_end(&dstats->syncp);
 	} else {
 		this_cpu_inc(dev->dstats->tx_drps);
-- 
2.1.4
