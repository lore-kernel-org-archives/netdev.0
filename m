From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net v4 3/4] r8152: support stopping/waking tx queue
Date: Tue, 19 Nov 2013 15:25:36 -0500 (EST)
Message-ID: <20131119.152536.146706009595105149.davem@davemloft.net>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com>
	<1384831511-1625-1-git-send-email-hayeswang@realtek.com>
	<1384831511-1625-4-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384831511-1625-4-git-send-email-hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Date: Tue, 19 Nov 2013 11:25:10 +0800

> The maximum packet number which a tx aggregation buffer could contain
> is the buffer size / (packet size + descriptor size).
> 
> If the tx buffer is empty and the tx queue length is more than the
> maximum value which is defined above, stop the tx queue. Wake the tx
> queue after any queued packet is filled in a available tx buffer.
> 
> Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>

This is racy.

You have nothing which synchronizes r8152_tx_agg_fill() and rtl8152_start_xmit(),
therefore:

> +	if (netif_queue_stopped(tp->netdev))
> +		netif_wake_queue(tp->netdev);
> +

A netif_stop_queue() can occur right after the netif_queue_stopped() check,
meaning you can end up with the queue being stopped forever and the TX queue
stuck.

I am finding this patch series _very_ tiring, every single time I take
the time to review it, I find major problems.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
