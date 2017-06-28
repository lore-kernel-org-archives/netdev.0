From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 7/9] nfp: add metadata to each flow offload
Date: Wed, 28 Jun 2017 22:30:00 +0200
Message-ID: <1498681802-2897-8-git-send-email-simon.horman@netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:32872 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752165AbdF1Ubv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 16:31:51 -0400
Received: by mail-qt0-f177.google.com with SMTP id r30so59385012qtc.0
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 13:31:51 -0700 (PDT)
In-Reply-To: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Adds metadata describing the mask id of each flow and keeps track of
flows installed in hardware. Previously a flow could not be removed
from hardware as there was no way of knowing if that a specific flow
was installed. This is solved by storing the offloaded flows in a
hash table.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/flower/main.c   |  14 +-
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  53 +++
 .../net/ethernet/netronome/nfp/flower/metadata.c   | 377 +++++++++++++++++++++
 .../net/ethernet/netronome/nfp/flower/offload.c    |  22 +-
 5 files changed, 456 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/flower/metadata.c

diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
index 1ba0ea78adc3..b8e1358868bd 100644
--- a/drivers/net/ethernet/netronome/nfp/Makefile
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -35,6 +35,7 @@ nfp-objs += \
 	    flower/cmsg.o \
 	    flower/main.o \
 	    flower/match.o \
+	    flower/metadata.o \
 	    flower/offload.o
 endif
 
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
index 19f20f819e2f..1103d23a8ec7 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
@@ -50,14 +50,6 @@
 
 #define NFP_FLOWER_ALLOWED_VER 0x0001000000010000UL
 
-/**
- * struct nfp_flower_priv - Flower APP per-vNIC priv data
- * @nn:		     Pointer to vNIC
- */
-struct nfp_flower_priv {
-	struct nfp_net *nn;
-};
-
 static const char *nfp_flower_extra_cap(struct nfp_app *app, struct nfp_net *nn)
 {
 	return "FLOWER";
@@ -351,6 +343,12 @@ static int nfp_flower_init(struct nfp_app *app)
 	if (!app->priv)
 		return -ENOMEM;
 
+	err = nfp_flower_metadata_init(app);
+	if (nfp_flower_metadata_init(app)) {
+		kfree(app->priv);
+		return err;
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
index 7c9530504752..ae54b8052043 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -34,12 +34,51 @@
 #ifndef __NFP_FLOWER_H__
 #define __NFP_FLOWER_H__ 1
 
+#include <linux/circ_buf.h>
+#include <linux/hashtable.h>
+#include <linux/time64.h>
 #include <linux/types.h>
 
 struct tc_to_netdev;
 struct net_device;
 struct nfp_app;
 
+#define NFP_FLOWER_HASH_BITS		10
+#define NFP_FLOWER_HASH_SEED		129004
+
+#define NFP_FLOWER_MASK_ENTRY_RS	256
+#define NFP_FLOWER_MASK_ELEMENT_RS	1
+#define NFP_FLOWER_MASK_HASH_BITS	10
+#define NFP_FLOWER_MASK_HASH_SEED	9198806
+
+#define NFP_FL_META_FLAG_NEW_MASK	128
+#define NFP_FL_META_FLAG_LAST_MASK	1
+
+#define NFP_FL_MASK_REUSE_TIME_NS	40000
+#define NFP_FL_MASK_ID_LOCATION		1
+
+struct nfp_fl_mask_id {
+	struct circ_buf mask_id_free_list;
+	struct timespec64 *last_used;
+	u8 init_unallocated;
+};
+
+/**
+ * struct nfp_flower_priv - Flower APP per-vNIC priv data
+ * @nn:			Pointer to vNIC
+ * @flower_version:	HW version of flower
+ * @mask_ids:		List of free mask ids
+ * @mask_table:		Hash table used to store masks
+ * @flow_table:		Hash table used to store flower rules
+ */
+struct nfp_flower_priv {
+	struct nfp_net *nn;
+	u64 flower_version;
+	struct nfp_fl_mask_id mask_ids;
+	DECLARE_HASHTABLE(mask_table, NFP_FLOWER_MASK_HASH_BITS);
+	DECLARE_HASHTABLE(flow_table, NFP_FLOWER_HASH_BITS);
+};
+
 struct nfp_fl_key_ls {
 	u32 key_layer_two;
 	u8 key_layer;
@@ -64,6 +103,9 @@ struct nfp_fl_payload {
 	char *action_data;
 };
 
+int nfp_flower_metadata_init(struct nfp_app *app);
+void nfp_flower_metadata_cleanup(struct nfp_app *app);
+
 int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
 			u32 handle, __be16 proto, struct tc_to_netdev *tc);
 int nfp_flower_compile_flow_match(struct tc_cls_flower_offload *flow,
@@ -73,5 +115,16 @@ int nfp_flower_compile_flow_match(struct tc_cls_flower_offload *flow,
 int nfp_flower_compile_action(struct tc_cls_flower_offload *flow,
 			      struct net_device *netdev,
 			      struct nfp_fl_payload *nfp_flow);
+int nfp_compile_flow_metadata(struct nfp_app *app,
+			      struct tc_cls_flower_offload *flow,
+			      struct nfp_fl_payload *nfp_flow);
+int nfp_modify_flow_metadata(struct nfp_app *app,
+			     struct nfp_fl_payload *nfp_flow);
+
+struct nfp_fl_payload *
+nfp_flower_find_in_fl_table(struct nfp_app *app,
+			    unsigned long tc_flower_cookie);
+struct nfp_fl_payload *
+nfp_flower_remove_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie);
 
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/flower/metadata.c b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
new file mode 100644
index 000000000000..51de9ab85951
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/flower/metadata.c
@@ -0,0 +1,377 @@
+/*
+ * Copyright (C) 2017 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/hash.h>
+#include <linux/hashtable.h>
+#include <linux/jhash.h>
+#include <linux/vmalloc.h>
+#include <net/pkt_cls.h>
+
+#include "cmsg.h"
+#include "main.h"
+#include "../nfp_app.h"
+
+struct nfp_mask_id_table {
+	struct hlist_node link;
+	u32 hash_key;
+	u32 ref_cnt;
+	u8 mask_id;
+};
+
+struct nfp_flower_table {
+	unsigned long tc_flower_cookie;
+	struct nfp_fl_payload *nfp_flow;
+	struct hlist_node link;
+	struct rcu_head rcu;
+};
+
+static struct nfp_flower_table *
+nfp_flower_search_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	struct nfp_flower_table *flower_entry;
+
+	hash_for_each_possible_rcu(priv->flow_table, flower_entry, link,
+				   tc_flower_cookie)
+		if (flower_entry->tc_flower_cookie == tc_flower_cookie)
+			return flower_entry;
+
+	return NULL;
+}
+
+static int
+nfp_flower_add_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie,
+			struct nfp_fl_payload *nfp_flow)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	struct nfp_flower_table *flower_entry;
+
+	flower_entry = nfp_flower_search_fl_table(app, tc_flower_cookie);
+	if (flower_entry)
+		return -EEXIST;
+
+	flower_entry = kmalloc(sizeof(*flower_entry), GFP_KERNEL);
+	if (!flower_entry)
+		return -ENOMEM;
+
+	INIT_HLIST_NODE(&flower_entry->link);
+	flower_entry->nfp_flow = nfp_flow;
+	flower_entry->tc_flower_cookie = tc_flower_cookie;
+	hash_add_rcu(priv->flow_table, &flower_entry->link, tc_flower_cookie);
+
+	return 0;
+}
+
+struct nfp_fl_payload *
+nfp_flower_find_in_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie)
+{
+	struct nfp_flower_table *flow_entry;
+
+	flow_entry = nfp_flower_search_fl_table(app, tc_flower_cookie);
+	if (!flow_entry)
+		return NULL;
+
+	return flow_entry->nfp_flow;
+}
+
+struct nfp_fl_payload *
+nfp_flower_remove_fl_table(struct nfp_app *app, unsigned long tc_flower_cookie)
+{
+	struct nfp_flower_table *flow_entry;
+	struct nfp_fl_payload *nfp_flow;
+
+	flow_entry = nfp_flower_search_fl_table(app, tc_flower_cookie);
+	if (!flow_entry)
+		return NULL;
+
+	nfp_flow = flow_entry->nfp_flow;
+	hash_del_rcu(&flow_entry->link);
+	/* Allow caller to rely on there being no other references for
+	 * further cleanup of nfp_flow. Otherwise kfree_rcu() could be
+	 * used.
+	 */
+	synchronize_rcu();
+	kfree(flow_entry);
+
+	return nfp_flow;
+}
+
+static int nfp_release_mask_id(struct nfp_app *app, u8 mask_id)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	struct circ_buf *ring;
+	struct timespec64 now;
+
+	ring = &priv->mask_ids.mask_id_free_list;
+	/* Checking if buffer is full. */
+	if (CIRC_SPACE(ring->head, ring->tail, NFP_FLOWER_MASK_ENTRY_RS) == 0)
+		return -ENOBUFS;
+
+	memcpy(&ring->buf[ring->head], &mask_id, NFP_FLOWER_MASK_ELEMENT_RS);
+	ring->head = (ring->head + NFP_FLOWER_MASK_ELEMENT_RS) %
+		     (NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS);
+
+	getnstimeofday64(&now);
+	priv->mask_ids.last_used[mask_id] = now;
+
+	return 0;
+}
+
+static int nfp_mask_alloc(struct nfp_app *app, u8 *mask_id)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	struct timespec64 delta, now;
+	struct circ_buf *ring;
+	u8 temp_id, freed_id;
+
+	ring = &priv->mask_ids.mask_id_free_list;
+	freed_id = NFP_FLOWER_MASK_ENTRY_RS - 1;
+	/* Checking for unallocated entries first. */
+	if (priv->mask_ids.init_unallocated > 0) {
+		*mask_id = priv->mask_ids.init_unallocated;
+		priv->mask_ids.init_unallocated--;
+		return 0;
+	}
+
+	/* Checking if buffer is empty. */
+	if (ring->head == ring->tail) {
+		*mask_id = freed_id;
+		return -ENOENT;
+	}
+
+	memcpy(&temp_id, &ring->buf[ring->tail], NFP_FLOWER_MASK_ELEMENT_RS);
+	*mask_id = temp_id;
+	memcpy(&ring->buf[ring->tail], &freed_id, NFP_FLOWER_MASK_ELEMENT_RS);
+	ring->tail = (ring->tail + NFP_FLOWER_MASK_ELEMENT_RS) %
+		     (NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS);
+
+	getnstimeofday64(&now);
+	delta = timespec64_sub(now, priv->mask_ids.last_used[*mask_id]);
+
+	if (timespec64_to_ns(&delta) < NFP_FL_MASK_REUSE_TIME_NS) {
+		nfp_release_mask_id(app, *mask_id);
+		return -ENOENT;
+	}
+
+	return 0;
+}
+
+static int
+nfp_add_mask_table(struct nfp_app *app, char *mask_data, u32 mask_len)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	struct nfp_mask_id_table *mask_entry;
+	unsigned long hash_key;
+	u8 mask_id;
+
+	if (nfp_mask_alloc(app, &mask_id))
+		return -ENOENT;
+
+	mask_entry = kmalloc(sizeof(*mask_entry), GFP_KERNEL);
+	if (!mask_entry) {
+		nfp_release_mask_id(app, mask_id);
+		return -ENOMEM;
+	}
+
+	INIT_HLIST_NODE(&mask_entry->link);
+	mask_entry->mask_id = mask_id;
+	hash_key = jhash(mask_data, mask_len, NFP_FLOWER_MASK_HASH_SEED);
+	mask_entry->hash_key = hash_key;
+	mask_entry->ref_cnt = 1;
+	hash_add(priv->mask_table, &mask_entry->link, hash_key);
+
+	return mask_id;
+}
+
+static struct nfp_mask_id_table *
+nfp_search_mask_table(struct nfp_app *app, char *mask_data, u32 mask_len)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	struct nfp_mask_id_table *mask_entry;
+	unsigned long hash_key;
+
+	hash_key = jhash(mask_data, mask_len, NFP_FLOWER_MASK_HASH_SEED);
+
+	hash_for_each_possible(priv->mask_table, mask_entry, link, hash_key)
+		if (mask_entry->hash_key == hash_key)
+			return mask_entry;
+
+	return NULL;
+}
+
+static int
+nfp_find_in_mask_table(struct nfp_app *app, char *mask_data, u32 mask_len)
+{
+	struct nfp_mask_id_table *mask_entry;
+
+	mask_entry = nfp_search_mask_table(app, mask_data, mask_len);
+	if (!mask_entry)
+		return -ENOENT;
+
+	mask_entry->ref_cnt++;
+
+	/* Casting u8 to int for later use. */
+	return mask_entry->mask_id;
+}
+
+static bool
+nfp_check_mask_add(struct nfp_app *app, char *mask_data, u32 mask_len,
+		   u8 *meta_flags, u8 *mask_id)
+{
+	int id;
+
+	id = nfp_find_in_mask_table(app, mask_data, mask_len);
+	if (id < 0) {
+		id = nfp_add_mask_table(app, mask_data, mask_len);
+		if (id < 0)
+			return false;
+		*meta_flags |= NFP_FL_META_FLAG_NEW_MASK;
+	}
+	*mask_id = id;
+
+	return true;
+}
+
+static bool
+nfp_check_mask_remove(struct nfp_app *app, char *mask_data, u32 mask_len,
+		      u8 *meta_flags, u8 *mask_id)
+{
+	struct nfp_mask_id_table *mask_entry;
+
+	mask_entry = nfp_search_mask_table(app, mask_data, mask_len);
+	if (!mask_entry)
+		return false;
+
+	*mask_id = mask_entry->mask_id;
+	mask_entry->ref_cnt--;
+	if (!mask_entry->ref_cnt) {
+		hash_del(&mask_entry->link);
+		nfp_release_mask_id(app, *mask_id);
+		kfree(mask_entry);
+		if (meta_flags)
+			*meta_flags |= NFP_FL_META_FLAG_LAST_MASK;
+	}
+
+	return true;
+}
+
+int nfp_compile_flow_metadata(struct nfp_app *app,
+			      struct tc_cls_flower_offload *flow,
+			      struct nfp_fl_payload *nfp_flow)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	u8 new_mask_id;
+	int err;
+
+	new_mask_id = 0;
+	if (!nfp_check_mask_add(app, nfp_flow->mask_data,
+				nfp_flow->meta.mask_len,
+				&nfp_flow->meta.flags, &new_mask_id))
+		return -ENOENT;
+
+	nfp_flow->meta.flow_version = cpu_to_be64(priv->flower_version);
+	priv->flower_version++;
+
+	/* Update flow payload with mask ids. */
+	nfp_flow->unmasked_data[NFP_FL_MASK_ID_LOCATION] = new_mask_id;
+
+	err = nfp_flower_add_fl_table(app, flow->cookie, nfp_flow);
+	if (err < 0) {
+		if (!nfp_check_mask_remove(app, nfp_flow->mask_data,
+					   nfp_flow->meta.mask_len,
+					   NULL, &new_mask_id))
+			return -EINVAL;
+
+		return err;
+	}
+
+	return 0;
+}
+
+int nfp_modify_flow_metadata(struct nfp_app *app,
+			     struct nfp_fl_payload *nfp_flow)
+{
+	struct nfp_flower_priv *priv = app->priv;
+	u8 new_mask_id = 0;
+
+	nfp_check_mask_remove(app, nfp_flow->mask_data,
+			      nfp_flow->meta.mask_len, &nfp_flow->meta.flags,
+			      &new_mask_id);
+
+	nfp_flow->meta.flow_version = cpu_to_be64(priv->flower_version);
+	priv->flower_version++;
+
+	/* Update flow payload with mask ids. */
+	nfp_flow->unmasked_data[NFP_FL_MASK_ID_LOCATION] = new_mask_id;
+
+	return 0;
+}
+
+int nfp_flower_metadata_init(struct nfp_app *app)
+{
+	struct nfp_flower_priv *priv = app->priv;
+
+	hash_init(priv->mask_table);
+	hash_init(priv->flow_table);
+
+	/* Init ring buffer and unallocated mask_ids. */
+	priv->mask_ids.mask_id_free_list.buf =
+		kmalloc(NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS,
+			GFP_KERNEL);
+	if (!priv->mask_ids.mask_id_free_list.buf)
+		return -ENOMEM;
+
+	priv->mask_ids.init_unallocated = NFP_FLOWER_MASK_ENTRY_RS - 1;
+
+	/* Init timestamps for mask id*/
+	priv->mask_ids.last_used =
+		kmalloc_array(NFP_FLOWER_MASK_ENTRY_RS,
+			      sizeof(*priv->mask_ids.last_used), GFP_KERNEL);
+	if (!priv->mask_ids.last_used) {
+		kfree(priv->mask_ids.mask_id_free_list.buf);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+void nfp_flower_metadata_cleanup(struct nfp_app *app)
+{
+	struct nfp_flower_priv *priv = app->priv;
+
+	if (!priv)
+		return;
+
+	kfree(priv->mask_ids.mask_id_free_list.buf);
+	kfree(priv->mask_ids.last_used);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index f1cb0bd54137..d0c0350efef1 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -230,8 +230,14 @@ nfp_flower_add_offload(struct nfp_app *app, struct net_device *netdev,
 	if (err)
 		goto err_destroy_flow;
 
-	/* TODO: Complete flower_add_offload. */
-	err = -EOPNOTSUPP;
+	err = nfp_compile_flow_metadata(app, flow, flow_pay);
+	if (err)
+		goto err_destroy_flow;
+
+	/* Deallocate flow payload when flower rule has been destroyed. */
+	kfree(key_layer);
+
+	return 0;
 
 err_destroy_flow:
 	nfp_flower_deallocate_nfp(flow_pay);
@@ -256,7 +262,17 @@ static int
 nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
 		       struct tc_cls_flower_offload *flow)
 {
-	return -EOPNOTSUPP;
+	struct nfp_fl_payload *nfp_flow;
+	int err;
+
+	nfp_flow = nfp_flower_remove_fl_table(app, flow->cookie);
+	if (!nfp_flow)
+		return -ENOENT;
+
+	err = nfp_modify_flow_metadata(app, nfp_flow);
+
+	nfp_flower_deallocate_nfp(nfp_flow);
+	return err;
 }
 
 /**
-- 
2.1.4
