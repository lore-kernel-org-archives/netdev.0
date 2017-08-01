From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] net ipv6: convert fib6_table rwlock to a percpu
 lock
Date: Tue, 01 Aug 2017 00:15:03 -0700
Message-ID: <1501571703.1876.24.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1a5ad2f0585aa66496b27e123d1c38b75552df4c.1501520674.git.shli@fb.com>
         <20170731161007.61c2d958@xeon-e3>
         <20170801025704.fuhxll23d3eenwrz@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>, Wei Wang <weiwan@google.com>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35325 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdHAHPG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 03:15:06 -0400
Received: by mail-wr0-f193.google.com with SMTP id c24so601268wra.2
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 00:15:06 -0700 (PDT)
In-Reply-To: <20170801025704.fuhxll23d3eenwrz@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-31 at 19:57 -0700, Shaohua Li wrote:
> On Mon, Jul 31, 2017 at 04:10:07PM -0700, Stephen Hemminger wrote:
> > On Mon, 31 Jul 2017 10:18:57 -0700
> > Shaohua Li <shli@kernel.org> wrote:
> > 
> > > From: Shaohua Li <shli@fb.com>
> > > 
> > > In a syn flooding test, the fib6_table rwlock is a significant
> > > bottleneck. While converting the rwlock to rcu sounds straighforward,
> > > but is very challenging if it's possible. A percpu spinlock is quite
> > > trival for this problem since updating the routing table is a rare
> > > event. In my test, the server receives around 1.5 Mpps in syn flooding
> > > test without the patch in a dual sockets and 56-CPU system. With the
> > > patch, the server receives around 3.8Mpps, and perf report doesn't show
> > > the locking issue.
> > > 
> > > Cc: Wei Wang <weiwan@google.com>
> > 
> > You just reinvented brlock...
> 
> you mean lglock? It has been removed from kernel.
>  
> > RCU is not that hard, why not do it right?
> 
> Maybe. But don't think it's the reason why we shouldn't do the percpu lock now,
> this is a simple change, if some smart guys find a way of RCU, we can easily
> remove this.

Make sure to test this on a 256 cpu host, dealing with ICMP messages a
lot.

percpu locks do not scale. This hack was okay last decade, sure, but it
is no longer a good hack.

I would rather focus on the RCU work, Wei is actively working on it.
