From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 21 Jan 2009 03:21:23 -0800
Message-ID: <m1fxjcucp8.fsf@fess.ebiederm.org>
References: <20090115183942.GA6325@elte.hu>
	<200901170827.33729.rusty@rustcorp.com.au>
	<20090116220832.GB20653@elte.hu>
	<200901201328.24605.rusty@rustcorp.com.au>
	<20090120104022.GB29346@elte.hu> <4976B82E.1080002@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757181AbZAULWF@vger.kernel.org>
In-Reply-To: <4976B82E.1080002@kernel.org> (Tejun Heo's message of "Wed\, 21 Jan 2009 14\:52\:46 +0900")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tejun Heo <tj@kernel.org> writes:

> Ingo Molnar wrote:
>> The larger point still remains: the kernel dominantly uses static percpu 
>> variables by a margin of 10 to 1, so we cannot just brush away the static 
>> percpu variables and must concentrate on optimizing that side with 
>> priority. It's nice if the dynamic percpu-alloc side improves as well, of 
>> course.
>
> Well, the infrequent usage of dynamic percpu allocation is in some
> part due to the poor implementation, so it's sort of chicken and egg
> problem.  I got into this percpu thing because I wanted a percpu
> reference count which can be dynamically allocated and it sucked.

Counters are our other special case, and counters are interesting
because they are individually very small.  I just looked and the vast
majority of the alloc_percpu users are counters.

I just did a rough count in include/linux/snmp.h  and I came
up with 171*2 counters.  At 8 bytes per counter that is roughly
2.7K.  Or about two thirds of a 4K page.

What makes this is a challenge is that those counters are per network
namespace, and there are no static limits on the number of network
namespaces.

If we push the system and allocate 1024 network namespaces we wind up
needing 2.7MB per cpu, just for the SNMP counters.  

Which nicely illustrates the principle that typically each individual
per cpu allocation is small, but with dynamic allocation we have the
challenge that number of allocations becomes unbounded and in some cases
could be large, while the typical per cpu size is likely to be very small.

I wonder if for the specific case of counters it might make sense to
simply optimize the per cpu allocator for machine word size allocations
and allocate each counter individually freeing us from the burden of
worrying about fragmentation.


The pain with the current alloc_percpu implementation when working
with counters is that it has to allocate an array with one entry
for each cpu to point at the per cpu data.  Which isn't especially efficient.


Eric
