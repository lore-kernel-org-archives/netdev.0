From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if
	not OOM
Date: Tue, 9 Sep 2014 13:45:30 -0700
Message-ID: <CAB=NE6U6v-GhAaZv3yXn9uVFvBvE4Uq8z7MQU8N+CyW19WpnNQ@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
 Takashi Iwai <tiwai@suse.de>, Kay Sievers <kay@vrfy.org>,
 Oleg Nesterov <oleg@redhat.com>,
 Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>, hare@suse.com,
 Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
 Wu Zhangjin <falcon@meizu.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 MPT-FusionLinux.pdl@avagotech.com, Tim Gardner <tim.gardner@canonical.com>,
 Benjamin Poirier <bpoirier@suse.de>, Santosh Rastapur <santosh@chelsio.com>,
 Casey Leedom <leedom@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>,
 Pierre Fersing <pierre-fersing@pierref.org>,
 Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
 Arjan van de Ven <arjan@linux.intel.com>,
 Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
 systemd-devel@lists.freedesktop.org,
 Linux SCSI List <linux-scsi@vger.kernel.org>,
 Dmitry Torokhov <dmitr
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
In-Reply-To: <1410291346.13298.16.camel@jarvis.lan>
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

On Tue, Sep 9, 2014 at 12:35 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Tue, 2014-09-09 at 12:16 -0700, Luis R. Rodriguez wrote:
>> On Mon, Sep 8, 2014 at 10:38 PM, James Bottomley
>> <James.Bottomley@hansenpartnership.com> wrote:
>> > If we want to sort out some sync/async mechanism for probing devices, as
>> > an agreement between the init systems and the kernel, that's fine, but
>> > its a to-be negotiated enhancement.
>>
>> Unfortunately as Tejun notes the train has left which already made
>> assumptions on this.
>
> Well, that's why it's a bug.  It's a material regression impacting
> users.

Indeed. I believe the issue with this regression however was that the
original commit e64fae55 (January 2012) was only accepted by *kernel
folks* to be a real regression until recently. More than two years
have gone by on growing design and assumptions on top of that original
commit. I'm not sure if *systemd folks* yet believe its was a design
regression?

>>  I'm afraid distributions that want to avoid this
>> sigkill at least on the kernel front will have to work around this
>> issue either on systemd by increasing the default timeout which is now
>> possible thanks to Hannes' changes or by some other means such as the
>> combination of a modified non-chatty version of this patch + a check
>> at the end of load_module() as mentioned earlier on these threads.
>
> Increasing the default timeout in systemd seems like the obvious bug fix
> to me.  If the patch exists already, having distros that want it use it
> looks to be correct ... not every bug is a kernel bug, after all.

Its merged upstream on systemd now, along with a few fixes on top of
it. I also see Kay merged a change to the default timeout to 60 second
on August 30. Its unclear if these discussions had any impact on that
decision or if that was just because udev firmware loading got now
ripped out. I'll note that the new 60 second timeout wouldn't suffice
for cxgb4 even if it didn't do firmware loading, its probe takes over
one full minute.

> Negotiating a probe vs init split for drivers is fine too, but it's a
> longer term thing rather than a bug fix.

Indeed. What I proposed with a multiplier for the timeout for the
different types of built in commands was deemed complex but saw no
alternatives proposed despite my interest to work on one and
clarifications noted that this was a design regression. Not quite sure
what else I could have done here. I'm interested in learning what the
better approach is for the future as if we want to marry init + kernel
we need a smooth way for us to discuss design without getting worked
up about it, or taking it personal. I really want this to work as I
personally like systemd so far.

>> > For the current bug fix, just fix  the component that broke ... which would be systemd.
>>
>> For new systems it seems the proposed fix is to have systemd tell the
>> kernel what it thought it should be seeing and that is all pure async
>> probes through a sysctl, and then we'd do async probe on all modules
>> unless a driver is specifically flagged with a need to run synchronous
>> (we'll enable this for request_firmware() users for example to start
>> off with).
>
> I don't have very strong views on this one.  However, I've got to say
> from a systems point of view that if the desire is to flag when the
> module is having problems, probing and initializing synchronously in a
> thread spawned by init which the init process can watchdog and thus can
> flash up warning messages seems to be more straightforwards

Indeed however it was not understood that module loading did init +
probe synchrounously, and indeed what you recommend is also what I was
hoping systemd *should do* instead of a hard sigkill at the default
timeout.

> than an
> elaborate asynchronous mechanism with completion signalling which
> achieves the same thing in a more complicated (and thus bug prone)
> fashion.

I couldn't be in any more agreement with you. It takes two to tango though.

  Luis
