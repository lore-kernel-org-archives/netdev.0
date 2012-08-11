From: Denis Efremov <yefremov.denis@gmail.com>
Subject: [PATCH] macvtap: rcu_dereference outside read-lock section
Date: Sat, 11 Aug 2012 14:05:27 +0400
Message-ID: <1344679527-13377-1-git-send-email-yefremov.denis@gmail.com>
Cc: Denis Efremov <yefremov.denis@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In this case it is not an error. rcu_dereference
occurs in update section. Replacement by
rcu_dereference_protected (with spinlock) in order to
prevent lockdep complaint.

Found by Linux Driver Verification project (linuxtesting.org)

Signed-off-by: Denis Efremov <yefremov.denis@gmail.com>
---
 drivers/net/macvtap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0737bd4..8ef11a8 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -94,7 +94,8 @@ static int get_slot(struct macvlan_dev *vlan, struct macvtap_queue *q)
 	int i;
 
 	for (i = 0; i < MAX_MACVTAP_QUEUES; i++) {
-		if (rcu_dereference(vlan->taps[i]) == q)
+		if (rcu_dereference_protected(vlan->taps[i],
+				lockdep_is_held(&macvtap_lock)) == q)
 			return i;
 	}
 
-- 
1.7.7
