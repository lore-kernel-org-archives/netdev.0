From: "David S. Miller" <davem@redhat.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 23:00:21 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <accom8$9i4$2@main.gmane.org>
References: <Pine.LNX.4.33.0205201836160.9301-100000@w-nivedita2.des.beaverton.ibm.com>
	<3CE9E466.AC2358EE@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, kuznet@ms2.inr.ac.ru, ak@suse.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com
In-Reply-To: <3CE9E466.AC2358EE@mvista.com>
List-Id: netdev.vger.kernel.org

   From: george anzinger <george@mvista.com>
   Date: Mon, 20 May 2002 23:08:38 -0700

   Nivedita Singhvi wrote:
   > 
   > On Mon, 20 May 2002, David S. Miller wrote:
   > 
   > > Such rule does not even make this piece of code legal.  Consider:
   > >
   > > task1:cpu0:   x = counters[smp_processor_id()];
   > >       cpu0:   PREEMPT
   > > task2:cpu0:   x = counters[smp_processor_id()];
   > > task2:cpu0:   counters[smp_processor_id()] = x + 1;
   > >       cpu0:   PREEMPT
   > > task1:cpu0:   counters[smp_processor_id()] = x + 1;
   > >               full garbage
   
   May be someone could tell me if these matter.  If you are
   bumping a counter and you switch cpus in the middle, a.)
   does it matter? and b.) if so which cpu should get the
   count?  I sort of thought that, if this were going on, it
   did not really matter as long as some counter was bumped.

That's not the problem.  We use per-cpu values for each counter (and
when the user asks for the value, we add together the values from
each processor).

Please review the example I quote above, you aren't reading it
carefully enough.

Let us imagine that we are dealing with counter "X", and
that the values at the beginning of the example are:

	X[0] = 5
	X[1] = 7
	X[2] = ...

Actually, no values matter for the purposes of this example
except the one for cpu 0.  Here is what happens, watch carefully:

   > > task1:cpu0:   x = counters[smp_processor_id()];
   > >       cpu0:   PREEMPT

task1 sees 'x' as '5'

   > > task2:cpu0:   x = counters[smp_processor_id()];
   > > task2:cpu0:   counters[smp_processor_id()] = x + 1;
   > >       cpu0:   PREEMPT

task2 bumps the counter to '6'

   > > task1:cpu0:   counters[smp_processor_id()] = x + 1;
   > >               full garbage

task1 also bumps the counter to '6'

This is the problem.  We make these counters non-atomic on purpose
for performance reasons, so do not mention that as a possible fix.
