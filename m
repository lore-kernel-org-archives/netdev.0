From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] 802: fix a possible race condition
Date: Wed,  3 Apr 2013 15:52:40 +0800
Message-ID: <1364975560-6812-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	David Ward <david.ward@ll.mit.edu>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54585 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759083Ab3DCHxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Apr 2013 03:53:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

(Resend with a better changelog)

garp_pdu_queue() should ways be called with this spin lock.
garp_uninit_applicant() only holds rtnl lock which is not
enough here.  A possible race can happen as garp_pdu_rcv()
is called in BH context:

	garp_pdu_rcv()
	  |->garp_pdu_parse_msg()
	    |->garp_pdu_parse_attr()
	      |-> garp_gid_event()

Found by code inspection.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: David Ward <david.ward@ll.mit.edu>
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/802/garp.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/802/garp.c b/net/802/garp.c
index 8456f5d..5d9630a 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -609,8 +609,12 @@ void garp_uninit_applicant(struct net_device *dev, struct garp_application *appl
 	/* Delete timer and generate a final TRANSMIT_PDU event to flush out
 	 * all pending messages before the applicant is gone. */
 	del_timer_sync(&app->join_timer);
+
+	spin_lock_bh(&app->lock);
 	garp_gid_event(app, GARP_EVENT_TRANSMIT_PDU);
 	garp_pdu_queue(app);
+	spin_unlock_bh(&app->lock);
+
 	garp_queue_xmit(app);
 
 	dev_mc_del(dev, appl->proto.group_address);
-- 
1.7.7.6
