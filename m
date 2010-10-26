From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Tue, 26 Oct 2010 09:29:48 -0400
Message-ID: <4CC6D7CC.5040608@cox.net>
References: <loom.20101012T185411-307@post.gmane.org>	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>	 <1287805487.2658.5.camel@edumazet-laptop>	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net> <1287851745.2658.364.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao101.cox.net ([68.230.240.7]:65486 "EHLO
	eastrmmtao101.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab0JZN3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 09:29:50 -0400
In-Reply-To: <1287851745.2658.364.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> With a normal workload, on a dual cpu machine, a missing memory barrier
> can stay un-noticed for quite a long time. The race window is so small
> that probability for the bug might be 0.0000001 % or something like
> that :(

I'm looking at the LINUX source at the moment and not liking what I see
in include/asm-mips/barrier.h:

#define smp_mb()	__asm__ __volatile__(__WEAK_ORDERING_MB : : :"memory")
#ifdef CONFIG_CPU_CAVIUM_OCTEON
#define smp_rmb()	barrier()
#define smp_wmb()	barrier()
#else
#define smp_rmb()	__asm__ __volatile__(__WEAK_ORDERING_MB : : :"memory")
#define smp_wmb()	__asm__ __volatile__(__WEAK_ORDERING_MB : : :"memory")
#endif

The Octeon documentation explicitly says that neither loads nor stores
need execute in program order, so the definitions for smp_rmb and
smp_wmb appear to be wrong wrong wrong.

It appears that smp_wmb should be making use of SYNCW and smp_rmb should
be making use of SYNC.

Should I pursue this question on the main LINUX kernel list?

Joe Buehler
