From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH 0/6] net: qmi_wwan: MDM9x30 support
Date: Thu,  3 Dec 2015 19:24:17 +0100
Message-ID: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	Dan Williams <dcbw@redhat.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47912 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbbLCSZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 13:25:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add new device IDs all the time, often without any testing on
actual hardware. This is usually OK as long as the device is similar
to already supported devices, using the same chipset and firmware
basis.  But the Sierra Wireless MC7455 is an example of a new chipset
generation. Adding it based on assumed similarity with its ancestors
proved too optimistic.

This series adds the missing bits and pieces necessary to support LTE
Advanced modems based on the Qualcomm MDM9x30 chipset. A big thanks to
Sierra Wireless for providing MC7455 samples for testing

The most important change is the "raw-ip" support. The series also
adds a necessary control request, removes an unsupported device ID,
and adds a driver specific entry in MAINTAINERS.

A few random notes about "raw-ip":

"I rather have these all running in raw IP mode. The 802.3 framing is
utterly stupid." - Marcel Holtmann in Jan 2012 [1]

Marcel was right.  I should have listened to him. What more can I say?

The 802.3 framing has provided a steady supply of firmware bugs for
many years. We've added driver workarounds for many of these, but
there are still known bugs where the workaround is so yucky that we
have refused to apply it. But all that is over now.  The latest
generation Qualcomm chips no longer supports 802.3 framing at all.

I had two open questions regarding the "raw-ip" userspace API:

1) Should we continue faking an ethernet device, even if we don't use
   the L2 headers on the USB link anymore?

   There was a vote in favour of the "headerless" device. This is the
   honest representation of the hardware/firmware interface.

2) What input should the driver base its framing on?

   Snooping or directly manipulating QMI is considered out of the
   question. We delegated all QMI handling to userspace from the
   beginning.

   We have so far required userspace to configure the firmware for
   "802.3" framing, or fail if that proved impossible.  This
   requirement is now changed.  Userspace must now inform the driver
   if it negotiates "raw-ip" framing.  Two alternative interfaces were
   proposed:
    - ethtool private driver flag, or
    - sysfs file

   The NetworkManager/ModemManager developers were in favour of the
   sysfs alternative.

These questions (or any other you migh have :) are of course still
open.  This patch set presents the solutions I currently prefer,
considering the above.

All comments are appreciated, even simple '+1' ones.


Bj=C3=B8rn

[1] http://www.spinics.net/lists/linux-usb/msg57056.html


Bj=C3=B8rn Mork (6):
  net: qmi_wwan: MDM9x30 specific power management
  net: qmi_wwan: remove 1199:9070 device id
  usbnet: allow mini-drivers to consume L2 headers
  net: qmi_wwan: support "raw IP" mode
  net: qmi_wwan: document the qmi/raw_ip sysfs file
  MAINTAINERS: add qmi_wwan driver entry

 Documentation/ABI/testing/sysfs-class-net-qmi |  23 +++++
 MAINTAINERS                                   |   7 ++
 drivers/net/usb/qmi_wwan.c                    | 138 ++++++++++++++++++=
+++++++-
 drivers/net/usb/usbnet.c                      |   5 +-
 4 files changed, 169 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-qmi

--=20
2.1.4
