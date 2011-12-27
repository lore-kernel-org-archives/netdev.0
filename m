From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/23] tipc: Add new address conversion routines for Ethernet media
Date: Tue, 27 Dec 2011 12:39:26 -0500
Message-ID: <1325007582-31610-8-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39382 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754780Ab1L0Rj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:39:58 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Enhances TIPC's Ethernet media support to provide 3 new address conversion
routines, which allow TIPC to interpret an address that is in string form
and to convert an address to and from the 20 byte format used in TIPC's
neighbor discovery messages.

These routines are pre-requisites to a follow on commit that hides all
media-specific addressing details from TIPC's generic bearer code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.h    |   19 ++++++++++++++-
 net/tipc/eth_media.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 79 insertions(+), 3 deletions(-)

diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 4e9367f..41a61d2 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -43,6 +43,17 @@
 #define MAX_MEDIA	2
 
 /*
+ * Identifiers associated with TIPC message header media address info
+ *
+ * - address info field is 20 bytes long
+ * - media type identifier located at offset 3
+ * - remaining bytes vary according to media type
+ */
+
+#define TIPC_MEDIA_ADDR_SIZE	20
+#define TIPC_MEDIA_TYPE_OFFSET	3
+
+/*
  * Identifiers of supported TIPC media types
  */
 #define TIPC_MEDIA_TYPE_ETH	1
@@ -68,7 +79,10 @@ struct tipc_bearer;
  * @send_msg: routine which handles buffer transmission
  * @enable_bearer: routine which enables a bearer
  * @disable_bearer: routine which disables a bearer
- * @addr2str: routine which converts bearer's address to string form
+ * @addr2str: routine which converts media address to string
+ * @str2addr: routine which converts media address from string
+ * @addr2msg: routine which converts media address to protocol message area
+ * @msg2addr: routine which converts media address from protocol message area
  * @bcast_addr: media address used in broadcasting
  * @priority: default link (and bearer) priority
  * @tolerance: default time (in ms) before declaring link failure
@@ -84,6 +98,9 @@ struct media {
 	int (*enable_bearer)(struct tipc_bearer *b_ptr);
 	void (*disable_bearer)(struct tipc_bearer *b_ptr);
 	int (*addr2str)(struct tipc_media_addr *a, char *str_buf, int str_size);
+	int (*str2addr)(struct tipc_media_addr *a, char *str_buf);
+	int (*addr2msg)(struct tipc_media_addr *a, char *msg_area);
+	int (*msg2addr)(struct tipc_media_addr *a, char *msg_area);
 	struct tipc_media_addr bcast_addr;
 	u32 priority;
 	u32 tolerance;
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 67f616a..ebba0fc 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -39,6 +39,8 @@
 
 #define MAX_ETH_BEARERS		MAX_BEARERS
 
+#define ETH_ADDR_OFFSET	4	/* message header offset of MAC address */
+
 /**
  * struct eth_bearer - Ethernet bearer data structure
  * @bearer: ptr to associated "generic" bearer structure
@@ -57,6 +59,16 @@ static int eth_started;
 static struct notifier_block notifier;
 
 /**
+ * eth_media_addr_set - initialize Ethernet media address structure
+ */
+
+static void eth_media_addr_set(struct tipc_media_addr *a, char *mac)
+{
+	a->type = htonl(TIPC_MEDIA_TYPE_ETH);
+	memcpy(&a->dev_addr.eth_addr, mac, ETH_ALEN);
+}
+
+/**
  * send_msg - send a TIPC message out over an Ethernet interface
  */
 
@@ -169,8 +181,7 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	tb_ptr->usr_handle = (void *)eb_ptr;
 	tb_ptr->mtu = dev->mtu;
 	tb_ptr->blocked = 0;
-	tb_ptr->addr.type = htonl(TIPC_MEDIA_TYPE_ETH);
-	memcpy(&tb_ptr->addr.dev_addr, dev->dev_addr, ETH_ALEN);
+	eth_media_addr_set(&tb_ptr->addr, (char *)dev->dev_addr);
 	return 0;
 }
 
@@ -254,6 +265,51 @@ static int eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 	return 0;
 }
 
+/**
+ * eth_str2addr - convert string to Ethernet address
+ */
+
+static int eth_str2addr(struct tipc_media_addr *a, char *str_buf)
+{
+	char mac[ETH_ALEN];
+	int r;
+
+	r = sscanf(str_buf, "%02x:%02x:%02x:%02x:%02x:%02x",
+		       (u32 *)&mac[0], (u32 *)&mac[1], (u32 *)&mac[2],
+		       (u32 *)&mac[3], (u32 *)&mac[4], (u32 *)&mac[5]);
+
+	if (r != ETH_ALEN)
+		return 1;
+
+	eth_media_addr_set(a, mac);
+	return 0;
+}
+
+/**
+ * eth_str2addr - convert Ethernet address format to message header format
+ */
+
+static int eth_addr2msg(struct tipc_media_addr *a, char *msg_area)
+{
+	memset(msg_area, 0, TIPC_MEDIA_ADDR_SIZE);
+	msg_area[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_ETH;
+	memcpy(msg_area + ETH_ADDR_OFFSET, a->dev_addr.eth_addr, ETH_ALEN);
+	return 0;
+}
+
+/**
+ * eth_str2addr - convert message header address format to Ethernet format
+ */
+
+static int eth_msg2addr(struct tipc_media_addr *a, char *msg_area)
+{
+	if (msg_area[TIPC_MEDIA_TYPE_OFFSET] != TIPC_MEDIA_TYPE_ETH)
+		return 1;
+
+	eth_media_addr_set(a, msg_area + ETH_ADDR_OFFSET);
+	return 0;
+}
+
 /*
  * Ethernet media registration info
  */
@@ -263,6 +319,9 @@ static struct media eth_media_info = {
 	.enable_bearer	= enable_bearer,
 	.disable_bearer	= disable_bearer,
 	.addr2str	= eth_addr2str,
+	.str2addr	= eth_str2addr,
+	.addr2msg	= eth_addr2msg,
+	.msg2addr	= eth_msg2addr,
 	.bcast_addr	= { htonl(TIPC_MEDIA_TYPE_ETH),
 			    { {0xff, 0xff, 0xff, 0xff, 0xff, 0xff} } },
 	.priority	= TIPC_DEF_LINK_PRI,
-- 
1.7.4.4
