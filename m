From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH] can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
Date: Mon, 01 Dec 2008 17:15:42 +0100
Message-ID: <49340DAE.5060603@hartkopp.net>
References: <20081128153317.GA3726@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020504090804000801040702"
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:49965 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbYLAQPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 11:15:48 -0500
In-Reply-To: <20081128153317.GA3726@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020504090804000801040702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter

Due to a wrong safety check in af_can.c it was not possible to filter
for SFF frames with a specific CAN identifier without getting the
same selected CAN identifier from a received EFF frame also.

This fix has a minimum (but user visible) impact on the CAN filter
API and therefore the CAN version is set to a new date.

Indeed the 'old' API is still working as-is. But when now setting
CAN_(EFF|RTR)_FLAG in can_filter.can_mask you might get less traffic
than before - but still the stuff that you expected to get for your
defined filter ...

Thanks to Kurt Van Dijck for pointing at this issue and for the review.

Signed-Off-by: Oliver Hartkopp <oliver@hartkopp.net>
Acked-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
---

Hello Dave & Greg,

this patch fixes an issue when running with mixed CAN frame formats.

It should go into 2.6.28 before the bug fix window closes.

Additionally the patch applies excellent down to 2.6.26. Greg please
consider this patch for stable .26 and .27 also.

Thanks & best regards,
Oliver


--------------020504090804000801040702
Content-Type: text/x-patch;
 name="can_filter.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can_filter.patch"

diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index e9ca210..f50785a 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -19,7 +19,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 
-#define CAN_VERSION "20071116"
+#define CAN_VERSION "20081130"
 
 /* increment this number each time you change some user-space interface */
 #define CAN_ABI_VERSION "8"
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 7d4d2b3..d8173e5 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -319,23 +319,52 @@ static struct dev_rcv_lists *find_dev_rcv_lists(struct net_device *dev)
 	return n ? d : NULL;
 }
 
+/**
+ * find_rcv_list - determine optimal filterlist inside device filter struct
+ * @can_id: pointer to CAN identifier of a given can_filter
+ * @mask: pointer to CAN mask of a given can_filter
+ * @d: pointer to the device filter struct
+ *
+ * Description:
+ *  Returns the optimal filterlist to reduce the filter handling in the
+ *  receive path. This function is called by service functions that need
+ *  to register or unregister a can_filter in the filter lists.
+ *
+ *  A filter matches in general, when
+ *
+ *          <received_can_id> & mask == can_id & mask
+ *
+ *  so every bit set in the mask (even CAN_EFF_FLAG, CAN_RTR_FLAG) describe
+ *  relevant bits for the filter.
+ *
+ *  The filter can be inverted (CAN_INV_FILTER bit set in can_id) or it can
+ *  filter for error frames (CAN_ERR_FLAG bit set in mask). For error frames
+ *  there is a special filterlist and a special rx path filter handling.
+ *
+ * Return:
+ *  Pointer to optimal filterlist for the given can_id/mask pair.
+ *  Constistency checked mask.
+ *  Reduced can_id to have a preprocessed filter compare value.
+ */
 static struct hlist_head *find_rcv_list(canid_t *can_id, canid_t *mask,
 					struct dev_rcv_lists *d)
 {
 	canid_t inv = *can_id & CAN_INV_FILTER; /* save flag before masking */
 
-	/* filter error frames */
+	/* filter for error frames in extra filterlist */
 	if (*mask & CAN_ERR_FLAG) {
-		/* clear CAN_ERR_FLAG in list entry */
+		/* clear CAN_ERR_FLAG in filter entry */
 		*mask &= CAN_ERR_MASK;
 		return &d->rx[RX_ERR];
 	}
 
-	/* ensure valid values in can_mask */
-	if (*mask & CAN_EFF_FLAG)
-		*mask &= (CAN_EFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG);
-	else
-		*mask &= (CAN_SFF_MASK | CAN_RTR_FLAG);
+	/* with cleared CAN_ERR_FLAG we have a simple mask/value filterpair */
+
+#define CAN_EFF_RTR_FLAGS (CAN_EFF_FLAG | CAN_RTR_FLAG)
+
+	/* ensure valid values in can_mask for 'SFF only' frame filtering */
+	if ((*mask & CAN_EFF_FLAG) && !(*can_id & CAN_EFF_FLAG))
+		*mask &= (CAN_SFF_MASK | CAN_EFF_RTR_FLAGS);
 
 	/* reduce condition testing at receive time */
 	*can_id &= *mask;
@@ -348,15 +377,19 @@ static struct hlist_head *find_rcv_list(canid_t *can_id, canid_t *mask,
 	if (!(*mask))
 		return &d->rx[RX_ALL];
 
-	/* use extra filterset for the subscription of exactly *ONE* can_id */
-	if (*can_id & CAN_EFF_FLAG) {
-		if (*mask == (CAN_EFF_MASK | CAN_EFF_FLAG)) {
-			/* RFC: a use-case for hash-tables in the future? */
-			return &d->rx[RX_EFF];
+	/* extra filterlists for the subscription of a single non-RTR can_id */
+	if (((*mask & CAN_EFF_RTR_FLAGS) == CAN_EFF_RTR_FLAGS)
+	    && !(*can_id & CAN_RTR_FLAG)) {
+
+		if (*can_id & CAN_EFF_FLAG) {
+			if (*mask == (CAN_EFF_MASK | CAN_EFF_RTR_FLAGS)) {
+				/* RFC: a future use-case for hash-tables? */
+				return &d->rx[RX_EFF];
+			}
+		} else {
+			if (*mask == (CAN_SFF_MASK | CAN_EFF_RTR_FLAGS))
+				return &d->rx_sff[*can_id];
 		}
-	} else {
-		if (*mask == CAN_SFF_MASK)
-			return &d->rx_sff[*can_id];
 	}
 
 	/* default: filter via can_id/can_mask */
diff --git a/net/can/bcm.c b/net/can/bcm.c
index d0dd382..da0d426 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -64,10 +64,11 @@
 #define BCM_CAN_DLC_MASK 0x0F /* clean private flags in can_dlc by masking */
 
 /* get best masking value for can_rx_register() for a given single can_id */
-#define REGMASK(id) ((id & CAN_RTR_FLAG) | ((id & CAN_EFF_FLAG) ? \
-			(CAN_EFF_MASK | CAN_EFF_FLAG) : CAN_SFF_MASK))
+#define REGMASK(id) ((id & CAN_EFF_FLAG) ? \
+		     (CAN_EFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG) : \
+		     (CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG))
 
-#define CAN_BCM_VERSION "20080415"
+#define CAN_BCM_VERSION CAN_VERSION
 static __initdata const char banner[] = KERN_INFO
 	"can: broadcast manager protocol (rev " CAN_BCM_VERSION ")\n";
 

--------------020504090804000801040702--
