From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] net: use helpers to access mc list
Date: Tue, 26 Jan 2010 15:57:39 +0100
Message-ID: <20100126145738.GA2537@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441Ab0AZO5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 09:57:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the similar helpers as those already done for uc list.
However multicast lists are no list_head lists but "mademanually". The three
macros added by this patch will make the transition of mc_list to list_head
smooth.

>From now on, drivers can (and should) use "netdev_for_each_mc_addr" to iterate
over the addresses with iterator of type "struct netdev_hw_addr". Also macros
"netdev_mc_count" and "netdev_mc_empty" to read list's length. This is the state
which should be reached in all drivers.

Temporary macro "netdev_for_each_mc_addr" works in the ugly way, I'm aware, but
it will be replaced. It uses iterator stored in "struct net_device". In every
iteration, it copies addr from the list to "struct netdev_hw_addr" instance
(also stored in "struct net_device"). Driver reads address stored in this
structure. All is protected by addr_list_lock held by a caller.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 93a32a5..e470b22 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -268,6 +268,18 @@ struct netdev_hw_addr_list {
 #define netdev_for_each_uc_addr(ha, dev) \
 	list_for_each_entry(ha, &dev->uc.list, list)
 
+#define netdev_mc_count(dev) ((dev)->mc_count)
+#define netdev_mc_empty(dev) (netdev_mc_count(dev) == 0)
+
+/* This is ugly, but only temporary. */
+#define netdev_for_each_mc_addr(ha, dev)			\
+	for ((dev)->tmp_mc_iter = (dev)->mc_list,		\
+	     netdev_tmp_mc_addr_cpy(dev),			\
+	     ha = &dev->tmp_mc_ha;				\
+	     (dev)->tmp_mc_iter;				\
+	     (dev)->tmp_mc_iter = (dev)->tmp_mc_iter->next,	\
+	     netdev_tmp_mc_addr_cpy(dev))
+
 struct hh_cache {
 	struct hh_cache *hh_next;	/* Next entry			     */
 	atomic_t	hh_refcnt;	/* number of users                   */
@@ -820,6 +832,8 @@ struct net_device {
 						   mac addresses */
 	int			uc_promisc;
 	spinlock_t		addr_list_lock;
+	struct netdev_hw_addr	tmp_mc_ha;
+	struct dev_addr_list	*tmp_mc_iter;
 	struct dev_addr_list	*mc_list;	/* Multicast mac addresses	*/
 	int			mc_count;	/* Number of installed mcasts	*/
 	unsigned int		promiscuity;
@@ -953,6 +967,15 @@ struct net_device {
 
 #define	NETDEV_ALIGN		32
 
+/* Used and to be used by netdev_for_each_mc_addr. This will disappear. */
+static inline void netdev_tmp_mc_addr_cpy(struct net_device *dev)
+{
+	if (dev->tmp_mc_iter)
+		memcpy(dev->tmp_mc_ha.addr,
+		       dev->tmp_mc_iter->da_addr,
+		       MAX_ADDR_LEN);
+}
+
 static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
