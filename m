From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on
 low-end broads.
Date: Wed, 28 Dec 2011 18:13:43 +0100
Message-ID: <1325092423.2327.70.camel@deadeye>
References: <1325075319-13464-1-git-send-email-gurligebis@gentoo.org>
	 <1325083051.2327.47.camel@deadeye>
	 <CACPM=kWpGnBOuKPUK9MgzyETe4VmvEtVXkYtPA_+Xgn=COkCPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Luethi <rl@hellgate.ch>
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACPM=kWpGnBOuKPUK9MgzyETe4VmvEtVXkYtPA_+Xgn=COkCPw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-12-28 at 16:14 +0100, Bjarke Istrup Pedersen wrote:
> 2011/12/28 Ben Hutchings <bhutchings@solarflare.com>:
> > On Wed, 2011-12-28 at 12:28 +0000, Bjarke Istrup Pedersen wrote:
> >> Working around problem causing high CPU load and hanging system when
> >> there is alot of network trafic.
> >>
> >> It is kind of an ugly way to work around it, but it allows the Soekris
> >> net5501 to have trafic between two of it's NICs without hanging so much
> >> that the watchdog kicks in and does a hard reboot of the system.
> >>
> >> There is more info on the problem here:
> >> http://http://lists.soekris.com/pipermail/soekris-tech/2010-October/016889.html
> >>
> >> Tested with positive results on two Soekris net5501-70 boxes.
> >
> > This is completely wrong.  In a UP configuration the extra spinlock
> > calls have no effect (except perhaps a small delay).  In an SMP
> > configuration they will cause rhine_tx() to deadlock when it also tries
> > to acquire the spinlock.
> >
> > Ben.
> 
> Okay, the Soekris net5501-70 boxes are single-core, and I haven't got
> any SMP boxes with that nic.
> Is there a better solution for the problem then, to avoid it hanging
> the box on a non-smp machine with a slow (500mhz) cpu?

If the system actually hangs then I assume there is some bug in the
driver.  I would guess the actual problem is that the interrupt and NAPI
handlers are running constantly so that user processes never run (which
I think counts as soft lockup).

If the hardware supports it, interrupt moderation may help a little by
slightly reducing the per-packet processing cost, but it isn't a full
solution.  Or you can use a real-time kernel, which schedules interrupt
and NAPI handlers as tasks, and adjust priorities so that user processes
can still run.  But that brings its own problems (including generally
lower throughput).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
