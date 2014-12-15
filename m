From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Bluetooth: Add framework for device found filtering based on UUID
Date: Mon, 15 Dec 2014 13:37:59 +0100
Message-ID: <CAMuHMdVTciynVTaqm43U_WOzc2j5dJYwDVyKqF0p9AM4n=SdSQ@mail.gmail.com>
References: <20141211224808.A00526614C4@gitolite.kernel.org>
	<CAMuHMdX7w0RF0Azn2-p88=maXOcy1pfXy_KHznV4Vozd9=5mfg@mail.gmail.com>
	<22DA2C3B-5743-40F5-8001-F772FCCB5750@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johan Hedberg <johan.hedberg@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:42131 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaLOMiB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 07:38:01 -0500
In-Reply-To: <22DA2C3B-5743-40F5-8001-F772FCCB5750@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel,

On Mon, Dec 15, 2014 at 1:27 PM, Marcel Holtmann <marcel@holtmann.org> =
wrote:
>>> --- a/net/bluetooth/mgmt.c
>>> +++ b/net/bluetooth/mgmt.c
>>> @@ -6809,6 +6814,7 @@ void mgmt_device_found(struct hci_dev *hdev, =
bdaddr_t *bdaddr, u8 link_type,
>>>        char buf[512];
>>>        struct mgmt_ev_device_found *ev =3D (void *) buf;
>>>        size_t ev_size;
>>> +       bool match;
>>
>> net/bluetooth/mgmt.c: In function =E2=80=98mgmt_device_found=E2=80=99=
:
>> net/bluetooth/mgmt.c:6993: warning: =E2=80=98match=E2=80=99 may be u=
sed uninitialized
>> in this function
>
> I did not get this warning, but I did consider it happening and my co=
nclusion was that it will not and thus no need for initializing this to=
 false.

It's highly compiler-dependent, and it's the reason I'll stick to gcc
4.1.2 as long it
helps me finding several real issues during each merge window.

>> All tests for "match" are protected by "if (hdev->discovery.uuid_cou=
nt > 0)",
>> so we only have to care about that case.
>>
>>>        /* Don't send events for a non-kernel initiated discovery. W=
ith
>>>         * LE one exception is if we have pend_le_reports > 0 in whi=
ch
>>> @@ -6843,15 +6849,59 @@ void mgmt_device_found(struct hci_dev *hdev=
, bdaddr_t *bdaddr, u8 link_type,
>>>        ev->rssi =3D rssi;
>>>        ev->flags =3D cpu_to_le32(flags);
>>>
>>> -       if (eir_len > 0)
>>> +       if (eir_len > 0) {
>>> +               /* When using service discovery and a list of UUID =
is
>>> +                * provided, results with no matching UUID should b=
e
>>> +                * dropped. In case there is a match the result is
>>> +                * kept and checking possible scan response data
>>> +                * will be skipped.
>>> +                */
>>> +               if (hdev->discovery.uuid_count > 0) {
>>> +                       match =3D eir_has_uuids(eir, eir_len,
>>> +                                             hdev->discovery.uuid_=
count,
>>> +                                             hdev->discovery.uuids=
);
>>> +                       if (!match)
>>> +                               return;
>>> +               }
>>
>> If we get here and if (hdev->discovery.uuid_count > 0), "match" must=
 be true.
>
> We need to keep the match state to optimize the later branch. There i=
s no point in running through the second list if the first one already =
has a match.
>
> Actually this is the bogus one here. The only valid reason to leave h=
ere is when also !scan_rsp_len.

OK.

>> Is my analysis correct?
>> Am I missing something?
>
> Your analysis seems correct and even while putting in tons of comment=
s, my brain still messed it up.
>
> I looked at the whole code again and this is would should make all st=
atements work correctly.
>
> @@ -7085,7 +7085,7 @@ void mgmt_device_found(struct hci_dev *hdev, bd=
addr_t *bdaddr, u8 link_type,
>                         match =3D eir_has_uuids(eir, eir_len,
>                                               hdev->discovery.uuid_co=
unt,
>                                               hdev->discovery.uuids);
> -                       if (!match)
> +                       if (!match && !scan_rsp_len)
>                                 return;
>                 }

Thanks, that indeed changes all further checks for match to make sense.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
