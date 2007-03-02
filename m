From: Norbert Eicker <n.eicker@fz-juelich.de>
Subject: Re: [PATCH] spidernet: Fix problem sending IP fragments
Date: Fri, 2 Mar 2007 18:39:15 +0100
Message-ID: <200703021839.16158.n.eicker@fz-juelich.de>
References: <200702281521.34277.n.eicker@fz-juelich.de> <1e548a3f0703011452u6dde9c53ifde2fa41fe5f4c38@mail.gmail.com> <20070301233426.GH4717@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chris Engel <chrisengel@gmail.com>, linuxppc-dev@ozlabs.org,
	Adam Emerich <aemerich@us.ibm.com>, netdev@vger.kernel.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zam837.fz-juelich.de ([134.94.100.69]:55627 "HELO
	zam837.fz-juelich.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S2992671AbXCBRjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 12:39:18 -0500
In-Reply-To: <20070301233426.GH4717@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 2.3.2007 00:34, Linas Vepstas wrote:
> On Thu, Mar 01, 2007 at 04:52:54PM -0600, Chris Engel wrote:
> > I tried to apply this patch to 2.6.21-rc2 and CHECKSUM_HW appears
> > to be changed to CHECKSUM_COMPLETE

Oops. I did not test this on the actual 2.6.21-rc2 before sending it.
It worked fine for me on 2.6.18.

In the meantime it tested the patch below on 2.6.21.

> The use of CHECKSUM_HW was replaced by CHECKSUM_PARTIAL and
> CHECKSUM_COMPLETE on a cae-by-case basis, in the patch series leading
> up to 2.6.19.  In this case, I'm not sure which should have been
> used.

In fact CHECKSUM_COMPLETE seems to be used on the receiving side while
CHECKSUM_PARTIAL is the one to be used while sending frames. Thus the
latter is the one to chose.

> Norbert, can you resubmit a patch that applies to a more recent
> kernel? p.s. your emailer replaced tabs by spaces ...

so here's the new one:

Fix problem sending IP fragments on spidernet.

Signed-off-by: Norbert Eicker <n.eicker@fz-juelich.de>
---
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 3b91af8..e3019d5 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -719,7 +719,7 @@ spider_net_prepare_tx_descr(struct spide
			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
	spin_unlock_irqrestore(&chain->lock, flags);

-	if (skb->protocol == htons(ETH_P_IP))
+	if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed == CHECKSUM_PARTIAL)
		switch (skb->nh.iph->protocol) {
		case IPPROTO_TCP:
			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;

