From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH][RFC] Infrastructure for compact call location
 representation
Date: Tue, 8 Jun 2010 08:44:56 -0700
Message-ID: <20100608084456.4da00349@nehalam>
References: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: to@dvomlehn-lnx2.corp.sa.net, netdev@vger.kernel.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48277 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753396Ab0FHPpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jun 2010 11:45:04 -0400
In-Reply-To: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jun 2010 17:30:52 -0700
David VomLehn <dvomlehn@cisco.com> wrote:

> This patch allows the location of a call to be recorded as a small integer,
> with each call location ("callsite") assigned a new value the first time
> the code in that location is executed. Locations can be recorded as a
> an address or as a __FILE__/__LINE__ pair. The later is easier to read, but
> requires significantly more space.
> 
> The goal here was to record the location in very few bits but, at the same
> time, to have minimal overhead.  The key observation towards achieving this
> goals is to note that there are are far fewer locations where calls of
> interest are made than there are addresses. If the site of each call of
> interest is assigned a unique ID, and there are fewer than n of them,
> only log2(n) bits are required to identify the call site. If the IDs
> are assigned dynamically and most call sites aren't reached, you can get
> by with even fewer bits.
> 
> This is debugging code and callsite IDs are generally only used when failures
> are detected, so though the mapping from a callsite location to a callsite ID
> must be fast, speed is not as critical for the reverse mapping. Also, an ID
> is assigned to a callsite just once, so it is acceptable to take a while to
> assign an ID, but things should run with minimal delay if an ID is already
> assigned.
> 
> The major implementation pieces are:
> 1.	Two macros are provided for use in wrapping functions that are to
> 	be instrumented. CALLSITE_CALL is for functions that return values,
> 	CALLSITE_CALL_VOID is used for functions that do not.
> 2.	The call site infrastructure consists of three data structures:
> 	a.	A statically allocated struct callsite_id holds the ID for
> 		the call site.
> 	b.	A statically allocated struct callsite_static holds
> 		information which is constant for each callsite. The call site
> 		ID could be combined with this, but by separating them I hope
> 		to avoid polluting the cache with this very cold information.
> 	c.	A struct callsite_frame builds on the oobparam infrastructure
> 		and holds the call site ID. This is assigned at this time
> 		if this had not previously been done. This will be pushed on
> 		the OOB parameter stack before calling the skb_* function
> 		and popped after it returns.
> 3.	A callsite_top structure is added to task_struct. When a call site
> 	is entered, its callsite_frame is pushed on the call site stack.
> 4.	When a function needs to know the call site ID so it can be stored,
> 	it gets it from the callsite_frame at the top of the call site
> 	stack.
> 
> Notes
> o	Under simple test conditions, the number of call site IDs allocated
> 	can be quite small, small enough to fit in 6 bits. That would reduce
> 	the sk_buff growth to one byte. This is *not* a recommended
> 	configuration.
> o	This is placed in net/core and linux/net since those are the only
> 	current users, but there is nothing about this that is networking-
> 	specific.
> 
> Restrictions
> o	Call site IDs are never reused, so it is possible to exceed the
> 	maximum number of IDs by having a large number of call locations.
> 	In addition, it does not recognize that the same module has been
> 	unloaded and reloaded, so calls from the reloaded module will be
> 	assigned new IDs. Detection of incorrect operations on an sk_buff
> 	is not affected by exhaustion of call site IDs, but it may not be
> 	possible to determine the location of the last operation.
> 	CONFIG_DEBUG_SKB_ID_SIZE is set to reduce the sk_buff growth to 16
> 	bits and should handle most cases. It could be made larger to allow
> 	more call site IDs, if necessary.
> o	The callsite structures for a module will be freed when that module
> 	is unloaded, even though sk_buffs may be using IDs corresponding to
> 	those call sites. To allow useful error reporting, the call site
> 	information in a module being unloaded is copied. If
> 	CONFIG_CALLSITE_TERSE is not enabled and the module that last changed
> 	the sk_buff is no longer loaded, the address of the call site
> 	is no longer valid, so only the function name and offset are printed
> 	if the module is unloaded. If it is loaded, the address is also
> 	reported.
> 
> History
> v2	Support small callsite IDs and split out out-of-band parameter
> 	parsing.
> V1	Initial release
> 
> Signed-off-by: David VomLehn <dvomlehn@cisco.com>

This is really Linux Kernel Mailing List material (not just netdev). And it will
be a hard sell to get it accepted, because it is basically an alternative call
tracing mechanism, and there are already several of these in use or under development
(see perf and ftrace).


-- 
