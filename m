From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net-next] net/usb: new driver for RTL8152
Date: Thu, 02 May 2013 11:02:10 +0200
Message-ID: <2267010.M7uxa7hLi4@linux-5eaq.site>
References: <1366965948-1805-1-git-send-email-hayeswang@realtek.com> <201305020622.r426MYGv032465@rtits1.realtek.com> <95FC8A7CCB904AB6B26751C6DBEE49F2@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	'nic_swsd' <nic_swsd@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34248 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755708Ab3EBJBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 05:01:15 -0400
In-Reply-To: <95FC8A7CCB904AB6B26751C6DBEE49F2@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 02 May 2013 15:46:50 hayeswang wrote:
>  Oliver Neukum [mailto:oneukum@suse.de] 
> > Sent: Friday, April 26, 2013 7:57 PM
> > To: Hayeswang
> > Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; 
> > linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org; nic_swsd
> > Subject: Re: [PATCH net-next] net/usb: new driver for RTL8152
> > 
> [...]
> > > +static inline void set_ethernet_addr(struct r8152 *tp)
> > > +{
> > > +	struct net_device *dev = tp->netdev;
> > > +	u8 node_id[8] = {0};
> > > +
> > > +	if (pla_ocp_read(tp, PLA_IDR, sizeof(node_id), node_id) < 0)
> > 
> > DMA coherency rules. No buffers on the stack.
> 
> Excuse me. I don't understand what you mean. I reference the rtl8150.c and it

On some CPUs special operations need to be performed on buffers
intended for DMA. After these operations until the DMA is over any cacheline
shared with the buffer must not be touched. In addition it is not guaranteed
that the stack is DMAable at all.
This is documented in DMA-API.txt

I know this a very common bug because it works on x86, but on some architectures it
fails.

> uses the same way. Besides, when I check the other drivers, I find the data
> pointer of the parameter of the usb_control_msg() may be a pointer of a local
> variable from the other functions.
> 
> [...]
> > > +static void rtl_work_func_t(struct work_struct *work)
> > > +{
> > > +	struct r8152 *tp = container_of(work, struct r8152, 
> > schedule.work);
> > > +
> > > +	if (!netif_running(tp->netdev))
> > > +		goto out1;
> > > +
> > > +	if (test_bit(RTL8152_UNPLUG, &tp->flags))
> > > +		goto out1;
> > > +
> > > +	set_carrier(tp);
> > > +
> > > +	if (test_bit(RTL8152_SET_RX_MODE, &tp->flags))
> > > +		_rtl8152_set_rx_mode(tp->netdev);
> > > +
> > > +	schedule_delayed_work(&tp->schedule, HZ);
> > 
> > Why does this need to run permanently?
> 
> It is used to periodically check the speed, link status, and any other tasks
> which need to be finished.

Unfortunate. It will hurt power consumption.

> 
> [...]
> > > +static int rtl8152_close(struct net_device *netdev)
> > > +{
> > > +	struct r8152 *tp = netdev_priv(netdev);
> > > +	int res = 0;
> > > +
> > > +	cancel_delayed_work_sync(&tp->schedule);
> > 
> > Looks like a race. What makes sure the work isn't rescheduled?
> 
> netif_running would be checked.

I see.

	HTH
		Oliver
