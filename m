From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: Add missing hotplug notifier transition
Date: Fri, 11 Mar 2016 11:28:55 +0100
Message-ID: <8737rx2tqw.fsf@free-electrons.com>
References: <1457687423-39784-1-git-send-email-anna-maria@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, rt@linutronix.de,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Anna-Maria Gleixner <anna-maria@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457687423-39784-1-git-send-email-anna-maria@linutronix.de>
	(Anna-Maria Gleixner's message of "Fri, 11 Mar 2016 10:10:23 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Anna-Maria,
 
 On ven., mars 11 2016, Anna-Maria Gleixner <anna-maria@linutronix.de> wrote:

> The mvneta_percpu_notifier() hotplug callback lacks handling of the
> CPU_DOWN_FAILED case. That means, if CPU_DOWN_PREPARE failes, the
> driver is not well configured on the CPU.
>
> Add handling for CPU_DOWN_FAILED[_FROZEN] hotplug notifier transition
> to setup the driver.

I agree that we need to handle this case, however reusing CPU_ONLINE
case for it seems too much. Indeed in the case of a CPU down failure all
the napi are already synchronized thanks to the CPU_DOWN_PREPARE
case. Moreover, we didn't call yet mvneta_percpu_elect() so we don't have
to call it again. I would prefer something like that:

@@ -2987,6 +2987,23 @@ static int mvneta_percpu_notifier(struct notifier_block *nfb,
                                         pp, true);
 
                break;
+       case CPU_DOWN_FAILED:
+       case CPU_DOWN_FAILED_FROZEN:
+               /* Re-enable per-CPU interrupts on the CPU that failed
+                * to bring up.
+                */
+               smp_call_function_single(cpu, mvneta_percpu_enable,
+                                        pp, true);
+
+               napi_enable(&port->napi);
+               /* Unmask all ethernet port interrupts */
+               on_each_cpu(mvneta_percpu_unmask_interrupt, pp, true);
+               mvreg_write(pp, MVNETA_INTR_MISC_MASK,
+                       MVNETA_CAUSE_PHY_STATUS_CHANGE |
+                       MVNETA_CAUSE_LINK_CHANGE |
+                       MVNETA_CAUSE_PSC_SYNC_CHANGE);
+               netif_tx_start_all_queues(pp->dev);
+               break;
        case CPU_DEAD:
        case CPU_DEAD_FROZEN:
                /* Check if a new CPU must be elected now this on is down */


Also it would be nice to appy this fix on the stable kernel, the bug was
introduced with this commit: f86428854480 ("net: mvneta: Statically
assign queues to CPUs")

Thanks,

Gregory

>
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
> ---
>  drivers/net/ethernet/marvell/mvneta.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -2920,6 +2920,8 @@ static int mvneta_percpu_notifier(struct
>  	switch (action) {
>  	case CPU_ONLINE:
>  	case CPU_ONLINE_FROZEN:
> +	case CPU_DOWN_FAILED:
> +	case CPU_DOWN_FAILED_FROZEN:
>  		spin_lock(&pp->lock);
>  		/* Configuring the driver for a new CPU while the
>  		 * driver is stopping is racy, so just avoid it.

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
