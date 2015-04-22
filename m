From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods
 with timespec64 type for k_clock structure
Date: Wed, 22 Apr 2015 10:44:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB23A45@AcuExch.aculab.com>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <3231171.5TrYVVBLh4@wuerfel> <alpine.DEB.2.11.1504211701140.13914@nanos>
 <2819798.f0KhjY3UAe@wuerfel> <alpine.DEB.2.11.1504212204130.13914@nanos>
 <alpine.DEB.2.11.1504220946460.13914@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "y2038@lists.linaro.org" <y2038@lists.linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	"pang.xunlei@linaro.org" <pang.xunlei@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
	"cl@linux.com" <cl@linux.com>,
	"heenasirwani@gmail.com" <heenasirwani@gmail.com>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"mpe@ellerman.id.au" <mpe@ellerman.id.au>,
	"rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>,
	"ahh@google.com" <ahh@google.com>,
	"Frederic Weisbecker" <fweisbec@gmail.com>,
	"pjt@google.com" <pjt@google.com>,
	"riel@redhat.com" <riel@redhat.com>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	John Stultz <jo
To: 'Thomas Gleixner' <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:55487 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbbDVKqX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 06:46:23 -0400
In-Reply-To: <alpine.DEB.2.11.1504220946460.13914@nanos>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner
> Sent: 22 April 2015 09:45
> On Tue, 21 Apr 2015, Thomas Gleixner wrote:
> > On Tue, 21 Apr 2015, Arnd Bergmann wrote:
> > > I know there are concerns about this, in particular because C11 and
> > > POSIX both require tv_nsec to be 'long', unlike timeval->tv_usec,
> > > which is a 'suseconds_t' and can be defined as 'long long'.
> > >
> > > a)
> > >
> > > struct timespec {
> > > 	time_t tv_sec;
> > > 	long long tv_nsec; /* or typedef long long snseconds_t */
> > > };
> > >
> > > This is not directly compatible with C11 or POSIX.1-2008, but it
> > > matches what we do inside of 64-bit kernels, so probably has the
> > > highest chance of working correctly in practice
> >
> > After reading Linus rant in the x32 thread again (thanks for the
> > reminder), and looking at b/c/d - which rate between ugly and butt
> > ugly - I think we should go for a) and screw POSIX and C11 as those
> > committee dinosaurs seem to completely ignore the 2038 problem on
> > 32bit machines. At least I have not found any hint that these folks
> > care at all. So why should we comply to something which is completely
> > useless?
> >
> > That also makes the question about the upper 32bits check moot, so
> > it's the simplest and clearest of the possible solutions.
> 
> Second thoughts after some sleep.
> 
> So the outcome of this is going to be that user space libraries will
> not expose the syscall variant of
> 
>     syscall_timespec64 {
>            s64 tv_sec;
> 	   s64 tv_nsec;
>     };
> 
> to applications. The libs will translate them to spec conforming
> 
>    timespec {
>            time_t tv_sec;
> 	   long   tv_nsec;
>    };
> 
> anyway. That means we have two translation steps on 32bit systems:
> 
>   1) user space timespec -> syscall timespec64
> 
>   2) syscall timespec64 -> scalar nsec s64 (ktime_t)
> 
> and the other way round. The kernel internal representation is simply
> s64 (nsec) based all over the place.

Do you need the double-translation?
If all the kernel uses a 64bit nsec value the in-kernel syscall stub
can convert the user-supplied values appropriately before calling
the standard function.
Not that a syscall that takes a linear nsec value isn't useful.

FWIW I can't remember what NetBSD did when they extended time_t to 64bits.

	David
