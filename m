From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth: Add framework for device found filtering based on UUID
Date: Mon, 15 Dec 2014 13:27:39 +0100
Message-ID: <22DA2C3B-5743-40F5-8001-F772FCCB5750@holtmann.org>
References: <20141211224808.A00526614C4@gitolite.kernel.org> <CAMuHMdX7w0RF0Azn2-p88=maXOcy1pfXy_KHznV4Vozd9=5mfg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johan Hedberg <johan.hedberg@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49729 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbaLOM1o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 07:27:44 -0500
In-Reply-To: <CAMuHMdX7w0RF0Azn2-p88=maXOcy1pfXy_KHznV4Vozd9=5mfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert,

>> Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3Db487b9ce9340=
a6e98d7f8277399304b23b7be456
>> Commit:     b487b9ce9340a6e98d7f8277399304b23b7be456
>> Parent:     bda157a40077447b25a1172a17b8ef81a2905cb7
>> Refname:    refs/heads/master
>> Author:     Marcel Holtmann <marcel@holtmann.org>
>> AuthorDate: Fri Dec 5 10:55:57 2014 +0100
>> Committer:  Johan Hedberg <johan.hedberg@intel.com>
>> CommitDate: Fri Dec 5 12:37:35 2014 +0200
>>=20
>>    Bluetooth: Add framework for device found filtering based on UUID
>>=20
>>    Using Start Service Discovery provides the option to specifiy a l=
ist
>>    of UUID that are used to filter out device found events. This pat=
ch
>>    provides the framework for hooking up the UUID filter.
>>=20
>>    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
>>    Signed-off-by: Johan Hedberg <johan.hedberg@intel.com>
>> ---
>> net/bluetooth/mgmt.c | 54 ++++++++++++++++++++++++++++++++++++++++++=
++++++++--
>> 1 file changed, 52 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
>> index 1715c91..e39190a 100644
>> --- a/net/bluetooth/mgmt.c
>> +++ b/net/bluetooth/mgmt.c
>> @@ -6802,6 +6802,11 @@ void mgmt_read_local_oob_data_complete(struct=
 hci_dev *hdev, u8 *hash192,
>>        mgmt_pending_remove(cmd);
>> }
>>=20
>> +static bool eir_has_uuids(u8 *eir, u16 eir_len, u16 uuid_count, u8 =
(*uuids)[16])
>> +{
>> +       return false;
>> +}
>> +
>> void mgmt_device_found(struct hci_dev *hdev, bdaddr_t *bdaddr, u8 li=
nk_type,
>>                       u8 addr_type, u8 *dev_class, s8 rssi, u32 flag=
s,
>>                       u8 *eir, u16 eir_len, u8 *scan_rsp, u8 scan_rs=
p_len)
>> @@ -6809,6 +6814,7 @@ void mgmt_device_found(struct hci_dev *hdev, b=
daddr_t *bdaddr, u8 link_type,
>>        char buf[512];
>>        struct mgmt_ev_device_found *ev =3D (void *) buf;
>>        size_t ev_size;
>> +       bool match;
>=20
> net/bluetooth/mgmt.c: In function =E2=80=98mgmt_device_found=E2=80=99=
:
> net/bluetooth/mgmt.c:6993: warning: =E2=80=98match=E2=80=99 may be us=
ed uninitialized
> in this function

I did not get this warning, but I did consider it happening and my conc=
lusion was that it will not and thus no need for initializing this to f=
alse.

> All tests for "match" are protected by "if (hdev->discovery.uuid_coun=
t > 0)",
> so we only have to care about that case.
>=20
>>        /* Don't send events for a non-kernel initiated discovery. Wi=
th
>>         * LE one exception is if we have pend_le_reports > 0 in whic=
h
>> @@ -6843,15 +6849,59 @@ void mgmt_device_found(struct hci_dev *hdev,=
 bdaddr_t *bdaddr, u8 link_type,
>>        ev->rssi =3D rssi;
>>        ev->flags =3D cpu_to_le32(flags);
>>=20
>> -       if (eir_len > 0)
>> +       if (eir_len > 0) {
>> +               /* When using service discovery and a list of UUID i=
s
>> +                * provided, results with no matching UUID should be
>> +                * dropped. In case there is a match the result is
>> +                * kept and checking possible scan response data
>> +                * will be skipped.
>> +                */
>> +               if (hdev->discovery.uuid_count > 0) {
>> +                       match =3D eir_has_uuids(eir, eir_len,
>> +                                             hdev->discovery.uuid_c=
ount,
>> +                                             hdev->discovery.uuids)=
;
>> +                       if (!match)
>> +                               return;
>> +               }
>=20
> If we get here and if (hdev->discovery.uuid_count > 0), "match" must =
be true.

We need to keep the match state to optimize the later branch. There is =
no point in running through the second list if the first one already ha=
s a match.

Actually this is the bogus one here. The only valid reason to leave her=
e is when also !scan_rsp_len.

>> +
>> +               /* Copy EIR or advertising data into event */
>>                memcpy(ev->eir, eir, eir_len);
>> +       } else {
>> +               /* When using service discovery and a list of UUID i=
s
>> +                * provided, results with empty EIR or advertising d=
ata
>> +                * should be dropped since they do not match any UUI=
D.
>> +                */
>> +               if (hdev->discovery.uuid_count > 0)
>> +                       return;
>=20
> We will never get here if (hdev->discovery.uuid_count > 0).

>=20
>> +       }
>=20
> Hence if we get here and if (hdev->discovery.uuid_count > 0),
> "match" is always true.

>=20
>>        if (dev_class && !eir_has_data_type(ev->eir, eir_len, EIR_CLA=
SS_OF_DEV))
>>                eir_len =3D eir_append_data(ev->eir, eir_len, EIR_CLA=
SS_OF_DEV,
>>                                          dev_class, 3);
>>=20
>> -       if (scan_rsp_len > 0)
>> +       if (scan_rsp_len > 0) {
>> +               /* When using service discovery and a list of UUID i=
s
>> +                * provided, results with no matching UUID should be
>> +                * dropped if there is no previous match from the
>> +                * advertising data.
>> +                */
>> +               if (hdev->discovery.uuid_count > 0) {
>> +                       if (!match && !eir_has_uuids(scan_rsp, scan_=
rsp_len,
>=20
> "match" is true, so this whole block is useless.

This was meant to not bother checking the second data block since we al=
ready had a match in the first one. However we need to append the secon=
d data block to the first one before sending out the event.

>=20
>> +                                                    hdev->discovery=
=2Euuid_count,
>> +                                                    hdev->discovery=
=2Euuids))
>> +                               return;
>> +               }
>> +
>> +               /* Append scan response data to event */
>>                memcpy(ev->eir + eir_len, scan_rsp, scan_rsp_len);
>> +       } else {
>> +               /* When using service discovery and a list of UUID i=
s
>> +                * provided, results with empty scan response and no
>> +                * previous matched advertising data should be dropp=
ed.
>> +                */
>> +               if (hdev->discovery.uuid_count > 0 && !match)
>=20
> "match" is true, so this whole block is useless.

This was suppose to do what the comment says, but we never get here :(

>=20
>> +                       return;
>> +       }
>>=20
>>        ev->eir_len =3D cpu_to_le16(eir_len + scan_rsp_len);
>>        ev_size =3D sizeof(*ev) + eir_len + scan_rsp_len;
>=20
> Is my analysis correct?
> Am I missing something?

Your analysis seems correct and even while putting in tons of comments,=
 my brain still messed it up.

I looked at the whole code again and this is would should make all stat=
ements work correctly.

@@ -7085,7 +7085,7 @@ void mgmt_device_found(struct hci_dev *hdev, bdad=
dr_t *bdaddr, u8 link_type,
                        match =3D eir_has_uuids(eir, eir_len,
                                              hdev->discovery.uuid_coun=
t,
                                              hdev->discovery.uuids);
-                       if (!match)
+                       if (!match && !scan_rsp_len)
                                return;
                }

Regards

Marcel
