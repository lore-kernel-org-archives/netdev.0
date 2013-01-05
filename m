From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be active
Date: Sat, 05 Jan 2013 11:59:16 +0100
Message-ID: <87y5g7nbej.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1357318096.5370.15.camel@dcbw.foobar.com>
	<2212516.GkG3xP33yG@linux-5eaq.site>
	<1357349193.19684.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357349193.19684.3.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org> (Dan Williams's
	message of "Fri, 04 Jan 2013 19:26:33 -0600")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> On Fri, 2013-01-04 at 23:16 +0100, Oliver Neukum wrote:
>> On Friday 04 January 2013 10:48:16 Dan Williams wrote:
>> > Some drivers (ex sierra_net) need the status interrupt URB
>> > active even when the device is closed, because they receive
>> > custom indications from firmware.  Allow sub-drivers to set
>> > a flag that submits the status interrupt URB on probe and
>> > keeps the URB alive over device open/close.  The URB is still
>> > killed/re-submitted for suspend/resume, as before.
>> >=20
>> > Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> > ---
>> > Oliver: alternatively, is there a problem with *always*
>> > submitting the interrupt URB, and then simply not calling
>> > the subdriver's .status function when the netdev is
>> > closed?  That would be a much simpler patch.
>>=20
>> That is quite radical. We have no idea what a device
>> does when we do not react to a status update. I would
>> much prefer to not take the risk.
>> Besides, we don't use bandwidth if we don't have to.
>
> Ok, so scratch the alternative.  Thus, does the posted patch look lik=
e
> the right course of action?
>
> If I wasn't clear enough before, sierra_net needs to listen to the
> status interrupt URB to receive the custom Restart indication as part=
 of
> the driver's device setup.  Thus for sierra_net at least, tying the
> status interrupt URB submission to device open/close isn't right.
>
> I'd previously done a patch to handle this all in sierra_net, but the
> problem there is suspend/resume: without directly accessing the usbne=
t
> structure's ->suspend_count member (icky!) sierra_net can't correctly
> kill/submit the URB itself.  So I went with a flag to usbnet that Sie=
rra
> can set.

Just a few random thoughts...

The sierra_net driver would have been an excellent candidate for the
cdc-wdm subdriver model if that had existed when sierra_net was written=
=2E
I assume the current driver only implements a minimal subset of the
DirectIP HIP protocol embedded in CDC, and exporting this to userspace
instead would have made it possible to extend that support without
changing the driver, in addtion to making the driver much more robust
against firmware differences.  It would have eliminated the problem you
are facing and removed the minidriver workqueue complexity.

But I guess it's too late to change this now.  In theory we could
implement the cdc-wdm hooks that were initially proposed for cdc_mbim
and rewrite sierra_net to use it while being backwards compatible.
Don't think anyone wants to do either, so forget about it...

You can still use a trick similar to what qmi_wwan and cdc_mbim does to
take over the status endpoint from usbnet: By not implementing .status,
and possibly setting dev->status to NULL in .bind, you are free to
handle the status endpoint entirely inside the minidriver.  Not sure if
that is smart though.  You would have to reimplement init_status and
intr_complete from usbnet, and kill or resubmit the interrupt urb on
suspend/resume/disconnect yourself.

The new usbnet flag is probably a better solution.

=46WIW, I agree with Oliver that always submitting the interrupt URB is
both risky and will cause too much unnecessary USB activity for most
usbnet devices.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
