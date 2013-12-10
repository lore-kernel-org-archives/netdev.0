From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net] xen-netback: fix abuse of napi budget
Date: Tue, 10 Dec 2013 10:55:14 +0000
Message-ID: <20131210105514.GL32155@zion.uk.xensource.com>
References: <1386670600-5882-1-git-send-email-paul.durrant@citrix.com>
 <1386671136.11925.46.camel@kazak.uk.xensource.com>
 <52A6ED35.7070003@citrix.com>
 <20131210103736.GJ32155@zion.uk.xensource.com>
 <20131210104443.GK32155@zion.uk.xensource.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD01ABD2E@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59598 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab3LJKzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 05:55:15 -0500
Content-Disposition: inline
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD01ABD2E@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 10:48:13AM +0000, Paul Durrant wrote:
> > -----Original Message-----
> > From: Wei Liu [mailto:wei.liu2@citrix.com]
> > Sent: 10 December 2013 10:45
> > To: David Vrabel
> > Cc: Ian Campbell; Paul Durrant; xen-devel@lists.xen.org;
> > netdev@vger.kernel.org; Wei Liu
> > Subject: Re: [PATCH net] xen-netback: fix abuse of napi budget
> > 
> > On Tue, Dec 10, 2013 at 10:37:36AM +0000, Wei Liu wrote:
> > > On Tue, Dec 10, 2013 at 10:30:13AM +0000, David Vrabel wrote:
> > > > On 10/12/13 10:25, Ian Campbell wrote:
> > > > > On Tue, 2013-12-10 at 10:16 +0000, Paul Durrant wrote:
> > > > >> netback seemed to be somewhat confused about the napi budget
> > parameter and
> > > > >> basically ignored it. This patch fixes that, properly limiting the work
> > done
> > > > >> in each poll.
> > > > >
> > > > > What do you mean "ignored", xenvif_tx_submit seems to be tracking
> > and
> > > > > testing work_done against the budget.
> > > >
> > > > I have seen this warning in net_rx_action() trigger.
> > > >
> > > > 	WARN_ON_ONCE(work > weight);
> > > >
> > > > Which means netback wasn't limiting the work done.
> > > >
> > >
> > > But in the original code work_done is returned by xenvif_tx_submit which
> > > has guard against that situation, right?
> > >
> > 
> > And now I think I spot a bug...
> > 
> >   work_done = xenvif_tx_submit(vif, nr_gops);
> > 
> > The second argument should really be "budget". :-(
> > 
> 
> Yep - that's basically the problem.
> 

So size-wise the attached patch is smaller. Now the only problem is that
is it better to move flow control earlier.

Wei.

---8<---
>From 11db4a9cd7267a621725c48f0e0a99c1d6d31866 Mon Sep 17 00:00:00 2001
From: Wei Liu <wei.liu2@citrix.com>
Date: Tue, 10 Dec 2013 10:49:59 +0000
Subject: [PATCH] xen-netback: correct typo nr_gops -> budget

work_done should be limited by budget not nr_gops. Otherwise we trigger
"WARN_ON_ONCE(work > weight)" in net/dev/core:net_rx_action.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index acf1392..b11f65d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1707,7 +1707,7 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
 
 	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
 
-	work_done = xenvif_tx_submit(vif, nr_gops);
+	work_done = xenvif_tx_submit(vif, budget);
 
 	return work_done;
 }
-- 
1.7.10.4
