From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH 2/3] cxgb4: make configuration load use
	request_firmware_direct()
Date: Wed, 25 Jun 2014 19:31:56 +0200
Message-ID: <20140625173156.GW27687@wotan.suse.de>
References: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com> <1403649583-12707-3-git-send-email-mcgrof@do-not-panic.com> <D46B557B-AF4A-4E60-8D83-6181D406C64F@chelsio.com> <20140625015048.GI27687@wotan.suse.de> <53AB02F4.1090701@chelsio.com>
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
In-Reply-To: <53AB02F4.1090701@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 10:12:20AM -0700, Casey Leedom wrote:
>
> On 06/24/14 18:50, Luis R. Rodriguez wrote:
>> On Tue, Jun 24, 2014 at 03:54:44PM -0700, Casey Leedom wrote:
>>> [[ Hopefully this makes it through to the kernel.org lists -- I=E2=80=
=99m using the
>>>    Mac OS/X Mailer and it=E2=80=99s not clear how to force it not t=
o use HTML format.
>>>    -- Casey ]]
>>>
>>>    So does request_firmware_direct() only fail if the requested fil=
e is not
>>>    present on the file system or does it fail in other cases as wel=
l?
>> Same as before they are the same exact call with the only difference
>> being udev is not used as an extra helper, so it saves the extra
>> delay caused by udev. That's all.
>>
>>>    If it=E2=80=99s the former, then the change to cxgb4 is fine.
>>>
>>>    But if it=E2=80=99s the latter, then it=E2=80=99s definitely not=
 okay.  While the driver
>>>    _can_ continue running without the local on-disk Firmware Config=
uration
>>>    File, that file can be used to significantly change the behavior=
 and
>>>    capabilities of the adapter and is user-customizable.  If a user=
 makes
>>>    changes to the local on-disk Firmware Configuration File and the=
se are
>>>    randomly silently ignored this will lead to highly annoying supp=
ort issues.
>> This just avoids udev, the request goes directly to the filesystem. =
The
>> failure will happen when the file is not present just as before, the
>> only difference here is skipping udev, it doesn't suffer from the ex=
tra
>> 60 second timeout. There's another possible failure, when
>> usermodehelper_read_trylock() fails but that is just as the code was=
 before
>> so this change doesn't introduce that as a new false check. When tha=
t
>> triggers yout get a nasty WARN_ON() just as before.
>
>   Huh, okay.  I guess I'm confused about the value of request_firmwar=
e()=20
> and the User Device helper.  If request_firmware_direct() just goes t=
o the=20
> file system to grab the file and returns with ENOENT if it's not ther=
e,=20
> then you could replace every usage of request_firmware() in the cxgb4=
=20
> driver as far as I can see ...  Either the files are there and we'll =
use=20
> them or they won't be and we'll have to cope with that.  Am I missing=
=20
> something?

You're actually right specially given that udev firmware uploading will
hopefully eventually be removed eventually (it seems it was just one dr=
iver
that caused to consider waiting on the removal, some driver that requir=
ed
looking for firmware on some custom path I think or used a custom loade=
r), for
now however its best to keep things consistent otherwise we'd replace
everything already. The _direct() call then is best used for optional f=
irmware
for now. Perhaps in the end will be that the non _direct() call will ha=
ve an
explicit print to the ring buffer if the file was not found.

>   And again, this definitely isn't going to solve the problem that st=
arted=20
> this whole line of research:

I consider this research part of understanding and optimizing firmware
loading on cxgb4, in this case this would save 60 seconds for each
optional configuration file not present when loading, its not clear to
me how often devices don't have optional configs so its unclear to me t=
he
exact savings in general, but if there's at least one user that should
speed things up.

> we're still going to time out the load of=20
> cxgb4 if there are multiple 10Gb/s BT adapters in a system and we nee=
d to=20
> load each one with both base firmware and PHY firmware.

Again, the timeout is *within* firmware_request(), firmware_release() d=
oes
not tell the firmware loader the timeout is over. The timeout is for th=
e
kernel doing the hunt for the file.

As I see it the next steps on the evaluation on firmware loading on cxg=
b4
would be to evaluate a clean strategy to split things up, and also woul=
d
appreciate feedback on the bus master thing. Perhaps best we continue t=
hat
discussoin on that thread?

  Luis
