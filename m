From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on
 linux-next
Date: Tue, 2 Dec 2014 17:35:30 +0100
Message-ID: <20141202163530.GA19420@kria>
References: <20141029155620.GA4886@kria>
 <20141029180734.GQ12706@worktop.programming.kicks-ass.net>
 <alpine.DEB.2.11.1410291918060.5308@nanos>
 <20141029193603.GS12706@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141029193603.GS12706@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, sorry for the delay.

2014-10-29, 20:36:03 +0100, Peter Zijlstra wrote:
> On Wed, Oct 29, 2014 at 07:33:00PM +0100, Thomas Gleixner wrote:
> > Yuck. No. You are just papering over the problem.
> > 
> > What happens if you add 'threadirqs' to the kernel command line? Or if
> > the interrupt line is shared with a real threaded interrupt user?
> > 
> > The proper solution is to have a poll_lock for e1000 which serializes
> > the hardware interrupt against netpoll instead of using
> > disable/enable_irq().
> > 
> > In fact that's less expensive than the disable/enable_irq() dance and
> > the chance of contention is pretty low. If done right it will be a
> > NOOP for the CONFIG_NET_POLL_CONTROLLER=n case.
> > 
> 
> OK a little something like so then I suppose.. But I suspect most all
> the network drivers will need this and maybe more, disable_irq() is a
> popular little thing and we 'just' changed semantics on them.
> 
> ---
>  drivers/net/ethernet/intel/e1000/e1000.h      |  2 ++
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 22 +++++++++++++++++-----
>  kernel/irq/manage.c                           |  2 +-
>  3 files changed, 20 insertions(+), 6 deletions(-)

I've been running with variants of this patch, things seem ok.

As noted earlier, there are a lot of drivers doing this disable_irq +
irq_handler + enable_irq sequence.  I found about 60.
Many already take a lock in the interrupt handler, and look like we
could just remove the call to disable_irq (example: cp_interrupt,
drivers/net/ethernet/realtek/8139cp.c).

Here's how I modified your patch.  The locking compiles away if
CONFIG_NET_POLL_CONTROLLER=n.

I can work on converting all the drivers from disable_irq to
netpoll_irq_lock, if that's okay with you.

In igb there's also a synchronize_irq() called from the netpoll
controller (in igb_irq_disable()), I think a similar locking scheme
would work.
I also saw a few disable_irq_nosync and disable_percpu_irq. These are
okay?


Thanks.

---

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 69707108d23c..79444125b9bd 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -68,6 +68,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
+#include <linux/netpoll.h>
 
 #define BAR_0		0
 #define BAR_1		1
@@ -323,6 +324,8 @@ struct e1000_adapter {
 	struct delayed_work watchdog_task;
 	struct delayed_work fifo_stall_task;
 	struct delayed_work phy_info_task;
+
+	struct netpoll_irq_lock netpoll_lock;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 24f3986cfae2..5749a27e5c5e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -32,6 +32,7 @@
 #include <linux/prefetch.h>
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
+#include <linux/netpoll.h>
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
@@ -1313,6 +1314,7 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
 	e1000_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
+	netpoll_irq_lock_init(&adapter->netpoll_lock);
 
 	set_bit(__E1000_DOWN, &adapter->flags);
 
@@ -3751,10 +3753,8 @@ void e1000_update_stats(struct e1000_adapter *adapter)
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
  **/
-static irqreturn_t e1000_intr(int irq, void *data)
+static irqreturn_t __e1000_intr(int irq, struct e1000_adapter *adapter)
 {
-	struct net_device *netdev = data;
-	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = er32(ICR);
 
@@ -3796,6 +3796,19 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t e1000_intr(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	irqreturn_t ret;
+
+	netpoll_irq_lock(&adapter->netpoll_lock);
+	ret = __e1000_intr(irq, adapter);
+	netpoll_irq_unlock(&adapter->netpoll_lock);
+
+	return ret;
+}
+
 /**
  * e1000_clean - NAPI Rx polling callback
  * @adapter: board private structure
@@ -5220,9 +5233,7 @@ static void e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
-	enable_irq(adapter->pdev->irq);
 }
 #endif
 
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index b25ee9ffdbe6..a171f1a50e0e 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -117,4 +117,35 @@ static inline bool netpoll_tx_running(struct net_device *dev)
 }
 #endif
 
+struct netpoll_irq_lock {
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	spinlock_t lock;
+#endif
+};
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static inline void netpoll_irq_lock_init(struct netpoll_irq_lock *np_lock)
+{
+	spin_lock_init(&np_lock->lock);
+}
+static inline void netpoll_irq_lock(struct netpoll_irq_lock *np_lock)
+{
+	spin_lock(&np_lock->lock);
+}
+static inline void netpoll_irq_unlock(struct netpoll_irq_lock *np_lock)
+{
+	spin_unlock(&np_lock->lock);
+}
+#else
+static inline void netpoll_irq_lock_init(struct netpoll_irq_lock *np_lock)
+{
+}
+static inline void netpoll_irq_lock(struct netpoll_irq_lock *np_lock)
+{
+}
+static inline void netpoll_irq_unlock(struct netpoll_irq_lock *np_lock)
+{
+}
+#endif
+
 #endif



> 
> diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
> index 69707108d23c..3f48609f2318 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000.h
> +++ b/drivers/net/ethernet/intel/e1000/e1000.h
> @@ -323,6 +323,8 @@ struct e1000_adapter {
>  	struct delayed_work watchdog_task;
>  	struct delayed_work fifo_stall_task;
>  	struct delayed_work phy_info_task;
> +
> +	spinlock_t irq_lock;
>  };
>  
>  enum e1000_state_t {
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 5f6aded512f5..d12cbffe2149 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -1310,6 +1310,7 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
>  	e1000_irq_disable(adapter);
>  
>  	spin_lock_init(&adapter->stats_lock);
> +	spin_lock_init(&adapter->irq_lock);
>  
>  	set_bit(__E1000_DOWN, &adapter->flags);
>  
> @@ -3748,10 +3749,8 @@ void e1000_update_stats(struct e1000_adapter *adapter)
>   * @irq: interrupt number
>   * @data: pointer to a network interface device structure
>   **/
> -static irqreturn_t e1000_intr(int irq, void *data)
> +static irqreturn_t __e1000_intr(int irq, struct e1000_adapter *adapter)
>  {
> -	struct net_device *netdev = data;
> -	struct e1000_adapter *adapter = netdev_priv(netdev);
>  	struct e1000_hw *hw = &adapter->hw;
>  	u32 icr = er32(ICR);
>  
> @@ -3793,6 +3792,19 @@ static irqreturn_t e1000_intr(int irq, void *data)
>  	return IRQ_HANDLED;
>  }
>  
> +static irqreturn_t e1000_intr(int irq, void *data)
> +{
> +	struct net_device *netdev = data;
> +	struct e1000_adapter *adapter = netdev_priv(netdev);
> +	irqreturn_t ret;
> +
> +	spin_lock(&adapter->irq_lock);
> +	ret = __e1000_intr(irq, adapter);
> +	spin_unlock(&adapter->irq_lock);
> +
> +	return ret;
> +}
> +
>  /**
>   * e1000_clean - NAPI Rx polling callback
>   * @adapter: board private structure
> @@ -5217,9 +5229,9 @@ static void e1000_netpoll(struct net_device *netdev)
>  {
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
>  
> -	disable_irq(adapter->pdev->irq);
> +	spin_lock(&adapter->irq_lock)
>  	e1000_intr(adapter->pdev->irq, netdev);
> -	enable_irq(adapter->pdev->irq);
> +	spin_unlock(&adapter->irq_lock)
>  }
>  #endif
>  
> diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> index 0a9104b4608b..b5a4a06bf2fd 100644
> --- a/kernel/irq/manage.c
> +++ b/kernel/irq/manage.c
> @@ -427,7 +427,7 @@ EXPORT_SYMBOL(disable_irq_nosync);
>   *	to complete before returning. If you use this function while
>   *	holding a resource the IRQ handler may need you will deadlock.
>   *
> - *	This function may be called - with care - from IRQ context.
> + *	This function may _NOT_ be called from IRQ context.
>   */
>  void disable_irq(unsigned int irq)
>  {

-- 
Sabrina
