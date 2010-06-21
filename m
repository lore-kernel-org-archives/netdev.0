From: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
Subject: [PATCH] kernel 2.6.35: ixgbe: skip non IPv4 packets in ATR filter
Date: Mon, 21 Jun 2010 15:05:02 +0200
Message-ID: <4C1F637E.8010005@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36153 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757828Ab0FUM5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 08:57:19 -0400
Received: by wyb33 with SMTP id 33so2220956wyb.19
        for <netdev@vger.kernel.org>; Mon, 21 Jun 2010 05:57:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

In driver ixgbe, ixgbe_atr may cause crashes for non-ipv4 packets. Just 
add a test to check skb->protocol:

 From fcb81aa89b6819f95349a4ed8c30f0629430aa1d Mon Sep 17 00:00:00 2001
From: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
Date: Thu, 17 Jun 2010 16:02:14 +0200
Subject: [PATCH] ixgbe: skip non IPv4 packets in ATR filter

It may crash on short packets due to ip_hdr() access.

Signed-off-by: Guillaume Gaudonville <guillaume.gaudonville@6wind.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b2af2f6..3581dbe 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6019,7 +6019,6 @@ static void ixgbe_tx_queue(struct ixgbe_adapter 
*adapter,
 static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
                      int queue, u32 tx_flags)
 {
-       /* Right now, we support IPv4 only */
        struct ixgbe_atr_input atr_input;
        struct tcphdr *th;
        struct iphdr *iph = ip_hdr(skb);
@@ -6028,6 +6027,10 @@ static void ixgbe_atr(struct ixgbe_adapter 
*adapter, struct sk_buff *skb,
        u32 src_ipv4_addr, dst_ipv4_addr;
        u8 l4type = 0;
 
+       /* Right now, we support IPv4 only */
+       if (skb->protocol != htons(ETH_P_IP))
+               return;
+
        /* check if we're UDP or TCP */
        if (iph->protocol == IPPROTO_TCP) {
                th = tcp_hdr(skb);
-- 
1.5.6.5

-- 
Guillaume Gaudonville
guillaume.gaudonville@6wind.com

