From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend fails in system sleep
Date: Tue, 05 Mar 2013 16:03:21 +0100
Message-ID: <871ubtq47a.fsf@nemi.mork.no>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-5-git-send-email-ming.lei@canonical.com>
	<87boayqq5c.fsf@nemi.mork.no>
	<CACVXFVMRpf0REYxfi1wtzUpXn2PTCeS6qNfYQP12tW8ca3Sp=g@mail.gmail.com>
	<87d2veot6t.fsf@nemi.mork.no>
	<CACVXFVOg9cVNYsRuAVkexwy4hvD_iJm_vARRksBAeiWppWnoXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <CACVXFVOg9cVNYsRuAVkexwy4hvD_iJm_vARRksBAeiWppWnoXA@mail.gmail.com>
	(Ming Lei's message of "Tue, 5 Mar 2013 22:50:43 +0800")
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ming Lei <ming.lei@canonical.com> writes:
> On Tue, Mar 5, 2013 at 9:46 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
>
>> Now, after inspecting wdm_suspend() which hides behind
>> info->subdriver->suspend(), I see that this is a completely theoreti=
cal
>> discussion as it always will return 0 if PMSG_IS_AUTO(msg) is true..=
=2E
>>
>> Which means that your change really is a noop().  I still don't like=
 it,
>> because it gives the impression that errors from info->subdriver->su=
spend()
>> isn't dealt with.
>
> Yes, it needn't dealt with in system sleep, so it has the document be=
nefit.

The document that the return code is ignored by forcing it to 0 and
always return success.

But am still not convinced this is correct in any way.  AFAICS there is
no documentation stating that the drivers should care about what the US=
B
core use the return value for. Drivers are allowed to fail and the core
will ignore and clean up if necessary.

I still find any partial failures horrendous.  If we are not going to
fail on errors, then we'll return success and pretend to be suspended.

> No, USB core does not handle it, and will always ignore the return
> failure from driver's suspend, see usb_suspend_both() for non-autosus=
pend
> case.

Right you are.  Somehow I read the inverse.  Sorry about that.

In any case, it ends up here and everythin will be OK, which I assume i=
s
why it can ignore the errors:

        /* If the suspend succeeded then prevent any more URB submissio=
ns
         * and flush any outstanding URBs.
         */
        } else {
                udev->can_submit =3D 0;
                for (i =3D 0; i < 16; ++i) {
                        usb_hcd_flush_endpoint(udev, udev->ep_out[i]);
                        usb_hcd_flush_endpoint(udev, udev->ep_in[i]);
                }
        }


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
