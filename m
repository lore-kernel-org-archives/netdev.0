From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH 1/8] macvtap: fix a possible race between queue selection and changing queues
Date: Thu,  6 Jun 2013 17:54:33 +0800
Message-ID: <1370512480-14272-2-git-send-email-jasowang@redhat.com>
References: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complier may generate codes that re-read the vlan->numvtaps during
macvtap_get_queue(). This may lead a race if vlan->numvtaps were changed in the
same time and which can lead unexpected result (e.g. very huge value).

We need prevent the compiler from generating such codes by adding an
ACCESS_ONCE() to make sure vlan->numvtaps were only read once.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 68efb91..5e485e3 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -172,7 +172,7 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvtap_queue *tap = NULL;
-	int numvtaps = vlan->numvtaps;
+	int numvtaps = ACCESS_ONCE(vlan->numvtaps);
 	__u32 rxq;
 
 	if (!numvtaps)
-- 
1.7.1
