From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: raw: raw_setsockopt: limit number of can_filter that can be set
Date: Wed,  7 Dec 2016 10:50:40 +0100
Message-ID: <20161207095040.5003-2-mkl@pengutronix.de>
References: <20161207095040.5003-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:39399 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932109AbcLGJuq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:50:46 -0500
In-Reply-To: <20161207095040.5003-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a check to limit the number of can_filters that can be
set via setsockopt on CAN_RAW sockets. Otherwise allocations > MAX_ORDER
are not prevented resulting in a warning.

Reference: https://lkml.org/lkml/2016/12/2/230

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 include/uapi/linux/can.h | 1 +
 net/can/raw.c            | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/uapi/linux/can.h b/include/uapi/linux/can.h
index 9692cda5f8fc..c48d93a28d1a 100644
--- a/include/uapi/linux/can.h
+++ b/include/uapi/linux/can.h
@@ -196,5 +196,6 @@ struct can_filter {
 };
 
 #define CAN_INV_FILTER 0x20000000U /* to be set in can_filter.can_id */
+#define CAN_RAW_FILTER_MAX 512 /* maximum number of can_filter set via setsockopt() */
 
 #endif /* !_UAPI_CAN_H */
diff --git a/net/can/raw.c b/net/can/raw.c
index 972c187d40ab..b075f028d7e2 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -499,6 +499,9 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen % sizeof(struct can_filter) != 0)
 			return -EINVAL;
 
+		if (optlen > CAN_RAW_FILTER_MAX * sizeof(struct can_filter))
+			return -EINVAL;
+
 		count = optlen / sizeof(struct can_filter);
 
 		if (count > 1) {
-- 
2.10.2
