From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net 4/4] net/ncsi: Improve HNCDSC AEN handler
Date: Thu, 20 Oct 2016 11:45:52 +1100
Message-ID: <1476924352-31165-5-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:38166 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932707AbcJTApL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 20:45:11 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9K0hqwT100442
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:11 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 266f4ctg94-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:45:10 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 20 Oct 2016 10:45:08 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id DD4172CE8056
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:05 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9K0j5Xj16777276
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:05 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9K0j53K019718
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:45:05 +1100
In-Reply-To: <1476924352-31165-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves AEN handler for Host Network Controller Driver Status
Change (HNCDSC):

   * The channel's lock should be hold when accessing its state.
   * Do failover when host driver isn't ready.
   * Configure channel when host driver becomes ready.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 net/ncsi/ncsi-aen.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/ncsi/ncsi-aen.c b/net/ncsi/ncsi-aen.c
index b41a661..6898e72 100644
--- a/net/ncsi/ncsi-aen.c
+++ b/net/ncsi/ncsi-aen.c
@@ -141,23 +141,35 @@ static int ncsi_aen_handler_hncdsc(struct ncsi_dev_priv *ndp,
 		return -ENODEV;
 
 	/* If the channel is active one, we need reconfigure it */
+	spin_lock_irqsave(&nc->lock, flags);
 	ncm = &nc->modes[NCSI_MODE_LINK];
 	hncdsc = (struct ncsi_aen_hncdsc_pkt *)h;
 	ncm->data[3] = ntohl(hncdsc->status);
 	if (!list_empty(&nc->link) ||
-	    nc->state != NCSI_CHANNEL_ACTIVE ||
-	    (ncm->data[3] & 0x1))
+	    nc->state != NCSI_CHANNEL_ACTIVE) {
+		spin_unlock_irqrestore(&nc->lock, flags);
 		return 0;
+	}
 
-	if (ndp->flags & NCSI_DEV_HWA)
+	spin_unlock_irqrestore(&nc->lock, flags);
+	if (!(ndp->flags & NCSI_DEV_HWA) && !(ncm->data[3] & 0x1))
 		ndp->flags |= NCSI_DEV_RESHUFFLE;
 
 	/* If this channel is the active one and the link doesn't
 	 * work, we have to choose another channel to be active one.
 	 * The logic here is exactly similar to what we do when link
 	 * is down on the active channel.
+	 *
+	 * On the other hand, we need configure it when host driver
+	 * state on the active channel becomes ready.
 	 */
 	ncsi_stop_channel_monitor(nc);
+
+	spin_lock_irqsave(&nc->lock, flags);
+	nc->state = (ncm->data[3] & 0x1) ? NCSI_CHANNEL_INACTIVE :
+					   NCSI_CHANNEL_ACTIVE;
+	spin_unlock_irqrestore(&nc->lock, flags);
+
 	spin_lock_irqsave(&ndp->lock, flags);
 	list_add_tail_rcu(&nc->link, &ndp->channel_queue);
 	spin_unlock_irqrestore(&ndp->lock, flags);
-- 
2.1.0
