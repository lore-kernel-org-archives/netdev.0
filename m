From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net/qdisc: IFF_NO_QUEUE drivers should use
 consistent TX queue len
Date: Fri, 4 Nov 2016 11:56:52 +0100
Message-ID: <20161104115652.597b8067@redhat.com>
References: <20161103135534.28737.37657.stgit@firesoul>
        <20161103135606.28737.67383.stgit@firesoul>
        <20161103205440.GB2940@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>,
        Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55016 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761803AbcKDK45 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:56:57 -0400
In-Reply-To: <20161103205440.GB2940@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Nov 2016 13:54:40 -0700
Krister Johansen <kjlx@templeofstupid.com> wrote:

> On Thu, Nov 03, 2016 at 02:56:06PM +0100, Jesper Dangaard Brouer wrote:
> > The flag IFF_NO_QUEUE marks virtual device drivers that doesn't need a
> > default qdisc attached, given they will be backed by physical device,
> > that already have a qdisc attached for pushback.
> > 
> > It is still supported to attach a qdisc to a IFF_NO_QUEUE device, as
> > this can be useful for difference policy reasons (e.g. bandwidth
> > limiting containers).  For this to work, the tx_queue_len need to have
> > a sane value, because some qdiscs inherit/copy the tx_queue_len
> > (namely, pfifo, bfifo, gred, htb, plug and sfb).
> > 
> > Commit a813104d9233 ("IFF_NO_QUEUE: Fix for drivers not calling
> > ether_setup()") caught situations where some drivers didn't initialize
> > tx_queue_len.  The problem with the commit was choosing 1 as the
> > fallback value.
> > 
> > A qdisc queue length of 1 causes more harm than good, because it
> > creates hard to debug situations for userspace. It gives userspace a
> > false sense of a working config after attaching a qdisc.  As low
> > volume traffic (that doesn't activate the qdisc policy) works,
> > like ping, while traffic that e.g. needs shaping cannot reach the
> > configured policy levels, given the queue length is too small.  
> 
> Thanks for fixing this.  I've run into this in the exact scenario you
> describe -- bandwith limiting containers.  I'm pretty sure my vote
> doesn't count, but I'm in favor of this change.

Thanks for confirming the problem. You voice is actually very important
in matters like this. It is important to know if people were actually
hit by this.

My own story is that I was hit by this subtle queue length 1 problem
approx 11 years ago without noticing.  An ISP were doing qdisc shaping
(with HTB) on VLAN devices.  The original guy who developed the system
were fired because Internet customers were not getting the bandwidth
they paid for.  I were hired to fix the problem, and unknowingly fixed
it (and bufferbloat) by using SFQ instead of pfifo_fast as leaf qdisc.
I actually didn't realize the root-cause until Oct 2014, see[1].
(I also ended-up fixing other scalability issues in iptables[2])

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://bugzilla.redhat.com/show_bug.cgi?id=1152231
[2] http://people.netfilter.org/hawk/presentations/osd2008/
