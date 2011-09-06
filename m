From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 3/3 RFC] macvtap: Add support for TUNSETTXFILTER
Date: Tue, 06 Sep 2011 15:35:55 -0700
Message-ID: <20110906223555.6552.50485.stgit@savbu-pc100.cisco.com>
References: <20110906223536.6552.2062.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dragos.tatulea@gmail.com, arnd@arndb.de, mst@redhat.com,
	dwang2@cisco.com, benve@cisco.com, kaber@trash.net, sri@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-2.cisco.com ([173.36.130.13]:3537 "EHLO
	mtv-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab1IFWpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 18:45:21 -0400
In-Reply-To: <20110906223536.6552.2062.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support for TUNSETTXFILTER. Calls macvlan set filter function
with address list and flags received via TUNSETTXFILTER.

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/macvtap.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)


diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index ab96c31..9943683 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -825,6 +825,10 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 	int __user *sp = argp;
 	int s;
 	int ret;
+	u8 *addrs;
+	struct tun_filter tf;
+	unsigned int flags = 0;
+	int alen;
 
 	switch (cmd) {
 	case TUNSETIFF:
@@ -896,6 +900,51 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 			return  -EINVAL;
 		return 0;
 
+	case TUNSETTXFILTER:
+		rcu_read_lock_bh();
+		vlan = rcu_dereference_bh(q->vlan);
+		if (vlan)
+			dev_hold(vlan->dev);
+		rcu_read_unlock_bh();
+
+		if (!vlan)
+			return -ENOLINK;
+
+		if (copy_from_user(&tf, argp, sizeof(tf))) {
+			dev_put(vlan->dev);
+			return -EFAULT;
+		}
+
+		/* XXX: If broadcast address present, set IFF_BROADCAST */
+		/* XXX: If multicast address present, set IFF_MULTICAST */
+		flags |= (tf.flags & TUN_FLT_ALLMULTI ? IFF_ALLMULTI : 0) |
+			 (!tf.count ? IFF_PROMISC : 0);
+		ret = 0;
+		if (tf.count > 0) {
+			alen = ETH_ALEN * tf.count;
+			addrs = kmalloc(alen, GFP_KERNEL);
+			if (!addrs) {
+				dev_put(vlan->dev);
+				return -ENOMEM;
+			}
+
+			if (copy_from_user(addrs, argp + sizeof(tf), alen)) {
+				kfree(addrs);
+				dev_put(vlan->dev);
+				return -EFAULT;
+			}
+		}
+
+		if (tf.count > 0 || flags)
+			ret = macvlan_set_filter(vlan->dev, flags,
+				tf.count, addrs);
+		dev_put(vlan->dev);
+
+		if (tf.count > 0)
+			kfree(addrs);
+
+		return ret;
+
 	default:
 		return -EINVAL;
 	}
