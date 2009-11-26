From: Andi Kleen <andi@firstfloor.org>
Subject: Re: how expensive are mallocs?
Date: Thu, 26 Nov 2009 23:25:27 +0100
Message-ID: <877htc6i08.fsf@basil.nowhere.org>
References: <c0a09e5c0911240957x45abfb26k1611e53f435e5179@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33713 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbZKZWZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 17:25:23 -0500
In-Reply-To: <c0a09e5c0911240957x45abfb26k1611e53f435e5179@mail.gmail.com> (Andrew Grover's message of "Tue, 24 Nov 2009 09:57:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Grover <andy.grover@gmail.com> writes:

> How much effort generally makes sense to avoid mallocs? For example,

The slab allocators are very optimized, with a fast path for
allocation and freeing that's essentially "disable interrupts ; 
unlink object from a list ; reenable". That's not expensive
(unless you're running on a CPU where disabling interrupts is)

The main costs in them come when you free objects on a different CPU
(or worse node) than where you allocate them. In that case you can end
up with some bounced cache lines, which are slow. If you can avoid
that you're good. If you can't even then you would need to make major
effort to do better.

> Also, RDS has its own per-cpu page remainder allocator (see
> net/rds/page.c) for kernel send buffers. Would cutting this code and
> just using kmalloc be recommended? Doesn't SL?B already do per-cpu
> pools?

Slab is all per cpu in the fast path, but see above.

> Does this stuff even matter enough to rise above the noise in benchmarks?

Yes it does in some circumstances, but it's hard to do better.

One example of doing better for special circumstances would be Eric's
rps work, but doing these things is not easy and only worth it
for really critical cases.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
