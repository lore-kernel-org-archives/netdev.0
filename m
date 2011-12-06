From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/4] bnx2x: support classification config query
Date: Mon, 5 Dec 2011 21:44:47 -0800
Message-ID: <1323150288-28153-3-git-send-email-mchan@broadcom.com>
References: <1323150288-28153-1-git-send-email-mchan@broadcom.com>
 <1323150288-28153-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, barak@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2021 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006Ab1LFFjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 00:39:23 -0500
In-Reply-To: <1323150288-28153-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

To support copying MAC addresses to firmware info structure in the proper
format.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c |   39 ++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h |   17 ++++++++++
 2 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index a34362e..da377d1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -30,6 +30,8 @@
 
 #define BNX2X_MAX_EMUL_MULTI		16
 
+#define MAC_LEADING_ZERO_CNT (ALIGN(ETH_ALEN, sizeof(u32)) - ETH_ALEN)
+
 /**** Exe Queue interfaces ****/
 
 /**
@@ -441,6 +443,42 @@ static bool bnx2x_put_credit_vlan_mac(struct bnx2x_vlan_mac_obj *o)
 	return true;
 }
 
+static int bnx2x_get_n_elements(struct bnx2x *bp,
+			 struct bnx2x_vlan_mac_obj *o,
+			 int n,
+			 u8 *buf)
+{
+	struct bnx2x_vlan_mac_registry_elem *pos;
+	u8 *next = buf;
+	int counter = 0;
+
+	/* traverse list */
+	list_for_each_entry(pos, &o->head, link)
+	{
+		if ((counter < n)) {
+
+			/* place leading zeroes in buffer */
+			memset(next, 0, MAC_LEADING_ZERO_CNT);
+
+			/* place mac after leading zeroes*/
+			memcpy(next + MAC_LEADING_ZERO_CNT,
+				  pos->u.mac.mac, ETH_ALEN);
+
+			/* calculate address of next element and
+			 * advance counter
+			 */
+			counter++;
+			next = buf + counter * ALIGN(ETH_ALEN,
+							   sizeof(u32));
+
+			DP(BNX2X_MSG_SP, "copied element number "
+				   "%d to address %p element was "
+				   "%pM\n", counter, next, pos->u.mac.mac);
+		}
+	}
+	return counter * ETH_ALEN;
+}
+
 /* check_add() callbacks */
 static int bnx2x_check_mac_add(struct bnx2x_vlan_mac_obj *o,
 			       union bnx2x_classification_ramrod_data *data)
@@ -1886,6 +1924,7 @@ void bnx2x_init_mac_obj(struct bnx2x *bp,
 		mac_obj->check_move        = bnx2x_check_move;
 		mac_obj->ramrod_cmd        =
 			RAMROD_CMD_ID_ETH_CLASSIFICATION_RULES;
+		mac_obj->get_n_elements    = bnx2x_get_n_elements;
 
 		/* Exe Queue */
 		bnx2x_exe_queue_init(bp,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 9a517c2..bf898fb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -286,6 +286,23 @@ struct bnx2x_vlan_mac_obj {
 	int				ramrod_cmd;
 
 	/**
+	 * copy first n elements onto preallocated buffer
+	 *
+	 * @param n number of elements to get
+	 * @param buf buffer preallocated by caller into which elements
+	 *            will be copied. Note elements are 4-byte aligned
+	 *            so buffer size must be able to accomodate the
+	 *            aligned elements.
+	 *
+	 * @return number of copied bytes
+	 *  */
+
+	int (*get_n_elements)(struct bnx2x *bp,
+			 struct bnx2x_vlan_mac_obj *o,
+			 int n,
+			 u8 *buf);
+
+	/**
 	 * Checks if ADD-ramrod with the given params may be performed.
 	 *
 	 * @return zero if the element may be added
-- 
1.7.1
