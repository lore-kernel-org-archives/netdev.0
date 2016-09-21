From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net] act_ife: Add support for machines with hard_header_len != mac_len
Date: Wed, 21 Sep 2016 15:54:13 +0300
Message-ID: <1474462453-37668-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yotam Gigi <yotamg@mellanox.com>
To: <jhs@mojatatu.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0068.outbound.protection.outlook.com ([104.47.2.68]:45568
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752360AbcIUQZG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 12:25:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without that fix, the following could occur:
 - On encode ingress, the total amount of skb_pushes (in lines 751 and
   753) was more than specified in cow.
 - On machines with hard_header_len > mac_len, the packet format was not
   according to the ife specifications, as the place reserved at the
   beginning of the packet is for hard_header_len, but only mac_len bytes
   get initialized in it. Acting upon simple ping packet, The following
   tc commands:

   tc qdisc add dev sw1p5 handle 1: root prio
   tc filter add dev sw1p5 parent 1: protocol ip \
		matchall skip_hw \
		action ife encode type 0xdead use mark 0x12

   when netdev sw1p5 has hard_header_len of 30, created the following
   packet:

   0x0000:  e41d 2da5 f1d3 e41d 2d46 ffb5 dead 0000  ..-.....-F......
   0x0010:  0000 0000 0000 0000 0000 0000 0000 000a  ................
   0x0020:  0001 0004 0000 0012 e41d 2da5 f1d3 e41d  ..........-.....
   0x0031:  2d46 ffb5 0800 4500 0054 55e9 4000 4001  -F....E..TU.@.@.
   0x0040:  ceba 0b00 0005 0b00 0001 0800 d2ea 63b7  ..............c.
   0x0050:  0002 a360 e257 0000 0000 7ad0 0200 0000  ...`.W....z.....
   0x0060:  0000 1011 1213 1415 1617 1819 1a1b 1c1d  ................
   0x0070:  1e1f 2021 2223 2425 2627 2829 2a2b 2c2d  ...!"#$%&'()*+,-
   0x0080:  2e2f 3031 3233 3435 3637                 ./01234567

   and it can be seen that bytes 0x0e to 0x01e are not initialized and
   contain random memory data, where bytes 0x01e to 0x028 contain the ife
   header.

To fix those problems, add the total_push and reserve variables, which
indicates the exact amount of pushes needed and the exact amount of
headroom the packet should have. Thus, it is possible to take care of the
cases:
 - on ingress, the mac header must be pushed back as the ingress parser
   already parses the mac header and pulls it
 - on egress, the code should reserve hard_header_len space extra in
   headroom for driver to put the rest of the headers

Fixes: ef6980b6becb ("net sched: introduce IFE action")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/sched/act_ife.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index e87cd81..27b19ca 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -708,11 +708,13 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	   where ORIGDATA = original ethernet header ...
 	 */
 	u16 metalen = ife_get_sz(skb, ife);
-	int hdrm = metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
-	unsigned int skboff = skb->dev->hard_header_len;
 	u32 at = G_TC_AT(skb->tc_verd);
-	int new_len = skb->len + hdrm;
 	bool exceed_mtu = false;
+	unsigned int skboff;
+	int total_push;
+	int reserve;
+	int new_len;
+	int hdrm;
 	int err;
 
 	if (at & AT_EGRESS) {
@@ -724,6 +726,22 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	bstats_update(&ife->tcf_bstats, skb);
 	tcf_lastuse_update(&ife->tcf_tm);
 
+	if (at & AT_EGRESS) {
+		/* on egress, reserve space for hard_header_len instead of
+		 * mac_len
+		 */
+		skb_reset_mac_len(skb);
+		hdrm = metalen + skb->mac_len + IFE_METAHDRLEN;
+		total_push = hdrm;
+		reserve = metalen + skb->dev->hard_header_len + IFE_METAHDRLEN;
+	} else {
+		/* on ingress, push mac_len as it already get parsed from tc */
+		hdrm = metalen + skb->mac_len + IFE_METAHDRLEN;
+		total_push = hdrm + skb->mac_len;
+		reserve = total_push;
+	}
+	new_len =  skb->len + hdrm;
+
 	if (!metalen) {		/* no metadata to send */
 		/* abuse overlimits to count when we allow packet
 		 * with no metadata
@@ -742,19 +760,17 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 
 	iethh = eth_hdr(skb);
 
-	err = skb_cow_head(skb, hdrm);
+	err = skb_cow_head(skb, reserve);
 	if (unlikely(err)) {
 		ife->tcf_qstats.drops++;
 		spin_unlock(&ife->tcf_lock);
 		return TC_ACT_SHOT;
 	}
 
-	if (!(at & AT_EGRESS))
-		skb_push(skb, skb->dev->hard_header_len);
-
-	__skb_push(skb, hdrm);
+	__skb_push(skb, total_push);
 	memcpy(skb->data, iethh, skb->mac_len);
 	skb_reset_mac_header(skb);
+	skboff += skb->mac_len;
 	oethh = eth_hdr(skb);
 
 	/*total metadata length */
@@ -792,7 +808,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 	oethh->h_proto = htons(ife->eth_type);
 
 	if (!(at & AT_EGRESS))
-		skb_pull(skb, skb->dev->hard_header_len);
+		skb_pull(skb, skb->mac_len);
 
 	spin_unlock(&ife->tcf_lock);
 
-- 
2.4.11
