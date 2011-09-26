From: <rongqing.li@windriver.com>
Subject: [PATCH] staging/octeon: Software should check the checksum of no tcp/udp packets
Date: Mon, 26 Sep 2011 09:08:00 +0800
Message-ID: <1316999280-11999-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ralf@linux-mips.org>, <david.daney@cavium.com>
To: <linux-mips@linux-mips.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64108 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab1IZBIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 21:08:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

Icmp packets with wrong checksum are never dropped since
skb->ip_summed is set to CHECKSUM_UNNECESSARY.

When icmp packets with wrong checksum pass through the octeon
net driver, the not_IP, IP_exc, L4_error hardware indicators
show no error. so the driver sets CHECKSUM_UNNECESSARY on
skb->ip_summed.

L4_error only works for TCP/UDP, not for ICMP.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 drivers/staging/octeon/ethernet-rx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
index 1a7c19a..1747024 100644
--- a/drivers/staging/octeon/ethernet-rx.c
+++ b/drivers/staging/octeon/ethernet-rx.c
@@ -411,7 +411,8 @@ static int cvm_oct_napi_poll(struct napi_struct *napi, int budget)
 				skb->protocol = eth_type_trans(skb, dev);
 				skb->dev = dev;
 
-				if (unlikely(work->word2.s.not_IP || work->word2.s.IP_exc || work->word2.s.L4_error))
+				if (unlikely(work->word2.s.not_IP || work->word2.s.IP_exc ||
+					work->word2.s.L4_error || !work->word2.s.tcp_or_udp))
 					skb->ip_summed = CHECKSUM_NONE;
 				else
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
-- 
1.7.1
