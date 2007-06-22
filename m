From: Patrick McHardy <kaber@trash.net>
Subject: [NET 02/05]: dev: introduce generic net_device address lists
Date: Fri, 22 Jun 2007 14:24:09 +0200 (MEST)
Message-ID: <20070622122333.15215.96140.sendpatchset@localhost.localdomain>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62394 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbXFVMYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 08:24:10 -0400
In-Reply-To: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: dev: introduce generic net_device address lists

Introduce struct dev_addr_list and list maintenance functions
based on dev_mc_list and the related functions. This will be
used by follow-up patches for both multicast and secondary
unicast addresses.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 6d8fd140951de7cc8faab4922dba74dd1db3cae5
tree b80412116a867d544808f140e76cdf22bbc8b248
parent cdf660f0bd4cca9d2cbe86a31adc60d6fa8a60ec
author Patrick McHardy <kaber@trash.net> Fri, 22 Jun 2007 03:25:26 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 22 Jun 2007 03:25:26 +0200

 include/linux/netdevice.h |   11 +++++++
 net/core/dev.c            |   69 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7913ee..3785a8a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -177,6 +177,14 @@ struct netif_rx_stats
 
 DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
 
+struct dev_addr_list
+{
+	struct dev_addr_list	*next;
+	u8			da_addr[MAX_ADDR_LEN];
+	u8			da_addrlen;
+	int			da_users;
+	int			da_gusers;
+};
 
 /*
  *	We tag multicasts with these structures.
@@ -1004,6 +1012,9 @@ extern void		dev_mc_upload(struct net_device *dev);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern void		dev_mc_discard(struct net_device *dev);
+extern int 		__dev_addr_delete(struct dev_addr_list **list, void *addr, int alen, int all);
+extern int		__dev_addr_add(struct dev_addr_list **list, void *addr, int alen, int newonly);
+extern void		__dev_addr_discard(struct dev_addr_list **list);
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 2609062..1496715 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2551,6 +2551,75 @@ void dev_set_allmulti(struct net_device *dev, int inc)
 		dev_mc_upload(dev);
 }
 
+int __dev_addr_delete(struct dev_addr_list **list, void *addr, int alen,
+		      int glbl)
+{
+	struct dev_addr_list *da;
+
+	for (; (da = *list) != NULL; list = &da->next) {
+		if (memcmp(da->da_addr, addr, da->da_addrlen) == 0 &&
+		    alen == da->da_addrlen) {
+			if (glbl) {
+				int old_glbl = da->da_gusers;
+				da->da_gusers = 0;
+				if (old_glbl == 0)
+					break;
+			}
+			if (--da->da_users)
+				return 0;
+
+			*list = da->next;
+			kfree(da);
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
+int __dev_addr_add(struct dev_addr_list **list, void *addr, int alen, int glbl)
+{
+	struct dev_addr_list *da;
+
+	for (da = *list; da != NULL; da = da->next) {
+		if (memcmp(da->da_addr, addr, da->da_addrlen) == 0 &&
+		    da->da_addrlen == alen) {
+			if (glbl) {
+				int old_glbl = da->da_gusers;
+				da->da_gusers = 1;
+				if (old_glbl)
+					return 0;
+			}
+			da->da_users++;
+			return 0;
+		}
+	}
+
+	da = kmalloc(sizeof(*da), GFP_ATOMIC);
+	if (da == NULL)
+		return -ENOMEM;
+	memcpy(da->da_addr, addr, alen);
+	da->da_addrlen = alen;
+	da->da_users = 1;
+	da->da_gusers = glbl ? 1 : 0;
+	da->next = *list;
+	*list = da;
+	return 0;
+}
+
+void __dev_addr_discard(struct dev_addr_list **list)
+{
+	struct dev_addr_list *tmp;
+
+	while (*list != NULL) {
+		tmp = *list;
+		*list = tmp->next;
+		if (tmp->da_users > tmp->da_gusers)
+			printk("__dev_addr_discard: address leakage! "
+			       "da_users=%d\n", tmp->da_users);
+		kfree(tmp);
+	}
+}
+
 unsigned dev_get_flags(const struct net_device *dev)
 {
 	unsigned flags;
