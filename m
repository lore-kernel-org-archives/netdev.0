From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 0/6] net: qmi_wwan: MDM9x30 support
Date: Thu, 03 Dec 2015 13:36:56 -0600
Message-ID: <1449171416.21472.42.camel@redhat.com>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Aleksander Morgado <aleksander@aleksander.es>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005AbbLCTg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 14:36:58 -0500
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 19:24 +0100, Bj=C3=B8rn Mork wrote:
> We add new device IDs all the time, often without any testing on
> actual hardware. This is usually OK as long as the device is similar
> to already supported devices, using the same chipset and firmware
> basis.  But the Sierra Wireless MC7455 is an example of a new chipset
> generation. Adding it based on assumed similarity with its ancestors
> proved too optimistic.
>=20
> This series adds the missing bits and pieces necessary to support LTE
> Advanced modems based on the Qualcomm MDM9x30 chipset. A big thanks
> to
> Sierra Wireless for providing MC7455 samples for testing
>=20
> The most important change is the "raw-ip" support. The series also
> adds a necessary control request, removes an unsupported device ID,
> and adds a driver specific entry in MAINTAINERS.
>=20
> A few random notes about "raw-ip":
>=20
> "I rather have these all running in raw IP mode. The 802.3 framing is
> utterly stupid." - Marcel Holtmann in Jan 2012 [1]
>=20
> Marcel was right.  I should have listened to him. What more can I
> say?

The decision was less clear-cut at the time, since all the devices did
support 802.3 framing and DHCP.  And people wanted easy-1-2-3 DHCP and
bridging capability too.  We still get a lot of people asking about
issues with DHCP and even bridging.  802.3 makes it *look* simple but
of course we know it's not that simple...

> The 802.3 framing has provided a steady supply of firmware bugs for
> many years. We've added driver workarounds for many of these, but
> there are still known bugs where the workaround is so yucky that we
> have refused to apply it. But all that is over now.  The latest
> generation Qualcomm chips no longer supports 802.3 framing at all.
>=20
> I had two open questions regarding the "raw-ip" userspace API:
>=20
> 1) Should we continue faking an ethernet device, even if we don't use
>    the L2 headers on the USB link anymore?
>=20
>    There was a vote in favour of the "headerless" device. This is the
>    honest representation of the hardware/firmware interface.

I like the approach of the current patchset where it's more like a tun
device.  Simple.

> 2) What input should the driver base its framing on?
>=20
>    Snooping or directly manipulating QMI is considered out of the
>    question. We delegated all QMI handling to userspace from the
>    beginning.
>=20
>    We have so far required userspace to configure the firmware for
>    "802.3" framing, or fail if that proved impossible.  This
>    requirement is now changed.  Userspace must now inform the driver
>    if it negotiates "raw-ip" framing.  Two alternative interfaces
> were
>    proposed:
>     - ethtool private driver flag, or
>     - sysfs file
>=20
>    The NetworkManager/ModemManager developers were in favour of the
>    sysfs alternative.

Sysfs is the easiest for most things to touch; ethtool requires being
able to do ioctls and bit operations or shell out to ethtool.  Just
stating the reasons for my above vote.

Dan

> These questions (or any other you migh have :) are of course still
> open.  This patch set presents the solutions I currently prefer,
> considering the above.
>=20
> All comments are appreciated, even simple '+1' ones.
>=20
>=20
> Bj=C3=B8rn
>=20
> [1] http://www.spinics.net/lists/linux-usb/msg57056.html
>=20
>=20
> Bj=C3=B8rn Mork (6):
>   net: qmi_wwan: MDM9x30 specific power management
>   net: qmi_wwan: remove 1199:9070 device id
>   usbnet: allow mini-drivers to consume L2 headers
>   net: qmi_wwan: support "raw IP" mode
>   net: qmi_wwan: document the qmi/raw_ip sysfs file
>   MAINTAINERS: add qmi_wwan driver entry
>=20
>  Documentation/ABI/testing/sysfs-class-net-qmi |  23 +++++
>  MAINTAINERS                                   |   7 ++
>  drivers/net/usb/qmi_wwan.c                    | 138
> +++++++++++++++++++++++++-
>  drivers/net/usb/usbnet.c                      |   5 +-
>  4 files changed, 169 insertions(+), 4 deletions(-)
>  create mode 100644 Documentation/ABI/testing/sysfs-class-net-qmi
>=20
