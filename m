From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Mon, 07 Jun 2010 13:41:45 +0200
Message-ID: <1275910905.29978.7.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
	 <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	 <m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	 <1275634452.5189.1.camel@jlt3.sipsolutions.net>
	 <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	 <1275640113.9953.8.camel@jlt3.sipsolutions.net>
	 <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	 <1275829701.3615.54.camel@jlt3.sipsolutions.net>
	 <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
	 <1275903773.29978.1.camel@jlt3.sipsolutions.net>
	 <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
	 <1275905686.29978.3.camel@jlt3.sipsolutions.net>
	 <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:55680 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab0FGLlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 07:41:53 -0400
In-Reply-To: <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-07 at 13:05 +0200, Kay Sievers wrote:

> > +               data->dev = kzalloc(sizeof(struct device), GFP_KERNEL);
> > +               if (!data->dev) {
> >                        err = -ENOMEM;
> >                        goto failed_drvdata;
> >                }
> > +
> > +               dev_set_name(data->dev, "hwsim%d", i);
> > +               data->dev->bus = &hwsim_bus;
> >                data->dev->driver = &mac80211_hwsim_driver;
> >
> > +               err = device_register(data->dev);
> > +               if (err) {
> > +                       printk(KERN_DEBUG
> > +                              "mac80211_hwsim: device_register failed (%d)\n",
> > +                              err);
> > +                       goto failed_drvdata;
> > +               }
> >
> > (ignore the pluses, snipped from a patch) but it ran into a null ptr
> > deref?
> 
> Oh, I see. It's probably something nobody ever did before. You try to
> register a bus device which has no parent. Seems that's something
> nobody ever expected to happen. :)
> 
> Your driver/subsystem is completely virtual, does not depend on any
> hardware, right? If we create a virtual parent, like:
>   parent = kzalloc(sizeof(struct device), GFP_KERNEL);
>   dev_set_name(parent, "mac80211_hwsim");
>   device_register(parent);
> 
> An in your code:
>   data->dev->parent = parent;
> 
> That should give you a /sys/devices/mac80211_hwsim/ directory where
> all the devices you create should show up.

So that seemed equivalent to my code except for the .bus/.driver
assignments and the two-level hierarchy of course. 

(mind you, I think we probably need to have the bus/driver assignment,
but I wanted to try out your suggestion first)

So I removed bus/driver assignment from the above code just to try it
out, and got

Device 'hwsim0' does not have a release() function, it is broken and
must be fixed.

This has evolved far too much for me right now. Can we just apply the
initial patch from Eric and be happier for a while? I can't justify
spending this much time on it right now. Alternatively, you could look
at hwsim too, since it's all virtual, nothing special is required, I do
testing in a virtual machine ...

current patch is at
http://johannes.sipsolutions.net/patches/kernel/all/2010-06-07-11:41/hwsim-bus.patch

johannes

