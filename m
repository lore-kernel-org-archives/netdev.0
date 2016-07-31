From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] 8139too:fix system hang when there is a tx timeout
 event.
Date: Sat, 30 Jul 2016 20:37:57 -0700 (PDT)
Message-ID: <20160730.203757.2140649329519453835.davem@davemloft.net>
References: <1469644797-13334-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469644797-13334-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chunhao Lin <hau@realtek.com>
Date: Thu, 28 Jul 2016 02:39:57 +0800

> If tx timeout event occur, kernel will call rtl8139_tx_timeout_task() to reset
> hardware. But in this function, driver does not stop tx and rx function before
> reset hardware, that will cause system hang.
> 
> In this patch, add stop tx and rx function before reset hardware.
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>

First, please always place a space after the subsystem prefix in your Subject
lines "8139too: ".

> @@ -1667,6 +1667,10 @@ static void rtl8139_tx_timeout_task (struct work_struct *work)
>  	int i;
>  	u8 tmp8;
>  
> +	napi_disable(&tp->napi);
> +	netif_stop_queue(dev);
> +	synchronize_sched();
> +
>  	netdev_dbg(dev, "Transmit timeout, status %02x %04x %04x media %02x\n",
>  		   RTL_R8(ChipCmd), RTL_R16(IntrStatus),
>  		   RTL_R16(IntrMask), RTL_R8(MediaStatus));
> @@ -1696,10 +1700,10 @@ static void rtl8139_tx_timeout_task (struct work_struct *work)
>  	spin_unlock_irq(&tp->lock);
>  
>  	/* ...and finally, reset everything */
> -	if (netif_running(dev)) {
> -		rtl8139_hw_start (dev);
> -		netif_wake_queue (dev);
> -	}
> +	napi_enable(&tp->napi);
> +	rtl8139_hw_start (dev);
> +	netif_wake_queue (dev);
> +

Get rid of these spaces in these function calls before the openning parenthesis.
