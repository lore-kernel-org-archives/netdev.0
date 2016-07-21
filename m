From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] net/ncsi: avoid maybe-uninitialized warning
Date: Thu, 21 Jul 2016 21:28:34 +0200
Message-ID: <20160721192927.3182806-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Joel Stanley <joel@jms.id.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-4.9 and higher warn about the newly added NSCI code:

net/ncsi/ncsi-manage.c: In function 'ncsi_process_next_channel':
net/ncsi/ncsi-manage.c:1003:2: error: 'old_state' may be used uninitialized in this function [-Werror=maybe-uninitialized]

The warning is a false positive and therefore harmless, but it would be good to
avoid it anyway. I have determined that the barrier in the spin_unlock_irqsave()
is what confuses gcc to the point that it cannot track whether the variable
was unused or not.

This rearranges the code in a way that makes it obvious to gcc that old_state
is always initialized at the time of use, functionally this should not
change anything.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ncsi/ncsi-manage.c | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index d627a39ddcd0..ef017b871857 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -982,23 +982,18 @@ int ncsi_process_next_channel(struct ncsi_dev_priv *ndp)
 	spin_lock_irqsave(&ndp->lock, flags);
 	nc = list_first_or_null_rcu(&ndp->channel_queue,
 				    struct ncsi_channel, link);
-	if (nc) {
-		old_state = xchg(&nc->state, NCSI_CHANNEL_INVISIBLE);
-		list_del_init(&nc->link);
+	if (!nc) {
+		spin_unlock_irqrestore(&ndp->lock, flags);
+		goto out;
 	}
+
+	old_state = xchg(&nc->state, NCSI_CHANNEL_INVISIBLE);
+	list_del_init(&nc->link);
+
 	spin_unlock_irqrestore(&ndp->lock, flags);
 
 	ndp->active_channel = nc;
-	ndp->active_package = nc ? nc->package : NULL;
-	if (!nc) {
-		if (ndp->flags & NCSI_DEV_RESHUFFLE) {
-			ndp->flags &= ~NCSI_DEV_RESHUFFLE;
-			return ncsi_choose_active_channel(ndp);
-		}
-
-		ncsi_report_link(ndp, false);
-		return -ENODEV;
-	}
+	ndp->active_package = nc->package;
 
 	switch (old_state) {
 	case NCSI_CHANNEL_INACTIVE:
@@ -1017,6 +1012,17 @@ int ncsi_process_next_channel(struct ncsi_dev_priv *ndp)
 	}
 
 	return 0;
+
+out:
+	ndp->active_channel = NULL;
+	ndp->active_package = NULL;
+	if (ndp->flags & NCSI_DEV_RESHUFFLE) {
+		ndp->flags &= ~NCSI_DEV_RESHUFFLE;
+		return ncsi_choose_active_channel(ndp);
+	}
+
+	ncsi_report_link(ndp, false);
+	return -ENODEV;
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-- 
2.9.0
