From: frank.blaschka@de.ibm.com
Subject: [patch 1/8] [PATCH] qeth: IP address takeover flag setting
Date: Fri, 23 Jul 2010 11:15:03 +0200
Message-ID: <20100723091549.729460000@de.ibm.com>
References: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:50808 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552Ab0GWJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:52 -0400
Content-Disposition: inline; filename=612-qeth-ip-takeover.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibmc.om>

The qeth IP address flag setting is possible when device is 
offline. When setting device online afterwards the current set
IP addresses have to be correctly registered with the device
regarding the IP address takeover attribute.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    3 +--
 drivers/s390/net/qeth_core_main.c |    7 +------
 drivers/s390/net/qeth_l3.h        |    1 +
 drivers/s390/net/qeth_l3_main.c   |    2 +-
 drivers/s390/net/qeth_l3_sys.c    |   14 ++++++++++++++
 5 files changed, 18 insertions(+), 9 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-07-22 10:22:33.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-07-22 10:22:34.000000000 +0200
@@ -188,8 +188,7 @@ static inline int qeth_is_ipa_enabled(st
 		qeth_is_enabled6(c, f) : qeth_is_enabled(c, f))
 
 #define QETH_IDX_FUNC_LEVEL_OSD		 0x0101
-#define QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT 0x4108
-#define QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT 0x5108
+#define QETH_IDX_FUNC_LEVEL_IQD		 0x4108
 
 #define QETH_MODELLIST_ARRAY \
 	{{0x1731, 0x01, 0x1732, QETH_CARD_TYPE_OSD, QETH_MAX_QUEUES, 0}, \
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:34.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-07-22 10:22:34.000000000 +0200
@@ -1383,12 +1383,7 @@ static void qeth_init_func_level(struct 
 {
 	switch (card->info.type) {
 	case QETH_CARD_TYPE_IQD:
-		if (card->ipato.enabled)
-			card->info.func_level =
-				QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT;
-		else
-			card->info.func_level =
-				QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT;
+		card->info.func_level =	QETH_IDX_FUNC_LEVEL_IQD;
 		break;
 	case QETH_CARD_TYPE_OSD:
 	case QETH_CARD_TYPE_OSN:
diff -urpN linux-2.6/drivers/s390/net/qeth_l3.h linux-2.6-patched/drivers/s390/net/qeth_l3.h
--- linux-2.6/drivers/s390/net/qeth_l3.h	2010-05-16 23:17:36.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3.h	2010-07-22 10:22:34.000000000 +0200
@@ -64,5 +64,6 @@ void qeth_l3_del_rxip(struct qeth_card *
 			const u8 *);
 int qeth_l3_set_large_send(struct qeth_card *, enum qeth_large_send_types);
 int qeth_l3_set_rx_csum(struct qeth_card *, enum qeth_checksum_types);
+int qeth_l3_is_addr_covered_by_ipato(struct qeth_card *, struct qeth_ipaddr *);
 
 #endif /* __QETH_L3_H__ */
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2010-07-22 10:22:33.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2010-07-22 10:22:34.000000000 +0200
@@ -195,7 +195,7 @@ static void qeth_l3_convert_addr_to_bits
 	}
 }
 
-static int qeth_l3_is_addr_covered_by_ipato(struct qeth_card *card,
+int qeth_l3_is_addr_covered_by_ipato(struct qeth_card *card,
 						struct qeth_ipaddr *addr)
 {
 	struct qeth_ipato_entry *ipatoe;
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_sys.c linux-2.6-patched/drivers/s390/net/qeth_l3_sys.c
--- linux-2.6/drivers/s390/net/qeth_l3_sys.c	2010-07-22 10:22:12.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_sys.c	2010-07-22 10:22:34.000000000 +0200
@@ -479,6 +479,7 @@ static ssize_t qeth_l3_dev_ipato_enable_
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
+	struct qeth_ipaddr *tmpipa, *t;
 	char *tmp;
 	int rc = 0;
 
@@ -497,8 +498,21 @@ static ssize_t qeth_l3_dev_ipato_enable_
 		card->ipato.enabled = (card->ipato.enabled)? 0 : 1;
 	} else if (!strcmp(tmp, "1")) {
 		card->ipato.enabled = 1;
+		list_for_each_entry_safe(tmpipa, t, card->ip_tbd_list, entry) {
+			if ((tmpipa->type == QETH_IP_TYPE_NORMAL) &&
+				qeth_l3_is_addr_covered_by_ipato(card, tmpipa))
+				tmpipa->set_flags |=
+					QETH_IPA_SETIP_TAKEOVER_FLAG;
+		}
+
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.enabled = 0;
+		list_for_each_entry_safe(tmpipa, t, card->ip_tbd_list, entry) {
+			if (tmpipa->set_flags &
+				QETH_IPA_SETIP_TAKEOVER_FLAG)
+				tmpipa->set_flags &=
+					~QETH_IPA_SETIP_TAKEOVER_FLAG;
+		}
 	} else
 		rc = -EINVAL;
 out:

