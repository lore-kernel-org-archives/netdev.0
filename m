From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 2/4] net: addr_list: add exclusive dev_uc_add
Date: Fri, 09 Mar 2012 14:48:01 -0800
Message-ID: <20120309224801.2514.18418.stgit@jf-dev1-dcblab>
References: <20120309223621.2514.82321.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, roprabhu@cisco.com, netdev@vger.kernel.org,
	mst@redhat.com, chrisw@redhat.com, davem@davemloft.net,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	chealy@imsco-us.com
To: jhs@mojatatu.com, shemminger@vyatta.com, bhutchings@solarflare.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120309223621.2514.82321.stgit@jf-dev1-dcblab>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index 3963992..7e4a86f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2553,6 +2553,7 @@ extern int dev_addr_init(struct net_device *dev);
 
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

