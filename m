From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] isdn_ppp: Use common error handling code in
 isdn_ppp_receive()
Date: Thu, 26 Oct 2017 22:40:04 +0200
Message-ID: <d4bf9f0e-7d68-d10a-aa0c-d6b6fa131183@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "David S. Miller" <davem@davemloft.net>,
        Geliang Tang <geliangtang@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Karsten Keil <isdn@linux-pingi.de>,
        Meng Xu <mengxu.gatech@gmail.com>,
        Yuan Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 26 Oct 2017 22:30:50 +0200

Add a jump target so that a bit of exception handling can be better reused
at the end of this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/i4l/isdn_ppp.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index cd2b3c69771a..e3348fdde32a 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1017,8 +1017,7 @@ void isdn_ppp_receive(isdn_net_dev *net_dev, isdn_net_local *lp, struct sk_buff
 	if (slot < 0 || slot >= ISDN_MAX_CHANNELS) {
 		printk(KERN_ERR "isdn_ppp_receive: lp->ppp_slot(%d)\n",
 		       lp->ppp_slot);
-		kfree_skb(skb);
-		return;
+		goto free_skb;
 	}
 	is = ippp_table[slot];
 
@@ -1028,15 +1027,12 @@ void isdn_ppp_receive(isdn_net_dev *net_dev, isdn_net_local *lp, struct sk_buff
 		isdn_ppp_frame_log("receive", skb->data, skb->len, 32, is->unit, lp->ppp_slot);
 	}
 
-	if (isdn_ppp_skip_ac(is, skb) < 0) {
-		kfree_skb(skb);
-		return;
-	}
+	if (isdn_ppp_skip_ac(is, skb) < 0)
+		goto free_skb;
+
 	proto = isdn_ppp_strip_proto(skb);
-	if (proto < 0) {
-		kfree_skb(skb);
-		return;
-	}
+	if (proto < 0)
+		goto free_skb;
 
 #ifdef CONFIG_ISDN_MPP
 	if (is->compflags & SC_LINK_DECOMP_ON) {
@@ -1053,6 +1049,10 @@ void isdn_ppp_receive(isdn_net_dev *net_dev, isdn_net_local *lp, struct sk_buff
 	}
 #endif
 	isdn_ppp_push_higher(net_dev, lp, skb, proto);
+	return;
+
+free_skb:
+	kfree_skb(skb);
 }
 
 /*
-- 
2.14.3
