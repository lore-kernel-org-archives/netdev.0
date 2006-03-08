From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 2/4] net: percpufy frequently used vars -- struct proto.memory_allocated
Date: Tue, 7 Mar 2006 19:08:03 -0800
Message-ID: <20060308030803.GF9062@localhost.localdomain>
References: <20060308015808.GA9062@localhost.localdomain> <20060308020118.GC9062@localhost.localdomain> <20060307181422.3e279ca1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964889AbWCHDHY@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060307181422.3e279ca1.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 07, 2006 at 06:14:22PM -0800, Andrew Morton wrote:
> Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> >
> > -	if (atomic_read(sk->sk_prot->memory_allocated) < sk->sk_prot->sysctl_mem[0]) {
> >  +	if (percpu_counter_read(sk->sk_prot->memory_allocated) <
> >  +			sk->sk_prot->sysctl_mem[0]) {
> 
> Bear in mind that percpu_counter_read[_positive] can be inaccurate on large
> CPU counts.
> 
> It might be worth running percpu_counter_sum() to get the exact count if we
> think we're about to cause something to fail.

The problem is percpu_counter_sum has to read all the cpus cachelines.  If
we have to use percpu_counter_sum everywhere, then might as well use plain
per-cpu counters instead of  batching ones no?
 
sysctl_mem[0] is about 196K  and on a 16 cpu box variance is 512 bytes, which 
is OK with just percpu_counter_read I hope.  Maybe, on very large cpu counts, 
we should just change the FBC_BATCH so that variance does not go quadratic.
Something like 32.  So that variance is 32 * NR_CPUS in that case, instead
of (NR_CPUS * NR_CPUS * 2) currently.  Comments?
