From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
	paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 14:28:50 +0100
Message-ID: <200703201428.50564.ak@suse.de>
References: <20070319.120854.30182994.davem@davemloft.net>
	<20070319.204712.118947830.davem@davemloft.net>
	<m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	mingo@elte.hu, linux-kernel@vger.kernel.org, jbeulich@novell.com,
	virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, anthony@codemonkey.ws,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

\
> I'm conflicted about the dwarf unwinder.  I was off doing other things
> at the time so I missed the pain, but I do have a distinct recollection of
> the back traces on x86_64 being distinctly worse the on i386. 

The only case were i386 was better was with frame pointers, which
was never fully implemented for x86-64. However i find that hilarious: 
people are spending a lot of time right here in this thread to squeeze
out the best call sequences for the paravirt ops, but then accept
losing a full frame pointer register on i386. I never found that
acceptable, that is why I prefered the unwinder instead. 

This said the big problem with the frame pointers is mostly gone now:
on older CPUs it tended to cause a pipeline stall early in the function.
That is now fixed in the latest Intel/upcomming AMD CPUs, but there 
are still millions and millions of older CPUs out there so I still
don't consider it acceptable.

> Lately 
> I haven't seen that so it may be I was misinterpreting what I was
> seeing, and the compiler optimizations were what gave me such weird
> back traces. 

The main problem is that subsystems are getting more and more complex
and especially callbacks seem to multiply far too quickly.

In 2.4 it was often very reasonable to just sort out the false positives,
but with sometimes 20-30+ level deep call chains in 2.6 with many callbacks that just
gets far too tenuous. 
 
> But if the quality of our backtraces has gone down and dwarf unwinder
> could give us better back traces it is likely worth pursuing.  Of
> course it would need to start with the assumption that it's tables
> may be borked (the kernel is busted after all) and be much more
> careful than Andi's last attempt.

The latest version validates the stack always. It was only a few lines
of change. I doubt it will make much difference though. The few true crashes
we had were not actually due the unwinder itself, but the buggy fallback code
(which were fixed quickly). But anyways it should satisfy everybody's paranoia now.

Although in future it would be good if people did some more analysis in root causes
for failures before let the paranoia take over and revert patches.

We see a good example here of what I call the JFS/ACPI effect: code gets merged
too early with some visible problems. It gets a bad name and afterwards people never
look objectively at it again and just trust their prejudices. 

But that's not a good strategy to get good code in the end I think. If there
is enough evidence the early problems were fixed then prejudices should
be reevaluated.

I will let it cook some time in -mm* and we will see if it works now or not.
I'm pretty confident it will though. And if it does there is no reason not 
to resubmit it.

-Andi
