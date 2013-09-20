From: Malahal Naineni <malahal@us.ibm.com>
Subject: Re: [PATCH] qlge: call ql_core_dump() only if dump memory was
 allocated.
Date: Fri, 20 Sep 2013 13:57:35 -0500
Message-ID: <20130920185735.GA30419@us.ibm.com>
References: <20130920.120201.1305554403409938708.davem@davemloft.net>
 <1379696386-29573-1-git-send-email-malahal@us.ibm.com>
 <1379700531.2301.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:47356 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753496Ab3ITS5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 14:57:41 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 20 Sep 2013 14:57:40 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B6D56C90045
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 14:57:37 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8KIvbWO66781420
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 18:57:37 GMT
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8KIvaNC008915
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 12:57:37 -0600
Content-Disposition: inline
In-Reply-To: <1379700531.2301.2.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches [joe@perches.com] wrote:
> On Fri, 2013-09-20 at 11:59 -0500, Malahal Naineni wrote:
> > Also changed a log message to indicate that memory was not allocated
> > instead of memory not available!
> []
> > diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
> []
> > @@ -1274,11 +1274,13 @@ void ql_mpi_reset_work(struct work_struct *work)
> >  		return;
> >  	}
> >  
> > -	if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
> > -		netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
> > -		qdev->core_is_dumped = 1;
> > -		queue_delayed_work(qdev->workqueue,
> > -			&qdev->mpi_core_to_log, 5 * HZ);
> > +	if (qdev->mpi_coredump) {
> > +		if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
> > +			netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
> > +			qdev->core_is_dumped = 1;
> > +			queue_delayed_work(qdev->workqueue,
> > +				&qdev->mpi_core_to_log, 5 * HZ);
> > +		}
> 
> This can be done without adding another indentation level
> 
> 	if (qdev->mpi_coredump &&
> 	    !ql_core_dump(qdev, qdev->mpi_coredump)) {
> 
> 

Makes sense! Sending another patch as suggested:


>From b4e1561cb46242c33a77484160f1f1cc3d0e3ffc Mon Sep 17 00:00:00 2001
From: Malahal Naineni <malahal@us.ibm.com>
Date: Fri, 20 Sep 2013 10:18:19 -0500
Subject: [PATCH] qlge: call ql_core_dump() only if dump memory was allocated.

Also changed a log message to indicate that memory was not allocated
instead of memory not available!

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c | 4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_mpi.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
index 10093f0..6bc5db7 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
@@ -740,8 +740,8 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	int i;
 
 	if (!mpi_coredump) {
-		netif_err(qdev, drv, qdev->ndev, "No memory available\n");
-		return -ENOMEM;
+		netif_err(qdev, drv, qdev->ndev, "No memory allocated\n");
+		return -EINVAL;
 	}
 
 	/* Try to get the spinlock, but dont worry if
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
index ff2bf8a..7ad1460 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
@@ -1274,7 +1274,7 @@ void ql_mpi_reset_work(struct work_struct *work)
 		return;
 	}
 
-	if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
+	if (qdev->mpi_coredump && !ql_core_dump(qdev, qdev->mpi_coredump)) {
 		netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
 		qdev->core_is_dumped = 1;
 		queue_delayed_work(qdev->workqueue,
-- 
1.7.11.7
