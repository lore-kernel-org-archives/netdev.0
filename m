From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Wed, 30 Oct 2013 07:02:14 -0400
Message-ID: <20131030110214.GA10220@localhost.localdomain>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Doug Ledford <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 30, 2013 at 01:25:39AM -0400, Doug Ledford wrote:
> * Neil Horman <nhorman@tuxdriver.com> wrote:
> > 3) The run times are proportionally larger, but still indicate that Parallel ALU
> > execution is hurting rather than helping, which is counter-intuitive.  I'm
> > looking into it, but thought you might want to see these results in case
> > something jumped out at you
> 
> So here's my theory about all of this.
> 
> I think that the original observation some years back was a fluke caused by
> either a buggy CPU or a CPU design that is no longer used.
> 
> The parallel ALU design of this patch seems OK at first glance, but it means
> that two parallel operations are both trying to set/clear both the overflow
> and carry flags of the EFLAGS register of the *CPU* (not the ALU).  So, either
> some CPU in the past had a set of overflow/carry flags per ALU and did some
> sort of magic to make sure that the last state of those flags across multiple
> ALUs that might have been used in parallelizing work were always in the CPU's
> logical EFLAGS register, or the CPU has a buggy microcode that allowed two
> ALUs to operate on data at the same time in situations where they would
> potentially stomp on the carry/overflow flags of the other ALUs operations.
> 
> It's my theory that all modern CPUs have this behavior fixed, probably via a
> microcode update, and so trying to do parallel ALU operations like this simply
> has no effect because the CPU (rightly so) serializes the operations to keep
> them from clobbering the overflow/carry flags of the other ALUs operations.
> 
> My additional theory then is that the reason you see a slowdown from this
> patch is because the attempt to parallelize the ALU operation has caused
> us to write a series of instructions that, once serialized, are non-optimal
> and hinder smooth pipelining of the data (aka going 0*8, 2*8, 4*8, 6*8, 1*8,
> 3*8, 5*8, and 7*8 in terms of memory accesses is worse than doing them in
> order, and since we aren't getting the parallel operation we want, this
> is the net result of the patch).
> 
> It would explain things anyway.
> 

That does makes sense, but it then begs the question, whats the advantage of
having multiple alu's at all?  If they're just going to serialize on the
updating of the condition register, there doesn't seem to be much advantage in
having multiple alu's at all, especially if a common use case (parallelizing an
operation on a large linear dataset) resulted in lower performance.

/me wonders if rearranging the instructions into this order:
adcq 0*8(src), res1
adcq 1*8(src), res2
adcq 2*8(src), res1

would prevent pipeline stalls.  That would be interesting data, and (I think)
support your theory, Doug.  I'll give that a try

Neil
