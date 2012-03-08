From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/2] bluetooth: hci_core: fix NULL-pointer dereference
 at unregister
Date: Thu, 08 Mar 2012 09:43:26 -0800
Message-ID: <1331228606.14217.5.camel@aeonflux>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
	 <1331136120-27075-3-git-send-email-jhovold@gmail.com>
	 <1331148560.3392.189.camel@aeonflux> <20120308115647.GA4497@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120308115647.GA4497@localhost>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Johan,

> > > Make sure hci_dev_open returns immediately if hci_dev_unregister has
> > > been called.
> > > 
> > > This fixes a race between hci_dev_open and hci_dev_unregister which can
> > > lead to a NULL-pointer dereference.
> 
> [...]
> 
> > what version of the kernel is this patch against? Since we cleaned up
> > the flags in bluetooth-next tree. Also in addition you can not just add
> > flags here.
> 
> As this to be fixed in 3.3 it is against 3.3-rc6.
> 
> > >  /*
> > > diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
> > > index 5aeb624..3937ce3 100644
> > > --- a/net/bluetooth/hci_core.c
> > > +++ b/net/bluetooth/hci_core.c
> > > @@ -525,6 +525,11 @@ int hci_dev_open(__u16 dev)
> > >  
> > >  	hci_req_lock(hdev);
> > >  
> > > +	if (test_bit(HCI_UNREGISTER, &hdev->flags)) {
> > > +		ret = -ENODEV;
> > > +		goto done;
> > > +	}
> > > +
> > >  	if (hdev->rfkill && rfkill_blocked(hdev->rfkill)) {
> > >  		ret = -ERFKILL;
> > >  		goto done;
> > > @@ -1577,6 +1582,8 @@ void hci_unregister_dev(struct hci_dev *hdev)
> > >  
> > >  	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
> > >  
> > > +	set_bit(HCI_UNREGISTER, &hdev->flags);
> > > +
> > >  	write_lock(&hci_dev_list_lock);
> > >  	list_del(&hdev->list);
> > >  	write_unlock(&hci_dev_list_lock);
> > 
> > Is this really enough to protect this race condition?
> 
> 1. first hci_dev_open grabs req lock
> 2. second hci_dev_open sleeps on req lock
> 3. hci_dev_unregister sleep on req lock (in do_close)
> 4. first hci_dev_open times out and releases req lock
> 
> Now either a) the second open grabs the lock or b) close does. 
> 
> a) The second open will time out eventually as well and setting a flag
>    at unregister will only speed things up (at least when the first
>    patch in my series is applied -- otherwise this leads to a
>    NULL-pointer exception as well).
> 
> b) If close grabs the lock while we have open sleeping on it things go
>    really bad and this is the case this patch intends to fix.
> 
> As far as I can see, a flag set at unregister (before acquiring the lock)
> will suffice to fix this race, but perhaps I'm missing something?
> 
> Where should such an internal flag be added as hdev->flags can not be
> used? hdev->dev_flags?

please add them to hdev->dev_flags as internal flag.

Regards

Marcel
