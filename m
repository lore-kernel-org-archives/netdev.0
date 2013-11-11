From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 06:39:47 -0800
Message-ID: <1384180787.16391.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	 <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.29720.673157.151074@gargle.gargle.HOWL>
	 <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.37647.979237.40802@gargle.gargle.HOWL>
	 <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Taht <dave.taht@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Sujith Manoharan <sujith@msujith.org>,
	Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36375 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab3KKOjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 09:39:48 -0500
Received: by mail-pd0-f180.google.com with SMTP id v10so1179333pde.25
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 06:39:48 -0800 (PST)
In-Reply-To: <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 06:27 -0800, Eric Dumazet wrote:
> On Mon, 2013-11-11 at 13:49 +0530, Sujith Manoharan wrote:
> 
> > I am not really clear on how this regression can be fixed in the driver
> > since the majority of the transmission/aggregation logic is present in the
> > TX completion path.
> 
> We have many choices.
> 
> 1) Add back a minimum of ~128 K of outstanding bytes per TCP session,
>    so that buggy drivers can sustain 'line rate'.
> 
>    Note that with 100 concurrent TCP streams, total amount of bytes
>    queued on the NIC is 12 MB.
>    And pfifo_fast qdisc will drop packets anyway.
> 
>    Thats what we call 'BufferBloat'
> 
> 2) Try lower values like 64K. Still bufferbloat.
> 
> 3) Fix buggy drivers, using a proper logic, or shorter timers (mvneta
> case for example)
> 
> 4) Add a new netdev attribute, so that well behaving NIC drivers do not
> have to artificially force TCP stack to queue too many bytes in
> Qdisc/NIC queues.

How following patch helps mvneta performance on current net-next tree
for a single TCP (sending) flow ?



diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 7d99e695a110..002ac464202f 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -172,12 +172,11 @@
 /* Various constants */
 
 /* Coalescing */
-#define MVNETA_TXDONE_COAL_PKTS		16
 #define MVNETA_RX_COAL_PKTS		32
 #define MVNETA_RX_COAL_USEC		100
 
 /* Timer */
-#define MVNETA_TX_DONE_TIMER_PERIOD	10
+#define MVNETA_TX_DONE_TIMER_PERIOD	1
 
 /* Napi polling weight */
 #define MVNETA_RX_POLL_WEIGHT		64
@@ -1592,8 +1591,7 @@ out:
 		dev_kfree_skb_any(skb);
 	}
 
-	if (txq->count >= MVNETA_TXDONE_COAL_PKTS)
-		mvneta_txq_done(pp, txq);
+	mvneta_txq_done(pp, txq);
 
 	/* If after calling mvneta_txq_done, count equals
 	 * frags, we need to set the timer
