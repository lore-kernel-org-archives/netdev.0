From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 2/3] net: usb: cdc_enc: New driver exposing USB CDC encapsulated protocols
Date: Sun, 15 Jan 2012 20:52:38 +0100
Message-ID: <87ehv0eoah.fsf@nemi.mork.no>
References: <cover.1326607234.git.bjorn@mork.no>
	<d11888532ee381806b35974e71af4c0122255c05.1326607234.git.bjorn@mork.no>
	<201201151436.29794.oliver@neukum.org> <87lip9dp11.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Dan Williams <dcbw@redhat.com>,
	Thomas =?utf-8?Q?Sch=C3=A4fer?= <tschaefer@t-online.de>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51207 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778Ab2AOTwr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2012 14:52:47 -0500
In-Reply-To: <87lip9dp11.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Sun, 15
	Jan 2012 15:22:02 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:
> Oliver Neukum <oliver@neukum.org> writes:
>> Am Sonntag, 15. Januar 2012, 07:40:36 schrieb Bj=C3=B8rn Mork:
>>> USB CDC Ethernet devices may encapsulate vendor specific protocols =
inside
>>> USB_CDC_SEND_ENCAPSULATED_COMMAND +USB_CDC_GET_ENCAPSULATED_RESPONS=
E
>>> control messages. Devices based on Qualcomm MSM
>>> chipsets are known to use this for exporting the Qualcomm
>>> MSM Interface (QMI) protocol. Examples of such devices are
>>> the Huawei E392 and E398 LTE modems.
>>
>> The problem is that this is another version of the code already
>> in cdc-wdm, which is tested well.
>
> Huh?  I thought that was something entirely different.  Isn't it?

I should look at things before asking.  I see what you mean.  The
cdc-wdm code is very similar, and should be fairly easy to adapt.  Why
didn't I just research that from the start?  Well, you learn more from
doing such mistakes ;-)


There is one fundamental design issue which worries me though: cdc-wdm
doesn't support multiple simultaneous readers/writers.  This is sort of
a blocker for my use case, as I will need to keep a reader/writer for
the driver internal wwan management at all times.  So two simultaneous
clients are necessary to actually have something available for
userspace at all.

Are there any reasons for this choice, and do you think it's feasible
changing it without destroying the advantage of the well tested code?  =
I
seem to remember that cdc-wdm allowed simultaneous reading/writing in
the past, but this changed somewhere between 2.6.32 and 3.0. I have an
Ericsson modem with two such AT command speaking interfaces, and I use =
a
simple shell script to configure it.  At one point I had to switch from
using /dev/cdc-wdm0 to /dev/ttyACM0 because the former started hanging
on constructs like this:

    while read x; do
    case "$x" in
         foo)
              echo -e "AT+bar\r" >/dev/cdc-wdm0
              ;;
         ...
        esac
    done </dev/cdc-wdm0
             =20

This used to work with 2.6.32, but that might have been just pure luck?
Anyway, that change really made cdc-wdm much less usable for me, and
that sort of proves that supporting simultaneous read/write would be an
improvement even for the existing supported devices.

And then there are a couple of minor issues which I believe needs
sorting out.  If I understand the WDM spec correctly (without bothering
to actually read if, of course), then it only defines the interface but
not the protocol.  Exactly like the embedded CDC Ethernet command
interface.  So I have the Ericsson modem which which speaks an AT
command protocol, of course with a number of vendor specific AT command=
s
included.  And then I have the Huawei modem which speaks QMI.  Just
mapping these to a number of /dev/cdc-wdmX interfaces isn't going to
help user applications much.  They need to be told *what* protocol to
use on the character device.  And the driver should know this, either b=
y
detection or maybe best: vid/pid based tables and sane fallbacks.


I'm not sure this will do (if the latter was changed to a cdc-wdmX
device):

bjorn@nemi:~$ grep . /sys/class/usb/cdc-wdm0/device/*
/sys/class/usb/cdc-wdm0/device/bAlternateSetting: 0
/sys/class/usb/cdc-wdm0/device/bInterfaceClass:02
/sys/class/usb/cdc-wdm0/device/bInterfaceNumber:05
/sys/class/usb/cdc-wdm0/device/bInterfaceProtocol:01
/sys/class/usb/cdc-wdm0/device/bInterfaceSubClass:09
/sys/class/usb/cdc-wdm0/device/bNumEndpoints:01
/sys/class/usb/cdc-wdm0/device/interface:Ericsson F3507g Mobile Broadba=
nd Minicard Device Management
/sys/class/usb/cdc-wdm0/device/modalias:usb:v0BDBp1900d0000dc02dsc00dp0=
0ic02isc09ip01
/sys/class/usb/cdc-wdm0/device/supports_autosuspend:1
/sys/class/usb/cdc-wdm0/device/uevent:DEVTYPE=3Dusb_interface
/sys/class/usb/cdc-wdm0/device/uevent:DRIVER=3Dcdc_wdm
/sys/class/usb/cdc-wdm0/device/uevent:DEVICE=3D/proc/bus/usb/002/056
/sys/class/usb/cdc-wdm0/device/uevent:PRODUCT=3Dbdb/1900/0
/sys/class/usb/cdc-wdm0/device/uevent:TYPE=3D2/0/0
/sys/class/usb/cdc-wdm0/device/uevent:INTERFACE=3D2/9/1
/sys/class/usb/cdc-wdm0/device/uevent:MODALIAS=3Dusb:v0BDBp1900d0000dc0=
2dsc00dp00ic02isc09ip01

bjorn@canardo:~$ grep . /sys/class/cdc_enc/cdc-enc0/device/*
/sys/class/cdc_enc/cdc-enc0/device/bAlternateSetting: 0
/sys/class/cdc_enc/cdc-enc0/device/bInterfaceClass:ff
/sys/class/cdc_enc/cdc-enc0/device/bInterfaceNumber:03
/sys/class/cdc_enc/cdc-enc0/device/bInterfaceProtocol:09
/sys/class/cdc_enc/cdc-enc0/device/bInterfaceSubClass:01
/sys/class/cdc_enc/cdc-enc0/device/bNumEndpoints:01
/sys/class/cdc_enc/cdc-enc0/device/modalias:usb:v12D1p1506d0000dc00dsc0=
0dp00icFFisc01ip09
/sys/class/cdc_enc/cdc-enc0/device/supports_autosuspend:1
/sys/class/cdc_enc/cdc-enc0/device/uevent:DEVTYPE=3Dusb_interface
/sys/class/cdc_enc/cdc-enc0/device/uevent:DRIVER=3Dqmi_wwan
/sys/class/cdc_enc/cdc-enc0/device/uevent:DEVICE=3D/proc/bus/usb/001/02=
0
/sys/class/cdc_enc/cdc-enc0/device/uevent:PRODUCT=3D12d1/1506/0
/sys/class/cdc_enc/cdc-enc0/device/uevent:TYPE=3D0/0/0
/sys/class/cdc_enc/cdc-enc0/device/uevent:INTERFACE=3D255/1/9
/sys/class/cdc_enc/cdc-enc0/device/uevent:MODALIAS=3Dusb:v12D1p1506d000=
0dc00dsc00dp00icFFisc01ip09

So my proposal have been something like a "protocol" attribute:

bjorn@canardo:~$ grep . /sys/class/cdc_enc/cdc-enc0/*
/sys/class/cdc_enc/cdc-enc0/dev:250:0
/sys/class/cdc_enc/cdc-enc0/protocol:qmi
/sys/class/cdc_enc/cdc-enc0/uevent:MAJOR=3D250
/sys/class/cdc_enc/cdc-enc0/uevent:MINOR=3D0
/sys/class/cdc_enc/cdc-enc0/uevent:DEVNAME=3Dcdc-enc0


bjorn@nemi:~$ grep . /sys/class/usb/cdc-wdm0/*
/sys/class/usb/cdc-wdm0/dev:180:0
/sys/class/usb/cdc-wdm0/uevent:MAJOR=3D180
/sys/class/usb/cdc-wdm0/uevent:MINOR=3D0
/sys/class/usb/cdc-wdm0/uevent:DEVNAME=3Dcdc-wdm0

Do you think it would be possible to add that (or similar meta data) to
the cdc-wdmX devices?  Maybe letting it default to "AT"?  Or "unknown"?
Any thoughts on this?  How do actual user applications deal with this?




Bj=C3=B8rn
