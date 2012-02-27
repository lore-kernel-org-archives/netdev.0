From: Andrei Warkentin <awarkentin@vmware.com>
Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
Date: Mon, 27 Feb 2012 15:33:55 -0800 (PST)
Message-ID: <628860779.1621452.1330385635262.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
References: <4F4C0EF8.8010405@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrei Warkentin <andreiw@vmware.com>,
	kgdb-bugreport@lists.sourceforge.net,
	Matt Mackall <mpm@selenic.com>,
	Andrei Warkentin <andrey.warkentin@gmail.com>
To: Jason Wessel <jason.wessel@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4C0EF8.8010405@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for the review, Jason. Comments inline.

----- Original Message -----
> From: "Jason Wessel" <jason.wessel@windriver.com>
> To: "Andrei Warkentin" <andrey.warkentin@gmail.com>
> Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Andrei Warkentin" <andreiw@vmware.com>,
> kgdb-bugreport@lists.sourceforge.net, "Matt Mackall" <mpm@selenic.com>
> Sent: Monday, February 27, 2012 6:17:12 PM
> Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
> 
> 
> I am just now starting to look how this patch set compares to kgdboe.
>  For the kgdboe the patch is a bit different.  The kgdboe opted to
> just pass the skb so as to cut down on the number of arguments to
> the function call.
> 
> From the kgdboe patch:
> 
> -       void (*rx_hook)(struct netpoll *, int, char *, int);
> +       void (*rx_hook)(struct netpoll *, int, char *, int, struct
> sk_buff *);
> 
> 

Interesting, I thought about passing the skb, but decided I didn't
want to copy and paste the skb parsing code, especially given
that it's always UDP anyway. I still have reservations about
passing the physical address, but I don't think anyone tried
to use netpoll or a non-ethernet device anyway.

> >  
> > +void netpoll_poll_dev(struct net_device *dev);
> >  void netpoll_send_udp(struct netpoll *np, const char *msg, int
> >  
> > -static void netpoll_poll_dev(struct net_device *dev)
> > +void netpoll_poll_dev(struct net_device *dev)
> 
> 
> This is interesting and I will have to look into this further...  A
> large part of the reason kgdboe never went anywhere was all around
> the locking problems the ability to safely use the network hardware
> and restore the state when it was done.  It appears you made this
> change so as to make a lockless call directly instead of going
> through netpoll_poll().  I am not entirely sure you could safely do
> this.
> 
> In kgdboe we always had:
> 
> +static int eth_get_char(void)
> +{
> +	int chr;
> +
> +	while (atomic_read(&in_count) == 0)
> +		netpoll_poll(&np);
> 
> 
> If it is the case that you really can safely call the
> netpoll_poll_dev() without the locks then the horrible sync irq
> state etc... could go away in kgdboe, and then it would be worth
> considering digging up all the ethernet polling errata fixes that
> live of out the mainline and perhaps submit some for review.
> 

I didn't look deeply at kgdboe (probably should have...). Anyway, netpoll_poll
doesn't seem to exist. netpoll_poll_dev is called from netpoll_send_skb_on_dev
and the only contract I see is running with the interrupts disabled - something
that is satisfied by running in the context of KDB.

This is slight OT, but...are WiFi drivers sufficiently similar that netpoll "just works?"

Thanks again.

A
