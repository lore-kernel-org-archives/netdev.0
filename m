From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: freeing an active object
Date: Sun, 06 Dec 2015 14:31:30 +0100
Message-ID: <1449408690.2515.15.camel@tiscali.nl>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
	 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
	 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
	 <1448906497.3546.16.camel@tiscali.nl> <565F8341.7010704@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Peter Hurley <peter@hurleysoftware.com>,
	Tilman Schmidt <tilman@imap.cc>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <565F8341.7010704@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On wo, 2015-12-02 at 18:48 -0500, Peter Hurley wrote:
> On 11/30/2015 01:01 PM, Paul Bolle wrote:
> > Should (something like) this go into stable too?
> 
> Definitely for stable since it has a userspace triggerable component.

Thanks, will do.

> > --- a/drivers/isdn/gigaset/ser-gigaset.c
> > +++ b/drivers/isdn/gigaset/ser-gigaset.c
> > @@ -42,8 +42,9 @@ MODULE_PARM_DESC(cidmode, "stay in CID mode when
> > idle");
> >  
> >  static struct gigaset_driver *driver;
> >  
> > +static struct platform_device pdev;
> > +
> >  struct ser_cardstate {
> > -	struct platform_device	dev;
> >  	struct tty_struct	*tty;
> >  	atomic_t		refcnt;
> >  	struct completion	dead_cmp;
> > @@ -370,8 +371,8 @@ static void gigaset_freecshw(struct cardstate
> > *cs)
> >  	tasklet_kill(&cs->write_tasklet);
> >  	if (!cs->hw.ser)
> >  		return;
> > -	dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
> > -	platform_device_unregister(&cs->hw.ser->dev);
> > +	dev_set_drvdata(&pdev.dev, NULL);
> > +	platform_device_unregister(&pdev);
> >  	kfree(cs->hw.ser);
> 
> Tilman,
> 
> Is there a 1:1 correspondence and lifetime for the embedded platform
> device and it's containing memory?

(Haven't heard from Tilman, so I'll give this a try.)

That containing memory is a struct ser_cardstate. And currently
instances of struct _ser_cardstate are malloced and freed in routines
that also call platform_device_register() and
platform_device_unregister(). So yes, I think there's a 1:1
correspondence.

> I ask because the typical approach for device teardown is to put the
> kfree() in the release method;

(Side note: the (struct device) release method of this driver 
-gigaset_device_release() - is actually a nop. It only frees device
->platform_data and platform_device->resource, but neither are actually
used: they remain NULL through their entire life.)

>  naturally, that won't work if there
> is some other lifetime issue.

I'm not sure I follow what you mean here. Could you point me at a driver
that uses that approach, so that I can have a look at it?

Thanks,


Paul Bolle
