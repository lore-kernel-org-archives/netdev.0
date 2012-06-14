From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 12:07:51 +0200
Message-ID: <1339668471.22704.714.camel@edumazet-glaptop>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
	 <1339665719.22704.692.camel@edumazet-glaptop>
	 <1339667417.22704.707.camel@edumazet-glaptop>
	 <20120614.030021.2291563831943273331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhautbois@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50605 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530Ab2FNKH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 06:07:56 -0400
Received: by eeit10 with SMTP id t10so501690eei.19
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 03:07:55 -0700 (PDT)
In-Reply-To: <20120614.030021.2291563831943273331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-14 at 03:00 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 14 Jun 2012 11:50:17 +0200
> 
> > On Thu, 2012-06-14 at 11:22 +0200, Eric Dumazet wrote:
> > 
> >> So you are saying that if you make skb_orphan_try() doing nothing, it
> >> solves your problem ?
> > 
> > It probably does, if your application does an UDP flood, trying to send
> > more than the link bandwidth. I guess only benchmarks workloads ever try
> > to do that.
> 
> Eric, I just want to point out that back when this early orphaning
> idea were being proposed I warned about this, and specifically I
> mentioned that, for datagram sockets, the socket send buffer limits
> are what provide proper rate control and fairness.

If I remember well, the argument was that if workload was using thousand
of sockets, the per socket limitation of in-flight packet would not save
you anyway. We would drop packets.


> It also, therefore, protects the system from one datagram spammer
> being able to essentially take over the network interface and blocking
> out all other users.
> 
> Early orphaning breaks this completely.
> 
> I guess we decided that moving an atomic operation earlier is worth
> all of this?

It was, but with BQL, we should have far less packets in TX rings, so it
might be different today (on BQL enabled NICS only)

> 
> Now we are so addicted to the increased performance from early
> orphaning that I fear we'll never be allowed back into that sane
> state of affairs ever again.


bonding (or other virtual devices) is special in the sense the
dev_hard_start_xmit() is called twice.

We should have a way to properly park packets in Qdiscs, and only do the
orphaning once skb given to real device for 'immediate or so'
transmission.

The pppoe thread is only another manifestation of the same problem.
