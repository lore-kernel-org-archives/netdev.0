From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: [PATCH] Consolidate multiple implementations of jiffies-msecs conversions.
Date: Thu, 25 Mar 2004 16:05:51 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040325210551.GA23993@ti19.telemetry-investments.com>
References: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jgarzik@pobox.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0403251142110.3037@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 25, 2004 at 12:17:41PM -0800, Sridhar Samudrala wrote:
> The following patch to 2.6.5-rc2 consolidates 6 different implementations
> of msecs to jiffies and 3 different implementation of jiffies to msecs.
> All of them now use the generic msecs_to_jiffies() and jiffies_to_msecs()
> that are added to include/linux/time.h
 
I was inplementing precisely the same diff while cleaning up the
select/poll timeout logic, when I came across this lkml post by George
Anziger,

   http://marc.theaimsgroup.com/?l=linux-kernel&m=107772721007761&w=4

the relevant part of which is:

   As to small drifts of ~170 PPM, they are caused by code (ps I would 
   guess)
   that assumes that jiffies is exactly 1/HZ whereas it is NOT in the 2.6.*
   kernel.  The size of the jiffie that the kernel uses is returned by:

   struct timespec tv;
   :
   :
   clock_res(CLOCK_REALTIME, &tv);

I inferred from the above that a generic msec_to_jiffies()/jiffies_to_msec()
ought to use TICK_NSEC, as with the other routines in time.h.  For 32-bit
platforms the scaled arithmetic is simple; one has to be more careful
when BITS_PER_LONG == 64.

After e-mailing George about it, he replied:

   You might want to look at the code in time.h that does the jiffies to
   timespec conversion.  We did a lot of work to get that right for both 32 and
   64 bit platforms.  I don't think you really need more precision than we get
   on the 32 bit platforms (if I recall correctly it is in the 100 PPB range,
   yeah that is parts per BILLION).

   Unless this conversion is done a lot, I would just start with the timespec
   conversions and convert from / to using simple math.  As it is all power of
   10 stuff it should not have a precision problem.

He also supplied me with his test harness.

I haven't gotten around to doing this properly yet.  It seems that the
only place where precision is actually important (due to the possibility
of very long timeouts) is in poll/epoll, so perhaps it is best
to just code up a special version for them, as the simple version
becomes a no-op everywhere else for the default HZ==1000.

Regards,

	Bill Rugolsky
