From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] garp: fix a NULL pointer dereference bug
Date: Mon,  4 Mar 2013 11:36:57 +0800
Message-ID: <1362368217-30984-1-git-send-email-amwang@redhat.com>
Cc: bugs@syam.in, David Ward <david.ward@ll.mit.edu>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32567 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755151Ab3CDDhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Mar 2013 22:37:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

A NULL-deref bug was reported in:
https://bugzilla.kernel.org/show_bug.cgi?id=54281
when deleting a vlan interface:

# ip link  del em1.57
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffffa03c356f>] garp_uninit_applicant+0x2f/0xd0 [garp]
...

This is probably app->pdu is NULL'ed in garp_pdu_rcv()
in BH, while garp_uninit_applicant() only holds rtnl lock
which is not enough to prevent this. 

OTOH, garp_pdu_queue() should ways be called with the spin lock.


Reported-by: bugs@syam.in
Cc: bugs@syam.in
Cc: David Ward <david.ward@ll.mit.edu>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
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
