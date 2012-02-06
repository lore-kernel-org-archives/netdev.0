From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] bnx2x: Fix mem leak in bnx2x_tpa_stop() if build_skb()
 fails.
Date: Mon, 6 Feb 2012 22:28:21 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1202062224210.20532@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eliezer Tamir <eliezert@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We allocate memory for 'new_data' with kmalloc(). If we get the memory
we then try to build_skb() and if that should fail (which it can) we
do not enter 'if (likely(skb)) {' and actually use 'new_data' but
instead fall through to the 'drop:' label and end up returning from
the function without ever assigning 'new'data' to anything or freeing
it. That leaks the memory allocated to 'new_data'.

This patch fixes the memory leak by doing a kfree(new_data) in the
case where build_skb() fails (or where allocation of 'new_data' itself
fails, but in taht case it's just a harmless kfree(NULL)).

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

 No hardware to test, so compile tested only.

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 03f3935..7aee469 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -523,7 +523,6 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		skb = build_skb(data);
 
 	if (likely(skb)) {
-
 #ifdef BNX2X_STOP_ON_ERROR
 		if (pad + len > fp->rx_buf_size) {
 			BNX2X_ERR("skb_put is about to fail...  "
@@ -557,7 +556,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		return;
 	}
-
+	kfree(new_data);
 drop:
 	/* drop the packet and keep the buffer in the bin */
 	DP(NETIF_MSG_RX_STATUS,
-- 
1.7.9


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
