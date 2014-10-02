From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe support
Date: Thu, 2 Oct 2014 08:12:37 +0200
Message-ID: <CAG-2HqVBnXUKSRBrJE=gEKA3St5KMfdgAbx2vRfpF3qw_teLOg@mail.gmail.com>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com>
 <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com>
 <CAG-2HqWmVODJ6Q46t96mS9ALbeFjRcQ18ypwejY=ug0wCUVv-Q@mail.gmail.com>
 <20140930022751.GA14081@wotan.suse.de> <CAG-2HqUdFWBPUrHg2yezVVu7xedqTQDBxAW5nuYWKWJCTkZSBg@mail.gmail.com>
 <20140930152419.GF14081@wotan.suse.de>
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
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20140930152419.GF14081@wotan.suse.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2014 at 5:24 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
>> > commit e64fae5573e566ce4fd9b23c68ac8f3096603314
>> > Author: Kay Sievers <kay.sievers@vrfy.org>
>> > Date:   Wed Jan 18 05:06:18 2012 +0100
>> >
>> >     udevd: kill hanging event processes after 30 seconds
>> >
>> >     Some broken kernel drivers load firmware synchronously in the module init
>> >     path and block modprobe until the firmware request is fulfilled.
>> >     <...>
>>
>> This was a workaround to avoid a deadlock between udev and the kernel.
>> The 180 s timeout was already in place before this change, and was not
>> motivated by firmware loading. Also note that this patch was not about
>> "tracking device drivers", just about avoiding dead-lock.
>
> Thanks, can you elaborate on how a deadlock can occur if the kmod
> worker is not at some point sigkilled?

This was only relevant whet udev did the firmware loading. modprobe
would wait for the kernel, which would wait for the firmware loading,
which would wait for modprobe. This is no longer a problem as udev
does not do firmware loading any more.

> Is the issue that if there is no extra worker available and all are
> idling on sleep / synchronous long work boot will potentially hang
> unless a new worker becomes available to do more work?

Correct.

> If so I can
> see the sigkill helping for hanging tasks but it doesn't necessarily
> mean its a good idea to kill modules loading taking a while. Also
> what if the sigkill is just avoided for *just* kmod workers?

Depending on the number of devices you have, I suppose we could still
exhaust the workers.

>> The way I see it, the current status from systemd's side is: our
>> short-term work-around is to increase the timeout, and at the moment
>> it appears no long-term solution is needed (i.e., it seems like the
>> right thing to do is to make sure insmod can be near instantaneous, it
>> appears people are working towards this goal, and so far no examples
>> have cropped up showing that it is fundamentally impossible (once/if
>> they do, we should of course revisit the problem)).
>
> That again would be reactive behaviour, what would prevent avoiding the
> sigkill only for kmod workers? Is it known the deadlock is immiment?
> If the amount of workers for kmod that would hit the timeout is
> considered low I don't see how that's possible and why not just lift
> the sigkill.

Making kmod a special case is of course possible. However, as long as
there is no fundamental reason why kmod should get this special
treatment, this just looks like a work-around to me. We already have a
work-around, which is to increase the global timeout. If you still
think we should do something different in systemd, it is probably best
to take the discussion to systemd-devel to make sure all the relevant
people are involved.

Cheers,

Tom
