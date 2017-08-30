From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Question about ip_defrag
Date: Wed, 30 Aug 2017 12:58:43 +0200
Message-ID: <20170830125843.250c91c1@redhat.com>
References: <4F88C5DDA1E80143B232E89585ACE27D018F07E2@DGGEMA502-MBX.china.huawei.com>
        <20170824155300.1e577dae@redhat.com>
        <4F88C5DDA1E80143B232E89585ACE27D018F0AE1@DGGEMA502-MBX.china.huawei.com>
        <20170824205926.2c45e3a1@redhat.com>
        <4F88C5DDA1E80143B232E89585ACE27D018F3157@DGGEMA502-MBX.china.huawei.com>
        <20170828140032.GB12926@breakpoint.cc>
        <20170829092021.0a46fffa@redhat.com>
        <20170829075315.GA9993@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "liujian (CE)" <liujian56@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>, brouer@redhat.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44966 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751263AbdH3K66 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 06:58:58 -0400
In-Reply-To: <20170829075315.GA9993@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(trimmed CC list a bit)

On Tue, 29 Aug 2017 09:53:15 +0200 Florian Westphal <fw@strlen.de> wrote:

> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > On Mon, 28 Aug 2017 16:00:32 +0200
> > Florian Westphal <fw@strlen.de> wrote:
> >   
> > > liujian (CE) <liujian56@huawei.com> wrote:  
> > > > Hi
> > > > 
> > > > I checked our 3.10 kernel, we had backported all percpu_counter
> > > > bug fix in lib/percpu_counter.c and include/linux/percpu_counter.h.
> > > > And I check 4.13-rc6, also has the issue if NIC's rx cpu num big enough.
> > > >     
> > > > > > > > the issue:
> > > > > > > > Ip_defrag fail caused by frag_mem_limit reached 4M(frags.high_thresh).
> > > > > > > > At this moment,sum_frag_mem_limit is about 10K.    
> > > > 
> > > > So should we change ipfrag high/low thresh to a reasonable value ? 
> > > > And if it is, is there a standard to change the value?    
> > > 
> > > Each cpu can have frag_percpu_counter_batch bytes rest doesn't know
> > > about so with 64 cpus that is ~8 mbyte.
> > > 
> > > possible solutions:
> > > 1. reduce frag_percpu_counter_batch to 16k or so
> > > 2. make both low and high thresh depend on NR_CPUS  
> 
> I take 2) back.  Its wrong to do this, for large NR_CPU values it
> would even overflow.

Alternatively solution 3:
Why do we want to maintain a (4MBytes) memory limit, across all CPUs?
Couldn't we just allow each CPU to have a memory limit?


> > To me it looks like we/I have been using the wrong API for comparing
> > against percpu_counters.  I guess we should have used __percpu_counter_compare().  
> 
> Are you sure?  For liujian use case (64 cores) it looks like we would
> always fall through to percpu_counter_sum() so we eat spinlock_irqsave
> cost for all compares.
> 
> Before we entertain this we should consider reducing frag_percpu_counter_batch
> to a smaller value.

Yes, I agree, we really need to lower/reduce the frag_percpu_counter_batch.
As you say, else the __percpu_counter_compare() call will be useless
(around systems with >= 32 CPUs).

I think the bug is in frag_mem_limit().  It just reads the global
counter (fbc->count), without considering other CPUs can have upto 130K
that haven't been subtracted yet (due to 3M low limit, become dangerous
at >=24 CPUs).  The  __percpu_counter_compare() does the right thing,
and takes into account the number of (online) CPUs and batch size, to
account for this.

If we choose 16K (16384), and use __percpu_counter_compare(), then we
can scale to systems with 256 CPUs (4*1024*1024/16384=256), before this
memory accounting becomes more expensive (than not using percpu_counters).
But Liujian, reports he have a 384 CPU system, so he would still need
to increase the lower+high threshold.


$ grep -H .  /proc/sys/net/ipv*/ip*frag_*_thresh /proc/sys/net/netfilter/nf_conntrack_frag6_*_thresh
/proc/sys/net/ipv4/ipfrag_high_thresh:4194304
/proc/sys/net/ipv4/ipfrag_low_thresh:3145728
/proc/sys/net/ipv6/ip6frag_high_thresh:4194304
/proc/sys/net/ipv6/ip6frag_low_thresh:3145728
/proc/sys/net/netfilter/nf_conntrack_frag6_high_thresh:4194304
/proc/sys/net/netfilter/nf_conntrack_frag6_low_thresh:3145728

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
