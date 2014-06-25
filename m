From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH 2/3] cxgb4: make configuration load use
	request_firmware_direct()
Date: Wed, 25 Jun 2014 03:50:48 +0200
Message-ID: <20140625015048.GI27687@wotan.suse.de>
References: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com> <1403649583-12707-3-git-send-email-mcgrof@do-not-panic.com> <D46B557B-AF4A-4E60-8D83-6181D406C64F@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, tiwai@suse.de,
	chunkeey@googlemail.com, cocci@systeme.lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, Philip Oswald <poswald@suse.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Jeffrey Cheung <jcheung@suse.com>,
	David Chang <dchang@suse.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <D46B557B-AF4A-4E60-8D83-6181D406C64F@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 24, 2014 at 03:54:44PM -0700, Casey Leedom wrote:
> [[ Hopefully this makes it through to the kernel.org lists -- I=E2=80=
=99m using the
>   Mac OS/X Mailer and it=E2=80=99s not clear how to force it not to u=
se HTML format.
>   -- Casey ]]
>=20
>   So does request_firmware_direct() only fail if the requested file i=
s not
>   present on the file system or does it fail in other cases as well?

Same as before they are the same exact call with the only difference
being udev is not used as an extra helper, so it saves the extra
delay caused by udev. That's all.

>   If it=E2=80=99s the former, then the change to cxgb4 is fine.
>=20
>   But if it=E2=80=99s the latter, then it=E2=80=99s definitely not ok=
ay.  While the driver
>   _can_ continue running without the local on-disk Firmware Configura=
tion
>   File, that file can be used to significantly change the behavior an=
d
>   capabilities of the adapter and is user-customizable.  If a user ma=
kes
>   changes to the local on-disk Firmware Configuration File and these =
are
>   randomly silently ignored this will lead to highly annoying support=
 issues.

This just avoids udev, the request goes directly to the filesystem. The
failure will happen when the file is not present just as before, the
only difference here is skipping udev, it doesn't suffer from the extra=
=20
60 second timeout. There's another possible failure, when
usermodehelper_read_trylock() fails but that is just as the code was be=
fore
so this change doesn't introduce that as a new false check. When that
triggers yout get a nasty WARN_ON() just as before.

One thing to note though is that the kernel firmware loader does not
log any failure to the kernel ring buffer if the firmware is not on the
filesystem, while the udev loader is a bit more chatty:

[ 2463.666120] platform fake-dev.0: Direct firmware load failed with er=
ror -2
[ 2463.666129] platform fake-dev.0: Falling back to user helper

Stuffing a print into the non-udev approach upstream seems a bit excess=
ive
though (unless folks disagree), so if you want the driver to be a bit m=
ore
informative I think its best to place this feedback on the driver for n=
ow.

I see the driver does provide this information already though so is any
additional prints really desirable ?

        dev_info(adapter->pdev_dev, "Successfully configured using Firm=
ware "\ =20
                 "Configuration File \"%s\", version %#x, computed chec=
ksum %#x\n",
                 config_name, finiver, cfcsum);  =20

  Luis
