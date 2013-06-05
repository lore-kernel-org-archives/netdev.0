From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc V3 7/9] macvtap: allow TUNSETIFF to create multiqueue device
Date: Wed,  5 Jun 2013 14:36:30 +0800
Message-ID: <1370414192-5830-8-git-send-email-jasowang@redhat.com>
References: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Though the queue were in fact created by open(), we still need to add this check
to be compatible with tuntap which can let mgmt software use a single API to
manage queues. This patch only validates the device name and moves the TUNSETIFF
to a helper.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |   51 ++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 5ccba99..14764cc 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -869,6 +869,7 @@ out:
 	return ret;
 }
 
+
 static struct macvlan_dev *macvtap_get_vlan(struct macvtap_queue *q)
 {
 	struct macvlan_dev *vlan;
@@ -887,6 +888,44 @@ static void macvtap_put_vlan(struct macvlan_dev *vlan)
 	dev_put(vlan->dev);
 }
 
+static int macvtap_set_iff(struct file *file, struct ifreq __user *ifr_u)
+{
+	struct macvtap_queue *q = file->private_data;
+	struct net *net = current->nsproxy->net_ns;
+	struct inode *inode = file_inode(file);
+	struct net_device *dev, *dev2;
+	struct ifreq ifr;
+
+	if (copy_from_user(&ifr, ifr_u, sizeof(struct ifreq)))
+		return -EFAULT;
+
+	/* To keep the same behavior of tuntap, validate ifr_name */
+	if (ifr.ifr_flags & IFF_MULTI_QUEUE) {
+		dev = __dev_get_by_name(net, ifr.ifr_name);
+		if (!dev)
+			return -EINVAL;
+
+		dev2 = dev_get_by_macvtap_minor(iminor(inode));
+		if (!dev2)
+			return -EINVAL;
+
+		if (dev != dev2) {
+			dev_put(dev2);
+			return -EINVAL;
+		}
+
+		dev_put(dev2);
+	}
+
+	if ((ifr.ifr_flags & ~(IFF_VNET_HDR | IFF_MULTI_QUEUE)) !=
+	    (IFF_NO_PI | IFF_TAP))
+		return -EINVAL;
+	else
+		q->flags = ifr.ifr_flags;
+
+	return 0;
+}
+
 /*
  * provide compatibility with generic tun/tap interface
  */
@@ -905,17 +944,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 
 	switch (cmd) {
 	case TUNSETIFF:
-		/* ignore the name, just look at flags */
-		if (get_user(u, &ifr->ifr_flags))
-			return -EFAULT;
-
-		ret = 0;
-		if ((u & ~IFF_VNET_HDR) != (IFF_NO_PI | IFF_TAP))
-			ret = -EINVAL;
-		else
-			q->flags = u;
-
-		return ret;
+		return macvtap_set_iff(file, ifr);
 
 	case TUNGETIFF:
 		vlan = macvtap_get_vlan(q);
-- 
1.7.1
