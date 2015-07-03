From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 6/6] net: mvneta: Statically assign queues to CPUs
Date: Fri, 3 Jul 2015 16:46:24 +0200
Message-ID: <20150703164624.77188a63@free-electrons.com>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
	<1435933551-28696-7-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:38408 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755400AbbGCOq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 10:46:28 -0400
In-Reply-To: <1435933551-28696-7-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxime,

On Fri,  3 Jul 2015 16:25:51 +0200, Maxime Ripard wrote:

> +static void mvneta_percpu_enable(void *arg)
> +{
> +	struct mvneta_port *pp = arg;
> +
> +	enable_percpu_irq(pp->dev->irq, IRQ_TYPE_NONE);
> +}
> +
>  static int mvneta_open(struct net_device *dev)
>  {
>  	struct mvneta_port *pp = netdev_priv(dev);
> @@ -2655,6 +2662,19 @@ static int mvneta_open(struct net_device *dev)
>  		goto err_cleanup_txqs;
>  	}
>  
> +	/*
> +	 * Even though the documentation says that request_percpu_irq
> +	 * doesn't enable the interrupts automatically, it actually
> +	 * does so on the local CPU.
> +	 *
> +	 * Make sure it's disabled.
> +	 */
> +	disable_percpu_irq(pp->dev->irq);
> +
> +	/* Enable per-CPU interrupt on the one CPU we care about */
> +	smp_call_function_single(rxq_def % num_online_cpus(),
> +				 mvneta_percpu_enable, pp, true);

What happens if that CPU goes offline through CPU hotplug?

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
