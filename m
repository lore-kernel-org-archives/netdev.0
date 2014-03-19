From: frank.blaschka@de.ibm.com
Subject: [patch 4/4] qeth: Fix IP version detection for VLAN traffic
Date: Wed, 19 Mar 2014 07:58:02 +0100
Message-ID: <20140319065813.642817087@de.ibm.com>
References: <20140319065758.841490297@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:54103 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932595AbaCSG6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 02:58:20 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 19 Mar 2014 06:58:18 -0000
Content-Disposition: inline; filename=603-qeth-ip-version-vlan.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

The current code would always return 0 for VLAN-encapsulated IP traffic.
One notable side effect was that VLAN traffic would never get prioritized
on OSD and OSX devices when priority queueing modes prio_queueing_tos or
prio_queueing_prec were enabled.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index a0de045..5333b2c 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -854,8 +854,11 @@ static inline int qeth_get_micros(void)
 
 static inline int qeth_get_ip_version(struct sk_buff *skb)
 {
-	struct ethhdr *ehdr = (struct ethhdr *)skb->data;
-	switch (ehdr->h_proto) {
+	__be16 *p = &((struct ethhdr *)skb->data)->h_proto;
+
+	if (*p == ETH_P_8021Q)
+		p += 2;
+	switch (*p) {
 	case ETH_P_IPV6:
 		return 6;
 	case ETH_P_IP:
