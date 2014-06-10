From: Florian Klink <flokli@flokli.de>
Subject: Re: cdc-wdm: unable to connect after suspend
Date: Tue, 10 Jun 2014 16:08:49 +0200
Message-ID: <53971171.5070001@flokli.de>
References: <ln6m4k$q49$1@ger.gmane.org> <874mzt55kz.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="0e0rcasXbpg7lsOKGeccRPcaktoPAADad"
Cc: netdev@vger.kernel.org, modemmanager-devel@lists.freedesktop.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asterix.flokli.de ([78.46.104.9]:46522 "EHLO asterix.flokli.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbaFJOQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 10:16:15 -0400
In-Reply-To: <874mzt55kz.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0e0rcasXbpg7lsOKGeccRPcaktoPAADad
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 10.06.2014 14:09, schrieb Bj=C3=83=C5=BErn Mork:
> Florian Klink <flokli@flokli.de> writes:
>=20
>> Hi,
>>
>> I recently bought a notebook (Fujitsu Lifebook T904) with integrated
>> 3G/4G modem (Sierra Wireless EM7305) thats powered by the cdc-wdm driv=
er.
>>
>> It works without any problems on a fresh bootup using Networkmanager.
>>
>> However, after putting the notebook into standby and waking up again,
>> I'm unable to get a connection (always reproducible, not signal qualit=
y
>> related).
>=20
> Does it work again if you restart NetworkManager and ModemManager at
> this point?

Nope. ModemManager gets confused completely and drops the modem out of
the list of connections:

ModemManager[3067]: <warn>  Couldn't find support for device at
'/sys/devices/pci0000:00/0000:00:19.0': not supported by any plugin
ModemManager[3067]: <warn>  Couldn't find support for device at
'/sys/devices/pci0000:00/0000:00:1c.3/0000:03:00.0': not supported by
any plugin
ModemManager[3067]: [/dev/cdc-wdm1] Queried max control message size: 409=
6
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
message
ModemManager[3067]: <info>  Creating modem with plugin 'Generic' and '2'
ports
ModemManager[3067]: <warn>  Could not grab port (usbmisc/cdc-wdm1):
'Cannot add port 'usbmisc/cdc-wdm1', unsupported'
ModemManager[3067]: <warn>  Couldn't create modem for device at
'/sys/devices/pci0000:00/0000:00:14.0/usb1/1-6': Failed to find primary
AT port
ModemManager[3067]: <info>  Creating modem with plugin 'Generic' and '1'
ports
ModemManager[3067]: <warn>  Could not grab port (tty/ttyS0): 'Cannot add
port 'tty/ttyS0', unhandled serial type'
ModemManager[3067]: <warn>  Couldn't create modem for device at
'/sys/devices/pci0000:00/0000:00:16.3': Failed to find primary AT port

>=20
> Does it help to do
>=20
>  echo  0 >/sys/bus/usb/devices/x-y/power/persist
>=20
> prior to suspending the notebook?  You'll have to replace "x-y" with th=
e
> correct USB bus and port number.  You can find this in e.g. the dmesg
> output.  For example, if your log shows:
>=20
>   qmi_wwan 2-4:1.8: cdc-wdm0: USB WDM device
>=20
> then x-y =3D 2-4.

dmesg shows "cdc_mbim 1-6:2.12: cdc-wdm1: USB WDM device", so I did echo
0 > /sys/bus/usb/devices/1-6/power/persist.

However, after a suspend/resume cycle, connecting didnt work either.
Errors were the same as without persist =3D 0.

>=20
>=20
>> I see the following error messages:
>>
>>
>> Couldn't reload current power state: Transaction timed out
>> [/dev/cdc-wdm1] No transaction matched in received message
>> <warn> (cdc-wdm1) failed to connect modem: Transaction timed out
>> <info> (cdc-wdm1): device state change: prepare -> failed (reason
>> 'unknown') [40 120 1]
>> modem_prepare_result: assertion 'state =3D=3D NM_DEVICE_STATE_PREPARE'=
 failed
>>
>>
>> It looks like a driver bug for me, like the device not woken up
>> correctly. I attached the syslog.
>=20
> It is certainly bad interaction between userspace and the driver.  We'l=
l
> have to fight about where the bug is :-)
>=20
> I believe the problem is that the modem is powered down when the
> notebook is suspended, combined with the "USB device persistence"
> feature and bad handling of "unexpected" states in ModemManager.
> The result is that MM and the device/driver ends up with different view=
s
> of the current modem state. But I might be completely wrong here.
> Seeing kernel logs would have helped.

dmesg doesn't really show an error message from the modem. Seems like it
also has an issue resuming "Bus 001 Device 006: ID 0483:91d1
STMicroelectronics", but this shouldn't cause the problems with the modem=
=2E..
=2E
>=20
> Initially I'd like to claim that this is a userspace problem.  But I'm
> open to reconsider that view, given convincing arguments. It's not my
> intention to reject this as "someone elses problem".
>=20
> A short explanation of what's going on: The "USB device persistence"
> feature just cannot work with 3G/LTE modem devices because they lose
> necessary internal state on any power loss.  The persist feature makes
> the modem reappear as exact the same device after resume, but with a
> case of severe amnesia.  So why don't we just disable the feature when
> it cannot work? The reason is that modems often are composite devices,
> and many of them include card reader functions. USB device persistences=

> is critical for such devices. Consider suspending a card reader with a
> mounted file system...
>=20
> For this reason I really do not want to disable the persist feature,
> even if it is pointless from a standalone modem point of view.  Instead=

> userspace should be able to cope with modems "suddendly" entering
> unexpected states.
>=20
>> I'm running Arch Linux amd64 with an 3.15.0-rc8 kernel, and
>> NetworkManager 0.9.8.10.
>>
>> Is there anybody else who observed this behaviour?
>=20
> Yes, I must admit I've seen similar behaviour.  The interaction between=

> system suspend and drivers/MM/NM is not good.
>=20
> Could you please bring this up on the ModemManager list?

I added modemmanager-devel to CC as suggested :-)
>=20
>=20
> Bj=C3=B8rn
>=20
Florian







--0e0rcasXbpg7lsOKGeccRPcaktoPAADad
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTlxFxAAoJEInyWbj6DRgf5MsP+we16HnVh3RNz6jaiG8w1w5J
S8wAOCMBpA6RvhonkI3txc0KPU/BpYp0esIACF5OUadyIVNRflem4I9wzJFRW6l9
KvY3TlV4PJvq0p5jVN5sdYiGPRgcjEML+yYVS4g9U1rsJ5jiwLqjAG7L7yCHmyMR
LhO3rhepyNIUSC5PHr68Gu12nc5nK4NY7VdklVT3zT2qb1Bbg7A2zqB/ArJKkia4
s0LueyDcYQa+jikMpTeQix8xzXNH7ITV/QuwFrC4QL80UgIpHR4BOfpPhwb+Rfq+
4CLW4iCsKsCKILrw13PhC/Ixl0ot6himT/Wf8/WuA/bC7e3aR3uIrPdi1yzLLXHj
l1t/A3qaINmDJwtwlgs+AWWlSNfvPFxez8rf2oyoH3el+AbeIpCn7pG7QpuUn4IY
W1iejG2JG2ZgQ91zeN/NT8ITOagyaikA3s32mf6fKZ8j7U2hpqdlUP7Iu3bSpj4M
Fov3gDkF7p07uhY8IKTFAIoTyfG+EXtBAiRkn05B0WWJc7NUOvgffy+o+ciJF3xG
klOwn+273OPKJsTiHdzGVT7/Hppls+f8Cok3CAAKsPNjI8Oz9tMVaNh5++KCCOmc
RJpwm6cwXoCuTxgGIfKnM+LMX7lNealonJ65bosKTxVH6Rvh/9oOse2m/XcFNS1X
XRHs2IueLAI8X8d1UnY/
=Ubqz
-----END PGP SIGNATURE-----

--0e0rcasXbpg7lsOKGeccRPcaktoPAADad--
