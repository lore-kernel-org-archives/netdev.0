From: David Miller <davem@davemloft.net>
Subject: Re: [nf-next PATCH 0/5] (repost) netfilter: conntrack:
 optimization, remove central spinlock
Date: Thu, 27 Feb 2014 18:34:15 -0500 (EST)
Message-ID: <20140227.183415.788592676169519032.davem@davemloft.net>
References: <20140227182220.25907.12758.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, netdev@vger.kernel.org, fw@strlen.de,
	kaber@trash.net
To: brouer@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140227182220.25907.12758.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 27 Feb 2014 19:23:24 +0100

> (Repost to netfilter-devel list)
> 
> This patchset change the conntrack locking and provides a huge
> performance improvements.
> 
> This patchset is based upon Eric Dumazet's proposed patch:
>   http://thread.gmane.org/gmane.linux.network/268758/focus=47306
> I have in agreement with Eric Dumazet, taken over this patch (and
> turned it into a entire patchset).
> 
> Primary focus is to remove the central spinlock nf_conntrack_lock.
> This requires several steps to be acheived.

I only worry about the raw_smp_processor_id()'s.

If preemption will be disabled in these contexts, then it's safe and
we can just use plain smp_processor_id().

If preemption is not necessarily disabled in these spots, the use
is not correct.  We'll need to use get_cpu/put_cpu sequences, or
(considering what these patches are doing) something like:

	struct ct_pcpu *pcpu;

	/* add this conntrack to the (per cpu) unconfirmed list */
	local_bh_disable();
	ct->cpu = smp_processor_id();
	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);

	spin_lock(&pcpu->lock);
	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
			     &pcpu->unconfirmed);
	spin_unlock_bh(&pcpu->lock);
