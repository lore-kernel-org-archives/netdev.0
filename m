From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: iperf: performance regression (was b44 driver problem?)
Date: Mon, 04 Jun 2007 19:32:48 +0200
Message-ID: <1180978368.4404.29.camel@chaos>
References: <20070525172431.60affaca@freepuppy>
	 <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos>
	 <200706031826.06891.maxi@daemonizer.de> <1180939188.4404.5.camel@chaos>
	 <20070604090918.42386fbb@freepuppy> <1180974958.4404.24.camel@chaos>
	 <20070604095924.651d91c8@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070604095924.651d91c8@freepuppy>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-04 at 09:59 -0700, Stephen Hemminger wrote:
> > > gettimeofday({1180973726, 982754}, NULL) = 0
> > > recv(4, "\0\0\0\0\0\0\0\1\0\0\23\211\0\0\0\0\0\0\0\0\377\377\364"..., 8192, 0) = 8192
> > > gettimeofday({1180973726, 983790}, NULL) = 0
> > 
> > Well, gettimeofday() is not affected by the highres code, but
> > 
> > > nanosleep({0, 0}, NULL) = 0
> > > nanosleep({0, 0}, NULL) = 0
> > 
> > is. The nanosleep call with a relative timeout of 0 returns immediately
> > with highres enabled, while it sleeps at least until the next tick
> > arrives when highres is off. Are there more of those stupid sleeps in
> > the code ?
> 
> GLIBC pthread_mutex does it, YES it is a problem!
> Looks like the old behavior is required for ABI compatibility.
>
> iperf server has several threads. One thread is using pthread_mutex_lock
> to wait for the other thread.  It looks like pthread_mutex_lock is using
> nanosleep as yield().

I doubt that. This is in the iperf code itself.

void thread_rest ( void ) {
#if defined( HAVE_THREAD )
#if defined( HAVE_POSIX_THREAD )
    // TODO add checks for sched_yield or pthread_yield and call that
    // if available
    usleep( 0 );

----------^^^^

It results in a nanosleep({0,0}, NULL)

	tglx
