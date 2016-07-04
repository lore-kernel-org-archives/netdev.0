From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 03/11] batman-adv: split tvlv into a separate
	file
Date: Mon,  4 Jul 2016 15:02:51 +0200
Message-ID: <1467637379-6089-4-git-send-email-sw@simonwunderlich.de>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467637379-6089-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

The tvlv functionality in main.c is mostly unrelated to the rest of the
content. It still takes up a large portion of this source file (~45%, 588
lines). Moving it to a separate file makes it better visible as a main
component of the batman-adv implementation and hides it less in the other
helper functions in main.c

Signed-off-by: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
[sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org: fix conflicts with current version, fix includes,
rewrote commit message]
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/Makefile                |   1 +
 net/batman-adv/bat_iv_ogm.c            |   1 +
 net/batman-adv/bat_v_ogm.c             |   1 +
 net/batman-adv/distributed-arp-table.c |   1 +
 net/batman-adv/gateway_common.c        |   1 +
 net/batman-adv/main.c                  | 591 -------------------------------
 net/batman-adv/main.h                  |  34 --
 net/batman-adv/multicast.c             |   1 +
 net/batman-adv/network-coding.c        |   1 +
 net/batman-adv/routing.c               |   1 +
 net/batman-adv/translation-table.c     |   1 +
 net/batman-adv/tvlv.c                  | 630 +++++++++++++++++++++++++++++++++
 net/batman-adv/tvlv.h                  |  61 ++++
 13 files changed, 700 insertions(+), 625 deletions(-)
 create mode 100644 net/batman-adv/tvlv.c
 create mode 100644 net/batman-adv/tvlv.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 797cf2f..5c6ece0 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -40,3 +40,4 @@ batman-adv-y += send.o
 batman-adv-y += soft-interface.o
 batman-adv-y += sysfs.o
 batman-adv-y += translation-table.o
+batman-adv-y += tvlv.o
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 6dc89b0..948a5b4 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -58,6 +58,7 @@
 #include "routing.h"
 #include "send.h"
 #include "translation-table.h"
+#include "tvlv.h"
 
 static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work);
 
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 23ea9bf..ca5a679 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -46,6 +46,7 @@
 #include "routing.h"
 #include "send.h"
 #include "translation-table.h"
+#include "tvlv.h"
 
 /**
  * batadv_v_ogm_orig_get - retrieve and possibly create an originator node
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 278800a..584b827 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -48,6 +48,7 @@
 #include "originator.h"
 #include "send.h"
 #include "translation-table.h"
+#include "tvlv.h"
 
 static void batadv_dat_purge(struct work_struct *work);
 
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 7754435..6a6f2d4 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -29,6 +29,7 @@
 
 #include "gateway_client.h"
 #include "packet.h"
+#include "tvlv.h"
 
 /**
  * batadv_parse_throughput - parse supplied string buffer to extract throughput
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 627d14e..225d63e 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -31,16 +31,13 @@
 #include <linux/kernel.h>
 #include <linux/kref.h>
 #include <linux/list.h>
-#include <linux/lockdep.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/netdevice.h>
-#include <linux/pkt_sched.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
 #include <linux/seq_file.h>
 #include <linux/skbuff.h>
-#include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
@@ -642,594 +639,6 @@ __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr)
 }
 
 /**
- * batadv_tvlv_handler_release - release tvlv handler from lists and queue for
- *  free after rcu grace period
- * @ref: kref pointer of the tvlv
- */
-static void batadv_tvlv_handler_release(struct kref *ref)
-{
-	struct batadv_tvlv_handler *tvlv_handler;
-
-	tvlv_handler = container_of(ref, struct batadv_tvlv_handler, refcount);
-	kfree_rcu(tvlv_handler, rcu);
-}
-
-/**
- * batadv_tvlv_handler_put - decrement the tvlv container refcounter and
- *  possibly release it
- * @tvlv_handler: the tvlv handler to free
- */
-static void batadv_tvlv_handler_put(struct batadv_tvlv_handler *tvlv_handler)
-{
-	kref_put(&tvlv_handler->refcount, batadv_tvlv_handler_release);
-}
-
-/**
- * batadv_tvlv_handler_get - retrieve tvlv handler from the tvlv handler list
- *  based on the provided type and version (both need to match)
- * @bat_priv: the bat priv with all the soft interface information
- * @type: tvlv handler type to look for
- * @version: tvlv handler version to look for
- *
- * Return: tvlv handler if found or NULL otherwise.
- */
-static struct batadv_tvlv_handler *
-batadv_tvlv_handler_get(struct batadv_priv *bat_priv, u8 type, u8 version)
-{
-	struct batadv_tvlv_handler *tvlv_handler_tmp, *tvlv_handler = NULL;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(tvlv_handler_tmp,
-				 &bat_priv->tvlv.handler_list, list) {
-		if (tvlv_handler_tmp->type != type)
-			continue;
-
-		if (tvlv_handler_tmp->version != version)
-			continue;
-
-		if (!kref_get_unless_zero(&tvlv_handler_tmp->refcount))
-			continue;
-
-		tvlv_handler = tvlv_handler_tmp;
-		break;
-	}
-	rcu_read_unlock();
-
-	return tvlv_handler;
-}
-
-/**
- * batadv_tvlv_container_release - release tvlv from lists and free
- * @ref: kref pointer of the tvlv
- */
-static void batadv_tvlv_container_release(struct kref *ref)
-{
-	struct batadv_tvlv_container *tvlv;
-
-	tvlv = container_of(ref, struct batadv_tvlv_container, refcount);
-	kfree(tvlv);
-}
-
-/**
- * batadv_tvlv_container_put - decrement the tvlv container refcounter and
- *  possibly release it
- * @tvlv: the tvlv container to free
- */
-static void batadv_tvlv_container_put(struct batadv_tvlv_container *tvlv)
-{
-	kref_put(&tvlv->refcount, batadv_tvlv_container_release);
-}
-
-/**
- * batadv_tvlv_container_get - retrieve tvlv container from the tvlv container
- *  list based on the provided type and version (both need to match)
- * @bat_priv: the bat priv with all the soft interface information
- * @type: tvlv container type to look for
- * @version: tvlv container version to look for
- *
- * Has to be called with the appropriate locks being acquired
- * (tvlv.container_list_lock).
- *
- * Return: tvlv container if found or NULL otherwise.
- */
-static struct batadv_tvlv_container *
-batadv_tvlv_container_get(struct batadv_priv *bat_priv, u8 type, u8 version)
-{
-	struct batadv_tvlv_container *tvlv_tmp, *tvlv = NULL;
-
-	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
-
-	hlist_for_each_entry(tvlv_tmp, &bat_priv->tvlv.container_list, list) {
-		if (tvlv_tmp->tvlv_hdr.type != type)
-			continue;
-
-		if (tvlv_tmp->tvlv_hdr.version != version)
-			continue;
-
-		kref_get(&tvlv_tmp->refcount);
-		tvlv = tvlv_tmp;
-		break;
-	}
-
-	return tvlv;
-}
-
-/**
- * batadv_tvlv_container_list_size - calculate the size of the tvlv container
- *  list entries
- * @bat_priv: the bat priv with all the soft interface information
- *
- * Has to be called with the appropriate locks being acquired
- * (tvlv.container_list_lock).
- *
- * Return: size of all currently registered tvlv containers in bytes.
- */
-static u16 batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
-{
-	struct batadv_tvlv_container *tvlv;
-	u16 tvlv_len = 0;
-
-	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
-
-	hlist_for_each_entry(tvlv, &bat_priv->tvlv.container_list, list) {
-		tvlv_len += sizeof(struct batadv_tvlv_hdr);
-		tvlv_len += ntohs(tvlv->tvlv_hdr.len);
-	}
-
-	return tvlv_len;
-}
-
-/**
- * batadv_tvlv_container_remove - remove tvlv container from the tvlv container
- *  list
- * @bat_priv: the bat priv with all the soft interface information
- * @tvlv: the to be removed tvlv container
- *
- * Has to be called with the appropriate locks being acquired
- * (tvlv.container_list_lock).
- */
-static void batadv_tvlv_container_remove(struct batadv_priv *bat_priv,
-					 struct batadv_tvlv_container *tvlv)
-{
-	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
-
-	if (!tvlv)
-		return;
-
-	hlist_del(&tvlv->list);
-
-	/* first call to decrement the counter, second call to free */
-	batadv_tvlv_container_put(tvlv);
-	batadv_tvlv_container_put(tvlv);
-}
-
-/**
- * batadv_tvlv_container_unregister - unregister tvlv container based on the
- *  provided type and version (both need to match)
- * @bat_priv: the bat priv with all the soft interface information
- * @type: tvlv container type to unregister
- * @version: tvlv container type to unregister
- */
-void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
-				      u8 type, u8 version)
-{
-	struct batadv_tvlv_container *tvlv;
-
-	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
-	tvlv = batadv_tvlv_container_get(bat_priv, type, version);
-	batadv_tvlv_container_remove(bat_priv, tvlv);
-	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
-}
-
-/**
- * batadv_tvlv_container_register - register tvlv type, version and content
- *  to be propagated with each (primary interface) OGM
- * @bat_priv: the bat priv with all the soft interface information
- * @type: tvlv container type
- * @version: tvlv container version
- * @tvlv_value: tvlv container content
- * @tvlv_value_len: tvlv container content length
- *
- * If a container of the same type and version was already registered the new
- * content is going to replace the old one.
- */
-void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
-				    u8 type, u8 version,
-				    void *tvlv_value, u16 tvlv_value_len)
-{
-	struct batadv_tvlv_container *tvlv_old, *tvlv_new;
-
-	if (!tvlv_value)
-		tvlv_value_len = 0;
-
-	tvlv_new = kzalloc(sizeof(*tvlv_new) + tvlv_value_len, GFP_ATOMIC);
-	if (!tvlv_new)
-		return;
-
-	tvlv_new->tvlv_hdr.version = version;
-	tvlv_new->tvlv_hdr.type = type;
-	tvlv_new->tvlv_hdr.len = htons(tvlv_value_len);
-
-	memcpy(tvlv_new + 1, tvlv_value, ntohs(tvlv_new->tvlv_hdr.len));
-	INIT_HLIST_NODE(&tvlv_new->list);
-	kref_init(&tvlv_new->refcount);
-
-	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
-	tvlv_old = batadv_tvlv_container_get(bat_priv, type, version);
-	batadv_tvlv_container_remove(bat_priv, tvlv_old);
-	hlist_add_head(&tvlv_new->list, &bat_priv->tvlv.container_list);
-	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
-}
-
-/**
- * batadv_tvlv_realloc_packet_buff - reallocate packet buffer to accommodate
- *  requested packet size
- * @packet_buff: packet buffer
- * @packet_buff_len: packet buffer size
- * @min_packet_len: requested packet minimum size
- * @additional_packet_len: requested additional packet size on top of minimum
- *  size
- *
- * Return: true of the packet buffer could be changed to the requested size,
- * false otherwise.
- */
-static bool batadv_tvlv_realloc_packet_buff(unsigned char **packet_buff,
-					    int *packet_buff_len,
-					    int min_packet_len,
-					    int additional_packet_len)
-{
-	unsigned char *new_buff;
-
-	new_buff = kmalloc(min_packet_len + additional_packet_len, GFP_ATOMIC);
-
-	/* keep old buffer if kmalloc should fail */
-	if (!new_buff)
-		return false;
-
-	memcpy(new_buff, *packet_buff, min_packet_len);
-	kfree(*packet_buff);
-	*packet_buff = new_buff;
-	*packet_buff_len = min_packet_len + additional_packet_len;
-
-	return true;
-}
-
-/**
- * batadv_tvlv_container_ogm_append - append tvlv container content to given
- *  OGM packet buffer
- * @bat_priv: the bat priv with all the soft interface information
- * @packet_buff: ogm packet buffer
- * @packet_buff_len: ogm packet buffer size including ogm header and tvlv
- *  content
- * @packet_min_len: ogm header size to be preserved for the OGM itself
- *
- * The ogm packet might be enlarged or shrunk depending on the current size
- * and the size of the to-be-appended tvlv containers.
- *
- * Return: size of all appended tvlv containers in bytes.
- */
-u16 batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
-				     unsigned char **packet_buff,
-				     int *packet_buff_len, int packet_min_len)
-{
-	struct batadv_tvlv_container *tvlv;
-	struct batadv_tvlv_hdr *tvlv_hdr;
-	u16 tvlv_value_len;
-	void *tvlv_value;
-	bool ret;
-
-	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
-	tvlv_value_len = batadv_tvlv_container_list_size(bat_priv);
-
-	ret = batadv_tvlv_realloc_packet_buff(packet_buff, packet_buff_len,
-					      packet_min_len, tvlv_value_len);
-
-	if (!ret)
-		goto end;
-
-	if (!tvlv_value_len)
-		goto end;
-
-	tvlv_value = (*packet_buff) + packet_min_len;
-
-	hlist_for_each_entry(tvlv, &bat_priv->tvlv.container_list, list) {
-		tvlv_hdr = tvlv_value;
-		tvlv_hdr->type = tvlv->tvlv_hdr.type;
-		tvlv_hdr->version = tvlv->tvlv_hdr.version;
-		tvlv_hdr->len = tvlv->tvlv_hdr.len;
-		tvlv_value = tvlv_hdr + 1;
-		memcpy(tvlv_value, tvlv + 1, ntohs(tvlv->tvlv_hdr.len));
-		tvlv_value = (u8 *)tvlv_value + ntohs(tvlv->tvlv_hdr.len);
-	}
-
-end:
-	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
-	return tvlv_value_len;
-}
-
-/**
- * batadv_tvlv_call_handler - parse the given tvlv buffer to call the
- *  appropriate handlers
- * @bat_priv: the bat priv with all the soft interface information
- * @tvlv_handler: tvlv callback function handling the tvlv content
- * @ogm_source: flag indicating whether the tvlv is an ogm or a unicast packet
- * @orig_node: orig node emitting the ogm packet
- * @src: source mac address of the unicast packet
- * @dst: destination mac address of the unicast packet
- * @tvlv_value: tvlv content
- * @tvlv_value_len: tvlv content length
- *
- * Return: success if handler was not found or the return value of the handler
- * callback.
- */
-static int batadv_tvlv_call_handler(struct batadv_priv *bat_priv,
-				    struct batadv_tvlv_handler *tvlv_handler,
-				    bool ogm_source,
-				    struct batadv_orig_node *orig_node,
-				    u8 *src, u8 *dst,
-				    void *tvlv_value, u16 tvlv_value_len)
-{
-	if (!tvlv_handler)
-		return NET_RX_SUCCESS;
-
-	if (ogm_source) {
-		if (!tvlv_handler->ogm_handler)
-			return NET_RX_SUCCESS;
-
-		if (!orig_node)
-			return NET_RX_SUCCESS;
-
-		tvlv_handler->ogm_handler(bat_priv, orig_node,
-					  BATADV_NO_FLAGS,
-					  tvlv_value, tvlv_value_len);
-		tvlv_handler->flags |= BATADV_TVLV_HANDLER_OGM_CALLED;
-	} else {
-		if (!src)
-			return NET_RX_SUCCESS;
-
-		if (!dst)
-			return NET_RX_SUCCESS;
-
-		if (!tvlv_handler->unicast_handler)
-			return NET_RX_SUCCESS;
-
-		return tvlv_handler->unicast_handler(bat_priv, src,
-						     dst, tvlv_value,
-						     tvlv_value_len);
-	}
-
-	return NET_RX_SUCCESS;
-}
-
-/**
- * batadv_tvlv_containers_process - parse the given tvlv buffer to call the
- *  appropriate handlers
- * @bat_priv: the bat priv with all the soft interface information
- * @ogm_source: flag indicating whether the tvlv is an ogm or a unicast packet
- * @orig_node: orig node emitting the ogm packet
- * @src: source mac address of the unicast packet
- * @dst: destination mac address of the unicast packet
- * @tvlv_value: tvlv content
- * @tvlv_value_len: tvlv content length
- *
- * Return: success when processing an OGM or the return value of all called
- * handler callbacks.
- */
-int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
-				   bool ogm_source,
-				   struct batadv_orig_node *orig_node,
-				   u8 *src, u8 *dst,
-				   void *tvlv_value, u16 tvlv_value_len)
-{
-	struct batadv_tvlv_handler *tvlv_handler;
-	struct batadv_tvlv_hdr *tvlv_hdr;
-	u16 tvlv_value_cont_len;
-	u8 cifnotfound = BATADV_TVLV_HANDLER_OGM_CIFNOTFND;
-	int ret = NET_RX_SUCCESS;
-
-	while (tvlv_value_len >= sizeof(*tvlv_hdr)) {
-		tvlv_hdr = tvlv_value;
-		tvlv_value_cont_len = ntohs(tvlv_hdr->len);
-		tvlv_value = tvlv_hdr + 1;
-		tvlv_value_len -= sizeof(*tvlv_hdr);
-
-		if (tvlv_value_cont_len > tvlv_value_len)
-			break;
-
-		tvlv_handler = batadv_tvlv_handler_get(bat_priv,
-						       tvlv_hdr->type,
-						       tvlv_hdr->version);
-
-		ret |= batadv_tvlv_call_handler(bat_priv, tvlv_handler,
-						ogm_source, orig_node,
-						src, dst, tvlv_value,
-						tvlv_value_cont_len);
-		if (tvlv_handler)
-			batadv_tvlv_handler_put(tvlv_handler);
-		tvlv_value = (u8 *)tvlv_value + tvlv_value_cont_len;
-		tvlv_value_len -= tvlv_value_cont_len;
-	}
-
-	if (!ogm_source)
-		return ret;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(tvlv_handler,
-				 &bat_priv->tvlv.handler_list, list) {
-		if ((tvlv_handler->flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND) &&
-		    !(tvlv_handler->flags & BATADV_TVLV_HANDLER_OGM_CALLED))
-			tvlv_handler->ogm_handler(bat_priv, orig_node,
-						  cifnotfound, NULL, 0);
-
-		tvlv_handler->flags &= ~BATADV_TVLV_HANDLER_OGM_CALLED;
-	}
-	rcu_read_unlock();
-
-	return NET_RX_SUCCESS;
-}
-
-/**
- * batadv_tvlv_ogm_receive - process an incoming ogm and call the appropriate
- *  handlers
- * @bat_priv: the bat priv with all the soft interface information
- * @batadv_ogm_packet: ogm packet containing the tvlv containers
- * @orig_node: orig node emitting the ogm packet
- */
-void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
-			     struct batadv_ogm_packet *batadv_ogm_packet,
-			     struct batadv_orig_node *orig_node)
-{
-	void *tvlv_value;
-	u16 tvlv_value_len;
-
-	if (!batadv_ogm_packet)
-		return;
-
-	tvlv_value_len = ntohs(batadv_ogm_packet->tvlv_len);
-	if (!tvlv_value_len)
-		return;
-
-	tvlv_value = batadv_ogm_packet + 1;
-
-	batadv_tvlv_containers_process(bat_priv, true, orig_node, NULL, NULL,
-				       tvlv_value, tvlv_value_len);
-}
-
-/**
- * batadv_tvlv_handler_register - register tvlv handler based on the provided
- *  type and version (both need to match) for ogm tvlv payload and/or unicast
- *  payload
- * @bat_priv: the bat priv with all the soft interface information
- * @optr: ogm tvlv handler callback function. This function receives the orig
- *  node, flags and the tvlv content as argument to process.
- * @uptr: unicast tvlv handler callback function. This function receives the
- *  source & destination of the unicast packet as well as the tvlv content
- *  to process.
- * @type: tvlv handler type to be registered
- * @version: tvlv handler version to be registered
- * @flags: flags to enable or disable TVLV API behavior
- */
-void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
-				  void (*optr)(struct batadv_priv *bat_priv,
-					       struct batadv_orig_node *orig,
-					       u8 flags,
-					       void *tvlv_value,
-					       u16 tvlv_value_len),
-				  int (*uptr)(struct batadv_priv *bat_priv,
-					      u8 *src, u8 *dst,
-					      void *tvlv_value,
-					      u16 tvlv_value_len),
-				  u8 type, u8 version, u8 flags)
-{
-	struct batadv_tvlv_handler *tvlv_handler;
-
-	tvlv_handler = batadv_tvlv_handler_get(bat_priv, type, version);
-	if (tvlv_handler) {
-		batadv_tvlv_handler_put(tvlv_handler);
-		return;
-	}
-
-	tvlv_handler = kzalloc(sizeof(*tvlv_handler), GFP_ATOMIC);
-	if (!tvlv_handler)
-		return;
-
-	tvlv_handler->ogm_handler = optr;
-	tvlv_handler->unicast_handler = uptr;
-	tvlv_handler->type = type;
-	tvlv_handler->version = version;
-	tvlv_handler->flags = flags;
-	kref_init(&tvlv_handler->refcount);
-	INIT_HLIST_NODE(&tvlv_handler->list);
-
-	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
-	hlist_add_head_rcu(&tvlv_handler->list, &bat_priv->tvlv.handler_list);
-	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
-}
-
-/**
- * batadv_tvlv_handler_unregister - unregister tvlv handler based on the
- *  provided type and version (both need to match)
- * @bat_priv: the bat priv with all the soft interface information
- * @type: tvlv handler type to be unregistered
- * @version: tvlv handler version to be unregistered
- */
-void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
-				    u8 type, u8 version)
-{
-	struct batadv_tvlv_handler *tvlv_handler;
-
-	tvlv_handler = batadv_tvlv_handler_get(bat_priv, type, version);
-	if (!tvlv_handler)
-		return;
-
-	batadv_tvlv_handler_put(tvlv_handler);
-	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
-	hlist_del_rcu(&tvlv_handler->list);
-	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
-	batadv_tvlv_handler_put(tvlv_handler);
-}
-
-/**
- * batadv_tvlv_unicast_send - send a unicast packet with tvlv payload to the
- *  specified host
- * @bat_priv: the bat priv with all the soft interface information
- * @src: source mac address of the unicast packet
- * @dst: destination mac address of the unicast packet
- * @type: tvlv type
- * @version: tvlv version
- * @tvlv_value: tvlv content
- * @tvlv_value_len: tvlv content length
- */
-void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
-			      u8 *dst, u8 type, u8 version,
-			      void *tvlv_value, u16 tvlv_value_len)
-{
-	struct batadv_unicast_tvlv_packet *unicast_tvlv_packet;
-	struct batadv_tvlv_hdr *tvlv_hdr;
-	struct batadv_orig_node *orig_node;
-	struct sk_buff *skb;
-	unsigned char *tvlv_buff;
-	unsigned int tvlv_len;
-	ssize_t hdr_len = sizeof(*unicast_tvlv_packet);
-
-	orig_node = batadv_orig_hash_find(bat_priv, dst);
-	if (!orig_node)
-		return;
-
-	tvlv_len = sizeof(*tvlv_hdr) + tvlv_value_len;
-
-	skb = netdev_alloc_skb_ip_align(NULL, ETH_HLEN + hdr_len + tvlv_len);
-	if (!skb)
-		goto out;
-
-	skb->priority = TC_PRIO_CONTROL;
-	skb_reserve(skb, ETH_HLEN);
-	tvlv_buff = skb_put(skb, sizeof(*unicast_tvlv_packet) + tvlv_len);
-	unicast_tvlv_packet = (struct batadv_unicast_tvlv_packet *)tvlv_buff;
-	unicast_tvlv_packet->packet_type = BATADV_UNICAST_TVLV;
-	unicast_tvlv_packet->version = BATADV_COMPAT_VERSION;
-	unicast_tvlv_packet->ttl = BATADV_TTL;
-	unicast_tvlv_packet->reserved = 0;
-	unicast_tvlv_packet->tvlv_len = htons(tvlv_len);
-	unicast_tvlv_packet->align = 0;
-	ether_addr_copy(unicast_tvlv_packet->src, src);
-	ether_addr_copy(unicast_tvlv_packet->dst, dst);
-
-	tvlv_buff = (unsigned char *)(unicast_tvlv_packet + 1);
-	tvlv_hdr = (struct batadv_tvlv_hdr *)tvlv_buff;
-	tvlv_hdr->version = version;
-	tvlv_hdr->type = type;
-	tvlv_hdr->len = htons(tvlv_value_len);
-	tvlv_buff += sizeof(*tvlv_hdr);
-	memcpy(tvlv_buff, tvlv_value, tvlv_value_len);
-
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) == NET_XMIT_DROP)
-		kfree_skb(skb);
-out:
-	batadv_orig_node_put(orig_node);
-}
-
-/**
  * batadv_get_vid - extract the VLAN identifier from skb if any
  * @skb: the buffer containing the packet
  * @header_len: length of the batman header preceding the ethernet header
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 38f9e55..3af6582 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -190,7 +190,6 @@ enum batadv_uev_type {
 
 #include "types.h"
 
-struct batadv_ogm_packet;
 struct seq_file;
 struct sk_buff;
 
@@ -372,39 +371,6 @@ static inline u64 batadv_sum_counter(struct batadv_priv *bat_priv,  size_t idx)
  */
 #define BATADV_SKB_CB(__skb)       ((struct batadv_skb_cb *)&((__skb)->cb[0]))
 
-void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
-				    u8 type, u8 version,
-				    void *tvlv_value, u16 tvlv_value_len);
-u16 batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
-				     unsigned char **packet_buff,
-				     int *packet_buff_len, int packet_min_len);
-void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
-			     struct batadv_ogm_packet *batadv_ogm_packet,
-			     struct batadv_orig_node *orig_node);
-void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
-				      u8 type, u8 version);
-
-void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
-				  void (*optr)(struct batadv_priv *bat_priv,
-					       struct batadv_orig_node *orig,
-					       u8 flags,
-					       void *tvlv_value,
-					       u16 tvlv_value_len),
-				  int (*uptr)(struct batadv_priv *bat_priv,
-					      u8 *src, u8 *dst,
-					      void *tvlv_value,
-					      u16 tvlv_value_len),
-				  u8 type, u8 version, u8 flags);
-void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
-				    u8 type, u8 version);
-int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
-				   bool ogm_source,
-				   struct batadv_orig_node *orig_node,
-				   u8 *src, u8 *dst,
-				   void *tvlv_buff, u16 tvlv_buff_len);
-void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
-			      u8 *dst, u8 type, u8 version,
-			      void *tvlv_value, u16 tvlv_value_len);
 unsigned short batadv_get_vid(struct sk_buff *skb, size_t header_len);
 bool batadv_vlan_ap_isola_get(struct batadv_priv *bat_priv, unsigned short vid);
 
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index d3222db..0e7d78f 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -57,6 +57,7 @@
 #include "hash.h"
 #include "packet.h"
 #include "translation-table.h"
+#include "tvlv.h"
 
 /**
  * batadv_mcast_get_bridge - get the bridge on top of the softif if it exists
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 678f068..d0383de 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -55,6 +55,7 @@
 #include "packet.h"
 #include "routing.h"
 #include "send.h"
+#include "tvlv.h"
 
 static struct lock_class_key batadv_nc_coding_hash_lock_class_key;
 static struct lock_class_key batadv_nc_decoding_hash_lock_class_key;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 24fc753..8cb459a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -46,6 +46,7 @@
 #include "send.h"
 #include "soft-interface.h"
 #include "translation-table.h"
+#include "tvlv.h"
 
 static int batadv_route_unicast_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 87bb203..6c8d624 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -51,6 +51,7 @@
 #include "originator.h"
 #include "packet.h"
 #include "soft-interface.h"
+#include "tvlv.h"
 
 /* hash class keys */
 static struct lock_class_key batadv_tt_local_hash_lock_class_key;
diff --git a/net/batman-adv/tvlv.c b/net/batman-adv/tvlv.c
new file mode 100644
index 0000000..2fd542e
--- /dev/null
+++ b/net/batman-adv/tvlv.c
@@ -0,0 +1,630 @@
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "main.h"
+
+#include <linux/byteorder/generic.h>
+#include <linux/etherdevice.h>
+#include <linux/fs.h>
+#include <linux/if_ether.h>
+#include <linux/kernel.h>
+#include <linux/kref.h>
+#include <linux/list.h>
+#include <linux/lockdep.h>
+#include <linux/netdevice.h>
+#include <linux/pkt_sched.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/stddef.h>
+#include <linux/string.h>
+#include <linux/types.h>
+
+#include "originator.h"
+#include "packet.h"
+#include "send.h"
+#include "tvlv.h"
+
+/**
+ * batadv_tvlv_handler_release - release tvlv handler from lists and queue for
+ *  free after rcu grace period
+ * @ref: kref pointer of the tvlv
+ */
+static void batadv_tvlv_handler_release(struct kref *ref)
+{
+	struct batadv_tvlv_handler *tvlv_handler;
+
+	tvlv_handler = container_of(ref, struct batadv_tvlv_handler, refcount);
+	kfree_rcu(tvlv_handler, rcu);
+}
+
+/**
+ * batadv_tvlv_handler_put - decrement the tvlv container refcounter and
+ *  possibly release it
+ * @tvlv_handler: the tvlv handler to free
+ */
+static void batadv_tvlv_handler_put(struct batadv_tvlv_handler *tvlv_handler)
+{
+	kref_put(&tvlv_handler->refcount, batadv_tvlv_handler_release);
+}
+
+/**
+ * batadv_tvlv_handler_get - retrieve tvlv handler from the tvlv handler list
+ *  based on the provided type and version (both need to match)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv handler type to look for
+ * @version: tvlv handler version to look for
+ *
+ * Return: tvlv handler if found or NULL otherwise.
+ */
+static struct batadv_tvlv_handler *
+batadv_tvlv_handler_get(struct batadv_priv *bat_priv, u8 type, u8 version)
+{
+	struct batadv_tvlv_handler *tvlv_handler_tmp, *tvlv_handler = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tvlv_handler_tmp,
+				 &bat_priv->tvlv.handler_list, list) {
+		if (tvlv_handler_tmp->type != type)
+			continue;
+
+		if (tvlv_handler_tmp->version != version)
+			continue;
+
+		if (!kref_get_unless_zero(&tvlv_handler_tmp->refcount))
+			continue;
+
+		tvlv_handler = tvlv_handler_tmp;
+		break;
+	}
+	rcu_read_unlock();
+
+	return tvlv_handler;
+}
+
+/**
+ * batadv_tvlv_container_release - release tvlv from lists and free
+ * @ref: kref pointer of the tvlv
+ */
+static void batadv_tvlv_container_release(struct kref *ref)
+{
+	struct batadv_tvlv_container *tvlv;
+
+	tvlv = container_of(ref, struct batadv_tvlv_container, refcount);
+	kfree(tvlv);
+}
+
+/**
+ * batadv_tvlv_container_put - decrement the tvlv container refcounter and
+ *  possibly release it
+ * @tvlv: the tvlv container to free
+ */
+static void batadv_tvlv_container_put(struct batadv_tvlv_container *tvlv)
+{
+	kref_put(&tvlv->refcount, batadv_tvlv_container_release);
+}
+
+/**
+ * batadv_tvlv_container_get - retrieve tvlv container from the tvlv container
+ *  list based on the provided type and version (both need to match)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv container type to look for
+ * @version: tvlv container version to look for
+ *
+ * Has to be called with the appropriate locks being acquired
+ * (tvlv.container_list_lock).
+ *
+ * Return: tvlv container if found or NULL otherwise.
+ */
+static struct batadv_tvlv_container *
+batadv_tvlv_container_get(struct batadv_priv *bat_priv, u8 type, u8 version)
+{
+	struct batadv_tvlv_container *tvlv_tmp, *tvlv = NULL;
+
+	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
+
+	hlist_for_each_entry(tvlv_tmp, &bat_priv->tvlv.container_list, list) {
+		if (tvlv_tmp->tvlv_hdr.type != type)
+			continue;
+
+		if (tvlv_tmp->tvlv_hdr.version != version)
+			continue;
+
+		kref_get(&tvlv_tmp->refcount);
+		tvlv = tvlv_tmp;
+		break;
+	}
+
+	return tvlv;
+}
+
+/**
+ * batadv_tvlv_container_list_size - calculate the size of the tvlv container
+ *  list entries
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Has to be called with the appropriate locks being acquired
+ * (tvlv.container_list_lock).
+ *
+ * Return: size of all currently registered tvlv containers in bytes.
+ */
+static u16 batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
+{
+	struct batadv_tvlv_container *tvlv;
+	u16 tvlv_len = 0;
+
+	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
+
+	hlist_for_each_entry(tvlv, &bat_priv->tvlv.container_list, list) {
+		tvlv_len += sizeof(struct batadv_tvlv_hdr);
+		tvlv_len += ntohs(tvlv->tvlv_hdr.len);
+	}
+
+	return tvlv_len;
+}
+
+/**
+ * batadv_tvlv_container_remove - remove tvlv container from the tvlv container
+ *  list
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tvlv: the to be removed tvlv container
+ *
+ * Has to be called with the appropriate locks being acquired
+ * (tvlv.container_list_lock).
+ */
+static void batadv_tvlv_container_remove(struct batadv_priv *bat_priv,
+					 struct batadv_tvlv_container *tvlv)
+{
+	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
+
+	if (!tvlv)
+		return;
+
+	hlist_del(&tvlv->list);
+
+	/* first call to decrement the counter, second call to free */
+	batadv_tvlv_container_put(tvlv);
+	batadv_tvlv_container_put(tvlv);
+}
+
+/**
+ * batadv_tvlv_container_unregister - unregister tvlv container based on the
+ *  provided type and version (both need to match)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv container type to unregister
+ * @version: tvlv container type to unregister
+ */
+void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
+				      u8 type, u8 version)
+{
+	struct batadv_tvlv_container *tvlv;
+
+	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
+	tvlv = batadv_tvlv_container_get(bat_priv, type, version);
+	batadv_tvlv_container_remove(bat_priv, tvlv);
+	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
+}
+
+/**
+ * batadv_tvlv_container_register - register tvlv type, version and content
+ *  to be propagated with each (primary interface) OGM
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv container type
+ * @version: tvlv container version
+ * @tvlv_value: tvlv container content
+ * @tvlv_value_len: tvlv container content length
+ *
+ * If a container of the same type and version was already registered the new
+ * content is going to replace the old one.
+ */
+void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
+				    u8 type, u8 version,
+				    void *tvlv_value, u16 tvlv_value_len)
+{
+	struct batadv_tvlv_container *tvlv_old, *tvlv_new;
+
+	if (!tvlv_value)
+		tvlv_value_len = 0;
+
+	tvlv_new = kzalloc(sizeof(*tvlv_new) + tvlv_value_len, GFP_ATOMIC);
+	if (!tvlv_new)
+		return;
+
+	tvlv_new->tvlv_hdr.version = version;
+	tvlv_new->tvlv_hdr.type = type;
+	tvlv_new->tvlv_hdr.len = htons(tvlv_value_len);
+
+	memcpy(tvlv_new + 1, tvlv_value, ntohs(tvlv_new->tvlv_hdr.len));
+	INIT_HLIST_NODE(&tvlv_new->list);
+	kref_init(&tvlv_new->refcount);
+
+	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
+	tvlv_old = batadv_tvlv_container_get(bat_priv, type, version);
+	batadv_tvlv_container_remove(bat_priv, tvlv_old);
+	hlist_add_head(&tvlv_new->list, &bat_priv->tvlv.container_list);
+	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
+}
+
+/**
+ * batadv_tvlv_realloc_packet_buff - reallocate packet buffer to accommodate
+ *  requested packet size
+ * @packet_buff: packet buffer
+ * @packet_buff_len: packet buffer size
+ * @min_packet_len: requested packet minimum size
+ * @additional_packet_len: requested additional packet size on top of minimum
+ *  size
+ *
+ * Return: true of the packet buffer could be changed to the requested size,
+ * false otherwise.
+ */
+static bool batadv_tvlv_realloc_packet_buff(unsigned char **packet_buff,
+					    int *packet_buff_len,
+					    int min_packet_len,
+					    int additional_packet_len)
+{
+	unsigned char *new_buff;
+
+	new_buff = kmalloc(min_packet_len + additional_packet_len, GFP_ATOMIC);
+
+	/* keep old buffer if kmalloc should fail */
+	if (!new_buff)
+		return false;
+
+	memcpy(new_buff, *packet_buff, min_packet_len);
+	kfree(*packet_buff);
+	*packet_buff = new_buff;
+	*packet_buff_len = min_packet_len + additional_packet_len;
+
+	return true;
+}
+
+/**
+ * batadv_tvlv_container_ogm_append - append tvlv container content to given
+ *  OGM packet buffer
+ * @bat_priv: the bat priv with all the soft interface information
+ * @packet_buff: ogm packet buffer
+ * @packet_buff_len: ogm packet buffer size including ogm header and tvlv
+ *  content
+ * @packet_min_len: ogm header size to be preserved for the OGM itself
+ *
+ * The ogm packet might be enlarged or shrunk depending on the current size
+ * and the size of the to-be-appended tvlv containers.
+ *
+ * Return: size of all appended tvlv containers in bytes.
+ */
+u16 batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
+				     unsigned char **packet_buff,
+				     int *packet_buff_len, int packet_min_len)
+{
+	struct batadv_tvlv_container *tvlv;
+	struct batadv_tvlv_hdr *tvlv_hdr;
+	u16 tvlv_value_len;
+	void *tvlv_value;
+	bool ret;
+
+	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
+	tvlv_value_len = batadv_tvlv_container_list_size(bat_priv);
+
+	ret = batadv_tvlv_realloc_packet_buff(packet_buff, packet_buff_len,
+					      packet_min_len, tvlv_value_len);
+
+	if (!ret)
+		goto end;
+
+	if (!tvlv_value_len)
+		goto end;
+
+	tvlv_value = (*packet_buff) + packet_min_len;
+
+	hlist_for_each_entry(tvlv, &bat_priv->tvlv.container_list, list) {
+		tvlv_hdr = tvlv_value;
+		tvlv_hdr->type = tvlv->tvlv_hdr.type;
+		tvlv_hdr->version = tvlv->tvlv_hdr.version;
+		tvlv_hdr->len = tvlv->tvlv_hdr.len;
+		tvlv_value = tvlv_hdr + 1;
+		memcpy(tvlv_value, tvlv + 1, ntohs(tvlv->tvlv_hdr.len));
+		tvlv_value = (u8 *)tvlv_value + ntohs(tvlv->tvlv_hdr.len);
+	}
+
+end:
+	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
+	return tvlv_value_len;
+}
+
+/**
+ * batadv_tvlv_call_handler - parse the given tvlv buffer to call the
+ *  appropriate handlers
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tvlv_handler: tvlv callback function handling the tvlv content
+ * @ogm_source: flag indicating whether the tvlv is an ogm or a unicast packet
+ * @orig_node: orig node emitting the ogm packet
+ * @src: source mac address of the unicast packet
+ * @dst: destination mac address of the unicast packet
+ * @tvlv_value: tvlv content
+ * @tvlv_value_len: tvlv content length
+ *
+ * Return: success if handler was not found or the return value of the handler
+ * callback.
+ */
+static int batadv_tvlv_call_handler(struct batadv_priv *bat_priv,
+				    struct batadv_tvlv_handler *tvlv_handler,
+				    bool ogm_source,
+				    struct batadv_orig_node *orig_node,
+				    u8 *src, u8 *dst,
+				    void *tvlv_value, u16 tvlv_value_len)
+{
+	if (!tvlv_handler)
+		return NET_RX_SUCCESS;
+
+	if (ogm_source) {
+		if (!tvlv_handler->ogm_handler)
+			return NET_RX_SUCCESS;
+
+		if (!orig_node)
+			return NET_RX_SUCCESS;
+
+		tvlv_handler->ogm_handler(bat_priv, orig_node,
+					  BATADV_NO_FLAGS,
+					  tvlv_value, tvlv_value_len);
+		tvlv_handler->flags |= BATADV_TVLV_HANDLER_OGM_CALLED;
+	} else {
+		if (!src)
+			return NET_RX_SUCCESS;
+
+		if (!dst)
+			return NET_RX_SUCCESS;
+
+		if (!tvlv_handler->unicast_handler)
+			return NET_RX_SUCCESS;
+
+		return tvlv_handler->unicast_handler(bat_priv, src,
+						     dst, tvlv_value,
+						     tvlv_value_len);
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * batadv_tvlv_containers_process - parse the given tvlv buffer to call the
+ *  appropriate handlers
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ogm_source: flag indicating whether the tvlv is an ogm or a unicast packet
+ * @orig_node: orig node emitting the ogm packet
+ * @src: source mac address of the unicast packet
+ * @dst: destination mac address of the unicast packet
+ * @tvlv_value: tvlv content
+ * @tvlv_value_len: tvlv content length
+ *
+ * Return: success when processing an OGM or the return value of all called
+ * handler callbacks.
+ */
+int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
+				   bool ogm_source,
+				   struct batadv_orig_node *orig_node,
+				   u8 *src, u8 *dst,
+				   void *tvlv_value, u16 tvlv_value_len)
+{
+	struct batadv_tvlv_handler *tvlv_handler;
+	struct batadv_tvlv_hdr *tvlv_hdr;
+	u16 tvlv_value_cont_len;
+	u8 cifnotfound = BATADV_TVLV_HANDLER_OGM_CIFNOTFND;
+	int ret = NET_RX_SUCCESS;
+
+	while (tvlv_value_len >= sizeof(*tvlv_hdr)) {
+		tvlv_hdr = tvlv_value;
+		tvlv_value_cont_len = ntohs(tvlv_hdr->len);
+		tvlv_value = tvlv_hdr + 1;
+		tvlv_value_len -= sizeof(*tvlv_hdr);
+
+		if (tvlv_value_cont_len > tvlv_value_len)
+			break;
+
+		tvlv_handler = batadv_tvlv_handler_get(bat_priv,
+						       tvlv_hdr->type,
+						       tvlv_hdr->version);
+
+		ret |= batadv_tvlv_call_handler(bat_priv, tvlv_handler,
+						ogm_source, orig_node,
+						src, dst, tvlv_value,
+						tvlv_value_cont_len);
+		if (tvlv_handler)
+			batadv_tvlv_handler_put(tvlv_handler);
+		tvlv_value = (u8 *)tvlv_value + tvlv_value_cont_len;
+		tvlv_value_len -= tvlv_value_cont_len;
+	}
+
+	if (!ogm_source)
+		return ret;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tvlv_handler,
+				 &bat_priv->tvlv.handler_list, list) {
+		if ((tvlv_handler->flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND) &&
+		    !(tvlv_handler->flags & BATADV_TVLV_HANDLER_OGM_CALLED))
+			tvlv_handler->ogm_handler(bat_priv, orig_node,
+						  cifnotfound, NULL, 0);
+
+		tvlv_handler->flags &= ~BATADV_TVLV_HANDLER_OGM_CALLED;
+	}
+	rcu_read_unlock();
+
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * batadv_tvlv_ogm_receive - process an incoming ogm and call the appropriate
+ *  handlers
+ * @bat_priv: the bat priv with all the soft interface information
+ * @batadv_ogm_packet: ogm packet containing the tvlv containers
+ * @orig_node: orig node emitting the ogm packet
+ */
+void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
+			     struct batadv_ogm_packet *batadv_ogm_packet,
+			     struct batadv_orig_node *orig_node)
+{
+	void *tvlv_value;
+	u16 tvlv_value_len;
+
+	if (!batadv_ogm_packet)
+		return;
+
+	tvlv_value_len = ntohs(batadv_ogm_packet->tvlv_len);
+	if (!tvlv_value_len)
+		return;
+
+	tvlv_value = batadv_ogm_packet + 1;
+
+	batadv_tvlv_containers_process(bat_priv, true, orig_node, NULL, NULL,
+				       tvlv_value, tvlv_value_len);
+}
+
+/**
+ * batadv_tvlv_handler_register - register tvlv handler based on the provided
+ *  type and version (both need to match) for ogm tvlv payload and/or unicast
+ *  payload
+ * @bat_priv: the bat priv with all the soft interface information
+ * @optr: ogm tvlv handler callback function. This function receives the orig
+ *  node, flags and the tvlv content as argument to process.
+ * @uptr: unicast tvlv handler callback function. This function receives the
+ *  source & destination of the unicast packet as well as the tvlv content
+ *  to process.
+ * @type: tvlv handler type to be registered
+ * @version: tvlv handler version to be registered
+ * @flags: flags to enable or disable TVLV API behavior
+ */
+void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
+				  void (*optr)(struct batadv_priv *bat_priv,
+					       struct batadv_orig_node *orig,
+					       u8 flags,
+					       void *tvlv_value,
+					       u16 tvlv_value_len),
+				  int (*uptr)(struct batadv_priv *bat_priv,
+					      u8 *src, u8 *dst,
+					      void *tvlv_value,
+					      u16 tvlv_value_len),
+				  u8 type, u8 version, u8 flags)
+{
+	struct batadv_tvlv_handler *tvlv_handler;
+
+	tvlv_handler = batadv_tvlv_handler_get(bat_priv, type, version);
+	if (tvlv_handler) {
+		batadv_tvlv_handler_put(tvlv_handler);
+		return;
+	}
+
+	tvlv_handler = kzalloc(sizeof(*tvlv_handler), GFP_ATOMIC);
+	if (!tvlv_handler)
+		return;
+
+	tvlv_handler->ogm_handler = optr;
+	tvlv_handler->unicast_handler = uptr;
+	tvlv_handler->type = type;
+	tvlv_handler->version = version;
+	tvlv_handler->flags = flags;
+	kref_init(&tvlv_handler->refcount);
+	INIT_HLIST_NODE(&tvlv_handler->list);
+
+	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
+	hlist_add_head_rcu(&tvlv_handler->list, &bat_priv->tvlv.handler_list);
+	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
+}
+
+/**
+ * batadv_tvlv_handler_unregister - unregister tvlv handler based on the
+ *  provided type and version (both need to match)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv handler type to be unregistered
+ * @version: tvlv handler version to be unregistered
+ */
+void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
+				    u8 type, u8 version)
+{
+	struct batadv_tvlv_handler *tvlv_handler;
+
+	tvlv_handler = batadv_tvlv_handler_get(bat_priv, type, version);
+	if (!tvlv_handler)
+		return;
+
+	batadv_tvlv_handler_put(tvlv_handler);
+	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
+	hlist_del_rcu(&tvlv_handler->list);
+	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
+	batadv_tvlv_handler_put(tvlv_handler);
+}
+
+/**
+ * batadv_tvlv_unicast_send - send a unicast packet with tvlv payload to the
+ *  specified host
+ * @bat_priv: the bat priv with all the soft interface information
+ * @src: source mac address of the unicast packet
+ * @dst: destination mac address of the unicast packet
+ * @type: tvlv type
+ * @version: tvlv version
+ * @tvlv_value: tvlv content
+ * @tvlv_value_len: tvlv content length
+ */
+void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
+			      u8 *dst, u8 type, u8 version,
+			      void *tvlv_value, u16 tvlv_value_len)
+{
+	struct batadv_unicast_tvlv_packet *unicast_tvlv_packet;
+	struct batadv_tvlv_hdr *tvlv_hdr;
+	struct batadv_orig_node *orig_node;
+	struct sk_buff *skb;
+	unsigned char *tvlv_buff;
+	unsigned int tvlv_len;
+	ssize_t hdr_len = sizeof(*unicast_tvlv_packet);
+
+	orig_node = batadv_orig_hash_find(bat_priv, dst);
+	if (!orig_node)
+		return;
+
+	tvlv_len = sizeof(*tvlv_hdr) + tvlv_value_len;
+
+	skb = netdev_alloc_skb_ip_align(NULL, ETH_HLEN + hdr_len + tvlv_len);
+	if (!skb)
+		goto out;
+
+	skb->priority = TC_PRIO_CONTROL;
+	skb_reserve(skb, ETH_HLEN);
+	tvlv_buff = skb_put(skb, sizeof(*unicast_tvlv_packet) + tvlv_len);
+	unicast_tvlv_packet = (struct batadv_unicast_tvlv_packet *)tvlv_buff;
+	unicast_tvlv_packet->packet_type = BATADV_UNICAST_TVLV;
+	unicast_tvlv_packet->version = BATADV_COMPAT_VERSION;
+	unicast_tvlv_packet->ttl = BATADV_TTL;
+	unicast_tvlv_packet->reserved = 0;
+	unicast_tvlv_packet->tvlv_len = htons(tvlv_len);
+	unicast_tvlv_packet->align = 0;
+	ether_addr_copy(unicast_tvlv_packet->src, src);
+	ether_addr_copy(unicast_tvlv_packet->dst, dst);
+
+	tvlv_buff = (unsigned char *)(unicast_tvlv_packet + 1);
+	tvlv_hdr = (struct batadv_tvlv_hdr *)tvlv_buff;
+	tvlv_hdr->version = version;
+	tvlv_hdr->type = type;
+	tvlv_hdr->len = htons(tvlv_value_len);
+	tvlv_buff += sizeof(*tvlv_hdr);
+	memcpy(tvlv_buff, tvlv_value, tvlv_value_len);
+
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) == NET_XMIT_DROP)
+		kfree_skb(skb);
+out:
+	batadv_orig_node_put(orig_node);
+}
diff --git a/net/batman-adv/tvlv.h b/net/batman-adv/tvlv.h
new file mode 100644
index 0000000..e4369b5
--- /dev/null
+++ b/net/batman-adv/tvlv.h
@@ -0,0 +1,61 @@
+/* Copyright (C) 2007-2016  B.A.T.M.A.N. contributors:
+ *
+ * Marek Lindner, Simon Wunderlich
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef _NET_BATMAN_ADV_TVLV_H_
+#define _NET_BATMAN_ADV_TVLV_H_
+
+#include "main.h"
+
+#include <linux/types.h>
+
+struct batadv_ogm_packet;
+
+void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
+				    u8 type, u8 version,
+				    void *tvlv_value, u16 tvlv_value_len);
+u16 batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
+				     unsigned char **packet_buff,
+				     int *packet_buff_len, int packet_min_len);
+void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
+			     struct batadv_ogm_packet *batadv_ogm_packet,
+			     struct batadv_orig_node *orig_node);
+void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
+				      u8 type, u8 version);
+
+void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
+				  void (*optr)(struct batadv_priv *bat_priv,
+					       struct batadv_orig_node *orig,
+					       u8 flags,
+					       void *tvlv_value,
+					       u16 tvlv_value_len),
+				  int (*uptr)(struct batadv_priv *bat_priv,
+					      u8 *src, u8 *dst,
+					      void *tvlv_value,
+					      u16 tvlv_value_len),
+				  u8 type, u8 version, u8 flags);
+void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
+				    u8 type, u8 version);
+int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
+				   bool ogm_source,
+				   struct batadv_orig_node *orig_node,
+				   u8 *src, u8 *dst,
+				   void *tvlv_buff, u16 tvlv_buff_len);
+void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
+			      u8 *dst, u8 type, u8 version,
+			      void *tvlv_value, u16 tvlv_value_len);
+
+#endif /* _NET_BATMAN_ADV_TVLV_H_ */
-- 
2.8.1
