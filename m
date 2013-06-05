From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc V3 4/9] macvtap: introduce macvtap_get_vlan()
Date: Wed,  5 Jun 2013 14:36:27 +0800
Message-ID: <1370414192-5830-5-git-send-email-jasowang@redhat.com>
References: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477Ab3FEGrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 02:47:14 -0400
In-Reply-To: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor out the device holding logic to a macvtap_get_vlan(), this will be also
used by multiqueue API.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 8949631..d18130b 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -893,6 +893,24 @@ out:
 	return ret;
 }
 
+static struct macvlan_dev *macvtap_get_vlan(struct macvtap_queue *q)
+{
+	struct macvlan_dev *vlan;
+
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
@@ -924,12 +942,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
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
 			return -ENOLINK;
 
@@ -937,7 +950,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
 		    put_user(q->flags, &ifr->ifr_flags))
 			ret = -EFAULT;
-		dev_put(vlan->dev);
+		macvtap_put_vlan(vlan);
 		return ret;
 
 	case TUNGETFEATURES:
-- 
1.7.1
