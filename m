From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [BUG][mvebu] mvneta: cannot request irq 25 on openblocks-ax3
Date: Tue, 19 Mar 2013 17:43:49 +0100
Message-ID: <514895C5.40706@free-electrons.com>
References: <51486445.8040506@hitachi.com> <20130319133928.GE3137@localhost> <514873FB.5050202@hitachi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060409020006070206050307"
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>,
	Florian Fainelli <florian@openwrt.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <514873FB.5050202@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060409020006070206050307
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 03/19/2013 03:19 PM, Masami Hiramatsu wrote:
> Hi Ezequiel,
> 
> (2013/03/19 22:39), Ezequiel Garcia wrote:
>> Hi Masami,
>>
>> On Tue, Mar 19, 2013 at 10:12:37PM +0900, Masami Hiramatsu wrote:
>>>
>>> Here I've hit a bug on the recent kernel. As far as I know, this bug
>>> exists on 3.9-rc1 too.
>>>
>>> When I tried the latest mvebu for-next tree
>>> (git://git.infradead.org/users/jcooper/linux.git mvebu/for-next),
>>> I got below warning at bootup time and mvneta didn't work (link was never up).
>>> I ensured that "ifconfig ethX up" always caused that.
>>>
>>> Does anyone succeed to boot openblocks-ax3 recently or hit same
>>> trouble?
>>
>> This is a known bug. Gregory Clement already has a fix and he
>> will submit it soon. In case you need this fixed ASAP, I'm attaching
>> you a patch with a fix.
> 
> Thanks! I'll try that.
> 
>> Please note the attached patch is not ready for mainline inclusion,
>> as I said Gregory will submit a cleaner version soon.
> 
> Yeah, I look forward to it :)

Hi Masami,

You can try this patch if you want.
I don't have the hardware today so I didn't test it.
If you (and also Florian and Ezequiel) can test it and if it fixed
the bug, then I will be able send a proper email for it,

Thanks,
-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com


--------------060409020006070206050307
Content-Type: text/x-diff;
 name="0001-net-mvneta-convert-to-local-interrupt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-net-mvneta-convert-to-local-interrupt.patch"

>From a82800cbd4f2ff34a4a03c8caa688149b8770ab7 Mon Sep 17 00:00:00 2001
From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Tue, 19 Mar 2013 15:11:48 +0100
Subject: [PATCH] net: mvneta: convert to local interrupt

Since commit 3a6f08a37 "arm: mvebu: Add support for local interrupt",
the mvneta interrupt is now managed as a local interrupt. That means
that the driver have to use the request_percpu_irq() function instead
of request_irq().

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c |   26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index cd345b8..ad64a50 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -256,6 +256,8 @@ struct mvneta_port {
 	unsigned int link;
 	unsigned int duplex;
 	unsigned int speed;
+
+	struct mvneta_port __percpu **percpu_pp;
 };
 
 /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
@@ -1799,7 +1801,7 @@ static void mvneta_set_rx_mode(struct net_device *dev)
 /* Interrupt handling - the callback for request_irq() */
 static irqreturn_t mvneta_isr(int irq, void *dev_id)
 {
-	struct mvneta_port *pp = (struct mvneta_port *)dev_id;
+	struct mvneta_port *pp = *(struct mvneta_port **)dev_id;
 
 	/* Mask all interrupts */
 	mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
@@ -2371,8 +2373,19 @@ static void mvneta_mdio_remove(struct mvneta_port *pp)
 static int mvneta_open(struct net_device *dev)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
+
 	int ret;
 
+	/* As the mvneta interrupts are locals, we need to create a
+	 * percpu variable
+	 */
+	pp->percpu_pp = alloc_percpu(struct mvneta_port *);
+	if (!pp) {
+		ret = -ENOMEM;
+		goto err_percpu_alloc;
+	}
+	*__this_cpu_ptr(pp->percpu_pp) = pp;
+
 	mvneta_mac_addr_set(pp, dev->dev_addr, rxq_def);
 
 	pp->pkt_size = MVNETA_RX_PKT_SIZE(pp->dev->mtu);
@@ -2385,13 +2398,15 @@ static int mvneta_open(struct net_device *dev)
 	if (ret)
 		goto err_cleanup_rxqs;
 
+
 	/* Connect to port interrupt line */
-	ret = request_irq(pp->dev->irq, mvneta_isr, 0,
-			  MVNETA_DRIVER_NAME, pp);
+	ret = request_percpu_irq(pp->dev->irq, mvneta_isr,
+				MVNETA_DRIVER_NAME, pp->percpu_pp);
 	if (ret) {
 		netdev_err(pp->dev, "cannot request irq %d\n", pp->dev->irq);
 		goto err_cleanup_txqs;
 	}
+	enable_percpu_irq(pp->dev->irq, 0);
 
 	/* In default link is down */
 	netif_carrier_off(pp->dev);
@@ -2407,11 +2422,13 @@ static int mvneta_open(struct net_device *dev)
 	return 0;
 
 err_free_irq:
+	free_percpu(pp->percpu_pp);
 	free_irq(pp->dev->irq, pp);
 err_cleanup_txqs:
 	mvneta_cleanup_txqs(pp);
 err_cleanup_rxqs:
 	mvneta_cleanup_rxqs(pp);
+err_percpu_alloc:
 	return ret;
 }
 
@@ -2422,7 +2439,8 @@ static int mvneta_stop(struct net_device *dev)
 
 	mvneta_stop_dev(pp);
 	mvneta_mdio_remove(pp);
-	free_irq(dev->irq, pp);
+	free_percpu(pp->percpu_pp);
+	free_percpu_irq(dev->irq, pp);
 	mvneta_cleanup_rxqs(pp);
 	mvneta_cleanup_txqs(pp);
 	del_timer(&pp->tx_done_timer);
-- 
1.7.9.5



--------------060409020006070206050307--
