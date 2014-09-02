From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH net] qeth: don't query for info if hardware not ready.
Date: Tue, 2 Sep 2014 08:20:17 +0200
Message-ID: <20140902062017.GA23360@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:50742 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbaIBGUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 02:20:22 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Tue, 2 Sep 2014 07:20:20 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

When qeth device is queried for ethtool data, hardware operation
is performed to extract the necessary information from the card.
If the card is not online at the moment (e.g. it is undergoing
recovery), this operation produces undesired effects like
temporarily freezing the system. This patch prevents execution
of the hardware query operation when the card is not online.
In such case, ioctl() operation returns error with errno ENODEV.

Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  1 +
 drivers/s390/net/qeth_core_main.c | 16 +++++++++++++++-
 drivers/s390/net/qeth_l2_sys.c    |  7 +------
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 97ef37b..e7646ce 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -889,6 +889,7 @@ extern const struct attribute_group *qeth_generic_attr_groups[];
 extern const struct attribute_group *qeth_osn_attr_groups[];
 extern struct workqueue_struct *qeth_wq;
 
+int qeth_card_hw_is_reachable(struct qeth_card *);
 const char *qeth_get_cardname_short(struct qeth_card *);
 int qeth_realloc_buffer_pool(struct qeth_card *, int);
 int qeth_core_load_discipline(struct qeth_card *, enum qeth_discipline_id);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index c0d6ba8..fd22c81 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -73,6 +73,13 @@ static int qeth_init_qdio_out_buf(struct qeth_qdio_out_q *, int);
 struct workqueue_struct *qeth_wq;
 EXPORT_SYMBOL_GPL(qeth_wq);
 
+int qeth_card_hw_is_reachable(struct qeth_card *card)
+{
+	return (card->state == CARD_STATE_SOFTSETUP) ||
+		(card->state == CARD_STATE_UP);
+}
+EXPORT_SYMBOL_GPL(qeth_card_hw_is_reachable);
+
 static void qeth_close_dev_handler(struct work_struct *work)
 {
 	struct qeth_card *card;
@@ -5790,6 +5797,7 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 	struct qeth_card *card = netdev->ml_priv;
 	enum qeth_link_types link_type;
 	struct carrier_info carrier_info;
+	int rc;
 	u32 speed;
 
 	if ((card->info.type == QETH_CARD_TYPE_IQD) || (card->info.guestlan))
@@ -5832,8 +5840,14 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 	/* Check if we can obtain more accurate information.	 */
 	/* If QUERY_CARD_INFO command is not supported or fails, */
 	/* just return the heuristics that was filled above.	 */
-	if (qeth_query_card_info(card, &carrier_info) != 0)
+	if (!qeth_card_hw_is_reachable(card))
+		return -ENODEV;
+	rc = qeth_query_card_info(card, &carrier_info);
+	if (rc == -EOPNOTSUPP) /* for old hardware, return heuristic */
 		return 0;
+	if (rc) /* report error from the hardware operation */
+		return rc;
+	/* on success, fill in the information got from the hardware */
 
 	netdev_dbg(netdev,
 	"card info: card_type=0x%02x, port_mode=0x%04x, port_speed=0x%08x\n",
diff --git a/drivers/s390/net/qeth_l2_sys.c b/drivers/s390/net/qeth_l2_sys.c
index ae1bc04..59e3aa5 100644
--- a/drivers/s390/net/qeth_l2_sys.c
+++ b/drivers/s390/net/qeth_l2_sys.c
@@ -5,17 +5,12 @@
 
 #include <linux/slab.h>
 #include <asm/ebcdic.h>
+#include "qeth_core.h"
 #include "qeth_l2.h"
 
 #define QETH_DEVICE_ATTR(_id, _name, _mode, _show, _store) \
 struct device_attribute dev_attr_##_id = __ATTR(_name, _mode, _show, _store)
 
-static int qeth_card_hw_is_reachable(struct qeth_card *card)
-{
-	return (card->state == CARD_STATE_SOFTSETUP) ||
-		(card->state == CARD_STATE_UP);
-}
-
 static ssize_t qeth_bridge_port_role_state_show(struct device *dev,
 				struct device_attribute *attr, char *buf,
 				int show_state)
