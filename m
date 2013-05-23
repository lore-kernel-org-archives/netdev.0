From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC 3/8] macvtap: introduce macvtap_get_vlan()
Date: Thu, 23 May 2013 11:12:28 +0800
Message-ID: <1369278753-2533-4-git-send-email-jasowang@redhat.com>
References: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369278753-2533-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Factor out the device holding logic to a macvtap_get_vlan(), this will be also
used by multiqueue API.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index ce1c72a..a36e49e 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -890,6 +890,23 @@ out:
 	return ret;
 }
 
+static struct macvlan_dev *macvtap_get_vlan(struct macvtap_queue *q)
+{
+	struct macvlan_dev *vlan;
+	rcu_read_lock_bh();
+	vlan = rcu_dereference_bh(q->vlan);
+	if (vlan)
+		dev_hold(vlan->dev);
+	rcu_read_unlock_bh();
+
+	return vlan;
+}
+
+static void macvtap_put_vlan(struct macvlan_dev *vlan)
+{
+	dev_put(vlan->dev);
+}
+
 /*
  * provide compatibility with generic tun/tap interface
  */
@@ -921,12 +938,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return ret;
 
 	case TUNGETIFF:
-		rcu_read_lock_bh();
-		vlan = rcu_dereference_bh(q->vlan);
-		if (vlan)
-			dev_hold(vlan->dev);
-		rcu_read_unlock_bh();
-
+		vlan = macvtap_get_vlan(q);
 		if (!vlan)
 			return -EBADFD;
 
@@ -934,7 +946,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
 		    put_user(q->flags, &ifr->ifr_flags))
 			ret = -EFAULT;
-		dev_put(vlan->dev);
+		macvtap_put_vlan(vlan);
 		return ret;
 
 	case TUNGETFEATURES:
-- 
1.7.1
