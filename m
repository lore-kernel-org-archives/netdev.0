From: Daniele Palmas <dnlplm@gmail.com>
Subject: Re: [PATCH 1/1] NET: usb: cdc_ncm: adding MBIM RESET_FUNCTION request
 and modifying ncm bind common code
Date: Mon, 5 Dec 2016 14:04:24 +0100
Message-ID: <CAGRyCJHjre7BByjcHt2XC5AH=Ta0jHGiPYAt=gDy71t=2PqOmw@mail.gmail.com>
References: <1479904606-30647-1-git-send-email-dnlplm@gmail.com>
 <1479904606-30647-2-git-send-email-dnlplm@gmail.com> <87k2bq7zn8.fsf@miraculix.mork.no>
 <87fume7xg5.fsf@miraculix.mork.no> <CAGRyCJFfNj4C_pNXWhMT7tVvdV4ZFzJ5d+LFAatvQmTuWU7OUg@mail.gmail.com>
 <CAGRyCJHsf6dFGaoui7fH1WspMhfHVdEdLAh-f4qV7YCZ2HxezA@mail.gmail.com> <87a8ca1yat.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oliver@neukum.org>,
        linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34764 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbcLENSD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 08:18:03 -0500
In-Reply-To: <87a8ca1yat.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2016-12-05 11:10 GMT+01:00 Bj=C3=B8rn Mork <bjorn@mork.no>:
> Daniele Palmas <dnlplm@gmail.com> writes:
>
>> I went back to this and further checking revealed that MBIM function
>> reset is not needed and the only problem is related to commit
>> 48906f62c96cc2cd35753e59310cb70eb08cc6a5 cdc_ncm: toggle altsetting to
>> force reset before setup, that, however, is mandatory for some Huawei
>> modems.
>
> Interesting.  That does sound like an odd firmware bug to me. I have a
> bit of a hard time understanding how this can be.  Using data interface
> altsetting 0 to reset the function is documented in the NCM spec:
>

Agree, this is likely a firmware bug and it is also proved by all the
other modems that accept the procedure without issues.

> "
>   7.2 Using Alternate Settings to Reset an NCM Function
>
>   To place the network aspects of a function in a known state, the host
>   shall:
>   =E2=80=A2 select alternate setting 0 of the NCM Data Interface (this is=
 the
>     setting with no endpoints). This can be done explicitly using
>     SetInterface, or implicitly using SetConfiguration. See [USB30] for
>     details.
>   =E2=80=A2 select the NCM operational parameters by sending commands to =
the NCM
>     Communication Interface, then
>   =E2=80=A2 select the second alternate interface setting of the NCM Data
>     Interface (this is the setting with a bulk IN endpoint and a bulk
>     OUT endpoint).
>
>   Whenever alternate setting 0 is selected by the host, the function
>   shall:
>   =E2=80=A2 flush function buffers
>   =E2=80=A2 reset the packet filter to its default state
>   =E2=80=A2 clear all multicast address filters
>   =E2=80=A2 clear all power filters set using
>     SetEthernetPowerManagementPatternFilter
>   =E2=80=A2 reset statistics counters to zero
>   =E2=80=A2 restore its Ethernet address to its default state
>   =E2=80=A2 reset its IN NTB size to the value given by field dwNtbInMaxS=
ize
>     from the NTB Parameter Struc- ture
>   =E2=80=A2 reset the NTB format to NTB-16
>   =E2=80=A2 reset the current Maximum Datagram Size to a function-specifi=
c
>     default. If SetMaxDatagramSize is not supported, then the maximum
>     datagram size shall be the same as the value in wMaxSegmentSize of
>     the Ethernet Networking Functional Descriptor. If SetMaxDatagramSize
>     is supported by the function, then the host must either query the
>     function to determine the current effective maximum datagram size,
>     or must explicitly set the maximum datagram size. If the host wishes
>     to set the Maximum Datagram Size, it may do so prior to selecting
>     the second alternate interface set- ting of the data
>     interface. Doing so will ensure that the change takes effect prior
>     to send or receiving data.
>   =E2=80=A2 reset CRC mode so that the function will not append CRCs to
>     datagrams sent on the IN pipe
>   =E2=80=A2 reset NTB sequence numbers to zero
>
>   When the host selects the second alternate interface setting of the
>   NCM Data Interface, the function shall perform the following actions
>   in the following order.
>   =E2=80=A2 If connected to the network, the function shall send a
>     ConnectionSpeedChange notification to the host indicating the
>     current connection speed.
>   =E2=80=A2 Whether connected or not, the function shall then send a
>     NetworkConnection notification to the host, with wValue indicating
>     the current state of network connectivity
> "
>
> The addition of the "RESET" request in MBIM did not change these
> requirements AFAICS.  Supporting NCM style "altsetting 0 reset" is
> required by default inheritance.  The description of dual NCM/MBIM
> functions in the MBIM spec further emphasizes this:
>
> "
>   Regardless of the previous sequence of SET_INTERFACE commands targeting
>   the Communication Interface, the host is able to put the function into
>   a defined state by the following sequence:
>
>   1. SET_INTERFACE(Data Interface, 0)
>   2. SET_INTERFACE(Communication Interface, desired alternate setting)
>   3. Sending the required class commands for the targeted alternate
>     setting
>   4. SET_INTERFACE(Data Interface, 1 if Communication Interface,0 and
>     Data Interface,2 Communication Interface 1)
> "
>
>
> This, along with the lack of *any* sort of discussion of the
> relation/interfaction between "MBIM RESET" and "data interface
> altsetting 0" makes the MBIM RESET control request either ambigious or
> redundant.  Or both...
>
> FWIW, I've always considered RESET a symptom of the sloppy MBIM spec
> development.  It did not exactly work to their advantage that the first
> (and only?) published errata simply was an excuse to add new features
> (the "MBIM extended functional descriptor" and "MBIM loopback testmode")
> without updating the revision number.  Causing even more confusion,
> since we now have two different MBIMv1.0 specs.
>
> Well, whatever.  No need to get all frustrated about that. We have to
> deal with whatever the firmware developers serve us.  And,
> unfortunately, it is not surprising that unclear and ambigious specs
> leads to incompatible firmware implementations.
>
> I wonder, what happens if you unload the MBIM driver and let the USB
> core reset the data interface to altsetting 0?  Will the device then
> fail when the driver is loaded again?  If not, then where is the
> difference?  And can we possibly reorder the driver set_interface
> requests to make them similar to the USB core reset
>

I will check this.

Thanks,
Daniele

> Until now, I was under the impression that this was the
> only documented way to reset both NCM and MBIM functions (since the
> RESET is MBIM specific),
>
>> My proposal is to add something like
>> CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE quirk to avoid the toggle.
>>
>> To have a conservative approach, I would add only Telit LE922 to this
>> quirk and keep also the usleep_range delay, since I do not have a
>> clear view on all the VIDs/PIDs affected by this quirk. Then other
>> modems, once tested, can be added to the quirk if the delay is not
>> enough.
>>
>> If this approach, though ugly, has chances to be accepted I can write
>> a new patch.
>
> Yes, that sounds like the best approach at the moment.  I have
> unfortunately not as much time to experiment with this as I seem to
> need.  And the EM7455 workaround (the delay) is a bit hard to verify,
> since it is easily affected by small additional delays caused by the
> debugging itself.  This can cause bogus test results.
>
>
> Bj=C3=B8rn
