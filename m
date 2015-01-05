From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on linux-next
Date: Mon, 05 Jan 2015 11:06:41 +0100
Message-ID: <54AA6231.5040101@acm.org>
References: <20141029155620.GA4886@kria> <20141029180734.GQ12706@worktop.programming.kicks-ass.net> <alpine.DEB.2.11.1410291918060.5308@nanos> <20141029193603.GS12706@worktop.programming.kicks-ass.net> <20141202163530.GA19420@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Sabrina Dubroca <sd@queasysnail.net>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141202163530.GA19420@kria>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/14 17:35, Sabrina Dubroca wrote:
> @@ -3751,10 +3753,8 @@ void e1000_update_stats(struct e1000_adapter *adapter)
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
> @@ -3796,6 +3796,19 @@ static irqreturn_t e1000_intr(int irq, void *data)
>  	return IRQ_HANDLED;
>  }
>  
> +static irqreturn_t e1000_intr(int irq, void *data)
> +{
> +	struct net_device *netdev = data;
> +	struct e1000_adapter *adapter = netdev_priv(netdev);
> +	irqreturn_t ret;
> +
> +	netpoll_irq_lock(&adapter->netpoll_lock);
> +	ret = __e1000_intr(irq, adapter);
> +	netpoll_irq_unlock(&adapter->netpoll_lock);
> +
> +	return ret;
> +}
> +
>  /**
>   * e1000_clean - NAPI Rx polling callback
>   * @adapter: board private structure
> @@ -5220,9 +5233,7 @@ static void e1000_netpoll(struct net_device *netdev)
>  {
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
>  
> -	disable_irq(adapter->pdev->irq);
>  	e1000_intr(adapter->pdev->irq, netdev);
> -	enable_irq(adapter->pdev->irq);
>  }
>  #endif

Sorry but this patch looks incorrect to me. Since e1000_netpoll() can be
called with interrupts disabled e1000_intr() must not enable interrupts
unconditionally. Shouldn't the save / restore variants be used in
e1000_intr() instead of spin_lock_irq() and spin_unlock_irq() ? See also
the invocation of call_console_drivers() in console_unlock().

Bart.
