From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Ipw2100-devel] ipw2100: race between isr_indicate_associated
 and rx path
Date: Wed, 25 Feb 2009 09:18:16 +0800
Message-ID: <1235524696.6354.562.camel@debian>
References: <200901211734.48625.helmut.schaa@gmail.com>
	 <200902231138.58067.helmut.schaa@gmail.com>
	 <1235446447.6354.549.camel@debian>
	 <200902241315.43128.helmut.schaa@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jouni Malinen <j@w1.fi>
To: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200902241315.43128.helmut.schaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-02-24 at 20:15 +0800, Helmut Schaa wrote:
> Am Dienstag, 24. Februar 2009 schrieb Zhu Yi:
> 
> [...]
> 
> > Thanks for the analysis. Are you sure noop_qdisc is still used when we
> > are about to netif_carrier_on() after receiving the association success
> > response? 
> 
> Yes, had a printk in noop_enqueue.
> 
> > From dev_open(), dev_activate() is called after netdev->open.
> > So the txq->qdisc_sleeping should be already replaced with pfifo_fast.
> > But the state is still DEACTIVATED.
> 
> Right. But for example when a connection cannot be established by ipw2100
> it will call netif_carrier_off on disassociation which in turn leads to a
> call to dev_deavtivate. Hence, it is possible that a noop_qdisc is
> assigned while the device is up and carrier is off.

Make sense. Whatever there is race here but either the driver or the
user space is able to control and avoid it.

BTW, does wpa_supplicant start to receive EAPOL frames after it gets the
association event?

[...]

> > But in wireless, 
> > netif_carrier_on() is usually called after an association is succeeded.
> > The driver has already some management frames transfered with AP. Now
> > it's the time to open the data frame transmission. The driver requires
> > to get the activate_dev() result (synchronously or via callback) because
> > otherwise the driver has no idea when the Qdisc is ready and then it can
> > start to deliver data frames to network stack and user space.
> 
> Exactly.

Looks like we didn't bring enough attention for netdev people on this.
Should you change the title to remove ipw2100? It should be a generic
issue for the current netif_carrier_on/dev_activate() implementation.

Thanks,
-yi

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
