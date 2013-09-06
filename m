From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH net] bonding: Avoid possible de-sync with arp_validate
Date: Fri,  6 Sep 2013 14:41:53 -0300
Message-ID: <994d2dc994a801fc3aae7aa912266b09ea45d95c.1378489255.git.mleitner@redhat.com>
Cc: naleksan@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23886 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771Ab3IFRmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 13:42:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Please queue this one for -stable trees too.

Thanks.

---8<---

As bond_store_arp_validation and bond_store_arp_interval doesn't
deal with each other, we can't chain both at bond_open, otherwise
we are open to this de-sync state, steps in sequence:
- bond is down
- arp_interval = 0
- arp_validate = 1 or 2
- bond is up
- arp_interval = 1

This would lead to bond issuing ARP requests but never listening
to the replies, because the tap wasn't attached. After reaching
this state, while bond is up, setting arp_validate won't help
as it only acts if needed.
---
 drivers/net/bonding/bond_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 39e5b1c..805d098 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3180,11 +3180,10 @@ static int bond_open(struct net_device *bond_dev)
 	if (bond->params.miimon)  /* link check interval, in milliseconds. */
 		queue_delayed_work(bond->wq, &bond->mii_work, 0);
 
-	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
+	if (bond->params.arp_interval)    /* arp interval, in milliseconds. */
 		queue_delayed_work(bond->wq, &bond->arp_work, 0);
-		if (bond->params.arp_validate)
-			bond->recv_probe = bond_arp_rcv;
-	}
+	if (bond->params.arp_validate)
+		bond->recv_probe = bond_arp_rcv;
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
-- 
1.8.3.1
