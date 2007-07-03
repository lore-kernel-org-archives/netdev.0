From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Mon, 02 Jul 2007 17:21:21 -0700
Message-ID: <1183422081.4947.14.camel@dell>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
 <1181216629.4064.22.camel@localhost>
 <20070619132148.GA32078@2ka.mipt.ru>
 <20070619133333.GA19667@2ka.mipt.ru>
 <20070619140038.GA13629@2ka.mipt.ru>
 <1182270529.4968.73.camel@localhost>
 <18040.5105.715624.286924@robur.slu.se>
 <1182275300.4968.83.camel@localhost>
 <1182989145.5155.81.camel@localhost>
 <1183411245.6609.16.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "Robert Olsson" <Robert.Olsson@data.slu.se>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Gagan Arneja" <gaagaan@gmail.com>,
	"netdev" <netdev@vger.kernel.org>,
	"Rick Jones" <rick.jones2@hp.com>,
	"Sridhar Samudrala" <sri@us.ibm.com>,
	"David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3754 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388AbXGBX3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 19:29:22 -0400
In-Reply-To: <1183411245.6609.16.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-02 at 14:20 -0700, Matt Carlson wrote:

> 
> Also, I think the count, max_per_txd, and nr_frags fields of the
> tg3_tx_cbdata struct are not needed.

The count field is not needed also.

+struct tg3_tx_cbdata {
+	u32 base_flags;
+	int count;
+	unsigned int max_per_txd;
+	unsigned int nr_frags;
+	unsigned int mss;
+};
+#define TG3_SKB_CB(__skb)       ((struct tg3_tx_cbdata *)&((__skb)->cb[0]))

Only base_flags and mss are needed and these can be determined right
before sending the frame.  So is it better not to store these in the
skb->cb at all?

@@ -3118,12 +3120,16 @@ static void tg3_tx(struct tg3 *tp)
 	 */
 	smp_mb();
 
+	dcount = tg3_tx_avail(tp);
 	if (unlikely(netif_queue_stopped(tp->dev) &&
-		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
+		     (dcount > TG3_TX_WAKEUP_THRESH(tp)))) {
 		netif_tx_lock(tp->dev);
+		tp->dev->xmit_win = 1;
 		if (netif_queue_stopped(tp->dev) &&
-		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
+		    (dcount > TG3_TX_WAKEUP_THRESH(tp))) {
 			netif_wake_queue(tp->dev);
+			tp->dev->xmit_win = dcount;
+		}
 		netif_tx_unlock(tp->dev);
 	}
 }

This is also not right.  tg3_tx() runs without netif_tx_lock().
tg3_tx_avail() can change after you get the netif_tx_lock() and we must
get the updated value again.  If we just rely on dcount, we can call
wake_queue() when the ring is full, or there may be no wakeup when the
ring is empty.



