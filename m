From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/13] batman-adv: handle routing code initialization properly
Date: Wed, 18 Apr 2012 12:00:04 +0200
Message-ID: <1334743210-12338-8-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:24575 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab2DRJ73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:29 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c     |   11 ++++++++++-
 net/batman-adv/hard-interface.c |   15 ++++++---------
 net/batman-adv/types.h          |    2 +-
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 4cc66db..2714670 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -30,10 +30,11 @@
 #include "send.h"
 #include "bat_algo.h"
 
-static void bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
+static int bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 	uint32_t random_seqno;
+	int res = -1;
 
 	/* randomize initial seqno to avoid collision */
 	get_random_bytes(&random_seqno, sizeof(random_seqno));
@@ -42,6 +43,9 @@ static void bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 	hard_iface->packet_len = BATMAN_OGM_LEN;
 	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
 
+	if (!hard_iface->packet_buff)
+		goto out;
+
 	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
 	batman_ogm_packet->header.packet_type = BAT_OGM;
 	batman_ogm_packet->header.version = COMPAT_VERSION;
@@ -50,6 +54,11 @@ static void bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 	batman_ogm_packet->tq = TQ_MAX_VALUE;
 	batman_ogm_packet->tt_num_changes = 0;
 	batman_ogm_packet->ttvn = 0;
+
+	res = 0;
+
+out:
+	return res;
 }
 
 static void bat_iv_ogm_iface_disable(struct hard_iface *hard_iface)
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index fd9715e..3b391fd 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -304,22 +304,17 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	if (!softif_is_valid(soft_iface)) {
 		pr_err("Can't create batman mesh interface %s: already exists as regular interface\n",
 		       soft_iface->name);
-		dev_put(soft_iface);
 		ret = -EINVAL;
-		goto err;
+		goto err_dev;
 	}
 
 	hard_iface->soft_iface = soft_iface;
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
-	bat_priv->bat_algo_ops->bat_iface_enable(hard_iface);
-
-	if (!hard_iface->packet_buff) {
-		bat_err(hard_iface->soft_iface,
-			"Can't add interface packet (%s): out of memory\n",
-			hard_iface->net_dev->name);
+	ret = bat_priv->bat_algo_ops->bat_iface_enable(hard_iface);
+	if (ret < 0) {
 		ret = -ENOMEM;
-		goto err;
+		goto err_dev;
 	}
 
 	hard_iface->if_num = bat_priv->num_ifaces;
@@ -363,6 +358,8 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 out:
 	return 0;
 
+err_dev:
+	dev_put(soft_iface);
 err:
 	hardif_free_ref(hard_iface);
 	return ret;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b034cf2..dd78023 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -378,7 +378,7 @@ struct bat_algo_ops {
 	struct hlist_node list;
 	char *name;
 	/* init routing info when hard-interface is enabled */
-	void (*bat_iface_enable)(struct hard_iface *hard_iface);
+	int (*bat_iface_enable)(struct hard_iface *hard_iface);
 	/* de-init routing info when hard-interface is disabled */
 	void (*bat_iface_disable)(struct hard_iface *hard_iface);
 	/* init primary OGM when primary interface is selected */
-- 
1.7.9.4
