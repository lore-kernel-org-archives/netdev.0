From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 2/3] cxgb4: make configuration load use request_firmware_direct()
Date: Wed, 25 Jun 2014 11:58:52 -0700
Message-ID: <53AB1BEC.4080107@chelsio.com>
References: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com> <1403649583-12707-3-git-send-email-mcgrof@do-not-panic.com> <D46B557B-AF4A-4E60-8D83-6181D406C64F@chelsio.com> <20140625015048.GI27687@wotan.suse.de> <53AB02F4.1090701@chelsio.com> <20140625173156.GW27687@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, tiwai@suse.de,
	chunkeey@googlemail.com, cocci@systeme.lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, Philip Oswald <poswald@suse.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Jeffrey Cheung <jcheung@suse.com>,
	David Chang <dchang@suse.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140625173156.GW27687@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

   Okay, I'll leave the whole request_firmware{,_direct,_nowait}() thin=
g=20
alone.  The request_firmware_direct() will "solve" a non-problem (since=
=20
all of our "firmware" files are _supposed to be_ always present.  (And=20
the 60 second timeout for udev to confirm that a file doesn't exist=20
seems like udev is just basically broken.)

   That aside, we still need to solve the real problem that we're=20
experiencing in that the boot-time load of cxgb4 is timing out on SLE12=
=20
because a maximum load timeout has been instituted in that distribution=
=20
for driver modules and if there are two 10Gb/s-BT adapters present in a=
=20
system which need both base firmware and BT PHY firmware, we exceed tha=
t=20
timeout.  The timeout really should be per device (since there ~could~=20
be an arbitrary number of devices in a system) and there probably shoul=
d=20
be a way for the driver to notify the kernel timeout mechanism that=20
forward progress is being made ...

Casey

On 06/25/14 10:31, Luis R. Rodriguez wrote:
> On Wed, Jun 25, 2014 at 10:12:20AM -0700, Casey Leedom wrote:
>> On 06/24/14 18:50, Luis R. Rodriguez wrote:
>>> On Tue, Jun 24, 2014 at 03:54:44PM -0700, Casey Leedom wrote:
>>>> [[ Hopefully this makes it through to the kernel.org lists -- I=E2=
=80=99m using the
>>>>     Mac OS/X Mailer and it=E2=80=99s not clear how to force it not=
 to use HTML format.
>>>>     -- Casey ]]
>>>>
>>>>     So does request_firmware_direct() only fail if the requested f=
ile is not
>>>>     present on the file system or does it fail in other cases as w=
ell?
>>> Same as before they are the same exact call with the only differenc=
e
>>> being udev is not used as an extra helper, so it saves the extra
>>> delay caused by udev. That's all.
>>>
>>>>     If it=E2=80=99s the former, then the change to cxgb4 is fine.
>>>>
>>>>     But if it=E2=80=99s the latter, then it=E2=80=99s definitely n=
ot okay.  While the driver
>>>>     _can_ continue running without the local on-disk Firmware Conf=
iguration
>>>>     File, that file can be used to significantly change the behavi=
or and
>>>>     capabilities of the adapter and is user-customizable.  If a us=
er makes
>>>>     changes to the local on-disk Firmware Configuration File and t=
hese are
>>>>     randomly silently ignored this will lead to highly annoying su=
pport issues.
>>> This just avoids udev, the request goes directly to the filesystem.=
 The
>>> failure will happen when the file is not present just as before, th=
e
>>> only difference here is skipping udev, it doesn't suffer from the e=
xtra
>>> 60 second timeout. There's another possible failure, when
>>> usermodehelper_read_trylock() fails but that is just as the code wa=
s before
>>> so this change doesn't introduce that as a new false check. When th=
at
>>> triggers yout get a nasty WARN_ON() just as before.
>>    Huh, okay.  I guess I'm confused about the value of request_firmw=
are()
>> and the User Device helper.  If request_firmware_direct() just goes =
to the
>> file system to grab the file and returns with ENOENT if it's not the=
re,
>> then you could replace every usage of request_firmware() in the cxgb=
4
>> driver as far as I can see ...  Either the files are there and we'll=
 use
>> them or they won't be and we'll have to cope with that.  Am I missin=
g
>> something?
> You're actually right specially given that udev firmware uploading wi=
ll
> hopefully eventually be removed eventually (it seems it was just one =
driver
> that caused to consider waiting on the removal, some driver that requ=
ired
> looking for firmware on some custom path I think or used a custom loa=
der), for
> now however its best to keep things consistent otherwise we'd replace
> everything already. The _direct() call then is best used for optional=
 firmware
> for now. Perhaps in the end will be that the non _direct() call will =
have an
> explicit print to the ring buffer if the file was not found.
>
>>    And again, this definitely isn't going to solve the problem that =
started
>> this whole line of research:
> I consider this research part of understanding and optimizing firmwar=
e
> loading on cxgb4, in this case this would save 60 seconds for each
> optional configuration file not present when loading, its not clear t=
o
> me how often devices don't have optional configs so its unclear to me=
 the
> exact savings in general, but if there's at least one user that shoul=
d
> speed things up.
>
>> we're still going to time out the load of
>> cxgb4 if there are multiple 10Gb/s BT adapters in a system and we ne=
ed to
>> load each one with both base firmware and PHY firmware.
> Again, the timeout is *within* firmware_request(), firmware_release()=
 does
> not tell the firmware loader the timeout is over. The timeout is for =
the
> kernel doing the hunt for the file.
>
> As I see it the next steps on the evaluation on firmware loading on c=
xgb4
> would be to evaluate a clean strategy to split things up, and also wo=
uld
> appreciate feedback on the bus master thing. Perhaps best we continue=
 that
> discussoin on that thread?
>
>    Luis
>
