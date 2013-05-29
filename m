From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/21] batman-adv: move ring_buffer helper functions in bat_iv_ogm
Date: Wed, 29 May 2013 02:59:36 +0200
Message-ID: <1369789186-3600-12-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43878 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934257Ab3E2BBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:53 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the two lonely ring_buffer helper functions are used by the
bat_iv_ogm module only and therefore they can be moved
inside it.

Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/Makefile      |  1 -
 net/batman-adv/bat_iv_ogm.c  | 43 ++++++++++++++++++++++++++++++++++++-
 net/batman-adv/ring_buffer.c | 51 --------------------------------------------
 net/batman-adv/ring_buffer.h | 27 -----------------------
 4 files changed, 42 insertions(+), 80 deletions(-)
 delete mode 100644 net/batman-adv/ring_buffer.c
 delete mode 100644 net/batman-adv/ring_buffer.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index acbac2a..489bb36 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -32,7 +32,6 @@ batman-adv-y += icmp_socket.o
 batman-adv-y += main.o
 batman-adv-$(CONFIG_BATMAN_ADV_NC) += network-coding.o
 batman-adv-y += originator.o
-batman-adv-y += ring_buffer.o
 batman-adv-y += routing.o
 batman-adv-y += send.o
 batman-adv-y += soft-interface.o
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ef41be4..31c2891 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -19,7 +19,6 @@
 
 #include "main.h"
 #include "translation-table.h"
-#include "ring_buffer.h"
 #include "originator.h"
 #include "routing.h"
 #include "gateway_common.h"
@@ -29,6 +28,48 @@
 #include "bat_algo.h"
 #include "network-coding.h"
 
+/**
+ * batadv_ring_buffer_set - update the ring buffer with the given value
+ * @lq_recv: pointer to the ring buffer
+ * @lq_index: index to store the value at
+ * @value: value to store in the ring buffer
+ */
+static void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
+				   uint8_t value)
+{
+	lq_recv[*lq_index] = value;
+	*lq_index = (*lq_index + 1) % BATADV_TQ_GLOBAL_WINDOW_SIZE;
+}
+
+/**
+ * batadv_ring_buffer_set - compute the average of all non-zero values stored
+ * in the given ring buffer
+ * @lq_recv: pointer to the ring buffer
+ *
+ * Returns computed average value.
+ */
+static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
+{
+	const uint8_t *ptr;
+	uint16_t count = 0, i = 0, sum = 0;
+
+	ptr = lq_recv;
+
+	while (i < BATADV_TQ_GLOBAL_WINDOW_SIZE) {
+		if (*ptr != 0) {
+			count++;
+			sum += *ptr;
+		}
+
+		i++;
+		ptr++;
+	}
+
+	if (count == 0)
+		return 0;
+
+	return (uint8_t)(sum / count);
+}
 static struct batadv_neigh_node *
 batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 			const uint8_t *neigh_addr,
diff --git a/net/batman-adv/ring_buffer.c b/net/batman-adv/ring_buffer.c
deleted file mode 100644
index ccab0bb..0000000
--- a/net/batman-adv/ring_buffer.c
+++ /dev/null
@@ -1,51 +0,0 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
- *
- * Marek Lindner
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
- */
-
-#include "main.h"
-#include "ring_buffer.h"
-
-void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
-			    uint8_t value)
-{
-	lq_recv[*lq_index] = value;
-	*lq_index = (*lq_index + 1) % BATADV_TQ_GLOBAL_WINDOW_SIZE;
-}
-
-uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
-{
-	const uint8_t *ptr;
-	uint16_t count = 0, i = 0, sum = 0;
-
-	ptr = lq_recv;
-
-	while (i < BATADV_TQ_GLOBAL_WINDOW_SIZE) {
-		if (*ptr != 0) {
-			count++;
-			sum += *ptr;
-		}
-
-		i++;
-		ptr++;
-	}
-
-	if (count == 0)
-		return 0;
-
-	return (uint8_t)(sum / count);
-}
diff --git a/net/batman-adv/ring_buffer.h b/net/batman-adv/ring_buffer.h
deleted file mode 100644
index 3f92ae2..0000000
--- a/net/batman-adv/ring_buffer.h
+++ /dev/null
@@ -1,27 +0,0 @@
-/* Copyright (C) 2007-2013 B.A.T.M.A.N. contributors:
- *
- * Marek Lindner
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
- */
-
-#ifndef _NET_BATMAN_ADV_RING_BUFFER_H_
-#define _NET_BATMAN_ADV_RING_BUFFER_H_
-
-void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
-			    uint8_t value);
-uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[]);
-
-#endif /* _NET_BATMAN_ADV_RING_BUFFER_H_ */
-- 
1.8.1.5
