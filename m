From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 2/2] r8152: check the status before submittingrx
Date: Mon, 22 Dec 2014 02:53:42 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ED5A35@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-107-Taiwan-albertk@realtek.com>
	<1394712342-15778-109-Taiwan-albertk@realtek.com>
 <20141219.154402.54691026682141762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141219.154402.54691026682141762.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem@davemloft.net] 
> Sent: Saturday, December 20, 2014 4:44 AM
[...]
> > Don't submit the rx if the device is unplugged, linking down,
> > or stopped.
>  ...
> > @@ -1789,6 +1789,11 @@ int r8152_submit_rx(struct r8152 
> *tp, struct rx_agg *agg, gfp_t mem_flags)
> >  {
> >  	int ret;
> >  
> > +	/* The rx would be stopped, so skip submitting */
> > +	if (test_bit(RTL8152_UNPLUG, &tp->flags) ||
> > +	    !test_bit(WORK_ENABLE, &tp->flags) || !(tp->speed & LINK_STATUS))
> > +		return 0;
> > +
> 
> I think netif_carrier_off() should always be true in all three of those
> situations, and would be a much simpler test than what you've coded
> here.

When the device is unplugged or stopped, the linking status
may be true, so I add additional checks to avoid the submission.

Besides, in set_carrier() I set netif_carrier_on() after
ops.enable() to avoid any transmission before I finish
starting the tx/rx.

	tp->rtl_ops.enable(tp);
	set_bit(RTL8152_SET_RX_MODE, &tp->flags);
	netif_carrier_on(netdev);

However, the r8152_submit_rx() would be called in ops.enable(),
and the check of netif_carrier_ok() would be always false. That
is why I use tp->speed, not netif_carrier_ok(), to check the
linking stauts.
 
Best Regards,
Hayes
