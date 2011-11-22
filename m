From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-next-2.6] atm: eliminate atm_guess_pdu2truesize()
Date: Tue, 22 Nov 2011 17:51:56 -0500
Message-ID: <201111222251.pAMMpujb007390@cmf.nrl.navy.mil>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:49741 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104Ab1KVWwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 17:52:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
---
 drivers/atm/iphase.c   |    4 ++--
 include/linux/atmdev.h |   10 ----------
 net/atm/atm_misc.c     |    2 +-
 3 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 3d0c2b0..9e373ba 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -1320,8 +1320,8 @@ static void rx_dle_intr(struct atm_dev *dev)
           if (ia_vcc == NULL)
           {
              atomic_inc(&vcc->stats->rx_err);
+             atm_return(vcc, skb->truesize);
              dev_kfree_skb_any(skb);
-             atm_return(vcc, atm_guess_pdu2truesize(len));
              goto INCR_DLE;
            }
           // get real pkt length  pwang_test
@@ -1334,8 +1334,8 @@ static void rx_dle_intr(struct atm_dev *dev)
              atomic_inc(&vcc->stats->rx_err);
              IF_ERR(printk("rx_dle_intr: Bad  AAL5 trailer %d (skb len %d)", 
                                                             length, skb->len);)
+             atm_return(vcc, skb->truesize);
              dev_kfree_skb_any(skb);
-             atm_return(vcc, atm_guess_pdu2truesize(len));
              goto INCR_DLE;
           }
           skb_trim(skb, length);
diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 43ea1b2..f4ff882 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -445,16 +445,6 @@ void vcc_insert_socket(struct sock *sk);
 
 void atm_dev_release_vccs(struct atm_dev *dev);
 
-/*
- * This is approximately the algorithm used by alloc_skb.
- *
- */
-
-static inline int atm_guess_pdu2truesize(int size)
-{
-	return SKB_TRUESIZE(size);
-}
-
 
 static inline void atm_force_charge(struct atm_vcc *vcc,int truesize)
 {
diff --git a/net/atm/atm_misc.c b/net/atm/atm_misc.c
index f41f026..876fbe8 100644
--- a/net/atm/atm_misc.c
+++ b/net/atm/atm_misc.c
@@ -26,7 +26,7 @@ struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc, int pdu_size,
 				 gfp_t gfp_flags)
 {
 	struct sock *sk = sk_atm(vcc);
-	int guess = atm_guess_pdu2truesize(pdu_size);
+	int guess = SKB_TRUESIZE(pdu_size);
 
 	atm_force_charge(vcc, guess);
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf) {
-- 
1.7.6
