From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] [PATCH] qeth: recognize vlan devices in layer3 mode
Date: Wed, 16 May 2012 13:28:26 +0200
Message-ID: <20120516112915.623908890@de.ibm.com>
References: <20120516112824.602200177@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:49759 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030271Ab2EPL3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 07:29:36 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 16 May 2012 12:29:35 +0100
Content-Disposition: inline; filename=600-qeth-vlan-layer3.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qeth layer3 driver is notified about IP address changes.
Changes concerning qeth driven network interfaces have to be
forwarded to the OSA-card. This includes IP addresses of VLAN
interfaces with a qeth device as base device. Function
qeth_l3_verify_vlan_dev() determines if the net_device of the
IP event belongs to a vlan device belonging to a qeth device
as real device. This function is broken starting with commit
7ff0bcf676f7ed224ce21b58c7858c8e527068b2 , which means IP
addresses of VLAN devices are no longer set at the base qeth
device. The patch repairs function qeth_l3_verify_vlan_dev().

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2073,7 +2073,7 @@ static int qeth_l3_verify_vlan_dev(struc
 		struct net_device *netdev;
 
 		rcu_read_lock();
-		netdev = __vlan_find_dev_deep(dev, vid);
+		netdev = __vlan_find_dev_deep(card->dev, vid);
 		rcu_read_unlock();
 		if (netdev == dev) {
 			rc = QETH_VLAN_CARD;
@@ -3602,9 +3602,9 @@ static int qeth_l3_ip_event(struct notif
 		return NOTIFY_DONE;
 
 	card = qeth_l3_get_card_from_dev(dev);
-	QETH_CARD_TEXT(card, 3, "ipevent");
 	if (!card)
 		return NOTIFY_DONE;
+	QETH_CARD_TEXT(card, 3, "ipevent");
 
 	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
 	if (addr != NULL) {
