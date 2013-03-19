From: frank.blaschka@de.ibm.com
Subject: [patch 2/3] qeth: Fix invalid router settings handling
Date: Tue, 19 Mar 2013 07:04:43 +0100
Message-ID: <20130319060454.865937233@de.ibm.com>
References: <20130319060441.956271217@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:47721 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933918Ab3CSGFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 02:05:01 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 19 Mar 2013 06:02:55 -0000
Content-Disposition: inline; filename=601-qeth-router-setting.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Give a bad return code when specifying a router setting that is either
invalid or not support on the respective device type. In addition, fall back
the previous setting instead of silently switching back to 'no routing'.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |   17 +++++++++++------
 drivers/s390/net/qeth_l3_sys.c  |    2 ++
 2 files changed, 13 insertions(+), 6 deletions(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -623,7 +623,7 @@ static int qeth_l3_send_setrouting(struc
 	return rc;
 }
 
-static void qeth_l3_correct_routing_type(struct qeth_card *card,
+static int qeth_l3_correct_routing_type(struct qeth_card *card,
 		enum qeth_routing_types *type, enum qeth_prot_versions prot)
 {
 	if (card->info.type == QETH_CARD_TYPE_IQD) {
@@ -632,7 +632,7 @@ static void qeth_l3_correct_routing_type
 		case PRIMARY_CONNECTOR:
 		case SECONDARY_CONNECTOR:
 		case MULTICAST_ROUTER:
-			return;
+			return 0;
 		default:
 			goto out_inval;
 		}
@@ -641,17 +641,18 @@ static void qeth_l3_correct_routing_type
 		case NO_ROUTER:
 		case PRIMARY_ROUTER:
 		case SECONDARY_ROUTER:
-			return;
+			return 0;
 		case MULTICAST_ROUTER:
 			if (qeth_is_ipafunc_supported(card, prot,
 						      IPA_OSA_MC_ROUTER))
-				return;
+				return 0;
 		default:
 			goto out_inval;
 		}
 	}
 out_inval:
 	*type = NO_ROUTER;
+	return -EINVAL;
 }
 
 int qeth_l3_setrouting_v4(struct qeth_card *card)
@@ -660,8 +661,10 @@ int qeth_l3_setrouting_v4(struct qeth_ca
 
 	QETH_CARD_TEXT(card, 3, "setrtg4");
 
-	qeth_l3_correct_routing_type(card, &card->options.route4.type,
+	rc = qeth_l3_correct_routing_type(card, &card->options.route4.type,
 				  QETH_PROT_IPV4);
+	if (rc)
+		return rc;
 
 	rc = qeth_l3_send_setrouting(card, card->options.route4.type,
 				  QETH_PROT_IPV4);
@@ -683,8 +686,10 @@ int qeth_l3_setrouting_v6(struct qeth_ca
 
 	if (!qeth_is_supported(card, IPA_IPV6))
 		return 0;
-	qeth_l3_correct_routing_type(card, &card->options.route6.type,
+	rc = qeth_l3_correct_routing_type(card, &card->options.route6.type,
 				  QETH_PROT_IPV6);
+	if (rc)
+		return rc;
 
 	rc = qeth_l3_send_setrouting(card, card->options.route6.type,
 				  QETH_PROT_IPV6);
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -87,6 +87,8 @@ static ssize_t qeth_l3_dev_route_store(s
 			rc = qeth_l3_setrouting_v6(card);
 	}
 out:
+	if (rc)
+		route->type = old_route_type;
 	mutex_unlock(&card->conf_mutex);
 	return rc ? rc : count;
 }
