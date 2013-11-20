From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net v4 3/4] r8152: support stopping/waking tx queue
Date: Wed, 20 Nov 2013 00:22:23 -0500 (EST)
Message-ID: <20131120.002223.1492430030566522391.davem@davemloft.net>
References: <1384831511-1625-4-git-send-email-hayeswang@realtek.com>
	<20131119.152536.146706009595105149.davem@davemloft.net>
	<9C2E97E7BED9426ABE0FF4F63E12E33D@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9C2E97E7BED9426ABE0FF4F63E12E33D-Rasf1IRRPZGoECsaD+WFmw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: hayeswang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Date: Wed, 20 Nov 2013 11:28:46 +0800

>  David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org] 
> [...]
>> This is racy.
>> 
>> You have nothing which synchronizes r8152_tx_agg_fill() and 
>> rtl8152_start_xmit(),
>> therefore:
>> 
>> > +	if (netif_queue_stopped(tp->netdev))
>> > +		netif_wake_queue(tp->netdev);
>> > +
>> 
>> A netif_stop_queue() can occur right after the 
>> netif_queue_stopped() check,
>> meaning you can end up with the queue being stopped forever 
>> and the TX queue
>> stuck.
> 
> If the situation occurs, it means there is no tx buffer at that time. If the
> netif_wake_queue() is called, only one more packet would be queued and the tx
> queue would be stopped again after calling rtl8152_start_xmit(). That is, it
> is not necessary to wake the queue. Besides, after the tx is completed, another
> tasklet would be scheduled if there is any packet which is queued in the list.
> That is, the r8152_tx_agg_fill() would be called and the netif_queue_stopped()
> would be check againg, so the tx queue would not be stopped forever.

Then the queue can be woken when in fact r8152_start_xmit() is not able to
actually queue packets.  It is just as equally problematic.

You have to synchronize this state, somehow.

tg3 driver does this by taking netif tx queue lock during the wake
test sequence in TX reclaim.  This works because ->ndo_start_xmit() is
run with this lock held.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
