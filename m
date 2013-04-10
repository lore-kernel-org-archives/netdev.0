From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be active
Date: Wed, 10 Apr 2013 17:21:31 +0200
Message-ID: <87d2u25s3o.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1357318096.5370.15.camel@dcbw.foobar.com>
	<1364488207.1877.20.camel@dcbw.foobar.com>
	<CACVXFVMBAzTYZKiE_uSTqr_yB4f7c5_PSnK=LBP6=oWdWwYHfg@mail.gmail.com>
	<1364832288.3059.12.camel@dcbw.foobar.com>
	<1365548547.23372.2.camel@dcbw.foobar.com>
	<87li8q5xgi.fsf@nemi.mork.no>
	<1365604263.28888.56.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52027 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932468Ab3DJQjq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 12:39:46 -0400
In-Reply-To: <1365604263.28888.56.camel@dcbw.foobar.com> (Dan Williams's
	message of "Wed, 10 Apr 2013 09:31:03 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:
> On Wed, 2013-04-10 at 15:25 +0200, Bj=C3=B8rn Mork wrote:
>> Dan Williams <dcbw@redhat.com> writes:
>>=20
>> > +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
>> > +{
>> > +	/* Only drivers that implement a status hook should call this */
>> > +	BUG_ON(dev->interrupt =3D=3D NULL);
>> >=20
>> I still don't think there is any reason to BUG out. See for example
>> http://article.gmane.org/gmane.linux.kernel/52102
>>=20
>> > +static void __usbnet_status_stop(struct usbnet *dev, bool force)
>> > +{
>> > +	if (dev->interrupt) {
>> > +		mutex_lock(&dev->interrupt_mutex);
>> > +		if (!force)
>> > +			BUG_ON(dev->interrupt_count =3D=3D 0);
>>=20
>> Same here.  You can deal with this just fine.  Warn once, and go on
>> ignoring the problem.  Why kill the machine because of some minor dr=
iver
>> issue?
>
> Actually in the stop case, no, we can't deal with it, because then (d=
ue
> to the buggy sub-driver) we'd go on to decrement 0 into UINT_MAX.  It
> really is a bug if, *not* at suspend time, we're told to stop the
> interrupt URB when it's not yet submitted.=20

Sure it is a bug.  All I'm saying is that you can deal with it.  Warn
about the bug and give up.  Or continue.  But don't roll over and die.
Let the user unload the buggy driver and email the author instead.

> I'm happy to add another
> if() here though, which would end up looking like this:
>
> if (dev->interrupt_count && --dev->interrupt_count =3D=3D 0)
>     usb_kill_urb(dev->interrupt);
>
> which seems odd, but fine.

Yes, there are too many decision factors, so it does look odd.  You
could also decide early that the bogus dev->interrupt_count means that
nothing needs to be done, because no interrupt URB was subitted.  Like

static void __usbnet_status_stop(struct usbnet *dev, bool force)
{
	if (dev->interrupt) {
		mutex_lock(&dev->interrupt_mutex);
                if (!force && dev->interrupt_count =3D=3D 0) {
                     print loud warning blaming the minidriver author;
                     goto out;
                }
		if (force || --dev->interrupt_count =3D=3D 0)
			usb_kill_urb(dev->interrupt);

		dev_dbg(&dev->udev->dev,
			"decremented interrupt URB count to %d\n",
			dev->interrupt_count);
out:
		mutex_unlock(&dev->interrupt_mutex);
	}
}


But it is pretty much the same.  "force" makes a mess of it.

In any case, I believe any of those solutions are a lot nicer to any
unsuspecting user, who may not agree with you that a failing 3G modem i=
s
important enough to kill the machine.


Bj=C3=B8rn
