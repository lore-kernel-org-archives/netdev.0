From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Mon, 8 Sep 2014 18:04:23 -0700
Message-ID: <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org> <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org> <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
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
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagot
To: Tejun Heo <tj@kernel.org>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:47642 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477AbaIIBEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 21:04:45 -0400
In-Reply-To: <20140905224047.GC15723@mtj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 5, 2014 at 3:40 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Luis.
>
> On Fri, Sep 05, 2014 at 11:12:17AM -0700, Luis R. Rodriguez wrote:
>> Meanwhile we are allowing a major design consideration such as a 30
>> second timeout for both init + probe all of a sudden become a hard
>> requirement for device drivers. I see your point but can't also be
>> introducing major design changes willy nilly either. We *need* a
>> solution for the affected drivers.
>
> Yes, make the behavior specifically specified from userland.  When did
> I ever say that there should be no solution for the problem?  I've
> been saying that the behavior should be selected from userland from
> the get-go, haven't I?
>
> I have no idea how the selection should be.  It could be per-insmod or
> maybe just a system-wide flag with explicit exceptions marked on
> drivers is good enough.  I don't know.

Its perfectly understandable if we don't know what path to take yet
and its also understandable for it to take time to figure out --
meanwhile though systemd already has merged a policy of a 30 second
timeout for *all drivers* though so we therefore need:

0) a solutions for affected combination of systemd / drivers
1) an agreed path forward

If we want a tight integration between both kernel / init system we
need to be able to communicate effectively folks and I'm afraid this
isn't happening. I last noted on systemd-devel how the 30 second
timeout issue was merged under incorrect assumptions -- that it was
not just init that at times caused delays, and that since we currently
batch both init and probe on the driver core we need a non fatal
userspace solution [0], while we work on design on the kernel side of
things for async'ing for drivers that make sense. A proper kernel
solution may take longer than expected, we can't just assume a
probe_async flag will suffice on drivers, in fact as Tejun notes, its
wrong since historically we have had some random userland depend on
the synhronous behaviour of module loading of some drivers, and that
*could* have taken a while.

Kay, Lennart, any recommendations ?

[0] http://lists.freedesktop.org/archives/systemd-devel/2014-August/022696.html

>> Also what stops drivers from going ahead and just implementing their
>> own async probe? Would that now be frowned upon as it strives away
>
> The drivers can't.  How many times should I explain the same thing
> over and over again.  libata can't simply make probing asynchronous
> w.r.t. module loading no matter how it does it.  Yeah, sure, there can
> be other drivers which can do that without most people noticing it but
> a storage driver isn't one of them and the storage drivers are the
> problematic ones already, right?

Its one of the subsystems that has suffered from this, but not the only one.

>> from the original design? The bool would let those drivers do this
>> easily, and we would still need to identify these drivers, although
>> this particular change can be NAK'd Oleg's suggestion on
>> WARN_ON(fatal_signal_pending() at the end of load_module() seems to me
>> at least needed. And if its not async probe... what do those with
>> failed drivers do?
>
> I'm getting tired of explaining the same thing over and over again.
> The said change was nacked because the whole approach of "let's see
> which drivers get reported on the issue which exists basically for all
> drivers and just change the behavior of them" is braindead.  It makes
> no sense whatsoever.  It doesn't address the root cause of the problem
> while making the same class of drivers behave significantly
> differently for no good reason.  Please stop chasing your own tail and
> try to understand the larger picture.

Understood.

  Luis
