From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- no earlier revision works with 3def3d6d diff
Date: Fri, 15 Aug 2008 20:20:20 -0700 (PDT)
Message-ID: <70719.89186.qm@web82106.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82106.mail.mud.yahoo.com ([209.191.84.219]:33875 "HELO
	web82106.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751989AbYHPDUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 23:20:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


My next experiment failed.  It was based on an excellent suggestion by
Mike Galbraith:

===== BEGIN QUOTE ============

What _could_ be happening is that 3def3d6d itself isn't directly causing
your problem, rather interacting with earlier changes such that you see
the problem as soon as 3def3d6d hit.  I recently found just such a
regression.  It looked like a performance problem was introduced by very
recent bug fixes, but in actuality, was introduced by a load balancing
change at the very beginning of the .27 cycle, the regression was merely
hidden by the now fixed bugs until those fixes went in.

Such cases can/do happen, and can cause much confusion.  To find such a
problem without actually troubleshooting it (if such a thing is
happening in your case), you'd have to work backward, ie apply 3def3d6d
to earlier kernels and test.  If you find one earlier than 3def3d6d
which works with 3def3d6d applied, you can be pretty sure that what
you've got is a nasty interaction.  At that point, you'd start your
bisection _with virgin source_ via git bisect good "the point that
worked _with_ 3def3d6d applied", and git bisect bad any later point that
failed.  During each and every bisection point, you'd have to apply
3def3d6d before testing (fixing any rejects), and _before_ saying git
bisect good/bad after building/testing, you must revert it first so git
bisect can proceed without encountering conflicts.
===== END QUOTE ============

I would have bet my last dollar that this method would find something,
but it did not.

The first commit that introduces lockups for me occured in the window 
after 2.6.25, but before 2.6.26-rc1.  So I ran 'git checkout v2.6.25',
applied the changes from the problem commit, built and installed the
kernel, rebooted... and it locked up.

OK, so maybe something was introduced on the way to 2.6.25....

I checked out tag "v2.6.25-rc1" and followed the same procedure.  The
diff from the problem commit still applied cleanly, so I faced no
difficulties... but that kernel locked up too.

I decided to keep moving backwards until the changes in the problem
commit would no longer apply cleanly.  The next earlier tag was
"v2.6.24", and the code was different enough that I had to manually
apply the changes.  Since I am not a kernel developer, trying the
manual patching probably was not a good idea, but I had nothing to
lose.  The kernel built fine, but still locked up.


I think going further back would serve little purpose:  it would force
more and more decisions on me about how to apply a diff to code which
no longer fits.  Ray Lee warned me not to bother with code suggestions,
much less code changes/decisions... and I think he was right.

Moving on now to Bill Fink's suggestion:

===== BEGIN QUOTE ============
I wonder if it would help to revert both the 3def3d6d... and 1e934dda...
commits.  If there are 2 (or more) problematic commits, then of course
it wouldn't help to revert just one of the two commits.  This is one of
the nastiest type of debugging scenario, when there is more than one
cause of the observed problem, although in such case the multiple
causes are often related in some way.
===== END QUOTE ============

The point here is that my lockups begin at 3def3d6d, and the very next
commit (1e934dda) prevents reverting the changes in 3def3d6d from giving
me a working kernel.  I can revert the changes from both of these commits,
then try to move forward as far as I can before the lockups come back.


Dave W.
