From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/5] qede: Add support for handling IP fragmented packets.
Date: Thu, 30 Jun 2016 02:35:18 -0400
Message-ID: <1467268522-24589-2-git-send-email-manish.chopra@qlogic.com>
References: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34722 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750937AbcF3HTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 03:19:51 -0400
In-Reply-To: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling IP fragmented packets with csum in their
transport header, the csum isn't changed as part of the
fragmentation. As a result, the packet containing the
transport headers would have the correct csum of the original
packet, but one that mismatches the actual packet that
passes on the wire. As a result, on receive path HW would
give an indication that the packet has incorrect csum,
which would cause qede to discard the incoming packet.

Since HW also delivers a notification of IP fragments,
change driver behavior to pass such incoming packets
to stack and let it make the decision whether it needs
to be dropped.

Signed-off-by: Manish <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  1 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 21 +++++++++++++++++++++
 3 files changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 1441c8f..677213e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -235,6 +235,7 @@ struct qede_rx_queue {
 
 	u64			rx_hw_errors;
 	u64			rx_alloc_errors;
+	u64			rx_ip_frags;
 };
 
 union db_prod {
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 6228482..f59322c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -37,6 +37,7 @@ static const struct {
 } qede_rqstats_arr[] = {
 	QEDE_RQSTAT(rx_hw_errors),
 	QEDE_RQSTAT(rx_alloc_errors),
+	QEDE_RQSTAT(rx_ip_frags),
 };
 
 #define QEDE_NUM_RQSTATS ARRAY_SIZE(qede_rqstats_arr)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 2972742..f476cd0 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1348,6 +1348,20 @@ static u8 qede_check_csum(u16 flag)
 		return qede_check_tunn_csum(flag);
 }
 
+static bool qede_pkt_is_ip_fragmented(struct eth_fast_path_rx_reg_cqe *cqe,
+				      u16 flag)
+{
+	u8 tun_pars_flg = cqe->tunnel_pars_flags.flags;
+
+	if ((tun_pars_flg & (ETH_TUNNEL_PARSING_FLAGS_IPV4_FRAGMENT_MASK <<
+			     ETH_TUNNEL_PARSING_FLAGS_IPV4_FRAGMENT_SHIFT)) ||
+	    (flag & (PARSING_AND_ERR_FLAGS_IPV4FRAG_MASK <<
+		     PARSING_AND_ERR_FLAGS_IPV4FRAG_SHIFT)))
+		return true;
+
+	return false;
+}
+
 static int qede_rx_int(struct qede_fastpath *fp, int budget)
 {
 	struct qede_dev *edev = fp->edev;
@@ -1426,6 +1440,12 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 
 		csum_flag = qede_check_csum(parse_flag);
 		if (unlikely(csum_flag == QEDE_CSUM_ERROR)) {
+			if (qede_pkt_is_ip_fragmented(&cqe->fast_path_regular,
+						      parse_flag)) {
+				rxq->rx_ip_frags++;
+				goto alloc_skb;
+			}
+
 			DP_NOTICE(edev,
 				  "CQE in CONS = %u has error, flags = %x, dropping incoming packet\n",
 				  sw_comp_cons, parse_flag);
@@ -1434,6 +1454,7 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 			goto next_cqe;
 		}
 
+alloc_skb:
 		skb = netdev_alloc_skb(edev->ndev, QEDE_RX_HDR_SIZE);
 		if (unlikely(!skb)) {
 			DP_NOTICE(edev,
-- 
2.7.2
