From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [BUG][mvebu] mvneta: cannot request irq 25 on openblocks-ax3
Date: Tue, 19 Mar 2013 10:39:30 -0300
Message-ID: <20130319133928.GE3137@localhost>
References: <51486445.8040506@hitachi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"yrl.pp-manager.tt@hitachi.com" <yrl.pp-manager.tt@hitachi.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51486445.8040506@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Masami,

On Tue, Mar 19, 2013 at 10:12:37PM +0900, Masami Hiramatsu wrote:
> 
> Here I've hit a bug on the recent kernel. As far as I know, this bug
> exists on 3.9-rc1 too.
> 
> When I tried the latest mvebu for-next tree
> (git://git.infradead.org/users/jcooper/linux.git mvebu/for-next),
> I got below warning at bootup time and mvneta didn't work (link was never up).
> I ensured that "ifconfig ethX up" always caused that.
> 
> Does anyone succeed to boot openblocks-ax3 recently or hit same
> trouble?

This is a known bug. Gregory Clement already has a fix and he
will submit it soon. In case you need this fixed ASAP, I'm attaching
you a patch with a fix.

Please note the attached patch is not ready for mainline inclusion,
as I said Gregory will submit a cleaner version soon.

-- 
Ezequiel García, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="0001-net-mvneta-convert-to-percpu-interrupt.patch"

>From 03080b4e459b103b97b658789658f118053de522 Mon Sep 17 00:00:00 2001
From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Sat, 9 Feb 2013 22:07:54 +0100
Subject: [PATCH] net: mvneta: convert to percpu interrupt

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b6025c3..7f63dd4 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1800,7 +1800,7 @@ static void mvneta_set_rx_mode(struct net_device *dev)
 /* Interrupt handling - the callback for request_irq() */
 static irqreturn_t mvneta_isr(int irq, void *dev_id)
 {
-	struct mvneta_port *pp = (struct mvneta_port *)dev_id;
+	struct mvneta_port *pp = *(struct mvneta_port **)dev_id;
 
 	/* Mask all interrupts */
 	mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
@@ -2368,6 +2368,7 @@ static void mvneta_mdio_remove(struct mvneta_port *pp)
 	phy_disconnect(pp->phy_dev);
 	pp->phy_dev = NULL;
 }
+static struct mvneta_port __percpu **percpu_pp;
 
 static int mvneta_open(struct net_device *dev)
 {
@@ -2386,9 +2387,14 @@ static int mvneta_open(struct net_device *dev)
 	if (ret)
 		goto err_cleanup_rxqs;
 
+	percpu_pp = alloc_percpu(struct mvneta_port *);
+	*__this_cpu_ptr(percpu_pp) = pp;
+
 	/* Connect to port interrupt line */
-	ret = request_irq(pp->dev->irq, mvneta_isr, 0,
-			  MVNETA_DRIVER_NAME, pp);
+	ret = request_percpu_irq(pp->dev->irq, mvneta_isr,
+			  MVNETA_DRIVER_NAME, percpu_pp);
+	enable_percpu_irq(pp->dev->irq, 0);
+
 	if (ret) {
 		netdev_err(pp->dev, "cannot request irq %d\n", pp->dev->irq);
 		goto err_cleanup_txqs;
-- 
1.7.8.6


--bg08WKrSYDhXBjb5--
