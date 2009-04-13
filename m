From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [Bugme-new] [Bug 13084] New: page allocation failure. order:0,
 mode:0x20
Date: Mon, 13 Apr 2009 13:06:04 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0904131255580.732@jbrandeb-desk1.amr.corp.intel.com>
References: <bug-13084-10286@http.bugzilla.kernel.org/> <20090413124228.be31e9f3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "reeve.yang@gmail.com" <reeve.yang@gmail.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53095 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029AbZDMUGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2009 16:06:08 -0400
In-Reply-To: <20090413124228.be31e9f3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Apr 2009, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Mon, 13 Apr 2009 19:27:27 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=13084
> > 
> >            Summary: page allocation failure. order:0, mode:0x20
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.17.4
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Page Allocator
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: reeve.yang@gmail.com
> >         Regression: No
> > 
> > 
> > Created an attachment (id=20964)
> >  --> (http://bugzilla.kernel.org/attachment.cgi?id=20964)
> > kernel config file.
> > 
> > The system is Intel Xeon Quad core with 8G physical RAM. When it's under UPD
> > loads, e.g., DNS queries, the box is stuck in terms it cannot be pinged or
> > login. By checking syslog, I'm seeing following trace back from various
> > dameon/processes. The network controller is E1000 82571 with NAPI enabled in
> > kernel.
> >
> > page allocation failure. order:0, mode:0x20
> 
> This is very common.  e1000 attempts to do large memory allocations
> from within interrupt context and the page allocator cannot satisfy the
> allocation and is not allowed to do the necessary work to make the
> allocation attempt succeed.  It's the same with all net drivers, but
> e1000 is especially prone, apparently because of hardware suckiness.

while in jumbo mode, andrew's statement is true, but with order:0 
allocation failures it is just normal networking goo that causes the 
memory allocator to run out of free pages, seems much less frequent in 
newer kernels.
 
> However the networking stack should just drop the packet and the system
> will recover.

I think at that point the kernel gets quite busy printing warnings about 
how much it is out of memory.

> You report is unclear.  Yes, the machine wedges up under the UDP load. 
> But does it recover when the other machine stops spraying UDP packets
> at this machine?  It _should_ recover.  If it does not, we have a bug
> somewhere.

In this case kmem_cache_alloc is failing to get memory, being called by 
the route_dst code, maybe someone on netdev can comment if this has been 
fixed along the way.
 
> The usual workaround for these problems is to increase the value in
> /proc/sys/vm/min_free_kbytes.

this should help a lot in my experience.

> 2.6.17 is fairly old.  If we need to do additional work on this report
> then we'll be asking you to test something more recent - ideally
> 2.6.29.

If you must run 2.6.17, then you might want to try the e1000e driver (*not 
e1000*) from sourceforge for your 82571.

Otherwise I also will be asking you to soon try a newer kernel.
