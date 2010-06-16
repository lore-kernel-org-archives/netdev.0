From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: Proposed linux kernel changes : scaling  tcp/ip stack
Date: Wed, 16 Jun 2010 12:39:05 -0700
Message-ID: <E4C28CAD-8179-4B4F-9F87-07F2D4587EC0@earthlink.net>
References: <FDFFEFAB-A741-4232-821E-17BFAE5CAFAC@earthlink.net> <1275556440.2456.19.camel@edumazet-laptop> <97746864-ED54-4A12-AFE7-752AA6E41CDD@earthlink.net> <87fx0nwdg0.fsf@basil.nowhere.org>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:54550 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754617Ab0FPTjL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 15:39:11 -0400
In-Reply-To: <87fx0nwdg0.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 16, 2010, at 2:10 AM, Andi Kleen wrote:

> Mitchell Erblich <erblichs@earthlink.net> writes:
>> 
>> Summary: Don't use last free pages for TCP ACKs with GFP_ATOMIC for our
>> sk buf allocs. 1 line change in tcp_output.c with a new gfp.h arg, and a change
>> in the generic kernel. TBD.
>> 
>> This change should have no effect with normal available kernel mem allocs.
>> 
>> Assuming memory pressure ( WAITING for clean memory) we should be allocating
>> our last pages for input skbufs and not for xmit allocs.
> 
> How about you instrument a kernel and measure if this really happens
> frequently under reasonable loads?  That is you can probably
> use the existing dropped page counters in netstat 
> Stephen added some time ago.
> 
> Since soft irqs cannot really wait exhausted GFP_ATOMIC would normally
> lead to dropped packets. FWIW I am not aware of any serious dropped
> packets problem on normal loads.
> 
> Running a kernel with nearly zero free memory is dangerous anyways
> -- pretty much any kernel service can fail arbitarily --
> if this happened frequently I suspect we would need generic
> VM solution for it.
> 
> -Andi
> 
> -- 
> ak@linux.intel.com -- Speaking for myself only.
> --

Andi Kleen and group,

I actually did instrument memory years ago an older Linux kernel for a 
multiple core system/server. Also, threw out the oom killer as a last item
when it wasn't need via a /proc value. These changes were for a now
defunct Linux OS company that built a hi-end  Linux NAS server.

In general, an increasing larger percentage of memory is cached and 
fragmented over time. So, buddy algors tend to fail if the mem is continually
held and over time smaller and smaller page order allocs fail.

The instrumenting was to be able to repeat a condition to verify
that the changes were mostly transparent and added only minimal
load when the system was experiencing a lull.

A problem found was that Linux tracks free pages and not dirty pages.

However, I am starting small and simply say that:

Can we agree that the GFP_NOWAIT is atomic, but just doesn't grab the
last pages?
#define GFP_NOWAIT	(GFP_ATOMIC & ~_GFP_HIGH)

Thus, in the general case of an atomic kernel memory consumer,
the GFP_NOWAIT SHOULD be used.

And where a safety valve to be able to clean or free kernel memory the
GFP_ATOMIC should be used.

Later, I will suggest changes changes to clean kernel memory when low
I/O is being done, so if the memory then later needs to be freed, it can be
done quickly.

Later, a /proc percentage  variable that reps a percent of memory is 
marked/saved/separated for rotating hi-order page allocs for consumers
after the system has been up for weeks/months. This work was initially
done at another UNIX company, based on an Internal public paper.


Mitchell Erblich

	
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

