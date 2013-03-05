From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend
 fails in system sleep
Date: Tue, 5 Mar 2013 22:50:43 +0800
Message-ID: <CACVXFVOg9cVNYsRuAVkexwy4hvD_iJm_vARRksBAeiWppWnoXA@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-5-git-send-email-ming.lei@canonical.com>
	<87boayqq5c.fsf@nemi.mork.no>
	<CACVXFVMRpf0REYxfi1wtzUpXn2PTCeS6qNfYQP12tW8ca3Sp=g@mail.gmail.com>
	<87d2veot6t.fsf@nemi.mork.no>
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
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <87d2veot6t.fsf@nemi.mork.no>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 5, 2013 at 9:46 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <ming.lei@canonical.com> writes:
>
>> On Tue, Mar 5, 2013 at 3:09 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>>> Ming Lei <ming.lei@canonical.com> writes:
>>>
>>>> If suspend callback fails in system sleep context, usb core will
>>>> ignore the failure and let system sleep go ahead further, so
>>>> this patch doesn't recover device under this situation.
>>>>
>>>> Cc: Bj=F8rn Mork <bjorn@mork.no>
>>>> Signed-off-by: Ming Lei <ming.lei@canonical.com>
>>>> ---
>>>>  drivers/net/usb/cdc_mbim.c |    2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim=
=2Ec
>>>> index 248d2dc..da83546 100644
>>>> --- a/drivers/net/usb/cdc_mbim.c
>>>> +++ b/drivers/net/usb/cdc_mbim.c
>>>> @@ -338,7 +338,7 @@ static int cdc_mbim_suspend(struct usb_interfa=
ce *intf, pm_message_t message)
>>>>
>>>>       if (intf =3D=3D ctx->control && info->subdriver && info->sub=
driver->suspend)
>>>>               ret =3D info->subdriver->suspend(intf, message);
>>>> -     if (ret < 0)
>>>> +     if (ret < 0 && PMSG_IS_AUTO(msg))
>>>>               usbnet_resume(intf);
>>>>
>>>>  error:
>>>
>>> NAK. We if the device cannot suspend, then it cannot do suspend hal=
fways
>>
>> Sorry, what do you mean that the device cannot suspend?
>
>
> Now, after inspecting wdm_suspend() which hides behind
> info->subdriver->suspend(), I see that this is a completely theoretic=
al
> discussion as it always will return 0 if PMSG_IS_AUTO(msg) is true...
>
> Which means that your change really is a noop().  I still don't like =
it,
> because it gives the impression that errors from info->subdriver->sus=
pend()
> isn't dealt with.

Yes, it needn't dealt with in system sleep, so it has the document bene=
fit.

>
>>  If you mean
>> usb_suspend_device(), its failure is still ignored, and generally it=
 is OK
>> since the suspend action is driven by upstream port.
>
>
> I mean that we do two operations here: first we suspend usbnet, then =
we
> suspend wdm:
>
>         ret =3D usbnet_suspend(intf, message);
>         if (ret < 0)
>                 goto error;
>         if (intf =3D=3D ctx->control && info->subdriver && info->subd=
river->suspend)
>                 ret =3D info->subdriver->suspend(intf, message);
>         if (ret < 0)
>                 usbnet_resume(intf);
> error:
>         return ret;
>
>
> The case you are trying to modify is when the second fails after the
> first succeeded. You know suspend has already failed at this point.  =
It
> is the implication of the error.  Your only task is to decide what to=
 do
> about that failure.  You seem to think that you can fix it.  You
> cannot.  It already has failed.  If you are going to fix that, then y=
ou
> have to go back to where it failed.
>
> So your next step if going down this route will naturally be looking
> into how you can prevent info->subdriver->suspend() from ever failing=
=2E
> Which will be easy as it won't.  But assuming for this argument that =
it
> can fail, which I guess can be true for some of the serial driver
> callback errors etc you also fixed this way.  I am pretty sure that w=
hen
> you look into those to make sure they never can fail, you will find
> another function you have to ensure never can fail.
>
> Forget it.  suspend can and will fail.   Deal with it in the upper
> layers.  In fact, the USB core already does.  If you think it doesn't
> then that's where you fix it.

No, USB core does not handle it, and will always ignore the return
failure from driver's suspend, see usb_suspend_both() for non-autosuspe=
nd
case.

>
>>> either. Whether the caller will ignore the error or not, is irrelev=
ant.
>>
>> Anyway, usbnet_resume() can't be called to submit new URBs in
>> the failure path of system suspend, so the patch should be correct.
>
> I fail to see how this is any different from a composite device with
> e.g. a usbnet function and a serial function where suspending the ser=
ial
> function fails after successfully suspending the usbnet function.
> usb_suspend_both() will then resume the usbnet function and return th=
e
> error.

No, usb_suspend_both() always ignores the suspend failure from drivers
and does not resume a non-root-hub device during system sleep.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
