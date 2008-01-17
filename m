From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] PHYLIB: Locking fixes for PHY I/O potentially sleeping
Date: Fri, 18 Jan 2008 08:04:48 +1100
Message-ID: <1200603889.7222.2.camel@pasglop>
References: <1199403419.25262.62.camel@localhost.localdomain>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59507 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481AbYAQVGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 16:06:25 -0500
In-Reply-To: <1199403419.25262.62.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-01-03 at 17:36 -0600, Nate Case wrote:
> PHY read/write functions can potentially sleep (e.g., a PHY accessed
> via I2C).  The following changes were made to account for this:
> 
>     * Change spin locks to mutex locks
>     * Add a BUG_ON() to phy_read() phy_write() to warn against
>       calling them from an interrupt context.
>     * Use work queue for PHY state machine handling since
>       it can potentially sleep
>     * Change phydev lock from spinlock to mutex
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>

Excellent ! I've been wanting to do that for some time. I'll be able to
convert EMAC to phylib now :-) I'll review the patch in detail as I do
this convesion, maybe next week. Thanks !

Ben.

> ---
>  drivers/net/phy/mdio_bus.c   |    2 +-
>  drivers/net/phy/phy.c        |   68 ++++++++++++++++++++++++++++-------------
>  drivers/net/phy/phy_device.c |   11 +++----
>  include/linux/phy.h          |    5 ++-
>  4 files changed, 55 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index c30196d..6e9f619 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -49,7 +49,7 @@ int mdiobus_register(struct mii_bus *bus)
>  	int i;
>  	int err = 0;
>  
> -	spin_lock_init(&bus->mdio_lock);
> +	mutex_init(&bus->mdio_lock);
>  
>  	if (NULL == bus || NULL == bus->name ||
>  			NULL == bus->read ||
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 7c9e6e3..12fccb1 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -26,7 +26,6 @@
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/skbuff.h>
> -#include <linux/spinlock.h>
>  #include <linux/mm.h>
>  #include <linux/module.h>
>  #include <linux/mii.h>
> @@ -72,9 +71,11 @@ int phy_read(struct phy_device *phydev, u16 regnum)
>  	int retval;
>  	struct mii_bus *bus = phydev->bus;
>  
> -	spin_lock_bh(&bus->mdio_lock);
> +	BUG_ON(in_interrupt());
> +
> +	mutex_lock(&bus->mdio_lock);
>  	retval = bus->read(bus, phydev->addr, regnum);
> -	spin_unlock_bh(&bus->mdio_lock);
> +	mutex_unlock(&bus->mdio_lock);
>  
>  	return retval;
>  }
> @@ -95,9 +96,11 @@ int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
>  	int err;
>  	struct mii_bus *bus = phydev->bus;
>  
> -	spin_lock_bh(&bus->mdio_lock);
> +	BUG_ON(in_interrupt());
> +
> +	mutex_lock(&bus->mdio_lock);
>  	err = bus->write(bus, phydev->addr, regnum, val);
> -	spin_unlock_bh(&bus->mdio_lock);
> +	mutex_unlock(&bus->mdio_lock);
>  
>  	return err;
>  }
> @@ -428,7 +431,7 @@ int phy_start_aneg(struct phy_device *phydev)
>  {
>  	int err;
>  
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  
>  	if (AUTONEG_DISABLE == phydev->autoneg)
>  		phy_sanitize_settings(phydev);
> @@ -449,13 +452,14 @@ int phy_start_aneg(struct phy_device *phydev)
>  	}
>  
>  out_unlock:
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  	return err;
>  }
>  EXPORT_SYMBOL(phy_start_aneg);
>  
> 
>  static void phy_change(struct work_struct *work);
> +static void phy_state_machine(struct work_struct *work);
>  static void phy_timer(unsigned long data);
>  
>  /**
> @@ -476,6 +480,7 @@ void phy_start_machine(struct phy_device *phydev,
>  {
>  	phydev->adjust_state = handler;
>  
> +	INIT_WORK(&phydev->state_queue, phy_state_machine);
>  	init_timer(&phydev->phy_timer);
>  	phydev->phy_timer.function = &phy_timer;
>  	phydev->phy_timer.data = (unsigned long) phydev;
> @@ -493,11 +498,12 @@ void phy_start_machine(struct phy_device *phydev,
>  void phy_stop_machine(struct phy_device *phydev)
>  {
>  	del_timer_sync(&phydev->phy_timer);
> +	cancel_work_sync(&phydev->state_queue);
>  
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  	if (phydev->state > PHY_UP)
>  		phydev->state = PHY_UP;
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  
>  	phydev->adjust_state = NULL;
>  }
> @@ -541,9 +547,9 @@ static void phy_force_reduction(struct phy_device *phydev)
>   */
>  void phy_error(struct phy_device *phydev)
>  {
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  	phydev->state = PHY_HALTED;
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  }
>  
>  /**
> @@ -705,10 +711,10 @@ static void phy_change(struct work_struct *work)
>  	if (err)
>  		goto phy_err;
>  
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
>  		phydev->state = PHY_CHANGELINK;
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  
>  	atomic_dec(&phydev->irq_disable);
>  	enable_irq(phydev->irq);
> @@ -735,7 +741,7 @@ phy_err:
>   */
>  void phy_stop(struct phy_device *phydev)
>  {
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  
>  	if (PHY_HALTED == phydev->state)
>  		goto out_unlock;
> @@ -751,7 +757,7 @@ void phy_stop(struct phy_device *phydev)
>  	phydev->state = PHY_HALTED;
>  
>  out_unlock:
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  
>  	/*
>  	 * Cannot call flush_scheduled_work() here as desired because
> @@ -773,7 +779,7 @@ out_unlock:
>   */
>  void phy_start(struct phy_device *phydev)
>  {
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  
>  	switch (phydev->state) {
>  		case PHY_STARTING:
> @@ -787,19 +793,26 @@ void phy_start(struct phy_device *phydev)
>  		default:
>  			break;
>  	}
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  }
>  EXPORT_SYMBOL(phy_stop);
>  EXPORT_SYMBOL(phy_start);
>  
> -/* PHY timer which handles the state machine */
> -static void phy_timer(unsigned long data)
> +/**
> + * phy_state_machine - Handle the state machine
> + * @work: work_struct that describes the work to be done
> + *
> + * Description: Scheduled by the state_queue workqueue each time
> + *   phy_timer is triggered.
> + */
> +static void phy_state_machine(struct work_struct *work)
>  {
> -	struct phy_device *phydev = (struct phy_device *)data;
> +	struct phy_device *phydev =
> +			container_of(work, struct phy_device, state_queue);
>  	int needs_aneg = 0;
>  	int err = 0;
>  
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  
>  	if (phydev->adjust_state)
>  		phydev->adjust_state(phydev->attached_dev);
> @@ -965,7 +978,7 @@ static void phy_timer(unsigned long data)
>  			break;
>  	}
>  
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  
>  	if (needs_aneg)
>  		err = phy_start_aneg(phydev);
> @@ -976,3 +989,14 @@ static void phy_timer(unsigned long data)
>  	mod_timer(&phydev->phy_timer, jiffies + PHY_STATE_TIME * HZ);
>  }
>  
> +/* PHY timer which schedules the state machine work */
> +static void phy_timer(unsigned long data)
> +{
> +	struct phy_device *phydev = (struct phy_device *)data;
> +
> +	/*
> +	 * PHY I/O operations can potentially sleep so we ensure that
> +	 * it's done from a process context
> +	 */
> +	schedule_work(&phydev->state_queue);
> +}
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 5b9e175..f4c4fd8 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -25,7 +25,6 @@
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/skbuff.h>
> -#include <linux/spinlock.h>
>  #include <linux/mm.h>
>  #include <linux/module.h>
>  #include <linux/mii.h>
> @@ -80,7 +79,7 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
>  
>  	dev->state = PHY_DOWN;
>  
> -	spin_lock_init(&dev->lock);
> +	mutex_init(&dev->lock);
>  
>  	return dev;
>  }
> @@ -656,7 +655,7 @@ static int phy_probe(struct device *dev)
>  	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
>  		phydev->irq = PHY_POLL;
>  
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  
>  	/* Start out supporting everything. Eventually,
>  	 * a controller will attach, and may modify one
> @@ -670,7 +669,7 @@ static int phy_probe(struct device *dev)
>  	if (phydev->drv->probe)
>  		err = phydev->drv->probe(phydev);
>  
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  
>  	return err;
>  
> @@ -682,9 +681,9 @@ static int phy_remove(struct device *dev)
>  
>  	phydev = to_phy_device(dev);
>  
> -	spin_lock_bh(&phydev->lock);
> +	mutex_lock(&phydev->lock);
>  	phydev->state = PHY_DOWN;
> -	spin_unlock_bh(&phydev->lock);
> +	mutex_unlock(&phydev->lock);
>  
>  	if (phydev->drv->remove)
>  		phydev->drv->remove(phydev);
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 554836e..5e43ae7 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -88,7 +88,7 @@ struct mii_bus {
>  
>  	/* A lock to ensure that only one thing can read/write
>  	 * the MDIO bus at a time */
> -	spinlock_t mdio_lock;
> +	struct mutex mdio_lock;
>  
>  	struct device *dev;
>  
> @@ -284,10 +284,11 @@ struct phy_device {
>  
>  	/* Interrupt and Polling infrastructure */
>  	struct work_struct phy_queue;
> +	struct work_struct state_queue;
>  	struct timer_list phy_timer;
>  	atomic_t irq_disable;
>  
> -	spinlock_t lock;
> +	struct mutex lock;
>  
>  	struct net_device *attached_dev;
>  

