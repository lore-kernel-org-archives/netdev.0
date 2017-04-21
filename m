From: Daniele Palmas <dnlplm@gmail.com>
Subject: Re: [PATCH 1/1] drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR
 for Telit PID 0x1201
Date: Fri, 21 Apr 2017 14:22:28 +0200
Message-ID: <CAGRyCJGVH9ZhHM_9kau3Trjg0osgaUre5tQ_aWDPVprzH_3mTQ@mail.gmail.com>
References: <1491838463-20299-1-git-send-email-dnlplm@gmail.com>
 <87efwob92t.fsf@miraculix.mork.no> <CAGRyCJG2AV9fZEoSWDz4Dh=_Q9Edas1ZiDcfOehz77WEc5OQMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-usb <linux-usb@vger.kernel.org>,
        Aleksander Morgado <aleksander@aleksander.es>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33049 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161123AbdDUMWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 08:22:30 -0400
In-Reply-To: <CAGRyCJG2AV9fZEoSWDz4Dh=_Q9Edas1ZiDcfOehz77WEc5OQMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bj=C3=B8rn,

2017-04-21 12:30 GMT+02:00 Daniele Palmas <dnlplm@gmail.com>:
> Hi Bj=C3=B8rn,
>
> 2017-04-19 19:28 GMT+02:00 Bj=C3=B8rn Mork <bjorn@mork.no>:
>> Daniele Palmas <dnlplm@gmail.com> writes:
>>
>>
>> Would you mind describing in detail how you trigger the EIOs?  What
>> software and command sequence are you using?  Does it reliably reproduce
>> the issue, or do you have to try several times?  What modem chipset and
>> firmware is used?
>>
>
> sorry for the delay, I'm using latest qmicli in master:
>
> danielepa@danielepa-OptiPlex-780:~/development/git/libqmi$ src/qmicli/qmi=
cli -V
>
> qmicli 1.19.0
>
> and I was able to reproduce the issue simply asking for something like
> the manufacturer with qmicli.
>
> But I'm currently retrying it and it has become even worse (do not ask
> me why...): qmicli returns a transaction timed out error and got
> stuck. Only when detaching the USB cable qmicli exits.
>
> danielepa@danielepa-OptiPlex-780:~/development/git/libqmi$ sudo
> src/qmicli/qmicli -d /dev/cdc-wdm0 --dms-get-manufacturer
> [21 apr 2017, 12:15:33] -Warning ** [/dev/cdc-wdm0] requested auto
> mode but no MBIM QMUX support available
> error: couldn't create client for the 'dms' service: CID allocation
> failed in the CTL client: Transaction timed out
>
> I'm not sure I'm seeing here only problems related to your commit, but
> reverting the commit makes things to work again.
>
> The modem is a Telit LE920A4. I will try to collect more debug info.
>

So, I applied your debug patch and this is what is happening:

[ 4294.935912] usb 2-2: new high-speed USB device number 18 using ehci-pci
[ 4295.101548] usb 2-2: New USB device found, idVendor=3D1bc7, idProduct=3D=
1201
[ 4295.101551] usb 2-2: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D3
[ 4295.101553] usb 2-2: Product: Android
[ 4295.101555] usb 2-2: Manufacturer: Android
[ 4295.101557] usb 2-2: SerialNumber: 0123456789ABCDEF
[ 4295.118159] option 2-2:1.0: GSM modem (1-port) converter detected
[ 4295.118280] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
0
[ 4295.119265] qmi_wwan 2-2:1.2: cdc-wdm0: USB WDM device
[ 4295.120387] qmi_wwan 2-2:1.2 wwan0: register 'qmi_wwan' at
usb-0000:00:1d.7-2, WWAN/QMI device, fe:b2:dd:b6:d5:b3
[ 4295.120464] option 2-2:1.3: GSM modem (1-port) converter detected
[ 4295.120555] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
1
[ 4295.120643] option 2-2:1.4: GSM modem (1-port) converter detected
[ 4295.120699] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
2
[ 4295.120785] option 2-2:1.5: GSM modem (1-port) converter detected
[ 4295.120839] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
3
[ 4295.120923] option 2-2:1.6: GSM modem (1-port) converter detected
[ 4295.120978] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
4
[ 4306.730786] wdm_open: qmi_wwan 2-2:1.2: draining queued data
[ 4306.730955] wdm_write: qmi_wwan 2-2:1.2: Tx URB has been submitted index=
=3D2

Here qmicli is stuck. Then I disconnect the cable:

[ 4421.317327] usb 2-2: USB disconnect, device number 18
[ 4421.317541] option1 ttyUSB0: GSM modem (1-port) converter now
disconnected from ttyUSB0
[ 4421.317558] option 2-2:1.0: device disconnected
[ 4421.320113] qmi_wwan 2-2:1.2 wwan0: unregister 'qmi_wwan'
usb-0000:00:1d.7-2, WWAN/QMI device
[ 4421.321297] qmi_wwan 2-2:1.2: Unexpected error -71
[ 4421.321303] wdm_in_callback: qmi_wwan 2-2:1.2: rerr=3D-71,
status=3D-71, length=3D0, resp_count=3D0
[ 4421.325567] qmi_wwan 2-2:1.2: Error in flush path: -71
[ 4421.325579] wdm_release: qmi_wwan 2-2:1.2: wdm_release: cleanup
[ 4421.335695] option1 ttyUSB1: GSM modem (1-port) converter now
disconnected from ttyUSB1
[ 4421.335710] option 2-2:1.3: device disconnected
[ 4421.335838] option1 ttyUSB2: GSM modem (1-port) converter now
disconnected from ttyUSB2
[ 4421.335850] option 2-2:1.4: device disconnected
[ 4421.335972] option1 ttyUSB3: GSM modem (1-port) converter now
disconnected from ttyUSB3
[ 4421.335984] option 2-2:1.5: device disconnected
[ 4421.336175] option1 ttyUSB4: GSM modem (1-port) converter now
disconnected from ttyUSB4
[ 4421.336187] option 2-2:1.6: device disconnected

This is instead the output with the commit reverted:

[ 9868.397535] usb 2-2: new high-speed USB device number 19 using ehci-pci
[ 9868.563187] usb 2-2: New USB device found, idVendor=3D1bc7, idProduct=3D=
1201
[ 9868.563189] usb 2-2: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D3
[ 9868.563191] usb 2-2: Product: Android
[ 9868.563193] usb 2-2: Manufacturer: Android
[ 9868.563195] usb 2-2: SerialNumber: 0123456789ABCDEF
[ 9868.579788] option 2-2:1.0: GSM modem (1-port) converter detected
[ 9868.579920] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
0
[ 9868.580559] option 2-2:1.3: GSM modem (1-port) converter detected
[ 9868.580629] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
1
[ 9868.580721] option 2-2:1.4: GSM modem (1-port) converter detected
[ 9868.580778] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
2
[ 9868.580859] option 2-2:1.5: GSM modem (1-port) converter detected
[ 9868.580915] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
3
[ 9868.580995] option 2-2:1.6: GSM modem (1-port) converter detected
[ 9868.581048] usb 2-2: GSM modem (1-port) converter now attached to ttyUSB=
4
[ 9868.603054] usbcore: registered new interface driver cdc_wdm
[ 9868.605852] qmi_wwan 2-2:1.2: cdc-wdm0: USB WDM device
[ 9868.606547] qmi_wwan 2-2:1.2 wwan0: register 'qmi_wwan' at
usb-0000:00:1d.7-2, WWAN/QMI device, fe:b2:dd:b6:d5:b3
[ 9868.606674] usbcore: registered new interface driver qmi_wwan
[ 9885.295723] wdm_write: qmi_wwan 2-2:1.2: Tx URB has been submitted index=
=3D2
[ 9885.296210] wdm_int_callback: qmi_wwan 2-2:1.2:
NOTIFY_NETWORK_CONNECTION disconnected from network
[ 9885.328208] wdm_int_callback: qmi_wwan 2-2:1.2:
NOTIFY_RESPONSE_AVAILABLE received: index 2 len 0
[ 9885.328216] wdm_int_callback: qmi_wwan 2-2:1.2: submit response URB 0
[ 9885.329166] wdm_write: qmi_wwan 2-2:1.2: Tx URB has been submitted index=
=3D2
[ 9885.360203] wdm_int_callback: qmi_wwan 2-2:1.2:
NOTIFY_RESPONSE_AVAILABLE received: index 2 len 0
[ 9885.360210] wdm_int_callback: qmi_wwan 2-2:1.2: submit response URB 0
[ 9885.361463] wdm_write: qmi_wwan 2-2:1.2: Tx URB has been submitted index=
=3D2
[ 9885.392210] wdm_int_callback: qmi_wwan 2-2:1.2:
NOTIFY_RESPONSE_AVAILABLE received: index 2 len 0
[ 9885.392221] wdm_int_callback: qmi_wwan 2-2:1.2: submit response URB 0
[ 9885.393370] wdm_release: qmi_wwan 2-2:1.2: wdm_release: cleanup

If needed I can try to collect usbmon.

Regards,
Daniele

> Thanks,
> Daniele
>
>>
>>
>>
>> Bj=C3=B8rn
>>
