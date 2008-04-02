From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 19:00:25 +0900
Message-ID: <20080402175857.959A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080402171104.9591.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080402.012406.246863209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org,
	csnook@redhat.com, davej@codemonkey.org.uk,
	nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:33960 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbYDBKBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 06:01:01 -0400
In-Reply-To: <20080402.012406.246863209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

> > if network guys hope known-good driver should call 
> > __netdev_alloc_skb(dev, length, GFP_ATOMIC|__GFP_NOWARN) instead netdev_alloc_skb,
> > I think we should make netdev_alloc_skb_nowarn.
> 
> Giving it a proper name like this takes away the indication that this
> situation is very special.

Hmmm,

at least, tg3 driver often output the same message on my test environment.
(because I often run stress test ;)
I doubt almost driver has the same problem under heavy workload.

and I think tg3 is known-good driver too.
because its alloc failure doesn't cause any bad thing at all.

Do you favorite the following patch?


---------------------------------------------------------------------
We get rather a lot of reports of page allocation warnings coming out of
tg3.  But this driver is know to handle them properly so let's suppress
them.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Miller <davem@davemloft.net>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

Index: b/drivers/net/tg3.c
===================================================================
--- a/drivers/net/tg3.c 2008-03-14 21:38:12.000000000 +0900
+++ b/drivers/net/tg3.c 2008-04-02 18:54:15.000000000 +0900
@@ -307,6 +307,11 @@ static const struct {
        { "interrupt test (offline)" },
 };

+static inline void *tg3_alloc_skb(struct net_device *dev, unsigned int length)
+{
+       return __netdev_alloc_skb(dev, length, GFP_ATOMIC|__GFP_NOWARN);
+}
+
 static void tg3_write32(struct tg3 *tp, u32 off, u32 val)
 {
        writel(val, tp->regs + off);
@@ -3437,7 +3442,7 @@ static int tg3_alloc_rx_skb(struct tg3 *
         * Callers depend upon this behavior and assume that
         * we leave everything unchanged if we fail.
         */
-       skb = netdev_alloc_skb(tp->dev, skb_size);
+       skb = tg3_alloc_skb(tp->dev, skb_size);
        if (skb == NULL)
                return -ENOMEM;
@@ -3609,7 +3614,7 @@ static int tg3_rx(struct tg3 *tp, int bu
                        tg3_recycle_rx(tp, opaque_key,
                                       desc_idx, *post_ptr);

-                       copy_skb = netdev_alloc_skb(tp->dev, len + 2);
+                       copy_skb = tg3_alloc_skb(tp->dev, len + 2);
                        if (copy_skb == NULL)
                                goto drop_it_no_recycle;

@@ -9370,7 +9375,7 @@ static int tg3_run_loopback(struct tg3 *
        err = -EIO;

        tx_len = 1514;
-       skb = netdev_alloc_skb(tp->dev, tx_len);
+       skb = tg3_alloc_skb(tp->dev, tx_len);
        if (!skb)
                return -ENOMEM;


