From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR for Telit PID 0x1201
Date: Fri, 21 Apr 2017 15:02:47 +0200
Message-ID: <8760hxzzew.fsf@miraculix.mork.no>
References: <1491838463-20299-1-git-send-email-dnlplm@gmail.com>
        <87efwob92t.fsf@miraculix.mork.no>
        <CAGRyCJG2AV9fZEoSWDz4Dh=_Q9Edas1ZiDcfOehz77WEc5OQMw@mail.gmail.com>
        <CAGRyCJGVH9ZhHM_9kau3Trjg0osgaUre5tQ_aWDPVprzH_3mTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-usb <linux-usb@vger.kernel.org>,
        Aleksander Morgado <aleksander@aleksander.es>
To: Daniele Palmas <dnlplm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47549 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1035334AbdDUNC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 09:02:59 -0400
In-Reply-To: <CAGRyCJGVH9ZhHM_9kau3Trjg0osgaUre5tQ_aWDPVprzH_3mTQ@mail.gmail.com>
        (Daniele Palmas's message of "Fri, 21 Apr 2017 14:22:28 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniele Palmas <dnlplm@gmail.com> writes:

> So, I applied your debug patch and this is what is happening:

Thanks

> [ 4306.730786] wdm_open: qmi_wwan 2-2:1.2: draining queued data
> [ 4306.730955] wdm_write: qmi_wwan 2-2:1.2: Tx URB has been submitted ind=
ex=3D2
>
> Here qmicli is stuck. Then I disconnect the cable:

I guess this modem dislikes the unsolicted IN control request so much
that it ignores the OUT control request. I have a feeling that this is
violating the USB spec, since a STALL on the control pipe is supposed to
be cleared by the next setup.

But either way, we have to just accept whatever the device does.


> This is instead the output with the commit reverted:
..
> [ 9885.295723] wdm_write: qmi_wwan 2-2:1.2: Tx URB has been submitted ind=
ex=3D2
> [ 9885.296210] wdm_int_callback: qmi_wwan 2-2:1.2: NOTIFY_NETWORK_CONNECT=
ION disconnected from network
> [ 9885.328208] wdm_int_callback: qmi_wwan 2-2:1.2: NOTIFY_RESPONSE_AVAILA=
BLE received: index 2 len 0
> [ 9885.328216] wdm_int_callback: qmi_wwan 2-2:1.2: submit response URB 0


I note that you get a NETWORK_CONNECTION notification here, which you
also did not receive in the failing case.  That's interesting.  Another
indication that the device is completely stuck as a result of the IN
control request.

Thanks for this.  It shows that we can forget about any such automatic
queue flushing for QMI devices. Any reimplementation of this feature
must be limited to CDC MBIM. The "queue-out-of-sync" issue is mostly
affecting Intel MBIM devices anyway.



Bj=C3=B8rn
