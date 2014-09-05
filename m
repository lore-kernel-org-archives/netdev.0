From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Fri, 5 Sep 2014 00:47:16 -0700
Message-ID: <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <1409899047-13045-4-git-send-email-mcgrof@do-not-panic.com> <20140905071925.GC9323@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Ma
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20140905071925.GC9323@mtj.dyndns.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 5, 2014 at 12:19 AM, Tejun Heo <tj@kernel.org> wrote:
> On Thu, Sep 04, 2014 at 11:37:24PM -0700, Luis R. Rodriguez wrote:
> ...
>> +             /*
>> +              * I got SIGKILL, but wait for 60 more seconds for completion
>> +              * unless chosen by the OOM killer. This delay is there as a
>> +              * workaround for boot failure caused by SIGKILL upon device
>> +              * driver initialization timeout.
>> +              *
>> +              * N.B. this will actually let the thread complete regularly,
>> +              * wait_for_completion() will be used eventually, the 60 second
>> +              * try here is just to check for the OOM over that time.
>> +              */
>> +             WARN_ONCE(!test_thread_flag(TIF_MEMDIE),
>> +                       "Got SIGKILL but not from OOM, if this issue is on probe use .driver.async_probe\n");
>> +             for (i = 0; i < 60 && !test_thread_flag(TIF_MEMDIE); i++)
>> +                     if (wait_for_completion_timeout(&done, HZ))
>> +                             goto wait_done;
>> +
>
> Ugh... Jesus, this is way too hacky, so now we fail on 90s timeout
> instead of 30?

Nope! I fell into the same trap and only with tons of patience by part
of Tetsuo with me was I able to grok that the 60 seconds here are not
for increasing the timeout, this is just time spent checking to ensure
that the OOM wasn't the one who triggered the SIGKILL. Even if the
drivers took eons it should be fine now, I tried it :D

>  Why do we even need this with the proposed async
> probing changes?

Ah -- well without it the way we "find" drivers that need this new
"async feature" is by a bug report and folks saying their system can't
boot, or they say their device doesn't come up. That's all. Tracing
this to systemd and a timeout was one of the most ugliest things ever.
There two insane bug reports you can go check:

mptsas was the first:

http://article.gmane.org/gmane.linux.kernel/1669550
https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1297248

Then cxgb4:

https://bugzilla.novell.com/show_bug.cgi?id=877622

I only had Cc'd you on the newest gem pata_marvell :

https://bugzilla.kernel.org/show_bug.cgi?id=59581

We can't seriously expect to be doing all this work for every driver.
a WARN_ONCE() would enable us to find the drivers that need this new
async probe "feature".

  Luis
