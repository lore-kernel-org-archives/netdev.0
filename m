From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 0/3] Adding a new driver for Huawei E392 WWAN modem
Date: Tue, 13 Dec 2011 10:02:13 +0100
Message-ID: <87r508deui.fsf@nemi.mork.no>
References: <1323750784-32608-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:32969 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab1LMJCs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 04:02:48 -0500
In-Reply-To: <1323750784-32608-1-git-send-email-bjorn@mork.no> (Bjorn Mork's
	message of "Tue, 13 Dec 2011 05:33:01 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bjorn Mork <bjorn@mork.no> writes:

> patch 3 adds the new driver.  Most of it is QMI protocol handling.
> The network device is a minimalistic usbnet minidriver.

In case anyone wonders what this really does, here's an excerpt of a
connection being initiated by simply doing "dhclient wwan1".=20
"ip link set dev wwan1 up" would achieve the same, except for address
configuration of course.


I'm explaining inline:


Dec 13 04:15:38 nemi kernel: [23893.115819] qmi_wwan 2-2:1.3: wwan1: re=
gister 'qmi_wwan' at usb-0000:00:1d.7-2, QMI speaking CDC ECM like wwan=
 device, 76:bb:09:ca:8e:84
Dec 13 04:15:38 nemi kernel: [23893.116732] usbcore: registered new int=
erface driver qmi_wwan
Dec 13 04:15:40 nemi kernel: [23894.842205] usb 2-2: QMI_CTL request: m=
sg 0x0022 (len 15) from "control point" with cid=3D0x00 and TLVs:
Dec 13 04:15:40 nemi kernel: [23894.842214] usb 2-2: [0x01] (1) 01     =
                                          .

requesting a client ID for subsystem QMI_WDS.  We need this for startin=
g
the network connection.

Dec 13 04:15:40 nemi kernel: [23894.944602] usb 2-2: QMI_CTL response: =
msg 0x0022 (len 23) from "service" with cid=3D0x00 and TLVs:
Dec 13 04:15:40 nemi kernel: [23894.944614] usb 2-2: [0x02] (4) SUCCESS=
 (0x0000)
Dec 13 04:15:40 nemi kernel: [23894.944622] usb 2-2: [0x01] (2) 01 03  =
                                          ..

received QMI_WDS client ID =3D 3

Dec 13 04:15:40 nemi kernel: [23894.945827] usb 2-2: QMI_CTL request: m=
sg 0x0022 (len 15) from "control point" with cid=3D0x00 and TLVs:
Dec 13 04:15:40 nemi kernel: [23894.945837] usb 2-2: [0x01] (1) 02     =
                                          .

requesting a client ID for subsystem QMI_DMS.  We need this for
verifying SIM PIN state (well, we don't really need to do that, but it
enables us to understand why the connection fails if a PIN code is
required).


Dec 13 04:15:40 nemi kernel: [23895.048729] usb 2-2: QMI_CTL response: =
msg 0x0022 (len 23) from "service" with cid=3D0x00 and TLVs:
Dec 13 04:15:40 nemi kernel: [23895.048738] usb 2-2: [0x02] (4) SUCCESS=
 (0x0000)
Dec 13 04:15:40 nemi kernel: [23895.048743] usb 2-2: [0x01] (2) 02 03  =
                                          ..

received QMI_DMS client ID =3D 3


Dec 13 04:15:40 nemi kernel: [23895.050066] usb 2-2: QMI_DMS request: m=
sg 0x002b (len 12) from "control point" with cid=3D0x03 and TLVs:

requesting PIN code state

Dec 13 04:15:40 nemi kernel: [23895.152746] usb 2-2: QMI_DMS response: =
msg 0x002b (len 31) from "service" with cid=3D0x03 and TLVs:
Dec 13 04:15:40 nemi kernel: [23895.152758] usb 2-2: [0x02] (4) SUCCESS=
 (0x0000)
Dec 13 04:15:40 nemi kernel: [23895.152767] usb 2-2: [0x12] (3) PIN2 st=
atus=3D1, 3 verify retries left, 10 unblock retries left
Dec 13 04:15:40 nemi kernel: [23895.152777] usb 2-2: [0x11] (3) PIN1 st=
atus=3D2, 3 verify retries left, 10 unblock retries left

PIN1 is enabled but already verified, so we're ready to go.


Dec 13 04:15:40 nemi kernel: [23895.153987] usb 2-2: QMI_WDS request: m=
sg 0x0022 (len 12) from "control point" with cid=3D0x03 and TLVs:

requesting connection state

Dec 13 04:15:41 nemi kernel: [23895.256746] usb 2-2: QMI_WDS response: =
msg 0x0022 (len 23) from "service" with cid=3D0x03 and TLVs:
Dec 13 04:15:41 nemi kernel: [23895.256757] usb 2-2: [0x02] (4) SUCCESS=
 (0x0000)
Dec 13 04:15:41 nemi kernel: [23895.256765] usb 2-2: [0x01] (1) 01     =
                                          .

state is disconnected

Dec 13 04:15:41 nemi kernel: [23895.257967] usb 2-2: QMI_WDS request: m=
sg 0x0020 (len 12) from "control point" with cid=3D0x03 and TLVs:

starting a new connection

Dec 13 04:15:41 nemi kernel: [23895.360622] usb 2-2: QMI_WDS response: =
msg 0x0020 (len 26) from "service" with cid=3D0x03 and TLVs:
Dec 13 04:15:41 nemi kernel: [23895.360634] usb 2-2: [0x02] (4) SUCCESS=
 (0x0000)
Dec 13 04:15:41 nemi kernel: [23895.360641] usb 2-2: [0x01] (4) e8 90 1=
5 02                                      ....


successfully connected.  Got a 32bit handle (needed for disconnect).
The connection is now fully usable, and DHCP will now succeed (not
shown).


Dec 13 04:15:41 nemi kernel: [23895.361114] usb 2-2: QMI_WDS indication=
: msg 0x0022 (len 21) from "service" with cid=3D0xff (broadcast) and TL=
Vs:
Dec 13 04:15:41 nemi kernel: [23895.361124] usb 2-2: [0x01] (2) 02 00  =
                                          ..
Dec 13 04:15:41 nemi kernel: [23895.361131] usb 2-2: [0x12] (1) 04     =
                                          .


received an unsolicited QMI_WDS status message (sent to all clients)
with the new IPv4 connected state

Dec 13 04:15:41 nemi kernel: [23895.362343] usb 2-2: QMI_WDS request: m=
sg 0x0001 (len 20) from "control point" with cid=3D0x03 and TLVs:
Dec 13 04:15:41 nemi kernel: [23895.362352] usb 2-2: [0x10] (1) 01     =
                                          .
Dec 13 04:15:41 nemi kernel: [23895.362360] usb 2-2: [0x15] (1) 01     =
                                          .

request speed and system change updates.  Nice to know, but not strictl=
y
required.

Dec 13 04:15:41 nemi kernel: [23895.464623] usb 2-2: QMI_WDS response: =
msg 0x0001 (len 19) from "service" with cid=3D0x03 and TLVs:
Dec 13 04:15:41 nemi kernel: [23895.464635] usb 2-2: [0x02] (4) SUCCESS=
 (0x0000)

received ack to the last request.  That's the last we'll see until
something changes.



Bj=C3=B8rn
