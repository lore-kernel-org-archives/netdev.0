From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH] ipv4: FIB Local/MAIN table collapse
Date: Wed, 11 Mar 2015 09:23:48 -0700
Message-ID: <55006C14.6030209@redhat.com>
References: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>	<55005829.5050406@gmail.com> <CAA93jw5GR_Mgx8rmrMmOLXsmeW2xsCy=5xYyzOiEFHAtY=mFeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>
To: Dave Taht <dave.taht@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbbCKQX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 12:23:57 -0400
In-Reply-To: <CAA93jw5GR_Mgx8rmrMmOLXsmeW2xsCy=5xYyzOiEFHAtY=mFeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2015 09:03 AM, Dave Taht wrote:
> On Wed, Mar 11, 2015 at 7:58 AM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On 03/06/2015 01:47 PM, Alexander Duyck wrote:
>>> This patch is meant to collapse local and main into one by converting
>>> tb_data from an array to a pointer.  Doing this allows us to point the
>>> local table into the main while maintaining the same variables in the
>>> table.
>>>
>>> As such the tb_data was converted from an array to a pointer, and a new
>>> array called data is added in order to still provide an object for tb_data
>>> to point to.
>>>
>>> In order to track the origin of the fib aliases a tb_id value was added in
>>> a hole that existed on 64b systems.  Using this we can also reverse the
>>> merge in the event that custom FIB rules are enabled.
>>>
>>> With this patch I am seeing an improvement of 20ns to 30ns for routing
>>> lookups as long as custom rules are not enabled, with custom rules enabled
>>> we fall back to split tables and the original behavior.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>>> ---
>>>
>>> Changes since the RFC:
>>>    Added tb_id value so I could split main and local for custom rules
>>>    Added functionality to split tables if custom rules were enabled
>>>    Added table replacement and unmerge functions
>>>
>>> I have done some testing on this to verify performance gains and that I can
>>> split the tables correctly when I enable custom rules, but this patch is
>>> what I would consider to be high risk since I am certain there are things I
>>> have not considered.
>>>
>>> If this gets pulled into someone's switchdev tree instead of into net-next I
>>> would be perfectly fine with that as I am sure this can use some additional
>>> testing.
>> Has anyone out there had a chance to review this patch?  I had suggested
>> holding off on applying it to net-next for additional testing, but I
>> haven't found anything, and the only related issue is the one issue
>> Sabrina reported for the RTNL locking which was already in net-next anyway.
>
> My environment consists largely of 32 bit routing platforms (openwrt)
> running the current homenet routing protocol (babel), using, in
> particular, the babeld source specific routing extensions ( see
> http://arxiv.org/pdf/1403.0445v3.pdf  ) which do use multiple routing
> tables, and other uncommon things like p2p routes and odd netmasks
> like /27 and /30.

Can you define "use multiple routing tables"?  If you are adding other 
routing tables than local/main and adding custom rules to determine the 
order then this latest patch should automatically be switched off.  This 
patch only applies to the case where custom rules are not enabled, 
otherwise it splits the tables and you are right back to two tables one 
for local and one for main.

This patch is based on work Dave Miller originally sent me to merge the 
tables for local/main in order to improve performance in the standard 
end user case.  As far as Quagga and such I am not that familiar with 
how they configure the tables so I cannot say if there is a performance 
gain available or not.

> But: I simply can't keep up with you and this entire patchset changes
> so dramatically how routing works that you make me nervous. I would
> like to see quagga (and babeld) improved to use atomic updates in
> particular (They do a delete + add for no good reason), and for
> protocols like ospf, bgp, etc, to be actively tested on real traffic
> loads on live data against this entire patchset.

Yeah, looking back on it I probably shouldn't have sat on my patches for 
an entire release cycle before pushing them but as it was I was trying 
to stretch things out over two releases.  As far as Quagga and such that 
is several levels above this work as I have no idea about the internals 
of the user space routing daemons.

> Your 64 bit x86 benchmarks are very exciting and I do look forward to
> one day soon attempting to evaluate and benchmark these changes on
> teeny 32 bit platforms both in the general case and in this
> environment, and am mostly just hoping that others that are doing
> higher end real world routing with big tables (such as BGP) are paying
> more attention than I can.

Merging the two tables is one of the requests that came out of netconf 
this year.  I hadn't anticipated the amount of improvement that I have 
seen, though it makes sense since we are essentially reducing the memory 
utilization significantly as we reduce the backtrace and main table 
look-up to something like one tnode since in the case of most /24 
subnets you only have 3 or 4 addresses that are tracked in the trie and 
the route from main will usually just end up overlapping with the .0 
broadcast address.

> What test procedures are you using at present (and what is everyone else using)?

What I have been doing is mostly performance testing for different 
portions of the trie, performance of shortest path to find a match, 
performance of longest path to find a match, load/unload/reload 
interface, insert/delete route or address, dumping route, fib_trie, and 
fib_triestat, and with this most recent patch adding custom rules to 
force the tables to split.

- Alex
