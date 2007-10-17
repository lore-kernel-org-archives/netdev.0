From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: BNX2X driver: kernel panic when running netperf
Date: Wed, 17 Oct 2007 13:46:02 +0200
Message-ID: <1192621562.29746.200.camel@eliezer>
References: <1192577680.5730.12.camel@w-amax.beaverton.ibm.com>
 <20071016.164938.66177554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>
To: masbock@us.ibm.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1926 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757937AbXJQLod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 07:44:33 -0400
In-Reply-To: <20071016.164938.66177554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-16 at 16:49 -0700, David Miller wrote:
> From: Max Asbock <masbock@us.ibm.com>
> Date: Tue, 16 Oct 2007 16:34:40 -0700
> 
> > I tested the bnx2x driver (0001-BNX2X-0.40.10a-net-2.6.24.patch)
> with
> > netdev-2.6.24 git tree and found that I can reproducibly panic the
> > system when running netperf with the TCP_STREAM test.
> > I copied the following information from the panic message:
> > RIP: 0xc02fff32
> > net_rx_action +0x142/0x190
> 
> The driver is doing netif_rx_complete() yet returning a value from
> ->poll() which is >= budget, which is illegal.
> 
> We had to fix a similar bug in the tg3 and bnx2 drivers, the same
> logic probably just propagated itself into bnx2x.

I think that this will fix the bug.

This is a diff against 0.40.10a.
I hope to get a new version out soon, once we finish working on Dave's
comments.

Eliezer


---
 drivers/net/bnx2x.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index f462c74..9220bd3 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -8085,9 +8085,10 @@ #endif
 		work_done = bnx2x_rx_int(fp, budget);
 	}
 
-	rmb(); /* TBD check */
+	rmb(); /* bnx2x_has_work() reads the status block */
 
-	if (!bnx2x_has_work(fp)) {
+	/* must not complete if we consumed full budget */
+	if ((work_done < budget) && !bnx2x_has_work(fp)) {
 		netif_rx_complete(bp->dev, napi);
 
 		bnx2x_ack_sb(bp, fp->index, USTORM_ID, fp->fp_u_idx,
-- 
1.4.2



