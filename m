From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/5] tipc: move bcast_addr from struct tipc_media to struct tipc_bearer
Date: Wed,  3 Apr 2013 14:43:27 +0200
Message-ID: <1364993010-15515-3-git-send-email-kaber@trash.net>
References: <1364993010-15515-1-git-send-email-kaber@trash.net>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	linux-rdma@vger.kernel.org
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48239 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759183Ab3DCMyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 08:54:01 -0400
In-Reply-To: <1364993010-15515-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some network protocols, like InfiniBand, don't have a fixed broadcast
address but one that depends on the configuration. Move the bcast_addr
to struct tipc_bearer and initialize it with the broadcast address of
the network device when the bearer is enabled.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/tipc/bcast.c     |  4 ++--
 net/tipc/bearer.c    |  5 +----
 net/tipc/bearer.h    |  5 +++--
 net/tipc/discover.c  |  2 +-
 net/tipc/eth_media.c | 18 +++++++++++-------
 5 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2655c9f..25e159c 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -620,10 +620,10 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 			continue;	/* bearer pair doesn't add anything */
 
 		if (!tipc_bearer_blocked(p))
-			tipc_bearer_send(p, buf, &p->media->bcast_addr);
+			tipc_bearer_send(p, buf, &p->bcast_addr);
 		else if (s && !tipc_bearer_blocked(s))
 			/* unable to send on primary bearer */
-			tipc_bearer_send(s, buf, &s->media->bcast_addr);
+			tipc_bearer_send(s, buf, &s->bcast_addr);
 		else
 			/* unable to send on either bearer */
 			continue;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index aa62f93..45d5398 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -89,9 +89,6 @@ int tipc_register_media(struct tipc_media *m_ptr)
 
 	if ((strlen(m_ptr->name) + 1) > TIPC_MAX_MEDIA_NAME)
 		goto exit;
-	if ((m_ptr->bcast_addr.media_id != m_ptr->type_id) ||
-	    !m_ptr->bcast_addr.broadcast)
-		goto exit;
 	if (m_ptr->priority > TIPC_MAX_LINK_PRI)
 		goto exit;
 	if ((m_ptr->tolerance < TIPC_MIN_LINK_TOL) ||
@@ -407,7 +404,7 @@ restart:
 	INIT_LIST_HEAD(&b_ptr->links);
 	spin_lock_init(&b_ptr->lock);
 
-	res = tipc_disc_create(b_ptr, &m_ptr->bcast_addr, disc_domain);
+	res = tipc_disc_create(b_ptr, &b_ptr->bcast_addr, disc_domain);
 	if (res) {
 		bearer_disable(b_ptr);
 		pr_warn("Bearer <%s> rejected, discovery object creation failed\n",
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index cc2d74e..3b3fa26 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -94,8 +94,8 @@ struct tipc_media {
 	void (*disable_bearer)(struct tipc_bearer *b_ptr);
 	int (*addr2str)(struct tipc_media_addr *a, char *str_buf, int str_size);
 	int (*addr2msg)(struct tipc_media_addr *a, char *msg_area);
-	int (*msg2addr)(struct tipc_media_addr *a, char *msg_area);
-	struct tipc_media_addr bcast_addr;
+	int (*msg2addr)(const struct tipc_bearer *b_ptr,
+			struct tipc_media_addr *a, char *msg_area);
 	u32 priority;
 	u32 tolerance;
 	u32 window;
@@ -134,6 +134,7 @@ struct tipc_bearer {
 	char name[TIPC_MAX_BEARER_NAME];
 	spinlock_t lock;
 	struct tipc_media *media;
+	struct tipc_media_addr bcast_addr;
 	u32 priority;
 	u32 window;
 	u32 tolerance;
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 1074b95..eedff58 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -129,7 +129,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	int link_fully_up;
 
 	media_addr.broadcast = 1;
-	b_ptr->media->msg2addr(&media_addr, msg_media_addr(msg));
+	b_ptr->media->msg2addr(b_ptr, &media_addr, msg_media_addr(msg));
 	kfree_skb(buf);
 
 	/* Ensure message from node is valid and communication is permitted */
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 1bdc6df..0648819 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -77,12 +77,13 @@ static struct notifier_block notifier = {
  * Media-dependent "value" field stores MAC address in first 6 bytes
  * and zeroes out the remaining bytes.
  */
-static void eth_media_addr_set(struct tipc_media_addr *a, char *mac)
+static void eth_media_addr_set(const struct tipc_bearer *tb_ptr,
+			       struct tipc_media_addr *a, char *mac)
 {
 	memcpy(a->value, mac, ETH_ALEN);
 	memset(a->value + ETH_ALEN, 0, sizeof(a->value) - ETH_ALEN);
 	a->media_id = TIPC_MEDIA_TYPE_ETH;
-	a->broadcast = !memcmp(mac, eth_media_info.bcast_addr.value, ETH_ALEN);
+	a->broadcast = !memcmp(mac, tb_ptr->bcast_addr.value, ETH_ALEN);
 }
 
 /**
@@ -201,9 +202,13 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	/* Associate TIPC bearer with Ethernet bearer */
 	eb_ptr->bearer = tb_ptr;
 	tb_ptr->usr_handle = (void *)eb_ptr;
+	memset(tb_ptr->bcast_addr.value, 0, sizeof(tb_ptr->bcast_addr.value));
+	memcpy(tb_ptr->bcast_addr.value, dev->broadcast, ETH_ALEN);
+	tb_ptr->bcast_addr.media_id = TIPC_MEDIA_TYPE_ETH;
+	tb_ptr->bcast_addr.broadcast = 1;
 	tb_ptr->mtu = dev->mtu;
 	tb_ptr->blocked = 0;
-	eth_media_addr_set(&tb_ptr->addr, (char *)dev->dev_addr);
+	eth_media_addr_set(tb_ptr, &tb_ptr->addr, (char *)dev->dev_addr);
 	return 0;
 }
 
@@ -315,12 +320,13 @@ static int eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
 /**
  * eth_str2addr - convert message header address format to Ethernet format
  */
-static int eth_msg2addr(struct tipc_media_addr *a, char *msg_area)
+static int eth_msg2addr(const struct tipc_bearer *tb_ptr,
+			struct tipc_media_addr *a, char *msg_area)
 {
 	if (msg_area[TIPC_MEDIA_TYPE_OFFSET] != TIPC_MEDIA_TYPE_ETH)
 		return 1;
 
-	eth_media_addr_set(a, msg_area + ETH_ADDR_OFFSET);
+	eth_media_addr_set(tb_ptr, a, msg_area + ETH_ADDR_OFFSET);
 	return 0;
 }
 
@@ -334,8 +340,6 @@ static struct tipc_media eth_media_info = {
 	.addr2str	= eth_addr2str,
 	.addr2msg	= eth_addr2msg,
 	.msg2addr	= eth_msg2addr,
-	.bcast_addr	= { { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff },
-			    TIPC_MEDIA_TYPE_ETH, 1 },
 	.priority	= TIPC_DEF_LINK_PRI,
 	.tolerance	= TIPC_DEF_LINK_TOL,
 	.window		= TIPC_DEF_LINK_WIN,
-- 
1.8.1.4
