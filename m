From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: include/linux/pcounter.h
Date: Fri, 15 Feb 2008 19:37:11 -0800
Message-ID: <20080215193711.2e3d41f3.akpm@linux-foundation.org>
References: <20080204014402.1c55d3fe.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50947 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752939AbYBPDhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 22:37:52 -0500
In-Reply-To: <20080204014402.1c55d3fe.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


- First up, why was this added at all?  We have percpu_counter.h which
  has several years development invested in it.  afaict it would suit the
  present applications of pcounters.

  If some deficiency in percpu_counters has been identified, is it
  possible to correct that deficiency rather than implementing a whole new
  counter type?  That would be much better.

- The comments in pcounter.h appear to indicate that there is a
  performance advantage (and we infer that the advantage is when the
  statically-allocated flavour of pcounters is used).  When compared with
  percpu_counters the number of data-reference indirections is the same as
  with percpu_counters, so no advantage there.

  And, bizarrely, because of a quite inappropriate abstraction toy, both
  flavours of pcounters add an indirect function call which I believe is
  significantly more expensive than a plain old pointer indirection.

  So it's quite possible that DEFINE_PCOUNTER-style counters consume more
  memory and are slower than percpu_counters.  They will surely be much
  slower on the read side.  More below.

  If we really want to put some helper wrappers around
  DEFINE_PER_CPU(s32) then I'd suggest that we should do that as a
  standalone thing and not attempt to graft the same interface onto two
  quite different types of storage (DEFINE_PER_CPU and alloc_per_cpu)

- The comment "2)" in pcounter.h (which overflows 80 cols and probably
  wasn't passed through checkpatch) indicates that some other
  implementation (presumably plain old DEFINE_PER_CPU) will use
  NR_CPUS*(32+sizeof(void *)) bytes of storage.  But DEFINE_PCOUNTER will
  use as much memory as DEFINE_PER_CPU(s32) and both pcounter_alloc()-style
  pcounters and percpu_counters use
  num_possible_cpus()*sizeof(s32)+epsilon.

- The CONFIG_SMP=n stubs in pcounter.h are cheesy and are vulnerable to
  several well-known compilation risks which I always forget.  Should be
  converted to regular static inlines.

- the comment in lib/pcounter.c needlessly exceeds 80 cols.

- pcounter_dyn_add() will spew a
  use-of-smp_processor_id()-in-preemptible-code warning if used in places
  where one could reasonably use it.  The interface could do with a bit of
  a rethink.  Or at least some justification and documentation.

- pcounter_getval() will be disastrously inefficient if
  num_possible_cpus() is much greater than num_online_cpus().  It should
  use for_each_online_cpu() (as does percpu_counter), and implement a CPU
  hotplug notifier (as does percpu_counter).

  It will remain grossly inefficient at high CPU counts, unlike
  percpu_counters, which solved this problem by doing a batched spill into
  a central counter at add/sub time.

  The danger here is that someone will actually use this interface in new
  code.  Six months later (when it's too late to fix it) the big-NUMA guys
  come up and say "whaa, when our user does <this> it disabled interrupts
  for N milliseconds".

- pcounter_getval() can return incorrect negative numbers.  This can
  cause caller malfunctions in very rare situations because callers just
  don't expect the things which they're counting to go negative.

  We experienced this during the evolution of percpu_counter.  See
  percpu_counter_sum_positive() and friends.

- pcounter_alloc() should return -ENOMEM on allocation error, not "1".

- pcounter_free() perhaps shouldn't test for (self->per_cpu_values !=
  NULL), because callers shouldn't be calling it if pcounter_alloc() failed
  (arguable).



afaict the whole implementation can and should be removed and replaced with
percpu_counters.  I don't think there's much point in its ability to manage
DEFINE_PER_CPU counters: pcounter_getval() remains grossly inefficient (and
can return negative values) and quite a bit of new code will need to be put
in place to address that.

But perhaps there are plans to evolve it into something further in the
future, I don't know.  But I would suggest that the people who have worked
upon percpu_counters (principally Gautham, Peter Z, clameter and me) be
involved in that work.

