From: Johan Hovold <jhovold@gmail.com>
Subject: Re: [PATCH 2/2] bluetooth: hci_core: fix NULL-pointer dereference at
 unregister
Date: Thu, 8 Mar 2012 12:56:47 +0100
Message-ID: <20120308115647.GA4497@localhost>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
 <1331136120-27075-3-git-send-email-jhovold@gmail.com>
 <1331148560.3392.189.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, stable <stable@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1331148560.3392.189.camel@aeonflux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

On Wed, Mar 07, 2012 at 11:29:20AM -0800, Marcel Holtmann wrote:
> Hi Johan,
> 
> > Make sure hci_dev_open returns immediately if hci_dev_unregister has
> > been called.
> > 
> > This fixes a race between hci_dev_open and hci_dev_unregister which can
> > lead to a NULL-pointer dereference.

[...]

> what version of the kernel is this patch against? Since we cleaned up
> the flags in bluetooth-next tree. Also in addition you can not just add
> flags here.

As this to be fixed in 3.3 it is against 3.3-rc6.

> >  /*
> > diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
> > index 5aeb624..3937ce3 100644
> > --- a/net/bluetooth/hci_core.c
> > +++ b/net/bluetooth/hci_core.c
> > @@ -525,6 +525,11 @@ int hci_dev_open(__u16 dev)
> >  
> >  	hci_req_lock(hdev);
> >  
> > +	if (test_bit(HCI_UNREGISTER, &hdev->flags)) {
> > +		ret = -ENODEV;
> > +		goto done;
> > +	}
> > +
> >  	if (hdev->rfkill && rfkill_blocked(hdev->rfkill)) {
> >  		ret = -ERFKILL;
> >  		goto done;
> > @@ -1577,6 +1582,8 @@ void hci_unregister_dev(struct hci_dev *hdev)
> >  
> >  	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
> >  
> > +	set_bit(HCI_UNREGISTER, &hdev->flags);
> > +
> >  	write_lock(&hci_dev_list_lock);
> >  	list_del(&hdev->list);
> >  	write_unlock(&hci_dev_list_lock);
> 
> Is this really enough to protect this race condition?

1. first hci_dev_open grabs req lock
2. second hci_dev_open sleeps on req lock
3. hci_dev_unregister sleep on req lock (in do_close)
4. first hci_dev_open times out and releases req lock

Now either a) the second open grabs the lock or b) close does. 

a) The second open will time out eventually as well and setting a flag
   at unregister will only speed things up (at least when the first
   patch in my series is applied -- otherwise this leads to a
   NULL-pointer exception as well).

b) If close grabs the lock while we have open sleeping on it things go
   really bad and this is the case this patch intends to fix.

As far as I can see, a flag set at unregister (before acquiring the lock)
will suffice to fix this race, but perhaps I'm missing something?

Where should such an internal flag be added as hdev->flags can not be
used? hdev->dev_flags?

Thanks,
Johan
