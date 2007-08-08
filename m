From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [patch] ipvs: force read of atomic_t in while loop
Date: Wed, 8 Aug 2007 11:33:00 +0200
Message-ID: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:16787 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758289AbXHHJdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 05:33:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>

For architectures that don't have a volatile atomic_ts constructs like
while (atomic_read(&something)); might result in endless loops since a
barrier() is missing which forces the compiler to generate code that
actually reads memory contents.
Fix this in ipvs by using the IP_VS_WAIT_WHILE macro which resolves to
while (expr) { cpu_relax(); }
(why isn't this open coded btw?)

Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>
Cc: David Miller <davem@davemloft.net>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---

Just saw this while grepping for atomic_reads in a while loops.
Maybe we should re-add the volatile to atomic_t. Not sure.

 net/ipv4/ipvs/ip_vs_ctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c
+++ linux-2.6/net/ipv4/ipvs/ip_vs_ctl.c
@@ -909,7 +909,7 @@ ip_vs_edit_dest(struct ip_vs_service *sv
 	write_lock_bh(&__ip_vs_svc_lock);
 
 	/* Wait until all other svc users go away */
-	while (atomic_read(&svc->usecnt) > 1) {};
+	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
 
 	/* call the update_service, because server weight may be changed */
 	svc->scheduler->update_service(svc);
