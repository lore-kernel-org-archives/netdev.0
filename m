From: "Stefan Behte" <s.behte@babiel.com>
Subject: AW: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520 NIC no longer work with allow_unsupported_sfp=1
Date: Mon, 18 Feb 2013 13:13:00 +0100
Message-ID: <D76AF9B3DDF5FF49833AC0A1396549060314FC0C@s554.babiel.com>
References: <D76AF9B3DDF5FF49833AC0A1396549060314FBD8@s554.babiel.com> <87618083B2453E4A8714035B62D67992337B4938@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01CE0DD1.4B4645A3"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.babiel.com ([217.79.215.109]:52202 "EHLO mail.babiel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab3BRMND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 07:13:03 -0500
Received: from localhost (unknown [127.0.0.1])
	by mail.babiel.com (Postfix) with ESMTP id 05581B00142
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 12:13:01 +0000 (UTC)
Received: from mail.babiel.com ([127.0.0.1])
	by localhost (mail.babiel.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6wO-bX9umv7n for <netdev@vger.kernel.org>;
	Mon, 18 Feb 2013 13:13:00 +0100 (CET)
Received: from s554.babiel.com (business-178-015-110-066.static.arcor-ip.net [178.15.110.66])
	by mail.babiel.com (Postfix) with ESMTP id AD722B00139
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 13:13:00 +0100 (CET)
Content-class: urn:content-classes:message
In-Reply-To: <87618083B2453E4A8714035B62D67992337B4938@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01CE0DD1.4B4645A3
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,

>I don't think this is a regression since the check you are bypassing =
with your patch has nothing to do with the unsupported SFP modules lock =
(this check is few lines below).
No, that part skipped by the goto.

>The check you are trying to bypass is actually for supported 1gig SFP =
module types.
Actually that's inaccurate: if it's not a compatible module, it's being =
marked as unsupported. That's the whole purpose of that code.

                //if it's not a 10GE Module
                if (comp_codes_10g =3D=3D 0 &&

                    // and if the current module is NOT compatible =
(hw->phy.sfp_type must be 9, 10, 11 or 12, see ixgbe_type.h)
                    !(hw->phy.sfp_type =3D=3D ixgbe_sfp_type_1g_cu_core1 =
||
                      hw->phy.sfp_type =3D=3D ixgbe_sfp_type_1g_cu_core0 =
||
                      hw->phy.sfp_type =3D=3D ixgbe_sfp_type_1g_sx_core0 =
||
                      hw->phy.sfp_type =3D=3D =
ixgbe_sfp_type_1g_sx_core1)) {

                       // then mark hardware as unsupported -> the SFP =
will not be enabled
                       // but it should be, if allow_unsupported_sfp=3D1
                        hw->phy.type =3D ixgbe_phy_sfp_unsupported;
                        status =3D IXGBE_ERR_SFP_NOT_SUPPORTED;
 =20
                        // skip other stuff, e.g. the checks you =
mentioned below
                        goto out;
                }

Ok, my patch is not nice. I've attached one that completely removes the =
block, as IMHO its only purpose is to lock out non-intel SFPs. Of course =
I've verified that the code works (at least for me :)).

>1. What is the SFP+ module you are using (make/model/type)?=20
The module is a TP-Link TL-SM311LS 1000BASE-LX LC.

>2. What is the hw->phy.sfp_type set to (you can add a printk, or if you =
plug it in after load there should be a "detected SFP+" message in =
dmesg).
It's in the log I sent:
[13920.949008] ixgbe 0000:02:00.1: MAC: 2, PHY: 14, SFP+: 65535, PBA No: =
E68793-005
So hw->phy.sfp_type is 65535.

>3. You said that you get the interfaces, but are they operational =
(link, pass traffic etc)?
I'm going to run some longterm tests for reliability. But yes, they =
appear to be working just fine.

>4. Because you mentioned that this is a regression - was there a =
previous version of the driver that loads without the unsupported errors =
with this SFP module?
Not sure, but as a result of the discussion =
(http://marc.info/?l=3De1000-devel&m=3D132697406314730&w=3D2) there was =
a decision and patch that would allow non-intel SFPs.
So I don't care too much what we call this - the driver does not work as =
intended: Intel is preventing use of 3rd-party SFPs.

So can we please remove this lock-in?

Best regards,
Stefan Behte

--------------------------------------------

Stefan Behte
Teamleiter Systemadministration

Babiel GmbH
Erkrather Str. 224a
D-40233 D=FCsseldorf

Tel: 0211-179349 0
Fax: 0211-179349 29
E-Mail: s.behte@babiel.com
Internet: http://www.babiel.com

Gesch=E4ftsf=FChrer: Georg Babiel, Dr. Rainer Babiel, Harald Babiel =
Amtsgericht D=FCsseldorf HRB 38633

~~~~~~~~~~~~~~ DISCLAIMER ~~~~~~~~~~~~~~~

The information transmitted in this electronic mail message may contain =
confidential and or privileged materials. Any review, retransmission, =
dissemination or other use of or taking of any action in reliance upon, =
this information by persons or entities other than the intended =
recipient is prohibited. If you receive such e-mails in error, please =
contact the sender and delete the material from any computer.


-----Urspr=FCngliche Nachricht-----
Von: Tantilov, Emil S [mailto:emil.s.tantilov@intel.com]=20
Gesendet: Freitag, 15. Februar 2013 21:14
An: Stefan Behte; netdev@vger.kernel.org
Cc: Skidmore, Donald C; Kirsher, Jeffrey T; Fujinaka, Todd; Ronciak, =
John
Betreff: RE: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s =
X520 NIC no longer work with allow_unsupported_sfp=3D1

Stefan,

I don't think this is a regression since the check you are bypassing =
with your patch has nothing to do with the unsupported SFP modules lock =
(this check is few lines below). The check you are trying to bypass is =
actually for supported 1gig SFP module types. Could you provide some =
additional information about your setup?=20

1. What is the SFP+ module you are using (make/model/type)?=20
2. What is the hw->phy.sfp_type set to (you can add a printk, or if you =
plug it in after load there should be a "detected SFP+" message in =
dmesg).
3. You said that you get the interfaces, but are they operational (link, =
pass traffic etc)?
4. Because you mentioned that this is a regression - was there a =
previous version of the driver that loads without the unsupported errors =
with this SFP module?

Thanks,
Emil

>-----Original Message-----
>From: netdev-owner@vger.kernel.org =
[mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Stefan Behte
>Sent: Thursday, February 14, 2013 4:58 PM
>To: netdev@vger.kernel.org
>Subject: ixgbe: Regression, unsupported SFP+ modules on 10Gbit/s X520 =
NIC
>no longer work with allow_unsupported_sfp=3D1
>
>Hello,
>
>I was told to send a mail, even though I had already opened
>https://bugzilla.kernel.org/show_bug.cgi?id=3D53901.
>
>Someone patched the ixgbe driver, and now non-intel SFPs do not work
>anymore, again. The issue of intel "lock-in" was discussed before here:
>http://marc.info/?l=3De1000-devel&m=3D132697406314730&w=3D2
>
>A tested patch is attached.
>
>Here is what I do:
>
># modinfo ixgbe | grep parm
>parm:           max_vfs:Maximum number of virtual functions to allocate =
per
>physical function - default is zero and maximum value is 63 (uint)
>parm:           allow_unsupported_sfp:Allow unsupported and untested =
SFP+
>modules on 82599-based adapters (uint)
>parm:           debug:Debug level (0=3Dnone,...,16=3Dall) (int)
>
># modprobe -r ixgbe
># modprobe ixgbe allow_unsupported_sfp=3D0
># dmesg | grep ixgbe
>[13690.355090] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
>version 3.9.15-k
>[13690.355092] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
>[13690.373128] ixgbe 0000:02:00.0: failed to load because an =
unsupported
>SFP+ module type was detected.
>[13690.373177] ixgbe 0000:02:00.0: Reload the driver after installing a
>supported module.
>[13690.390987] ixgbe 0000:02:00.1: failed to load because an =
unsupported
>SFP+ module type was detected.
>[13690.391036] ixgbe 0000:02:00.1: Reload the driver after installing a
>supported module.
>
># modprobe -r ixgbe
># modprobe ixgbe allow_unsupported_sfp=3D1
># dmesg | grep ixgbe
>[13679.088849] dca service started, version 1.12.1
>[13679.091174] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
>version 3.9.15-k
>[13679.091177] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
>[13679.109194] ixgbe 0000:02:00.0: failed to load because an =
unsupported
>SFP+ module type was detected.
>[13679.109243] ixgbe 0000:02:00.0: Reload the driver after installing a
>supported module.
>[13679.127399] ixgbe 0000:02:00.1: failed to load because an =
unsupported
>SFP+ module type was detected.
>[13679.127450] ixgbe 0000:02:00.1: Reload the driver after installing a
>supported module.
>[13690.352712] dca service started, version 1.12.1
>
>
>With the patch:
>
># modprobe -r ixgbe
># modprobe ixgbe allow_unsupported_sfp=3D0
># dmesg | grep ixgbe
>[13907.870087] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
>version 3.9.15-k
>[13907.870089] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
>[13907.888106] ixgbe 0000:02:00.0: failed to load because an =
unsupported
>SFP+ module type was detected.
>[13907.888155] ixgbe 0000:02:00.0: Reload the driver after installing a
>supported module.
>[13907.906187] ixgbe 0000:02:00.1: failed to load because an =
unsupported
>SFP+ module type was detected.
>[13907.906237] ixgbe 0000:02:00.1: Reload the driver after installing a
>supported module.
>
>
># modprobe -r ixgbe
># modprobe ixgbe allow_unsupported_sfp=3D1
># dmesg | grep ixgbe
>[13914.534758] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver -
>version3.9.15-k
>[13914.534761] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
>[13914.552820] ixgbe 0000:02:00.0 (unregistered net_device): WARNING: =
Intel
>(R) Network Connections are quality tested using Intel (R) Ethernet =
Optics.
>Using untested modules is not supported and may cause unstable =
operation or
>damage to
>the module or the adapter.  Intel Corporation is not responsible for =
any
>harm caused by using untested modules.
>[13917.741931] ixgbe 0000:02:00.0: irq 50 for MSI/MSI-X
>[13917.741938] ixgbe 0000:02:00.0: irq 51 for MSI/MSI-X
>[13917.741942] ixgbe 0000:02:00.0: irq 52 for MSI/MSI-X
>[13917.741951] ixgbe 0000:02:00.0: irq 53 for MSI/MSI-X
>[13917.741955] ixgbe 0000:02:00.0: irq 54 for MSI/MSI-X
>[13917.741960] ixgbe 0000:02:00.0: irq 55 for MSI/MSI-X
>[13917.741965] ixgbe 0000:02:00.0: irq 56 for MSI/MSI-X
>[13917.741969] ixgbe 0000:02:00.0: irq 57 for MSI/MSI-X
>[13917.741973] ixgbe 0000:02:00.0: irq 58 for MSI/MSI-X
>[13917.742002] ixgbe 0000:02:00.0: Multiqueue Enabled: Rx Queue count =
=3D 8,
>Tx Queue count =3D 8
>[13917.742126] ixgbe 0000:02:00.0: (PCI Express:5.0GT/s:Width x8)
>90:e2:ba:37:3b:18
>[13917.742207] ixgbe 0000:02:00.0: MAC: 2, PHY: 14, SFP+: 65535, PBA =
No:
>E68793-005
>[13917.743461] ixgbe 0000:02:00.0: Intel(R) 10 Gigabit Network =
Connection
>[13917.761578] ixgbe 0000:02:00.1 (unregistered net_device): WARNING: =
Intel
>(R) Network Connections are quality tested using Intel (R) Ethernet =
Optics.
>Using untested modules is not supported and may cause unstable =
operation or
>damage to the module or the adapter.  Intel Corporation is not =
responsible
>for any harm caused by using untested modules.
>[13920.948726] ixgbe 0000:02:00.1: irq 59 for MSI/MSI-X
>[13920.948737] ixgbe 0000:02:00.1: irq 60 for MSI/MSI-X
>[13920.948742] ixgbe 0000:02:00.1: irq 61 for MSI/MSI-X
>[13920.948746] ixgbe 0000:02:00.1: irq 62 for MSI/MSI-X
>[13920.948751] ixgbe 0000:02:00.1: irq 63 for MSI/MSI-X
>[13920.948757] ixgbe 0000:02:00.1: irq 64 for MSI/MSI-X
>[13920.948761] ixgbe 0000:02:00.1: irq 65 for MSI/MSI-X
>[13920.948767] ixgbe 0000:02:00.1: irq 66 for MSI/MSI-X
>[13920.948774] ixgbe 0000:02:00.1: irq 67 for MSI/MSI-X
>[13920.948803] ixgbe 0000:02:00.1: Multiqueue Enabled: Rx Queue count =
=3D 8,
>Tx Queue count =3D 8
>[13920.948927] ixgbe 0000:02:00.1: (PCI Express:5.0GT/s:Width x8)
>90:e2:ba:37:3b:19
>[13920.949008] ixgbe 0000:02:00.1: MAC: 2, PHY: 14, SFP+: 65535, PBA =
No:
>E68793-005
>[13920.950237] ixgbe 0000:02:00.1: Intel(R) 10 Gigabit Network =
Connection
>
>And then I get two nice Interfaces. Please apply. :)
>
>
>Best regards,
>
>Stefan Behte
>
>Babiel GmbH
>Moskauer Strasse 27
>D-40227 D=FCsseldorf
>
>Tel:    0211-179349 0
>Fax:    0211-179349 29
>E-Mail: S.Behte@babiel.com
>Internet: http://www.babiel.com
>
>Gesch=E4ftsf=FChrer: Georg Babiel, Dr. Rainer Babiel, Harald Babiel
>Amtsgericht D=FCsseldorf HRB 38633
>
>~~~~~~~~~~~~~~ DISCLAIMER ~~~~~~~~~~~~~~~
>
>The information transmitted in this electronic mail message may contain
>confidential and or privileged materials. Any review, retransmission,
>dissemination or other use of or taking of any action in reliance upon,
>this information by persons or entities other than the intended =
recipient
>is prohibited. If you receive such e-mails in error, please contact the
>sender and delete the material from any computer.

------_=_NextPart_001_01CE0DD1.4B4645A3
Content-Type: application/octet-stream;
	name="remove-intel-sfp-vendor-lock-in.patch"
Content-Transfer-Encoding: base64
Content-Description: remove-intel-sfp-vendor-lock-in.patch
Content-Disposition: attachment;
	filename="remove-intel-sfp-vendor-lock-in.patch"

LS0tIGxpbnV4LTMuNy43Lm9yaS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9peGdiZS9peGdi
ZV9waHkuYwkyMDEzLTAyLTExIDE4OjA1OjA5LjAwMDAwMDAwMCArMDEwMAorKysgaXhnYmVfcGh5
LmMJMjAxMy0wMi0xOCAxMjo0ODo0Ni4wMDAwMDAwMDAgKzAxMDAKQEAgLTEwNTUsMTcgKzEwNTUs
NiBAQAogCQkJZ290byBvdXQ7CiAJCX0KIAotCQkvKiBWZXJpZnkgc3VwcG9ydGVkIDFHIFNGUCBt
b2R1bGVzICovCi0JCWlmIChjb21wX2NvZGVzXzEwZyA9PSAwICYmCi0JCSAgICAhKGh3LT5waHku
c2ZwX3R5cGUgPT0gaXhnYmVfc2ZwX3R5cGVfMWdfY3VfY29yZTEgfHwKLQkJICAgICAgaHctPnBo
eS5zZnBfdHlwZSA9PSBpeGdiZV9zZnBfdHlwZV8xZ19jdV9jb3JlMCB8fAotCQkgICAgICBody0+
cGh5LnNmcF90eXBlID09IGl4Z2JlX3NmcF90eXBlXzFnX3N4X2NvcmUwIHx8Ci0JCSAgICAgIGh3
LT5waHkuc2ZwX3R5cGUgPT0gaXhnYmVfc2ZwX3R5cGVfMWdfc3hfY29yZTEpKSB7Ci0JCQlody0+
cGh5LnR5cGUgPSBpeGdiZV9waHlfc2ZwX3Vuc3VwcG9ydGVkOwotCQkJc3RhdHVzID0gSVhHQkVf
RVJSX1NGUF9OT1RfU1VQUE9SVEVEOwotCQkJZ290byBvdXQ7Ci0JCX0KLQogCQkvKiBBbnl0aGlu
ZyBlbHNlIDgyNTk4LWJhc2VkIGlzIHN1cHBvcnRlZCAqLwogCQlpZiAoaHctPm1hYy50eXBlID09
IGl4Z2JlX21hY184MjU5OEVCKSB7CiAJCQlzdGF0dXMgPSAwOwo=

------_=_NextPart_001_01CE0DD1.4B4645A3--
