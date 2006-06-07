From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Wed, 7 Jun 2006 15:18:00 -0400
Message-ID: <20060607191800.GB1241@localhost.localdomain>
References: <20060606170513.GB21969@hmsreliant.homelinux.net> <4485B8EC.4090603@intel.com> <x494pyyw5sr.fsf@segfault.boston.redhat.com> <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com> <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net> <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com> <x49d5dkvm8p.fsf@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:54278 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932366AbWFGTU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 15:20:57 -0400
To: Jeff Moyer <jmoyer@redhat.com>
Content-Disposition: inline
In-Reply-To: <x49d5dkvm8p.fsf@segfault.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006 at 02:44:54PM -0400, Jeff Moyer wrote:
> ==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Auke Kok <auke-jan.h.kok@intel.com> adds:
> 
> auke-jan.h.kok> Hi,
> 
> auke-jan.h.kok> we're not too happy with this as it puts a branch right in
> auke-jan.h.kok> the regular receive path. We haven't ran the numbers on it
> auke-jan.h.kok> yet but it is likely that this will lower performance
> auke-jan.h.kok> significantly during normal receives for something that is
> auke-jan.h.kok> not common use.
> 
> auke-jan.h.kok> Attached below a (revised) patch that adds proper locking
> auke-jan.h.kok> around the rx_clean to prevent the race.
> 
> That patch locks around the tx clean routine.  As such, it doesn't prevent
> the problem.
> 
Further to that, do tests on this if you like, but I would certainly think a
properly formed conditional operation is going to provide better performance
than a spin_lock operation in the receive path.  Why not just turn the:
if(netpoll_op)
into an
if(unlikely(netpoll_op))

I expect that will reduce the overhead of the conditional to effectively zero
for the normal receive case.  The following patch does that, and I expect you
performance won't suffer at all:

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>



 e1000_main.c |   54 +++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 45 insertions(+), 9 deletions(-)



--- linux-2.6.9/drivers/net/e1000/e1000_main.c.neil	2006-06-06 10:37:42.000000000 -0400
+++ linux-2.6.9/drivers/net/e1000/e1000_main.c	2006-06-07 10:48:22.000000000 -0400
@@ -3207,8 +3207,9 @@ e1000_update_stats(struct e1000_adapter 
  * @pt_regs: CPU registers structure
  **/
 
+
 static irqreturn_t
-e1000_intr(int irq, void *data, struct pt_regs *regs)
+__e1000_intr(int irq, void *data, struct pt_regs *regs, int netpoll_op)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -3217,6 +3218,7 @@ e1000_intr(int irq, void *data, struct p
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #else
+	struct net_device *dev_to_sched;
 	/* Interrupt Auto-Mask...upon reading ICR,
 	 * interrupts are masked.  No need for the
 	 * IMC write, but it does mean we should
@@ -3255,8 +3257,22 @@ e1000_intr(int irq, void *data, struct p
 		E1000_WRITE_REG(hw, IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
-	if (likely(netif_rx_schedule_prep(&adapter->polling_netdev[0])))
-		__netif_rx_schedule(&adapter->polling_netdev[0]);
+
+	/*
+	 * netpoll operations, in the interests of efficiency 
+	 * only do napi polling on the device passed to the 
+	 * poll_controller.  Therefore, if we are preforming 
+	 * a netpoll operation, then we can't schedule a receive
+	 * to one of the dummy net devices that exist for sole
+	 * purpose of spreading out rx schedules
+	 */	
+	if (unlikely(netpoll_op))
+		dev_to_sched = netdev;
+	else
+		dev_to_sched = &adapter->polling_netdev[0];
+
+	if (likely(netif_rx_schedule_prep(dev_to_sched)))
+		__netif_rx_schedule(dev_to_sched);
 	else
 		e1000_irq_enable(adapter);
 #else
@@ -3288,6 +3304,13 @@ e1000_intr(int irq, void *data, struct p
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t
+e1000_intr(int irq, void *data, struct pt_regs *regs)
+{
+	return __e1000_intr(irq, data, regs, 0);
+}
+
+
 #ifdef CONFIG_E1000_NAPI
 /**
  * e1000_clean - NAPI Rx polling callback
@@ -3300,7 +3323,6 @@ e1000_clean(struct net_device *poll_dev,
 	struct e1000_adapter *adapter;
 	int work_to_do = min(*budget, poll_dev->quota);
 	int tx_cleaned = 0, i = 0, work_done = 0;
-
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
 
@@ -3308,10 +3330,24 @@ e1000_clean(struct net_device *poll_dev,
 	if (!netif_carrier_ok(adapter->netdev))
 		goto quit_polling;
 
-	while (poll_dev != &adapter->polling_netdev[i]) {
-		i++;
-		if (unlikely(i == adapter->num_rx_queues))
-			BUG();
+	/*
+	 * only search for a matching polling_netdev in the event
+	 * that this isn't a real registered net_device
+	 * A real net device can be passed in here in the event
+	 * that netdump has been activated (this comes through 
+	 * netpoll_poll_dev).  We detect this by virtue of the 
+	 * fact that each polling_netdev->priv points to the private
+	 * data of its parent (registered) netdev.  So if:
+	 * poll_dev->priv == netdev_priv(poll_dev), its a real device
+	 * otherwise its a polling_netdev.
+	 */
+	if (likely(adapter != netdev_priv(poll_dev))) {
+		while (poll_dev != &adapter->polling_netdev[i]) {
+			i++;
+			if (unlikely(i == adapter->num_rx_queues))
+				BUG();
+		}
+
 	}
 
 	if (likely(adapter->num_tx_queues == 1)) {
@@ -4624,7 +4660,7 @@ e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	disable_irq(adapter->pdev->irq);
-	e1000_intr(adapter->pdev->irq, netdev, NULL);
+	__e1000_intr(adapter->pdev->irq, netdev, NULL, 1);
 	e1000_clean_tx_irq(adapter, adapter->tx_ring);
 #ifndef CONFIG_E1000_NAPI
 	adapter->clean_rx(adapter, adapter->rx_ring);

