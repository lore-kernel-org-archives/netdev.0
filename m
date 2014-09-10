From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if
	not OOM
Date: Wed, 10 Sep 2014 14:10:37 -0700
Message-ID: <CAB=NE6UprJH69hzc1mjqyq6PAn+7LZmX65Z8CDwUdJ73nDusHg@mail.gmail.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org>
 <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org>
 <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org>
 <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org> <1410241109.2028.22.camel@jarvis.lan>
 <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com>
 <1410291346.13298.16.camel@jarvis.lan>
 <CAB=NE6U6v-GhAaZv3yXn9uVFvBvE4Uq8z7MQU8N+CyW19WpnNQ@mail.gmail.com>
 <CAG-2HqUiUksdT4UyeDsdc1Q74=2BiX2TuzzGh_hoLiO5_DOvXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 Takashi Iwai <tiwai@suse.de>, Kay Sievers <kay@vrfy.org>,
 Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
 hare <hare@suse.com>,
 Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
 Wu Zhangjin <falcon@meizu.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 "mpt-fusionlinux.pdl" <MPT-FusionLinux.pdl@avagotech.com>,
 Tim Gardner <tim.gardner@canonical.com>, Benjamin Poirier <bpoirier@suse.de>,
 Santosh Rastapur <santosh@chelsio.com>, Casey Leedom <leedom@chelsio.com>,
 Hariprasad S <hariprasad@chelsio.com>,
 Pierre Fersing <pierre-fersing@pierref.org>,
 Arjan van de Ven <arjan@linux.intel.com>,
 Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
 systemd Mailing List <systemd-devel@lists.freedesk
To: Tom Gundersen <teg@jklm.no>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
In-Reply-To: <CAG-2HqUiUksdT4UyeDsdc1Q74=2BiX2TuzzGh_hoLiO5_DOvXQ@mail.gmail.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/systemd-devel>
List-Post: <mailto:systemd-devel@lists.freedesktop.org>
List-Help: <mailto:systemd-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: systemd-devel-bounces@lists.freedesktop.org
Sender: "systemd-devel" <systemd-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

Tom, thanks for reviewing this! My reply below!

On Tue, Sep 9, 2014 at 11:46 PM, Tom Gundersen <teg@jklm.no> wrote:
> On Tue, Sep 9, 2014 at 10:45 PM, Luis R. Rodriguez
> <mcgrof@do-not-panic.com> wrote:
>> On Tue, Sep 9, 2014 at 12:35 PM, James Bottomley
>> <James.Bottomley@hansenpartnership.com> wrote:
>>> On Tue, 2014-09-09 at 12:16 -0700, Luis R. Rodriguez wrote:
>>>> On Mon, Sep 8, 2014 at 10:38 PM, James Bottomley
>>>> <James.Bottomley@hansenpartnership.com> wrote:
>>>> > If we want to sort out some sync/async mechanism for probing devices, as
>>>> > an agreement between the init systems and the kernel, that's fine, but
>>>> > its a to-be negotiated enhancement.
>>>>
>>>> Unfortunately as Tejun notes the train has left which already made
>>>> assumptions on this.
>>>
>>> Well, that's why it's a bug.  It's a material regression impacting
>>> users.
>>
>> Indeed. I believe the issue with this regression however was that the
>> original commit e64fae55 (January 2012) was only accepted by *kernel
>> folks* to be a real regression until recently.
>
> Just for the record, this only caused user-visible problems after
> kernel commit 786235ee (November 2013), right?

Another one was cxgb4:

https://bugzilla.novell.com/show_bug.cgi?id=877622

SLE12 does not yet have commit 786235ee merged. Benjamim did some hard
work to debug this and trace the kill down to systemd-udev. A debug
kernel build has been provided now to try to pick up exactly on the
place where the kill was received, but its at least clear this came
from systemd.

>> More than two years
>> have gone by on growing design and assumptions on top of that original
>> commit. I'm not sure if *systemd folks* yet believe its was a design
>> regression?
>
> I don't think so. udev should not allow its workers to run for an
> unbounded length of time. Whether the upper bound should be 30, 60,
> 180 seconds or something else is up for debate (currently it is 60,
> but if that is too short for some drivers we could certainly revisit
> that).

That's the thing -- the timeout was put in place under the assumption
probe was asyncronous and its not, the driver core issues both module
init *and* probe together, the loader has to wait. That alone makes
the timeout a design flaw, and then systemd carried on top of that
design over two years after that. Its not systemd's fault, its just
that we never spoke about this as a design thing broadly and we should
have, and I will mention that even when the first issues creeped up,
the issue was still tossed back a driver problems. It was only until
recently that we realized that both init and probe run together that
we've been thinking about this problem differently. Systemd was trying
to ensure init on driver don't take long but its not init that is
taking long, its probe, and probe gets then penalized as the driver
core batches both init and probe synchronously before finishing module
loading. Furthermore as clarified by Tejun random userland is known to
exist that will wait indefinitely for module loading under the simple
assumption things *are done synchronously*, and its precisely why we
can't just blindly enable async probe upstream through a new driver
boolean as it can be unfair to this old userland. What is being
evaluated is to enable aync probe for *all* drivers through a new
general system-wide option. We cannot regress old userspace and
assumptions but we can create a new shiny universe.

> Moreover, it seems from this discussion that the aim is (still)
> that insmod should be near-instantaneous (i.e., not wait for probe),

The only reason that is being discussed is that systemd has not
accepted the timeout as a system design despite me pointing out the
original design flaw recently and at this point even if was accepted
as a design flaw it seems its too late. The approach taken to help
make all drivers async is simply an afterthought to give systemd what
it *thought* was in place, and it by no measure should be considered
the proper fix to the regression introduced by systemd, it may perhaps
be the right step long term for systemd systems given it goes with
what it assumed was there, but the timeout was flawed. Its not clear
if systemd can help with old kernels, it seems the ship has sailed and
there seems no options but for folks to work around that -- unless of
course some reasonable solution is found which doesn't break current
systemd design?

> so it seems to me that the basic design is correct and all we need is
> some temporary work-around and a way to better detect misbehaving
> drivers?

As part of this series I addressed hunting for the  "misbehaving
drivers" in-kernel as I saw no progress on the systemd side of things
to non-fatally detect "misbehaving drivers" despite my original RFCs
and request for advice. I quote  "misbehaving drivers" as its a flawed
view to consider them misbehaving now in light of clarifications of
how the driver core works in that it batches both init and probe
together always and we can't be penalizing long probes due to the fact
long probes are simply fine. My patch to pick up "misbehaving drivers"
drivers on the kernel front by picking up systemd's signal was
reactive but it was also simply braindead given the same exact reasons
why systemd's original timeout was flawed. We want a general solution
and we don't want to work around the root cause, in this case it was
systemd's assumption on how drivers work.

Keep in mind that the above just addresses kmod built-in cmd on
systemd, its where the timeout was introduced but as has been
clarified here assuming the same timeout on *all* other built-in
likely is likely pretty flawed as well and this does concern me. Its
why I mentioned that more than two years have gone by now on growing
design and assumptions on top of that original commit and its why its
hard for systemd to consider an alternative.

>>>>  I'm afraid distributions that want to avoid this
>>>> sigkill at least on the kernel front will have to work around this
>>>> issue either on systemd by increasing the default timeout which is now
>>>> possible thanks to Hannes' changes or by some other means such as the
>>>> combination of a modified non-chatty version of this patch + a check
>>>> at the end of load_module() as mentioned earlier on these threads.
>>>
>>> Increasing the default timeout in systemd seems like the obvious bug fix
>>> to me.  If the patch exists already, having distros that want it use it
>>> looks to be correct ... not every bug is a kernel bug, after all.
>>
>> Its merged upstream on systemd now, along with a few fixes on top of
>> it. I also see Kay merged a change to the default timeout to 60 second
>> on August 30. Its unclear if these discussions had any impact on that
>> decision or if that was just because udev firmware loading got now
>> ripped out. I'll note that the new 60 second timeout wouldn't suffice
>> for cxgb4 even if it didn't do firmware loading, its probe takes over
>> one full minute.
>>
>>> Negotiating a probe vs init split for drivers is fine too, but it's a
>>> longer term thing rather than a bug fix.
>>
>> Indeed. What I proposed with a multiplier for the timeout for the
>> different types of built in commands was deemed complex but saw no
>> alternatives proposed despite my interest to work on one and
>> clarifications noted that this was a design regression. Not quite sure
>> what else I could have done here. I'm interested in learning what the
>> better approach is for the future as if we want to marry init + kernel
>> we need a smooth way for us to discuss design without getting worked
>> up about it, or taking it personal. I really want this to work as I
>> personally like systemd so far.
>
> How about this: keep the timeout global, but also introduce a
> (relatively short, say 10 or 15 seconds) timeout after which a warning
> is printed.

That is something that I originally was looking forward to on systemd,
but here's the thing once that warning comes up  -- what would we do
with it? This patch addresses this warning in-kernel and the idea was
that we'd then peg an async_probe bool as true on the driver as a fix,
that was decided to be silly given all the above. These drivers are
actually not misbehaving and it would be even more incorrect to try to
"fix" them by making them run asynchronously. In fact for some old
storage drivers it may even be the worst thing to do given the
possible slew of userland deployment and scripts which assume things
*are* synchronous.

> Even if nothing is actually killed, having workers (be it
> insmod or something else) take longer than a couple of seconds is
> likely a sign that something is seriously off somewhere.

Probe can take a long time and that's fine, so for kmod the current
assumption is flawed. If we had an option to async probe all drivers
then perhaps this kmod timeout *might be reasonable*, and even then I
do recommend for a clear warning that can be collected on logs on its
first iteration rather than sigkilling, only after a whlie should
sigkilling be done really. If systemd can deal with module loading in
the background for drivers that take a long time and warning on that
intsead of sigkiling it may be good start prior to enabling a default
sigkill on drivers. This is perhaps also true for other workers but
its not clear if this is a reasonable strategy for systemd.

 Luis
