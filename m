From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH] phylib: convert state_queue work to delayed_work
Date: Sat, 7 Mar 2009 10:46:20 +0100
Message-ID: <20090307104620.7f2aed57@hyperion.delvare>
References: <20090306205139.GA30500@joi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Trent Piepho <tpiepho@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Marcin Slusarz <marcin.slusarz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:14894 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776AbZCGJqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 04:46:37 -0500
In-Reply-To: <20090306205139.GA30500@joi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Mar 2009 21:51:42 +0100, Marcin Slusarz wrote:
> It closes a race in phy_stop_machine when reprogramming of phy_timer
> (from phy_state_machine) happens between del_timer_sync and cancel_work_sync.
> 
> Without this change it could lead to crash if phy_device would be freed after
> phy_stop_machine (timer would fire and schedule freed work).
> 
> Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> Cc: Andy Fleming <afleming@freescale.com>
> Cc: Trent Piepho <tpiepho@freescale.com>
> ---
> 
> This patch was only compile tested.

Patch looks good.

Acked-by: Jean Delvare <khali@linux-fr.org>

> 
> ---
>  drivers/net/phy/phy.c |   41 +++++++++++------------------------------
>  include/linux/phy.h   |    3 +--
>  2 files changed, 12 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index e4ede60..58b73b0 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -414,7 +414,6 @@ EXPORT_SYMBOL(phy_start_aneg);
>  
>  static void phy_change(struct work_struct *work);
>  static void phy_state_machine(struct work_struct *work);
> -static void phy_timer(unsigned long data);
>  
>  /**
>   * phy_start_machine - start PHY state machine tracking
> @@ -434,11 +433,8 @@ void phy_start_machine(struct phy_device *phydev,
>  {
>  	phydev->adjust_state = handler;
>  
> -	INIT_WORK(&phydev->state_queue, phy_state_machine);
> -	init_timer(&phydev->phy_timer);
> -	phydev->phy_timer.function = &phy_timer;
> -	phydev->phy_timer.data = (unsigned long) phydev;
> -	mod_timer(&phydev->phy_timer, jiffies + HZ);
> +	INIT_DELAYED_WORK(&phydev->state_queue, phy_state_machine);
> +	schedule_delayed_work(&phydev->state_queue, jiffies + HZ);
>  }
>  
>  /**
> @@ -451,8 +447,7 @@ void phy_start_machine(struct phy_device *phydev,
>   */
>  void phy_stop_machine(struct phy_device *phydev)
>  {
> -	del_timer_sync(&phydev->phy_timer);
> -	cancel_work_sync(&phydev->state_queue);
> +	cancel_delayed_work_sync(&phydev->state_queue);
>  
>  	mutex_lock(&phydev->lock);
>  	if (phydev->state > PHY_UP)
> @@ -680,11 +675,9 @@ static void phy_change(struct work_struct *work)
>  	if (err)
>  		goto irq_enable_err;
>  
> -	/* Stop timer and run the state queue now.  The work function for
> -	 * state_queue will start the timer up again.
> -	 */
> -	del_timer(&phydev->phy_timer);
> -	schedule_work(&phydev->state_queue);
> +	/* reschedule state queue work to run as soon as possible */
> +	cancel_delayed_work_sync(&phydev->state_queue);
> +	schedule_delayed_work(&phydev->state_queue, 0);
>  
>  	return;
>  
> @@ -761,14 +754,13 @@ EXPORT_SYMBOL(phy_start);
>  /**
>   * phy_state_machine - Handle the state machine
>   * @work: work_struct that describes the work to be done
> - *
> - * Description: Scheduled by the state_queue workqueue each time
> - *   phy_timer is triggered.
>   */
>  static void phy_state_machine(struct work_struct *work)
>  {
> +	struct delayed_work *dwork =
> +			container_of(work, struct delayed_work, work);
>  	struct phy_device *phydev =
> -			container_of(work, struct phy_device, state_queue);
> +			container_of(dwork, struct phy_device, state_queue);
>  	int needs_aneg = 0;
>  	int err = 0;
>  
> @@ -946,17 +938,6 @@ static void phy_state_machine(struct work_struct *work)
>  	if (err < 0)
>  		phy_error(phydev);
>  
> -	mod_timer(&phydev->phy_timer, jiffies + PHY_STATE_TIME * HZ);
> -}
> -
> -/* PHY timer which schedules the state machine work */
> -static void phy_timer(unsigned long data)
> -{
> -	struct phy_device *phydev = (struct phy_device *)data;
> -
> -	/*
> -	 * PHY I/O operations can potentially sleep so we ensure that
> -	 * it's done from a process context
> -	 */
> -	schedule_work(&phydev->state_queue);
> +	schedule_delayed_work(&phydev->state_queue,
> +				jiffies + PHY_STATE_TIME * HZ);
>  }
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index d7e54d9..32cf14a 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -315,8 +315,7 @@ struct phy_device {
>  
>  	/* Interrupt and Polling infrastructure */
>  	struct work_struct phy_queue;
> -	struct work_struct state_queue;
> -	struct timer_list phy_timer;
> +	struct delayed_work state_queue;
>  	atomic_t irq_disable;
>  
>  	struct mutex lock;


-- 
Jean Delvare
