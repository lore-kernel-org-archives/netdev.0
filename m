From: Byron Bradley <byron.bbradley@gmail.com>
Subject: Re: [PATCH] mv643xx_eth: fix byte order when checksum offload is
 enabled
Date: Sun, 20 Jan 2008 15:05:54 +0000 (GMT)
Message-ID: <alpine.DEB.0.99.0801201459510.12279@git.byronbradley.co.uk>
References: <1200770858-11456-1-git-send-email-byron.bbradley@gmail.com>
 <20080119200900.GE27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>, netdev@vger.kernel.org,
	hvr@gnu.org, akpm@linux-foundation.org,
	Dale Farnsworth <dale@farnsworth.org>,
	Manish Lachwani <mlachwani@mvista.com>,
	Tzachi Perelstein <tzachi@marvell.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:6369 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690AbYATPGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 10:06:07 -0500
Received: by mu-out-0910.google.com with SMTP id i10so6090864mue.5
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 07:06:05 -0800 (PST)
In-Reply-To: <20080119200900.GE27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell Orion system on chips have an integrated mv643xx MAC.
On these little endian ARM devices mv643xx will oops when checksum
offload is enabled. Swapping the byte order of the protocol and
checksum solves this problem.

Signed-off-by: Byron Bradley <byron.bbradley@gmail.com>
Cc: Dale Farnsworth <dale@farnsworth.org>
Cc: Manish Lachwani <mlachwani@mvista.com>
---

Resubmitted after comments from Al Viro. udp_hdr(skb)->check returns
a __sum16 so I have called the function sum16_as_be(). Again lightly
tested only on two Marvell Orion boards.

 drivers/net/mv643xx_eth.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 651c269..b528ce7 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1652,6 +1652,11 @@ static void eth_tx_fill_frag_descs(struct mv643xx_private *mp,
 	}
 }

+static inline __be16 sum16_as_be(__sum16 sum)
+{
+	return (__force __be16)sum;
+}
+
 /**
  * eth_tx_submit_descs_for_skb - submit data from an skb to the tx hw
  *
@@ -1689,7 +1694,7 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);

 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		BUG_ON(skb->protocol != ETH_P_IP);
+		BUG_ON(skb->protocol != htons(ETH_P_IP));

 		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
 			   ETH_GEN_IP_V_4_CHECKSUM  |
@@ -1698,10 +1703,10 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
 			cmd_sts |= ETH_UDP_FRAME;
-			desc->l4i_chk = udp_hdr(skb)->check;
+			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
 			break;
 		case IPPROTO_TCP:
-			desc->l4i_chk = tcp_hdr(skb)->check;
+			desc->l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
 			break;
 		default:
 			BUG();
-- 
1.5.4.rc2.38.gd6da3


