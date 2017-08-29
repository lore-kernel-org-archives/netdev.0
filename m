From: Florian Westphal <fw@strlen.de>
Subject: Re: Question about ip_defrag
Date: Tue, 29 Aug 2017 09:53:15 +0200
Message-ID: <20170829075315.GA9993@breakpoint.cc>
References: <4F88C5DDA1E80143B232E89585ACE27D018F07E2@DGGEMA502-MBX.china.huawei.com>
 <20170824155300.1e577dae@redhat.com>
 <4F88C5DDA1E80143B232E89585ACE27D018F0AE1@DGGEMA502-MBX.china.huawei.com>
 <20170824205926.2c45e3a1@redhat.com>
 <4F88C5DDA1E80143B232E89585ACE27D018F3157@DGGEMA502-MBX.china.huawei.com>
 <20170828140032.GB12926@breakpoint.cc>
 <20170829092021.0a46fffa@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "liujian (CE)" <liujian56@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:55342 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751191AbdH2H4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 03:56:13 -0400
Content-Disposition: inline
In-Reply-To: <20170829092021.0a46fffa@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> On Mon, 28 Aug 2017 16:00:32 +0200
> Florian Westphal <fw@strlen.de> wrote:
> 
> > liujian (CE) <liujian56@huawei.com> wrote:
> > > Hi
> > > 
> > > I checked our 3.10 kernel, we had backported all percpu_counter bug fix in lib/percpu_counter.c and include/linux/percpu_counter.h.
> > > And I check 4.13-rc6, also has the issue if NIC's rx cpu num big enough.
> > >   
> > > > > > > the issue:
> > > > > > > Ip_defrag fail caused by frag_mem_limit reached 4M(frags.high_thresh).
> > > > > > > At this moment,sum_frag_mem_limit is about 10K.  
> > > 
> > > So should we change ipfrag high/low thresh to a reasonable value ? 
> > > And if it is, is there a standard to change the value?  
> > 
> > Each cpu can have frag_percpu_counter_batch bytes rest doesn't know
> > about so with 64 cpus that is ~8 mbyte.
> > 
> > possible solutions:
> > 1. reduce frag_percpu_counter_batch to 16k or so
> > 2. make both low and high thresh depend on NR_CPUS

I take 2) back.  Its wrong to do this, for large NR_CPU values it
would even overflow.

> To me it looks like we/I have been using the wrong API for comparing
> against percpu_counters.  I guess we should have used __percpu_counter_compare().

Are you sure?  For liujian use case (64 cores) it looks like we would
always fall through to percpu_counter_sum() so we eat spinlock_irqsave
cost for all compares.

Before we entertain this we should consider reducing frag_percpu_counter_batch
to a smaller value.
