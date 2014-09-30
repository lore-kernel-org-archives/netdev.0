From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe support
Date: Tue, 30 Sep 2014 11:22:14 +0200
Message-ID: <CAG-2HqUdFWBPUrHg2yezVVu7xedqTQDBxAW5nuYWKWJCTkZSBg@mail.gmail.com>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com>
 <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com>
 <CAG-2HqWmVODJ6Q46t96mS9ALbeFjRcQ18ypwejY=ug0wCUVv-Q@mail.gmail.com> <20140930022751.GA14081@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Michal Hocko <mhocko@suse.cz>,
	Greg KH <gregkh@linuxfoundation.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Takashi Iwai <tiwai@suse.de>, Tejun Heo <tj@kernel.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Robert Milasan <rmilasan@suse.com>, werner@suse.com,
	Oleg Nesterov <oleg@redhat.com>, hare <hare@suse.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>, pmladek@suse.cz,
	dbueso@suse.com, LKML <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotec
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140930022751.GA14081@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2014 at 4:27 AM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
> On Sun, Sep 28, 2014 at 07:07:24PM +0200, Tom Gundersen wrote:
>> On Fri, Sep 26, 2014 at 11:57 PM, Luis R. Rodriguez
>> <mcgrof@do-not-panic.com> wrote:
>> > From: "Luis R. Rodriguez" <mcgrof@suse.com>
>> > Systemd has a general timeout for all workers currently set to 180
>> > seconds after which it will send a sigkill signal. Systemd now has a
>> > warning which is issued once it reaches 1/3 of the timeout. The original
>> > motivation for the systemd timeout was to help track device drivers
>> > which do not use asynch firmware loading on init() and the timeout was
>> > originally set to 30 seconds.
>>
>> Please note that the motivation for the timeout in systemd had nothing
>> to do with async firmware loading (that was just the case where
>> problems cropped up).
>
> *Part *of the original kill logic, according to the commit log, was actually
> due to the assumption that the issues observed *were* synchronous firmware
> loading on module init():
>
> commit e64fae5573e566ce4fd9b23c68ac8f3096603314
> Author: Kay Sievers <kay.sievers@vrfy.org>
> Date:   Wed Jan 18 05:06:18 2012 +0100
>
>     udevd: kill hanging event processes after 30 seconds
>
>     Some broken kernel drivers load firmware synchronously in the module init
>     path and block modprobe until the firmware request is fulfilled.
>     <...>

This was a workaround to avoid a deadlock between udev and the kernel.
The 180 s timeout was already in place before this change, and was not
motivated by firmware loading. Also note that this patch was not about
"tracking device drivers", just about avoiding dead-lock.

> My point here is not to point fingers but to explain why we went on with
> this and how we failed to realize only until later that the driver core
> ran probe together with init. When a few folks pointed out the issues
> with the kill the issue was punted back to kernel developers and the
> assumption even among some kernel maintainers was that it was init paths
> with sync behaviour that was causing some delays and they were broken
> drivers. It is important to highlight these assumptions ended up setting
> us off on the wrong path for a while in a hunt to try to fix this issue
> either in driver or elsewhere.

Ok. I'm not sure the motivations for user-space changes is important
to include in the commit message, but if you do I'll try to clarify
things to avoid misunderstandings.

> Thanks for clarifying this, can you explain what issues could arise
> from making an exception to allowing kmod workers to hang around
> completing init + probe over a certain defined amount of time without
> being killed?

We could run out of udev workers and the whole boot would hang.

The way I see it, the current status from systemd's side is: our
short-term work-around is to increase the timeout, and at the moment
it appears no long-term solution is needed (i.e., it seems like the
right thing to do is to make sure insmod can be near instantaneous, it
appears people are working towards this goal, and so far no examples
have cropped up showing that it is fundamentally impossible (once/if
they do, we should of course revisit the problem)).

Cheers,

Tom
