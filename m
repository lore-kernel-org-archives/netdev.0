From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net/802/mrp: fix possible race condition when calling mrp_pdu_queue()
Date: Thu, 11 Apr 2013 19:47:15 -0400
Message-ID: <1365724035-30220-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>, Cong Wang <amwang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:57508 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731Ab3DKXrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 19:47:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Adapted from a very similar change to net/802/garp.c by Cong Wang.)

mrp_pdu_queue() should ways be called with the applicant spin lock.
mrp_uninit_applicant() only holds the rtnl lock which is not enough;
a race is possible because mrp_rcv() is called in BH context:

	mrp_rcv()
	  |->mrp_pdu_parse_msg()
	    |->mrp_pdu_parse_vecattr()
	      |->mrp_pdu_parse_vecattr_event()
	        |-> mrp_attr_event()
	          |-> mrp_pdu_append_vecattr_event()
	            |-> mrp_pdu_queue()

Cc: Cong Wang <amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/802/mrp.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/802/mrp.c b/net/802/mrp.c
index a4cc322..e085bcc 100644
--- a/net/802/mrp.c
+++ b/net/802/mrp.c
@@ -870,8 +870,12 @@ void mrp_uninit_applicant(struct net_device *dev, struct mrp_application *appl)
 	 * all pending messages before the applicant is gone.
 	 */
 	del_timer_sync(&app->join_timer);
+
+	spin_lock(&app->lock);
 	mrp_mad_event(app, MRP_EVENT_TX);
 	mrp_pdu_queue(app);
+	spin_unlock(&app->lock);
+
 	mrp_queue_xmit(app);
 
 	dev_mc_del(dev, appl->group_address);
-- 
1.7.1
