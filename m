From: Joe Perches <joe@perches.com>
Subject: [PATCH] bridge: netfilter: spanning tree: Add masked_ether_addr_equal and neatening
Date: Wed, 15 Jun 2016 13:58:45 -0700
Message-ID: <f39576f17e9f5dee35258917917f2d740e820a77.1466024030.git.joe@perches.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0101.hostedemail.com ([216.40.44.101]:53536 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752901AbcFOU6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 16:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is code duplication of a masked ethernet address comparison here
so make it a separate function instead.

Miscellanea:

o Neaten alignment of FWINV macro uses to make it clearer for the reader

Signed-off-by: Joe Perches <joe@perches.com>
---

This masked_ether_addr_equal function could go into etherdevice.h,
but I don't see another use like it in kernel code.  Is there one?

 net/bridge/netfilter/ebt_stp.c | 62 ++++++++++++++++++++++++------------------
 1 file changed, 35 insertions(+), 27 deletions(-)

diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index e77f90b..46c3b5d 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -40,13 +40,25 @@ struct stp_config_pdu {
 #define NR16(p) (p[0] << 8 | p[1])
 #define NR32(p) ((p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3])
 
+static bool masked_ether_addr_equal(const u8 *addr1, const u8 *addr2,
+				    const u8 *mask)
+{
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		if ((addr1[i] ^ addr2[i]) & mask[i])
+			return false;
+	}
+
+	return true;
+}
+
 static bool ebt_filter_config(const struct ebt_stp_info *info,
 			      const struct stp_config_pdu *stpc)
 {
 	const struct ebt_stp_config_info *c;
 	u16 v16;
 	u32 v32;
-	int verdict, i;
 
 	c = &info->config;
 	if ((info->bitmask & EBT_STP_FLAGS) &&
@@ -54,66 +66,62 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
 		return false;
 	if (info->bitmask & EBT_STP_ROOTPRIO) {
 		v16 = NR16(stpc->root);
-		if (FWINV(v16 < c->root_priol ||
-		    v16 > c->root_priou, EBT_STP_ROOTPRIO))
+		if (FWINV(v16 < c->root_priol || v16 > c->root_priou,
+			  EBT_STP_ROOTPRIO))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_ROOTADDR) {
-		verdict = 0;
-		for (i = 0; i < 6; i++)
-			verdict |= (stpc->root[2+i] ^ c->root_addr[i]) &
-				   c->root_addrmsk[i];
-		if (FWINV(verdict != 0, EBT_STP_ROOTADDR))
+		if (FWINV(!masked_ether_addr_equal(&stpc->root[2], c->root_addr,
+						   c->root_addrmsk),
+			  EBT_STP_ROOTADDR))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_ROOTCOST) {
 		v32 = NR32(stpc->root_cost);
-		if (FWINV(v32 < c->root_costl ||
-		    v32 > c->root_costu, EBT_STP_ROOTCOST))
+		if (FWINV(v32 < c->root_costl || v32 > c->root_costu,
+			  EBT_STP_ROOTCOST))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_SENDERPRIO) {
 		v16 = NR16(stpc->sender);
-		if (FWINV(v16 < c->sender_priol ||
-		    v16 > c->sender_priou, EBT_STP_SENDERPRIO))
+		if (FWINV(v16 < c->sender_priol || v16 > c->sender_priou,
+			  EBT_STP_SENDERPRIO))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_SENDERADDR) {
-		verdict = 0;
-		for (i = 0; i < 6; i++)
-			verdict |= (stpc->sender[2+i] ^ c->sender_addr[i]) &
-				   c->sender_addrmsk[i];
-		if (FWINV(verdict != 0, EBT_STP_SENDERADDR))
+		if (FWINV(!masked_ether_addr_equal(&stpc->sender[2],
+						   c->sender_addr,
+						   c->sender_addrmsk),
+			  EBT_STP_SENDERADDR))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_PORT) {
 		v16 = NR16(stpc->port);
-		if (FWINV(v16 < c->portl ||
-		    v16 > c->portu, EBT_STP_PORT))
+		if (FWINV(v16 < c->portl || v16 > c->portu, EBT_STP_PORT))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_MSGAGE) {
 		v16 = NR16(stpc->msg_age);
-		if (FWINV(v16 < c->msg_agel ||
-		    v16 > c->msg_ageu, EBT_STP_MSGAGE))
+		if (FWINV(v16 < c->msg_agel || v16 > c->msg_ageu,
+			  EBT_STP_MSGAGE))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_MAXAGE) {
 		v16 = NR16(stpc->max_age);
-		if (FWINV(v16 < c->max_agel ||
-		    v16 > c->max_ageu, EBT_STP_MAXAGE))
+		if (FWINV(v16 < c->max_agel || v16 > c->max_ageu,
+			  EBT_STP_MAXAGE))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_HELLOTIME) {
 		v16 = NR16(stpc->hello_time);
-		if (FWINV(v16 < c->hello_timel ||
-		    v16 > c->hello_timeu, EBT_STP_HELLOTIME))
+		if (FWINV(v16 < c->hello_timel || v16 > c->hello_timeu,
+			  EBT_STP_HELLOTIME))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_FWDD) {
 		v16 = NR16(stpc->forward_delay);
-		if (FWINV(v16 < c->forward_delayl ||
-		    v16 > c->forward_delayu, EBT_STP_FWDD))
+		if (FWINV(v16 < c->forward_delayl || v16 > c->forward_delayu,
+			  EBT_STP_FWDD))
 			return false;
 	}
 	return true;
-- 
2.8.0.rc4.16.g56331f8
