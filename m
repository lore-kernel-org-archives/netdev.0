From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend
 fails in system sleep
Date: Tue, 5 Mar 2013 23:29:15 +0800
Message-ID: <CACVXFVMDNtJOp+8jMOuhCBjrqq-L=jicEJBr_=ErG19Vr+7OGw@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-5-git-send-email-ming.lei@canonical.com>
	<87boayqq5c.fsf@nemi.mork.no>
	<CACVXFVMRpf0REYxfi1wtzUpXn2PTCeS6qNfYQP12tW8ca3Sp=g@mail.gmail.com>
	<87d2veot6t.fsf@nemi.mork.no>
	<CACVXFVOg9cVNYsRuAVkexwy4hvD_iJm_vARRksBAeiWppWnoXA@mail.gmail.com>
	<871ubtq47a.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36403 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489Ab3CEP3S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 10:29:18 -0500
In-Reply-To: <871ubtq47a.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 5, 2013 at 11:03 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <ming.lei@canonical.com> writes:
>> On Tue, Mar 5, 2013 at 9:46 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>>
>>> Now, after inspecting wdm_suspend() which hides behind
>>> info->subdriver->suspend(), I see that this is a completely theoret=
ical
>>> discussion as it always will return 0 if PMSG_IS_AUTO(msg) is true.=
=2E.
>>>
>>> Which means that your change really is a noop().  I still don't lik=
e it,
>>> because it gives the impression that errors from info->subdriver->s=
uspend()
>>> isn't dealt with.
>>
>> Yes, it needn't dealt with in system sleep, so it has the document b=
enefit.
>
> The document that the return code is ignored by forcing it to 0 and
> always return success.
>
> But am still not convinced this is correct in any way.  AFAICS there =
is
> no documentation stating that the drivers should care about what the =
USB

We have source code, :-)

> core use the return value for. Drivers are allowed to fail and the co=
re
> will ignore and clean up if necessary.
>
> I still find any partial failures horrendous.  If we are not going to
> fail on errors, then we'll return success and pretend to be suspended=
=2E
>
>> No, USB core does not handle it, and will always ignore the return
>> failure from driver's suspend, see usb_suspend_both() for non-autosu=
spend
>> case.
>
> Right you are.  Somehow I read the inverse.  Sorry about that.
>
> In any case, it ends up here and everythin will be OK, which I assume=
 is
> why it can ignore the errors:
>
>         /* If the suspend succeeded then prevent any more URB submiss=
ions
>          * and flush any outstanding URBs.
>          */
>         } else {
>                 udev->can_submit =3D 0;
>                 for (i =3D 0; i < 16; ++i) {
>                         usb_hcd_flush_endpoint(udev, udev->ep_out[i])=
;
>                         usb_hcd_flush_endpoint(udev, udev->ep_in[i]);
>                 }
>         }

Yes, USB core will flush any outstanding URBs, but the driver still nee=
d
to deal with suspend failure carefully, for example, suppose usb_resume=
()
is called in suspend failure path, and the submitted URBs are killed
by USB core later. But after the device is wakeup, and the resume() wil=
l
do nothing since the suspend count is leaked. So it is what the patches
are fixing, and it is better to not depend on the default flushing URBs=
 of
USB core.

Thanks,
--
Ming Lei
