From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Wed, 2 Sep 2015 13:58:02 -0700
Message-ID: <20150902205802.GA78846@kafai-mba.local>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
 <1441133703-1570969-4-git-send-email-kafai@fb.com>
 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:6415 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755810AbbIBU6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:58:13 -0400
Content-Disposition: inline
In-Reply-To: <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> > 2. Use a spinlock to protect the dst_cache operations
>
> Well, a seqlock would be better : No need for an atomic operation in
> fast path.
>
seqlock can ensure consistency between idst->dst and idst->cookie.
However, IPv6 dst destruction is not protected by rcu.  dst_free() is
directly called, like in ip6_fib.c and a few other places.
Hence, atomic_inc_not_zero() cannot be used here because the dst may
have already been kmem_cache_free() when refcnt is 0.  A spinlock is
needed to stop the ip6_tnl_dst_set() side from removing the refcnt.
