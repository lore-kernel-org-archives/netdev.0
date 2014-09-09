From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Tue, 9 Sep 2014 12:16:12 -0700
Message-ID: <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org> <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org> <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org> <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org> <1410241109.2028.22.camel@jarvis.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj@kernel.org>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@ava
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410241109.2028.22.camel@jarvis.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 8, 2014 at 10:38 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Tue, 2014-09-09 at 10:10 +0900, Tejun Heo wrote:
>> Hello, Luis.
>>
>> On Mon, Sep 08, 2014 at 06:04:23PM -0700, Luis R. Rodriguez wrote:
>> > > I have no idea how the selection should be.  It could be per-insmod or
>> > > maybe just a system-wide flag with explicit exceptions marked on
>> > > drivers is good enough.  I don't know.
>> >
>> > Its perfectly understandable if we don't know what path to take yet
>> > and its also understandable for it to take time to figure out --
>> > meanwhile though systemd already has merged a policy of a 30 second
>> > timeout for *all drivers* though so we therefore need:
>>
>> I'm not too convinced this is such a difficult problem to figure out.
>> We already have most of logic in place and the only thing missing is
>> how to switch it.  Wouldn't something like the following work?
>>
>> * Add a sysctl knob to enable asynchronous device probing on module
>>   load and enable asynchronous probing globally if the knob is set.
>>
>> * Identify cases which can't be asynchronous and make them
>>   synchronous.  e.g. keep who's doing request_module() and avoid
>>   asynchronous probing if current is probing one of those.
>
> What's wrong with just fixing systemd?  Arbitrary timeouts in init
> scripts for system bring up are plain wrong ... I thought we had this
> sorted out ten years ago when we were first having the arguments about
> how long to wait for root; I'm surprised it's coming back again.

By design it seems systemd should not allow worker processes to block
indefinitely and in fact it currently uses the same timeout for all
types of worker processes. I last recommended a multiplier to at least
allow systemd to distinguish and allow us to modify the timeout based
on the type of process by using an enum used to classify these, kmod
for example would be one type of command:

http://lists.freedesktop.org/archives/systemd-devel/2014-August/021852.html

This was deemed to introduce unnecessary complexity, but I believe
this was before we realized that the timeout was penalizing kmod usage
unfairly given that the original assumption that it was just init that
should be penalized was incorrect given that we batch both init +
probe together. I have been relaying updates back on that thread as we
move along with this discussion on the issues found with the timeout,
but haven't gotten feedback yet as to which path folks on systemd
would like to take in light of recent discussions / clarifications.
Perhaps your arguments might help folks here reconsider things a bit
as well.

If we want *tight* integration between init system / kernel these
discussions are necessary not only when we find issues but also should
be part of the design phase for major changes.

> If we want to sort out some sync/async mechanism for probing devices, as
> an agreement between the init systems and the kernel, that's fine, but
> its a to-be negotiated enhancement.

Unfortunately as Tejun notes the train has left which already made
assumptions on this. I'm afraid distributions that want to avoid this
sigkill at least on the kernel front will have to work around this
issue either on systemd by increasing the default timeout which is now
possible thanks to Hannes' changes or by some other means such as the
combination of a modified non-chatty version of this patch + a check
at the end of load_module() as mentioned earlier on these threads.

> For the current bug fix, just fix  the component that broke ... which would be systemd.

For new systems it seems the proposed fix is to have systemd tell the
kernel what it thought it should be seeing and that is all pure async
probes through a sysctl, and then we'd do async probe on all modules
unless a driver is specifically flagged with a need to run synchronous
(we'll enable this for request_firmware() users for example to start
off with).

 Luis
