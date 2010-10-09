From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sundance: get_stats proper locking
Date: Sat, 09 Oct 2010 14:17:01 +0200
Message-ID: <1286626621.2692.18.camel@edumazet-laptop>
References: <20101009095346.GA12951@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Denis Kirjanov <dkirjanov@kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60178 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754608Ab0JIMRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 08:17:24 -0400
Received: by wyb28 with SMTP id 28so1818758wyb.19
        for <netdev@vger.kernel.org>; Sat, 09 Oct 2010 05:17:22 -0700 (PDT)
In-Reply-To: <20101009095346.GA12951@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 09 octobre 2010 =C3=A0 09:53 +0000, Denis Kirjanov a =C3=A9cr=
it :
> Add initial ethtool statistics support=20

OK, I guess its time to add proper locking into sundance after all ;)

[PATCH net-next] sundance: get_stats proper locking

sundance get_stats() should not be run concurrently, add a lock to avoi=
d
potential losses.

Note: Remove unused rx_lock field

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/sundance.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 27d69aa..4283cc5 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -365,7 +365,6 @@ struct netdev_private {
 	struct timer_list timer;		/* Media monitoring timer. */
 	/* Frequently used values: keep some adjacent for cache effect. */
 	spinlock_t lock;
-	spinlock_t rx_lock;			/* Group with Tx control cache line. */
 	int msg_enable;
 	int chip_id;
 	unsigned int cur_rx, dirty_rx;		/* Producer/consumer ring indices */
@@ -390,6 +389,7 @@ struct netdev_private {
 	unsigned char phys[MII_CNT];		/* MII device addresses, only first one=
 used. */
 	struct pci_dev *pci_dev;
 	void __iomem *base;
+	spinlock_t statlock;
 };
=20
 /* The station address location in the EEPROM. */
@@ -514,6 +514,7 @@ static int __devinit sundance_probe1 (struct pci_de=
v *pdev,
 	np->chip_id =3D chip_idx;
 	np->msg_enable =3D (1 << debug) - 1;
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->statlock);
 	tasklet_init(&np->rx_tasklet, rx_poll, (unsigned long)dev);
 	tasklet_init(&np->tx_tasklet, tx_poll, (unsigned long)dev);
=20
@@ -1486,10 +1487,9 @@ static struct net_device_stats *get_stats(struct=
 net_device *dev)
 	struct netdev_private *np =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D np->base;
 	int i;
+	unsigned long flags;
=20
-	/* We should lock this segment of code for SMP eventually, although
-	   the vulnerability window is very small and statistics are
-	   non-critical. */
+	spin_lock_irqsave(&np->statlock, flags);
 	/* The chip only need report frame silently dropped. */
 	dev->stats.rx_missed_errors	+=3D ioread8(ioaddr + RxMissed);
 	dev->stats.tx_packets +=3D ioread16(ioaddr + TxFramesOK);
@@ -1506,6 +1506,8 @@ static struct net_device_stats *get_stats(struct =
net_device *dev)
 	dev->stats.rx_bytes +=3D ioread16(ioaddr + RxOctetsLow);
 	dev->stats.rx_bytes +=3D ioread16(ioaddr + RxOctetsHigh) << 16;
=20
+	spin_unlock_irqrestore(&np->statlock, flags);
+
 	return &dev->stats;
 }
=20


