From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/42] mlxsw: spectrum_router: Implement private fib
Date: Fri,  1 Jul 2016 16:04:44 +0200
Message-ID: <1467381910-3445-17-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36565 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbcGAOTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:19:39 -0400
Received: by mail-wm0-f65.google.com with SMTP id c82so5660738wme.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:19:38 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Shadow FIB is needed in order to hold additional information for FIB
entries and keep track of used prefixes. That is needed for the LPM tree
construction to be introduced later on in this set.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   7 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 120 +++++++++++++++++++++
 2 files changed, 127 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 83d5807..da0e072 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -43,6 +43,7 @@
 #include <linux/if_vlan.h>
 #include <linux/list.h>
 #include <linux/dcbnl.h>
+#include <linux/in6.h>
 #include <net/switchdev.h>
 
 #include "port.h"
@@ -160,6 +161,12 @@ struct mlxsw_sp_sb {
 	} ports[MLXSW_PORT_MAX_PORTS];
 };
 
+#define MLXSW_SP_PREFIX_COUNT (sizeof(struct in6_addr) * BITS_PER_BYTE)
+
+struct mlxsw_sp_prefix_usage {
+	DECLARE_BITMAP(b, MLXSW_SP_PREFIX_COUNT);
+};
+
 struct mlxsw_sp {
 	struct {
 		struct list_head list;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 8d70496..af4a35d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -35,11 +35,131 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
+#include <linux/rhashtable.h>
+#include <linux/bitops.h>
+#include <linux/in6.h>
 
 #include "spectrum.h"
 #include "core.h"
 #include "reg.h"
 
+static void
+mlxsw_sp_prefix_usage_set(struct mlxsw_sp_prefix_usage *prefix_usage,
+			  unsigned char prefix_len)
+{
+	set_bit(prefix_len, prefix_usage->b);
+}
+
+static void
+mlxsw_sp_prefix_usage_clear(struct mlxsw_sp_prefix_usage *prefix_usage,
+			    unsigned char prefix_len)
+{
+	clear_bit(prefix_len, prefix_usage->b);
+}
+
+struct mlxsw_sp_fib_key {
+	unsigned char addr[sizeof(struct in6_addr)];
+	unsigned char prefix_len;
+};
+
+struct mlxsw_sp_fib_entry {
+	struct rhash_head ht_node;
+	struct mlxsw_sp_fib_key key;
+};
+
+struct mlxsw_sp_fib {
+	struct rhashtable ht;
+	unsigned long prefix_ref_count[MLXSW_SP_PREFIX_COUNT];
+	struct mlxsw_sp_prefix_usage prefix_usage;
+};
+
+static const struct rhashtable_params mlxsw_sp_fib_ht_params = {
+	.key_offset = offsetof(struct mlxsw_sp_fib_entry, key),
+	.head_offset = offsetof(struct mlxsw_sp_fib_entry, ht_node),
+	.key_len = sizeof(struct mlxsw_sp_fib_key),
+	.automatic_shrinking = true,
+};
+
+static int mlxsw_sp_fib_entry_insert(struct mlxsw_sp_fib *fib,
+				     struct mlxsw_sp_fib_entry *fib_entry)
+{
+	unsigned char prefix_len = fib_entry->key.prefix_len;
+	int err;
+
+	err = rhashtable_insert_fast(&fib->ht, &fib_entry->ht_node,
+				     mlxsw_sp_fib_ht_params);
+	if (err)
+		return err;
+	if (fib->prefix_ref_count[prefix_len]++ == 0)
+		mlxsw_sp_prefix_usage_set(&fib->prefix_usage, prefix_len);
+	return 0;
+}
+
+static void mlxsw_sp_fib_entry_remove(struct mlxsw_sp_fib *fib,
+				      struct mlxsw_sp_fib_entry *fib_entry)
+{
+	unsigned char prefix_len = fib_entry->key.prefix_len;
+
+	if (--fib->prefix_ref_count[prefix_len] == 0)
+		mlxsw_sp_prefix_usage_clear(&fib->prefix_usage, prefix_len);
+	rhashtable_remove_fast(&fib->ht, &fib_entry->ht_node,
+			       mlxsw_sp_fib_ht_params);
+}
+
+static struct mlxsw_sp_fib_entry *
+mlxsw_sp_fib_entry_create(struct mlxsw_sp_fib *fib, const void *addr,
+			  size_t addr_len, unsigned char prefix_len)
+{
+	struct mlxsw_sp_fib_entry *fib_entry;
+
+	fib_entry = kzalloc(sizeof(*fib_entry), GFP_KERNEL);
+	if (!fib_entry)
+		return NULL;
+	memcpy(fib_entry->key.addr, addr, addr_len);
+	fib_entry->key.prefix_len = prefix_len;
+	return fib_entry;
+}
+
+static void mlxsw_sp_fib_entry_destroy(struct mlxsw_sp_fib_entry *fib_entry)
+{
+	kfree(fib_entry);
+}
+
+static struct mlxsw_sp_fib_entry *
+mlxsw_sp_fib_entry_lookup(struct mlxsw_sp_fib *fib, const void *addr,
+			  size_t addr_len, unsigned char prefix_len)
+{
+	struct mlxsw_sp_fib_key key = {{ 0 } };
+
+	memcpy(key.addr, addr, addr_len);
+	key.prefix_len = prefix_len;
+	return rhashtable_lookup_fast(&fib->ht, &key, mlxsw_sp_fib_ht_params);
+}
+
+static struct mlxsw_sp_fib *mlxsw_sp_fib_create(void)
+{
+	struct mlxsw_sp_fib *fib;
+	int err;
+
+	fib = kzalloc(sizeof(*fib), GFP_KERNEL);
+	if (!fib)
+		return ERR_PTR(-ENOMEM);
+	err = rhashtable_init(&fib->ht, &mlxsw_sp_fib_ht_params);
+	if (err)
+		goto err_rhashtable_init;
+	return fib;
+
+err_rhashtable_init:
+	kfree(fib);
+	return ERR_PTR(err);
+}
+
+static void mlxsw_sp_fib_destroy(struct mlxsw_sp_fib *fib)
+{
+	rhashtable_destroy(&fib->ht);
+	kfree(fib);
+}
+
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-- 
2.5.5
