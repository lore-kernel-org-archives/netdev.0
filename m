From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH] net: frag limit checks need to use
 percpu_counter_compare
Date: Fri, 1 Sep 2017 09:16:41 +0200
Message-ID: <20170901091641.4c62af06@redhat.com>
References: <150417481955.28907.15567119824187929000.stgit@firesoul>
        <20170831162349.k3qnkfgkygdh2zqw@unicorn.suse.cz>
        <4F88C5DDA1E80143B232E89585ACE27D018F6A9B@DGGEMA502-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>, brouer@redhat.com
To: "liujian (CE)" <liujian56@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41378 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751237AbdIAHQr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 03:16:47 -0400
In-Reply-To: <4F88C5DDA1E80143B232E89585ACE27D018F6A9B@DGGEMA502-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 1 Sep 2017 02:25:32 +0000 "liujian (CE)" <liujian56@huawei.com> wrote:

> > -----Original Message-----
> > From: Michal Kubecek [mailto:mkubecek@suse.cz]
> > Sent: Friday, September 01, 2017 12:24 AM
> > To: Jesper Dangaard Brouer
> > Cc: liujian (CE); netdev@vger.kernel.org; Florian Westphal
> > Subject: Re: [RFC PATCH] net: frag limit checks need to use
> > percpu_counter_compare
> > 
> > On Thu, Aug 31, 2017 at 12:20:19PM +0200, Jesper Dangaard Brouer wrote:  
> > > To: Liujian can you please test this patch?
> > >  I want to understand if using __percpu_counter_compare() solves  the
> > > problem correctness wise (even-though this will be slower  than using
> > > a simple atomic_t on your big system).  
> 
> I have test the patch, it can work. 

Thanks for confirming this.

> 1. make sure frag_mem_limit reach to thresh
>   ===>FRAG: inuse 0 memory 0 frag_mem_limit 5386864  
> 2. change NIC rx irq's affinity to a fixed CPU

If you pin the NIC RX queue to a single CPU, then the error issue
basically cannot happen.  Different CPU need to have a chance to "own"
part of the percpu_counter.  I guess default setup with irqbalance
could eventually screw the percpu_counter enough given enough CPUs, or
a network load with enough different L2-headers to high different RX
queues.

> 3. iperf -u -c 9.83.1.41 -l 10000 -i 1 -t 1000 -P 10 -b 20M
>   And check /proc/net/snmp, there are no ReasmFails.

My quick check command is:
 nstat > /dev/null && sleep 1 && nstat && grep FRAG /proc/net/sockstat

> And I think it is a better way that adding some counter sync points
> as you said.

I've discussed this offlist with Florian, while it is doable, we are
adding too much complexity for something that can be solved much
simpler with an atomic_t (as before my patch).  Thus, I'm now looking
at reverting my original change (commit 6d7b857d541e ("net: use
lib/percpu_counter API for fragmentation mem accounting")).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
