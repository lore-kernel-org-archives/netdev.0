From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] tuntap: fix a possible race between queue selection and changing queues
Date: Wed,  5 Jun 2013 16:44:57 +0800
Message-ID: <1370421897-30933-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complier may generate codes that re-read the tun->numqueues during
tun_select_queue(). This may be a race if vlan->numqueues were changed in the
same time and can lead unexpected result (e.g. very huge value).

We need prevent the compiler from generating such codes by adding an
ACCESS_ONCE() to make sure tun->numqueues were only read once.

Bug were introduced by commit c8d68e6be1c3b242f1c598595830890b65cea64a
(tuntap: multiqueue support).

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f042b03..adfcde7 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -352,7 +352,7 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
 	u32 numqueues = 0;
 
 	rcu_read_lock();
-	numqueues = tun->numqueues;
+	numqueues = ACCESS_ONCE(tun->numqueues);
 
 	txq = skb_get_rxhash(skb);
 	if (txq) {
-- 
1.7.1
