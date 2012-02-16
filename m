From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] vmxnet3: cap copy length at size of skb to prevent dropped frames on tx
Date: Thu, 16 Feb 2012 06:48:56 -0500
Message-ID: <1329392936-14548-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Max Matveev <mmatveev@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45269 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab2BPLta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 06:49:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was recently shown that vmxnet3 devices on transmit, will drop very small udp
frames consistently.  This is due to a regression introduced by commit
39d4a96fd7d2926e46151adbd18b810aeeea8ec0.  This commit attempts to introduce an
optimization to the tx path, indicating that the underlying hardware behaves
optimally when at least 54 bytes of header data are available for direct access.
This causes problems however, if the entire frame is less than 54 bytes long.
The subsequent pskb_may_pull in vmxnet3_parse_and_copy_hdr fails, causing an
error return code, which leads to vmxnet3_tq_xmit dropping the frame.

Fix it by placing a cap on the copy length.  For frames longer than 54 bytes, we
do the pull as we normally would.  If the frame is shorter than that, copy the
whole frame, but no more.  This ensures that we still get the optimization for
qualifying frames, but don't do any damange for frames that are too short.

Also, since I'm unable to do this, it wuold be great if vmware could follow up
this patch with some additional code commentary as to why 54 bytes is an optimal
pull length for a virtual NIC driver.  The comment that introduced this was
vague on that.  Thanks!

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Max Matveev <mmatveev@redhat.com>
CC: Max Matveev <mmatveev@redhat.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Shreyas Bhatewara <sbhatewara@vmware.com>
CC: "VMware, Inc." <pv-drivers@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index e1562e8..adf527e 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -837,8 +837,8 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 				/* for simplicity, don't copy L4 headers */
 				ctx->l4_hdr_size = 0;
 			}
-			ctx->copy_size = ctx->eth_ip_hdr_size +
-					 ctx->l4_hdr_size;
+			ctx->copy_size = min(ctx->eth_ip_hdr_size +
+					 ctx->l4_hdr_size, skb->len);
 		} else {
 			ctx->eth_ip_hdr_size = 0;
 			ctx->l4_hdr_size = 0;
-- 
1.7.7.6
