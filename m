From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be
 active
Date: Mon, 07 Jan 2013 09:21:30 -0600
Message-ID: <1357572090.27649.7.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
	 <2212516.GkG3xP33yG@linux-5eaq.site>
	 <1357349193.19684.3.camel@dcbw.foobar.com> <87y5g7nbej.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59392 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751387Ab3AGPTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 10:19:13 -0500
In-Reply-To: <87y5g7nbej.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-05 at 11:59 +0100, Bj=C3=B8rn Mork wrote:
> Dan Williams <dcbw@redhat.com> writes:
> > On Fri, 2013-01-04 at 23:16 +0100, Oliver Neukum wrote:
> >> On Friday 04 January 2013 10:48:16 Dan Williams wrote:
> >> > Some drivers (ex sierra_net) need the status interrupt URB
> >> > active even when the device is closed, because they receive
> >> > custom indications from firmware.  Allow sub-drivers to set
> >> > a flag that submits the status interrupt URB on probe and
> >> > keeps the URB alive over device open/close.  The URB is still
> >> > killed/re-submitted for suspend/resume, as before.
> >> >=20
> >> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> >> > ---
> >> > Oliver: alternatively, is there a problem with *always*
> >> > submitting the interrupt URB, and then simply not calling
> >> > the subdriver's .status function when the netdev is
> >> > closed?  That would be a much simpler patch.
> >>=20
> >> That is quite radical. We have no idea what a device
> >> does when we do not react to a status update. I would
> >> much prefer to not take the risk.
> >> Besides, we don't use bandwidth if we don't have to.
> >
> > Ok, so scratch the alternative.  Thus, does the posted patch look l=
ike
> > the right course of action?
> >
> > If I wasn't clear enough before, sierra_net needs to listen to the
> > status interrupt URB to receive the custom Restart indication as pa=
rt of
> > the driver's device setup.  Thus for sierra_net at least, tying the
> > status interrupt URB submission to device open/close isn't right.
> >
> > I'd previously done a patch to handle this all in sierra_net, but t=
he
> > problem there is suspend/resume: without directly accessing the usb=
net
> > structure's ->suspend_count member (icky!) sierra_net can't correct=
ly
> > kill/submit the URB itself.  So I went with a flag to usbnet that S=
ierra
> > can set.
>=20
> Just a few random thoughts...
>=20
> The sierra_net driver would have been an excellent candidate for the
> cdc-wdm subdriver model if that had existed when sierra_net was writt=
en.
> I assume the current driver only implements a minimal subset of the
> DirectIP HIP protocol embedded in CDC, and exporting this to userspac=
e
> instead would have made it possible to extend that support without
> changing the driver, in addtion to making the driver much more robust
> against firmware differences.  It would have eliminated the problem y=
ou
> are facing and removed the minidriver workqueue complexity.
>=20
> But I guess it's too late to change this now.  In theory we could
> implement the cdc-wdm hooks that were initially proposed for cdc_mbim
> and rewrite sierra_net to use it while being backwards compatible.
> Don't think anyone wants to do either, so forget about it...
>=20
> You can still use a trick similar to what qmi_wwan and cdc_mbim does =
to
> take over the status endpoint from usbnet: By not implementing .statu=
s,
> and possibly setting dev->status to NULL in .bind, you are free to
> handle the status endpoint entirely inside the minidriver.  Not sure =
if
> that is smart though.  You would have to reimplement init_status and
> intr_complete from usbnet, and kill or resubmit the interrupt urb on
> suspend/resume/disconnect yourself.

That was exactly the approach of my first patch.  But that was icky
because we need to also track suspend/resume state by looking at
internal members of usbnet's structure.  Yes, it's specific to Sierra,
but it's pretty much a layer violation.  So I went with the flag
approach.

Dan

> The new usbnet flag is probably a better solution.
>=20
> FWIW, I agree with Oliver that always submitting the interrupt URB is
> both risky and will cause too much unnecessary USB activity for most
> usbnet devices.
>=20
>=20
> Bj=C3=B8rn
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
