From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 1e918876 breaks r8169 (linux-3.18+)
Date: Sat, 21 Feb 2015 11:54:07 -0800
Message-ID: <1424548447.5565.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150203100816.GA5807@louise.pinerecords.com>
	 <20150203104214.GG24751@breakpoint.cc>
	 <20150210154536.GB16264@breakpoint.cc>
	 <20150221101512.GB17223@louise.pinerecords.com>
	 <20150221103104.GA26574@breakpoint.cc>
	 <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150221190507.GA25687@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marco Berizzi <pupilla@hotmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Tomas Szepe <szepe@pinerecords.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150221190507.GA25687@louise.pinerecords.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-02-21 at 20:05 +0100, Tomas Szepe wrote:

> Sure, just did.  Unfortunately, 3.19.0 + 0bec3b70 + this patch results
> in a driver that retains the problem.

OK, could you test following patch instead ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ad0020af2193..18d0decb5093 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7050,6 +7050,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	u32 opts[2];
 	int frags;
 	bool stop_queue;
+	bool xmit_more;
 
 	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
@@ -7091,7 +7092,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	txd->opts2 = cpu_to_le32(opts[1]);
 
 	netdev_sent_queue(dev, skb->len);
-
+	xmit_more = skb->xmit_more;
 	skb_tx_timestamp(skb);
 
 	/* Force memory writes to complete before releasing descriptor */
@@ -7108,7 +7109,14 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	stop_queue = !TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS);
 
-	if (!skb->xmit_more || stop_queue ||
+	if (stop_queue) {
+		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
+		 * not miss a ring update when it notices a stopped queue.
+		 */
+		smp_wmb();
+		netif_stop_queue(dev);
+	}
+	if (!xmit_more ||
 	    netif_xmit_stopped(netdev_get_tx_queue(dev, 0))) {
 		RTL_W8(TxPoll, NPQ);
 
@@ -7116,11 +7124,6 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	}
 
 	if (stop_queue) {
-		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
-		 * not miss a ring update when it notices a stopped queue.
-		 */
-		smp_wmb();
-		netif_stop_queue(dev);
 		/* Sync with rtl_tx:
 		 * - publish queue status and cur_tx ring index (write barrier)
 		 * - refresh dirty_tx ring index (read barrier).
