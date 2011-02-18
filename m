From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Fri, 18 Feb 2011 10:30:00 +0100
Message-ID: <20110218093000.GA12106@electric-eye.fr.zoreil.com>
References: <AANLkTin7GBSTcfZgr_9sNZ8CPMkW7Vstni+fs2v1-ink@mail.gmail.com> <1297581470.2510.18.camel@edumazet-laptop> <20110213135600.GA11382@electric-eye.fr.zoreil.com> <AANLkTikTw71-mv9WsPT8PxC1a1nwEJ=x0UNDhVQGP1A6@mail.gmail.com> <AANLkTikLOJ-XcwfdbWS19DKzh2s91tn5pQjJe0+CeAN-@mail.gmail.com> <20110213203417.GA11442@electric-eye.fr.zoreil.com> <AANLkTi=PrOXMD54hSbEwUtmzXiwsSwiSijE3AJ9n=WDe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ivan Vecera <ivecera@redhat.com>
To: Seblu <seblu@seblu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=PrOXMD54hSbEwUtmzXiwsSwiSijE3AJ9n=WDe@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Seblu <seblu@seblu.net> :
[...]
> I've applyed your patch on 2.6.38-rc5. Host have rebooted 2mn after udp start.
> After this reboot, host is still on after 2 hour under a 1Gbit/s udp flow.

Thanks for testing.

> I attached a dmesg output before reboot. Do you need anything else?

Mostly :
1. .config
2. the size of the udp packets and the mtu

As an option :
3. a few seconds of 'vmstat 1' from the host under test
4. an 'ethtool -s eth0' from the host under test
5. /proc/interrupts from the host under test
6. lspci -tv 

Can you apply the two attached patches on top of the previous ones and
give it a try ? The debug should not be too verbose if things are stationary
enough.

Do you have a serial cable and a second computer at hand by chance (don't
go for netconsole with the r8169 driver) ?

-- 
Ueimor

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-r8169-TX-stop-queue-race-fix.patch"

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 59ccf0c..712231f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4361,13 +4361,13 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	tp->cur_tx += frags + 1;
 
-	wmb();
-
 	RTL_W8(TxPoll, NPQ);	/* set polling bit */
 
+	mmiowb();
+
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-		smp_rmb();
+		smp_mb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
 			netif_wake_queue(dev);
 	}
@@ -4468,10 +4468,14 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-		smp_wmb();
-		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
-			netif_wake_queue(dev);
+		smp_mb();
+		if (unlikely(netif_queue_stopped(dev) &&
+		    (TX_BUFFS_AVAIL(tp) >= (NUM_TX_DESC / 4)))) {
+			netif_tx_lock(dev);
+			if (netif_queue_stopped(dev) &&
+			    (TX_BUFFS_AVAIL(tp) >= (NUM_TX_DESC / 4)))
+				netif_wake_queue(dev);
+			netif_tx_unlock(dev);
 		}
 		/*
 		 * 8168 hack: TxPoll requests are lost when the Tx packets are
-- 
1.7.3.4


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-r8169-debuginator.patch"

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 712231f..5eaccbb 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4622,6 +4622,11 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 	return count;
 }
 
+static struct {
+	u16 status[4];
+	u16 idx;
+} x = { { 0 }, 0 };
+
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
@@ -4637,6 +4642,12 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 	while (status && status != 0xffff) {
 		handled = 1;
 
+		x.status[x.idx++ % 4] = status;
+		if (net_ratelimit()) {
+			printk(KERN_INFO "%04x %04x %04x %04x\n",
+				x.status[0], x.status[1],
+				x.status[2], x.status[3]);
+		}
 		/* Handle all of the error cases first. These will reset
 		 * the chip, so just exit the loop.
 		 */
-- 
1.7.3.4


--YZ5djTAD1cGYuMQK--
