From: John Heenan <john@zgus.com>
Subject: Re: [PATCH] rtl8xxxu: Fix for agressive power saving by rtl8723bu
 wireless IC
Date: Wed, 2 Nov 2016 11:13:34 +1000
Message-ID: <CAAye0QP0FQetaaa-RE23teVgZ335ELE8O5qnzMA7CwQ4T8wc_Q@mail.gmail.com>
References: <20161031183522.GA13315@cube> <wrfj1sywrz2f.fsf@redhat.com>
 <CAAye0QNtcb28q1HY-xAr=bQ0s_nEQuv1TM+Ax5i99Eds7xOb=Q@mail.gmail.com> <CAAye0QNjYY5gBzSdc+0_rhy1OHk7iQ-CVp0Svph1DR7+mgVWGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>,
        Barry Day <briselec@gmail.com>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36125 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754166AbcKBBNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 21:13:36 -0400
Received: by mail-wm0-f65.google.com with SMTP id c17so499010wmc.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 18:13:36 -0700 (PDT)
In-Reply-To: <CAAye0QNjYY5gBzSdc+0_rhy1OHk7iQ-CVp0Svph1DR7+mgVWGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Barry Day has submitted real world reports for the 8192eu and 8192cu.
This needs to be acknowledged. I have submitted real world reports for
the 8723bu.

When it comes down to it, it looks like the kernel code changes are
really going to be very trivial to fix this problem and we need to
take the focus off dramatic outbursts over style issues to a strategy
for getting usable results from real world testing.

Addressing style issues in a dramatic manner to me looks like a mean
sport for maintainers who line up to easy target first time
contributors. This mean attitude comes from the top with a well known
comment about "publicly making fun of people". The polite comments
over style from Joe Perches and Rafa=C5=82 Mi=C5=82ecki are welcomed.

An effective strategy would be to insert some printk statements to
trace what init steps vendor derived drivers do each time
wpa_supplicant is called and ask real world testers to report their
results. This is a lot more productive and less error prone than
laboriously pouring over vendor source code. Alternative drivers that
use vendor code from Realtek is enormously complicated and a huge pain
to make sense of.

Joe Sorensen's driver code is far easier to make sense of and it is a
shame Realtek don't come to the party. Joe Sorensens's code take takes
advantage of the excellent work of kernel contributors to the mac80211
driver.

Previous comments I made about enable_rf, rtl8xxxu_start,
rtl8xxxu_init_device etc should be clarified. I will leave it for the
moment as it currently serves no direct useful purpose.


John Heenan

On 1 November 2016 at 17:24, John Heenan <john@zgus.com> wrote:
> I have a prepared another patch that is not USB VID/PID dependent for
> rtl8723bu devices. It is more elegant. I will send it after this
> email.
>
> If I have more patches is it preferable I just put them on github only
> and notify a link address until there might be some resolution?
>
> What I meant below about not finding a matching function is that I
> cannot find matching actions to take on any function calls in
> rtl8xxxu_stop as for rtl8xxxu_start.
>
> The function that is called later and potentially more than once for
> rtl8723bu devices is rtl8xxxu_init_device. There is no corresponding
> rtl8xxxu_deinit_device function.
>
> enable_rf is called in rtl8xxxu_start, not in the delayed call to
> rtl8xxxu_init_device. The corresponding disable_rf is called in
> rtl8xxxu_stop. So no matching issue here. However please see below for
> another potential issue.
>
> power_on is called in rtl8xxxu_init_device. power_off is called in
> rtl8xxxu_disconnect. Does not appear to be an issue if calling
> power_on has no real effect if already on.
>
> The following should be looked at though. For all devices enable_rf is
> only called once. For the proposed patch the first call to
> rtl8xxxu_init_device is called after the single call to enable_rf for
> rtl8723bu devices. Without the patch enable_rf is called after
> rtl8xxxu_init_device for all devices
>
> Perhaps enable_rf just configures RF modes to start up when RF is
> powered on or if called after power_on then enters requested RF modes.
>
> So I cannot see appropriate additional matching action to take.
>
> Below is some background for anyone interested
>
> rtl8xxxu_start and rtl8xxxu_stop are assigned to rtl8xxxu_ops.
>
> rtl8xxxu_probe assigns rtl8xxxu_ops to its driver layer with
> ieee80211_register_hw.
>
> rtl8xxxu_disconnect unassigns rtl8xxxu_ops from its driver layer with
> ieee80211_unregister_hw.
>
> rtl8xxxu_probe and rtl8xxxu_disconnect are USB driver functions
>
> John Heenan
>
>
> On 1 November 2016 at 08:15, John Heenan <john@zgus.com> wrote:
>> On 1 November 2016 at 07:25, Jes Sorensen <Jes.Sorensen@redhat.com> wrot=
e:
>>> John Heenan <john@zgus.com> writes:
>>
>>>
>>>> @@ -5776,9 +5781,17 @@ static int rtl8xxxu_start(struct ieee80211_hw *=
hw)
>>>>       struct rtl8xxxu_tx_urb *tx_urb;
>>>>       unsigned long flags;
>>>>       int ret, i;
>>>> +     struct usb_device_descriptor *udesc =3D &priv->udev->descriptor;
>>>>
>>>>       ret =3D 0;
>>>>
>>>> +     if(udesc->idVendor =3D=3D USB_VENDOR_ID_REALTEK
>>>> +                     && udesc->idProduct =3D=3D USB_PRODUCT_ID_RTL872=
3BU) {
>>>> +             ret =3D rtl8xxxu_init_device(hw);
>>>> +             if (ret)
>>>> +                     goto error_out;
>>>> +     }
>>>> +
>>>
>>> As mentioned previously, if this is to be changed here, it has to be
>>> matched in the _stop section too.
>>
>> I looked at this and could not find a matching function. I will have a
>> look again.
>>
