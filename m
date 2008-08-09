From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Sat, 9 Aug 2008 05:39:26 -0700 (PDT)
Message-ID: <859858.77737.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753102AbYHIMjh@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On Fri, 2008-08-08 at 18:23 -0700, David Witbrodt wrote:
> > I have tracked the regression down to an RCU problem.
> > [...]
> > After reading some documentation in Documentation/RCU/, it looks like 
> > something is misusing RCU -- and, according to the Documentation, those kinds 
> > of mistakes are easy to make.  Maybe necessary calls to
> >  
> >     rcu_read_lock()
> >     rcu_read_unlock()
> > 
> > are missing, and something about my hardware is triggering a freeze that 
> > doesn't occur on most hardware.
> > 
> > 
> > For some reason, turning off the HPET by booting with "hpet=disabled" keeps
> > the freeze from happening.  Just reading a couple of those docs about RCU
> > made me dizzy, so I hope someone familiar with RCU issues will take a look
> > at the code in the files I've listed.  Surely you guys can take it from here
> > now?!
> > 
> > If not, just give me some experimental code changes to make to get my 2.6.26
> > and 2.6.27 kernels working again without disabling HPET!!!
> 
> 
> The typical way to deadlock like this is do something like:
> 
> rcu_read_lock();
> 
>    synchronize_rcu();
> 
> rcu_read_unlock();
> 
> While I cannot immediately see any such usage in the function you
> quoted, it could be on of the callers.. let me browse some code..
> 
> Can't seem to find anything like that.
> 
> What's weird though - is that HPET makes any difference on these network
> code paths.
> 
> Could we end up calling rcu too soon? I doubt we bring up ipv4 before
> rcu..

I'm _way_ over my head in this discussion, but here's some more food
for thought.  Last weekend, when I first tried 2.6.26 and discovered the
freeze, I thought an error of my own in .config was causing it.  Before
I ever sought help, I made about a dozen experiments with different
.config files.

One series of those experiments involved turning off most of the kernel...
including CONFIG_INET.  The kernel still froze, but when entering 
pci_init().  (This info can be read in my original post to the Debian BTS,
which I have provided links for a couple of times in this LKML thread.  I
even went further and removed enough that the freeze was avoided, but so
much of the kernel was missing that my init scripts couldn't mount a hard
disk any more.  Trying to restore enough to allow HD mounting just brought
back the freeze.)

I am completely ignorant about how the kernel works, so any guesses I have
are probably worthless... but I'll throw some out anyway:

1.  Maybe HPET is used (if present) for timing by RCU, so disabling it
forces RCU to work differently.  (Pure guess here:  I know nothing about
RCU, and haven't even tried looking at its code.)

2.  Maybe my hardware is broken.  We need see one initcall return that
report over 280,000 msecs... when the entire boot->freeze time was about
3 secs.  On the other hand, 2.6.25 (and before) work just fine with HPET
enabled.

3. I was able to find the commit that introduced the freeze
(3def3d6ddf43dbe20c00c3cbc38dfacc8586998f), so there has to be a connection
between that commit and the RCU problem.  Is it possible that a prexisting
error or oversight in the code was merely exposed by that commit?  (And 
only on certain hardware?)  Or does that code itself contain the error?

4. Another bug has been posted on the Debian BTS, which is worked around
by disabling HPET.  The user provided some links to bugzilla.kernel.org
where David Brownell is fighting with some HPET/RTC issues (but no mention
of RCU):
http://bugzilla.kernel.org/show_bug.cgi?id=11111
http://bugzilla.kernel.org/show_bug.cgi?id=11153

I honestly don't know whether this is related to my problem or not.  :-(

If any has any test code I can run to detect massive HPET breakage on
these motherboards, I'll be glad to do so.  Or any other experimental
code changes, for that matter.


Thanks again,
Dave W.
