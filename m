From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe
	support
Date: Tue, 30 Sep 2014 09:47:35 +0200
Message-ID: <20140930074735.GE14081@wotan.suse.de>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com> <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com> <CAG-2HqWmVODJ6Q46t96mS9ALbeFjRcQ18ypwejY=ug0wCUVv-Q@mail.gmail.com> <20140930022751.GA14081@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Michal Hocko <mhocko@suse.cz>,
	Greg KH <gregkh@linuxfoundation.org>,
	Julia Lawall <julia.lawall@lip6.fr>,
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
	Nagalakshmi Nan
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140930022751.GA14081@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2014 at 04:27:51AM +0200, Luis R. Rodriguez wrote:
> On Sun, Sep 28, 2014 at 07:07:24PM +0200, Tom Gundersen wrote:
> > On Fri, Sep 26, 2014 at 11:57 PM, Luis R. Rodriguez
> > <mcgrof@do-not-panic.com> wrote:
> > > From: "Luis R. Rodriguez" <mcgrof@suse.com>
> > > 0) Not all drivers are killed, the signal is just sent and
> > >    the kill will only be acted upoon if the driver you loaded
> > >    happens to have some code path that either uses kthreads (which
> > >    as of 786235ee are now killable), or uses some code which checks for
> > >    fatal_signal_pending() on the kernel somewhere -- i.e: pci_read_vpd().
> > 
> > Shouldn't this be seen as something to be fixed in the kernel?
> 
> That's a great question. In practice now after CVE-2012-4398 and its series of
> patches added which enabled OOM to kill things followed by 786235ee to also
> handle OOM on kthreads it seems imperative we strive towards this, in practive
> however if you're getting OOMs on boot you have far more serious issue to be
> concerned over than handling CVE-2012-4398. Another issue is that even if we
> wanted to address this a critical right now on module loading driver error
> paths tend to be pretty buggy and we'd probably end up causing more issues than
> fixing anything if the sigkill that triggered this was an arbitrary timeout,
> specially if the timeout is not properly justified.

<-- snip -->

> So extending the kill onto more drivers *because* of the timeout is probably
> not a good reason as it would probably create more issue than fix anything
> right now.

A bit more on this. Tejun had added devres while trying to convert libata to
use iomap but in that process also help address buggy failure paths on drivers [0].
Even with devres in place and devm functions being available they actually
haven't been popularized until recent kernels [1]. There is even further
research on precicely these sorts of errors, such as "Hector: Detecting
Resource-Release Omission Faults in error-handling code for systems software" [2]
but unfortunately there is no data over time. Another paper is "An approach to
improving the structure of error-handling code in the Linux kernel" [3] which
tries to address moving error handling code in the middle of the function to gotos
to shared code at the end of the function...

So we have buggy error paths on drivers and trusting them unfortunately isn't
a good idea at this point. They should be fixed but saying we should equally
kill all drivers right now would likley introduce more issues than anything.

[0] http://lwn.net/Articles/215861/
[1] http://www.slideshare.net/ennael/kernel-recipes-2013?qid=f0888b85-377b-4b29-95c3-f4e59822f5b3&v=default&b=&from_search=6
    See slide 6 on graph usage of devm functions over time
[2] http://coccinelle.lip6.fr/papers/dsn2013.pdf
[3] http://coccinelle.lip6.fr/papers/lctes11.pdf

  Luis
