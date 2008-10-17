From: Roland Dreier <rdreier@cisco.com>
Subject: cxgb3: Fix kernel crash caused by uninitialized l2t_entry.arpq
Date: Fri, 17 Oct 2008 14:18:26 -0700
Message-ID: <ada63nqsyxp.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, divy@chelsio.com, davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:4360 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbYJQVS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 17:18:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 147e70e6 ("cxgb3: Use SKB list interfaces instead of home-grown
implementation.") causes a crash in t3_l2t_send_slow() when an iWARP
connection request is received.  This is because the new l2t_entry.arpq
skb queue is never initialized, and therefore trying to add an skb to
it causes a NULL dereference.  With the old code there was no need to
initialize the queues because the l2t_entry structures were zeroed,
and the code used NULL to mean empty.

Fix this by adding __skb_queue_head_init() when all the l2t_entry
structures get allocated.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
This should probably go to -stable as well, since it looks like the
commit that broke things went into 2.6.27-rc6.

 drivers/net/cxgb3/l2t.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 4407ac9..ff1611f 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -431,6 +431,7 @@ struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
 	for (i = 0; i < l2t_capacity; ++i) {
 		d->l2tab[i].idx = i;
 		d->l2tab[i].state = L2T_STATE_UNUSED;
+		__skb_queue_head_init(&d->l2tab[i].arpq);
 		spin_lock_init(&d->l2tab[i].lock);
 		atomic_set(&d->l2tab[i].refcnt, 0);
 	}
