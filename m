From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v0 2/5] net: addr_list: add exclusive dev_uc_add
Date: Sun, 18 Mar 2012 23:51:57 -0700
Message-ID: <20120319065157.10959.32215.stgit@jf-dev1-dcblab>
References: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	chealy@imsco-us.com
To: jhs@mojatatu.com, shemminger@vyatta.com, bhutchings@solarflare.com,
	roprabhu@cisco.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2554 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758051Ab2CSHE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 03:04:26 -0400
In-Reply-To: <20120319064719.10959.93361.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a dev_uc_add_excl() call similar to the original
dev_uc_add() except it sets the global bit. With this
change the reference count will not be bumped and -EEXIST
will be returned if a duplicate address exists.

This is useful for drivers that support SR-IOV and want
to manage the unicast lists.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/netdevice.h |    1 +
 net/core/dev_addr_lists.c |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4208901..5e43cec 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2571,6 +2571,7 @@ extern int dev_addr_init(struct net_device *dev);
 
 /* Functions used for unicast addresses handling */
 extern int dev_uc_add(struct net_device *dev, unsigned char *addr);
+extern int dev_uc_add_excl(struct net_device *dev, unsigned char *addr);
 extern int dev_uc_del(struct net_device *dev, unsigned char *addr);
 extern int dev_uc_sync(struct net_device *to, struct net_device *from);
 extern void dev_uc_unsync(struct net_device *to, struct net_device *from);
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 29c07fe..c7d27ad 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -377,6 +377,25 @@ EXPORT_SYMBOL(dev_addr_del_multiple);
  */
 
 /**
+ *	dev_uc_add_excl - Add a global secondary unicast address
+ *	@dev: device
+ *	@addr: address to add
+ */
+int dev_uc_add_excl(struct net_device *dev, unsigned char *addr)
+{
+	int err;
+
+	netif_addr_lock_bh(dev);
+	err = __hw_addr_add_ex(&dev->uc, addr, dev->addr_len,
+			       NETDEV_HW_ADDR_T_UNICAST, true);
+	if (!err)
+		__dev_set_rx_mode(dev);
+	netif_addr_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_uc_add_excl);
+
+/**
  *	dev_uc_add - Add a secondary unicast address
  *	@dev: device
  *	@addr: address to add
