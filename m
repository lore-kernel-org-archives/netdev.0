From: Florian Westphal <fw@strlen.de>
Subject: Re: Question about ip_defrag
Date: Wed, 30 Aug 2017 13:58:20 +0200
Message-ID: <20170830115820.GC9993@breakpoint.cc>
References: <4F88C5DDA1E80143B232E89585ACE27D018F07E2@DGGEMA502-MBX.china.huawei.com>
 <20170824155300.1e577dae@redhat.com>
 <4F88C5DDA1E80143B232E89585ACE27D018F0AE1@DGGEMA502-MBX.china.huawei.com>
 <20170824205926.2c45e3a1@redhat.com>
 <4F88C5DDA1E80143B232E89585ACE27D018F3157@DGGEMA502-MBX.china.huawei.com>
 <20170828140032.GB12926@breakpoint.cc>
 <20170829092021.0a46fffa@redhat.com>
 <20170829075315.GA9993@breakpoint.cc>
 <20170830125843.250c91c1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "liujian (CE)" <liujian56@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34002 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751317AbdH3MBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:01:11 -0400
Content-Disposition: inline
In-Reply-To: <20170830125843.250c91c1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > I take 2) back.  Its wrong to do this, for large NR_CPU values it
> > would even overflow.
> 
> Alternatively solution 3:
> Why do we want to maintain a (4MBytes) memory limit, across all CPUs?
> Couldn't we just allow each CPU to have a memory limit?

Consider ipv4, ipv6, nf ipv6 defrag, 6lowpan, and 8k cpus... This will
render any limit useless.

> > > To me it looks like we/I have been using the wrong API for comparing
> > > against percpu_counters.  I guess we should have used __percpu_counter_compare().  
> > 
> > Are you sure?  For liujian use case (64 cores) it looks like we would
> > always fall through to percpu_counter_sum() so we eat spinlock_irqsave
> > cost for all compares.
> > 
> > Before we entertain this we should consider reducing frag_percpu_counter_batch
> > to a smaller value.
> 
> Yes, I agree, we really need to lower/reduce the frag_percpu_counter_batch.
> As you say, else the __percpu_counter_compare() call will be useless
> (around systems with >= 32 CPUs).
> 
> I think the bug is in frag_mem_limit().  It just reads the global
> counter (fbc->count), without considering other CPUs can have upto 130K
> that haven't been subtracted yet (due to 3M low limit, become dangerous
> at >=24 CPUs).  The  __percpu_counter_compare() does the right thing,
> and takes into account the number of (online) CPUs and batch size, to
> account for this.

Right, I think we should at very least use __percpu_counter_compare
before denying a new frag queue allocation request.

I'll create a patch.
