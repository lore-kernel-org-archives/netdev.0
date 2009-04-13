From: Reeve Yang <reeve.yang@gmail.com>
Subject: Re: [Bugme-new] [Bug 13084] New: page allocation failure. order:0,
	mode:0x20
Date: Mon, 13 Apr 2009 13:11:46 -0700
Message-ID: <3b279e3f0904131311p101d1ca5k67a6dda2da1bfe14@mail.gmail.com>
References: <bug-13084-10286@http.bugzilla.kernel.org/>
	 <20090413124228.be31e9f3.akpm@linux-foundation.org>
	 <alpine.WNT.2.00.0904131255580.732@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f117.google.com ([209.85.221.117]:44973 "EHLO
	mail-qy0-f117.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbZDMUUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 16:20:05 -0400
Received: by qyk15 with SMTP id 15so51586qyk.33
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2009 13:20:03 -0700 (PDT)
In-Reply-To: <alpine.WNT.2.00.0904131255580.732@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the memory snapshot when problem happening:

MemTotal:      8307844 kB
MemFree:       6091208 kB
Buffers:          6524 kB
Cached:        1121528 kB
SwapCached:          0 kB
Active:        1361052 kB
Inactive:        25784 kB
HighTotal:     7470464 kB
HighFree:      6083688 kB
LowTotal:       837380 kB
LowFree:          7520 kB
SwapTotal:     2047992 kB
SwapFree:      2047992 kB
Dirty:          744488 kB
Writeback:           0 kB
Mapped:         285532 kB
Slab:           797500 kB
CommitLimit:   6201912 kB
Committed_AS:   459788 kB
PageTables:       3532 kB
VmallocTotal:   118776 kB
VmallocUsed:      2432 kB
VmallocChunk:   116084 kB

You can see I have lots of physical RAM available. The LowFree
reduction rate is about 10M/Second.

On Mon, Apr 13, 2009 at 1:06 PM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
> On Mon, 13 Apr 2009, Andrew Morton wrote:
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Mon, 13 Apr 2009 19:27:27 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>> > http://bugzilla.kernel.org/show_bug.cgi?id=13084
>> >
>> >            Summary: page allocation failure. order:0, mode:0x20
>> >            Product: Memory Management
>> >            Version: 2.5
>> >     Kernel Version: 2.6.17.4
>> >           Platform: All
>> >         OS/Version: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: high
>> >           Priority: P1
>> >          Component: Page Allocator
>> >         AssignedTo: akpm@linux-foundation.org
>> >         ReportedBy: reeve.yang@gmail.com
>> >         Regression: No
>> >
>> >
>> > Created an attachment (id=20964)
>> >  --> (http://bugzilla.kernel.org/attachment.cgi?id=20964)
>> > kernel config file.
>> >
>> > The system is Intel Xeon Quad core with 8G physical RAM. When it's under UPD
>> > loads, e.g., DNS queries, the box is stuck in terms it cannot be pinged or
>> > login. By checking syslog, I'm seeing following trace back from various
>> > dameon/processes. The network controller is E1000 82571 with NAPI enabled in
>> > kernel.
>> >
>> > page allocation failure. order:0, mode:0x20
>>
>> This is very common.  e1000 attempts to do large memory allocations
>> from within interrupt context and the page allocator cannot satisfy the
>> allocation and is not allowed to do the necessary work to make the
>> allocation attempt succeed.  It's the same with all net drivers, but
>> e1000 is especially prone, apparently because of hardware suckiness.
>
> while in jumbo mode, andrew's statement is true, but with order:0
> allocation failures it is just normal networking goo that causes the
> memory allocator to run out of free pages, seems much less frequent in
> newer kernels.
>
>> However the networking stack should just drop the packet and the system
>> will recover.
>
> I think at that point the kernel gets quite busy printing warnings about
> how much it is out of memory.
>
>> You report is unclear.  Yes, the machine wedges up under the UDP load.
>> But does it recover when the other machine stops spraying UDP packets
>> at this machine?  It _should_ recover.  If it does not, we have a bug
>> somewhere.
>
> In this case kmem_cache_alloc is failing to get memory, being called by
> the route_dst code, maybe someone on netdev can comment if this has been
> fixed along the way.
>
>> The usual workaround for these problems is to increase the value in
>> /proc/sys/vm/min_free_kbytes.
>
> this should help a lot in my experience.
>
>> 2.6.17 is fairly old.  If we need to do additional work on this report
>> then we'll be asking you to test something more recent - ideally
>> 2.6.29.
>
> If you must run 2.6.17, then you might want to try the e1000e driver (*not
> e1000*) from sourceforge for your 82571.
>
> Otherwise I also will be asking you to soon try a newer kernel.
>
