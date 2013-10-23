From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: -27% netperf TCP_STREAM regression by "tcp_memcontrol: Kill
 struct tcp_memcontrol"
Date: Wed, 23 Oct 2013 14:25:43 +0200
Message-ID: <20131023122543.GH5132@cpaasch-mac>
References: <20131022214129.GB2715@localhost>
 <20131022.180023.1141845387743361648.davem@davemloft.net>
 <87k3h461ql.fsf@tw-ebiederman.twitter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fengguang.wu@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87k3h461ql.fsf@tw-ebiederman.twitter.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 22/10/13 - 21:38:10, Eric W. Biederman wrote:
> David Miller <davem@davemloft.net> writes:
> > From: fengguang.wu@intel.com
> > Date: Tue, 22 Oct 2013 22:41:29 +0100
> >
> >> We noticed big netperf throughput regressions
> >> 
> >>     a4fe34bf902b8f709c63      2e685cad57906e19add7  
> >> ------------------------  ------------------------  
> >>                   707.40       -40.7%       419.60  lkp-nex04/micro/netperf/120s-200%-TCP_STREAM
> >>                  2775.60       -23.7%      2116.40  lkp-sb03/micro/netperf/120s-200%-TCP_STREAM
> >>                  3483.00       -27.2%      2536.00  TOTAL netperf.Throughput_Mbps
> >> 
> >> and bisected it to
> >> 
> >> commit 2e685cad57906e19add7189b5ff49dfb6aaa21d3
> >> Author: Eric W. Biederman <ebiederm@xmission.com>
> >> Date:   Sat Oct 19 16:26:19 2013 -0700
> >> 
> >>     tcp_memcontrol: Kill struct tcp_memcontrol
> >
> > Eric please look into this, I'd rather have a fix to apply than revert your
> > work.
> 
> Will do I expect some ordering changed, and that changed the cache line
> behavior.

may it be the below?


Cheers,
Christoph

----
From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH] Fix: Dereference pointer-value of sk_prot->memory_pressure

2e685cad57 (tcp_memcontrol: Kill struct tcp_memcontrol) falsly modified
the access to memory_pressure of sk->sk_prot->memory_pressure. The patch
did modify the memory_pressure-field of struct cg_proto, but not the one
of struct proto.

So, the access to sk_prot->memory_pressure should not be changed.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 include/net/sock.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c93542f..e3a18ff 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1137,7 +1137,7 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
        if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
                return !!sk->sk_cgrp->memory_pressure;

-       return !!sk->sk_prot->memory_pressure;
+       return !!*sk->sk_prot->memory_pressure;
 }

 static inline void sk_leave_memory_pressure(struct sock *sk)
-- 
1.8.3.2
