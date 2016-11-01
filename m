From: John Heenan <john@zgus.com>
Subject: Re: [PATCH] rtl8xxxu: Fix for agressive power saving by rtl8723bu
 wireless IC
Date: Tue, 1 Nov 2016 17:24:33 +1000
Message-ID: <CAAye0QNjYY5gBzSdc+0_rhy1OHk7iQ-CVp0Svph1DR7+mgVWGg@mail.gmail.com>
References: <20161031183522.GA13315@cube> <wrfj1sywrz2f.fsf@redhat.com> <CAAye0QNtcb28q1HY-xAr=bQ0s_nEQuv1TM+Ax5i99Eds7xOb=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAye0QNtcb28q1HY-xAr=bQ0s_nEQuv1TM+Ax5i99Eds7xOb=Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have a prepared another patch that is not USB VID/PID dependent for
rtl8723bu devices. It is more elegant. I will send it after this
email.

If I have more patches is it preferable I just put them on github only
and notify a link address until there might be some resolution?

What I meant below about not finding a matching function is that I
cannot find matching actions to take on any function calls in
rtl8xxxu_stop as for rtl8xxxu_start.

The function that is called later and potentially more than once for
rtl8723bu devices is rtl8xxxu_init_device. There is no corresponding
rtl8xxxu_deinit_device function.

enable_rf is called in rtl8xxxu_start, not in the delayed call to
rtl8xxxu_init_device. The corresponding disable_rf is called in
rtl8xxxu_stop. So no matching issue here. However please see below for
another potential issue.

power_on is called in rtl8xxxu_init_device. power_off is called in
rtl8xxxu_disconnect. Does not appear to be an issue if calling
power_on has no real effect if already on.

The following should be looked at though. For all devices enable_rf is
only called once. For the proposed patch the first call to
rtl8xxxu_init_device is called after the single call to enable_rf for
rtl8723bu devices. Without the patch enable_rf is called after
rtl8xxxu_init_device for all devices

Perhaps enable_rf just configures RF modes to start up when RF is
powered on or if called after power_on then enters requested RF modes.

So I cannot see appropriate additional matching action to take.

Below is some background for anyone interested

rtl8xxxu_start and rtl8xxxu_stop are assigned to rtl8xxxu_ops.

rtl8xxxu_probe assigns rtl8xxxu_ops to its driver layer with
ieee80211_register_hw.

rtl8xxxu_disconnect unassigns rtl8xxxu_ops from its driver layer with
ieee80211_unregister_hw.

rtl8xxxu_probe and rtl8xxxu_disconnect are USB driver functions

John Heenan


On 1 November 2016 at 08:15, John Heenan <john@zgus.com> wrote:
> On 1 November 2016 at 07:25, Jes Sorensen <Jes.Sorensen@redhat.com> wrote:
>> John Heenan <john@zgus.com> writes:
>
>>
>>> @@ -5776,9 +5781,17 @@ static int rtl8xxxu_start(struct ieee80211_hw *hw)
>>>       struct rtl8xxxu_tx_urb *tx_urb;
>>>       unsigned long flags;
>>>       int ret, i;
>>> +     struct usb_device_descriptor *udesc = &priv->udev->descriptor;
>>>
>>>       ret = 0;
>>>
>>> +     if(udesc->idVendor == USB_VENDOR_ID_REALTEK
>>> +                     && udesc->idProduct == USB_PRODUCT_ID_RTL8723BU) {
>>> +             ret = rtl8xxxu_init_device(hw);
>>> +             if (ret)
>>> +                     goto error_out;
>>> +     }
>>> +
>>
>> As mentioned previously, if this is to be changed here, it has to be
>> matched in the _stop section too.
>
> I looked at this and could not find a matching function. I will have a
> look again.
>
