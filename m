From: Timo Teras <timo.teras@iki.fi>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 13 Aug 2013 14:33:25 +0300
Message-ID: <20130813143325.364b4bab@vostro>
References: <20130812160142.71737a95@vostro>
	<CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
	<20130813092312.2493354e@vostro>
	<20130813074614.GM25511@secunet.com>
	<20130813105757.39fb0ab8@vostro>
	<20130813104548.GB26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Collins <bsderandrew@gmail.com>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:35803 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab3HMLd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 07:33:29 -0400
Received: by mail-ea0-f172.google.com with SMTP id r16so4031279ead.17
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 04:33:28 -0700 (PDT)
In-Reply-To: <20130813104548.GB26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013 12:45:48 +0200
Steffen Klassert <steffen.klassert@secunet.com> wrote:

> On Tue, Aug 13, 2013 at 10:57:57AM +0300, Timo Teras wrote:
> > On Tue, 13 Aug 2013 09:46:14 +0200
> > Steffen Klassert <steffen.klassert@secunet.com> wrote:
> > 
> > > Also, if you want parallelism, you could use the pcrypt algorithm.
> > > It sends the crypto requests asynchronously round robin to a
> > > configurable set of cpus. Finaly it takes care to bring the
> > > served crypto requests back into the order they were submitted
> > > to avoid packet reordering.
> > 
> > Right. Looks like this helps a lot.
> > 
> > Perhaps it would be worth to experiment also with RPS type hash
> > based cpu selection?
> 
> Actually, this was the reason why I started to write the below
> mentioned patches. The idea behind that was to use a combination of
> flow based and inner flow parallelization.
> 
> On bigger NUMA machines it does not make much sense to use all
> cores for parallelization. The performance depends too much on the
> actual topology. Moving crypto requests to another NUMA node can
> even reduce performance. So I wanted to use RPS type hash based
> cpu selection to choose the node for a given flow and then use
> pcrypt to parallelize this flow on the chosen node.

Excellent.

I've been now playing with pcrypt. It seems to not give significant
boost in throughput. I've setup the cpumaps properly, and top says the
work is distributed to appropriate kworkers, but for some reason
throughput does not get any better. I've tested with iperf in both udp
and tcp modes, with various amounts of threads.

Is there any more synchronization points for single SA that might limit
throughput? I've been testing with auth hmac(sha1), enc cbc(aes) -
according to metric the CPUs are still largely idle instead of
processing more data for better throughput. aes-gcm (without pcrypt)
achieves better throughput even saturating my test box links.

Any pointers what to test, or to pinpoint the bottleneck?

I also tried enabling RPS on the gre device, but it did not seem to
make any significant difference either.

> > > Currently we have only one systemwide workqueue for encryption
> > > and one decryption. So all IPsec packets are send to the same
> > > workqueue, regardless which state they use.
> > > 
> > > I have patches that make it possible to configure a separate
> > > workqueue for each state or to group some states to a specific
> > > workqueue. These patches are still unpublished because they
> > > have not much testing yet, but I could send them after some
> > > polishing for review or testing if you are interested.
> > 
> > Yes, I'd be interested.
> 
> Ok, I'll send them. May take some days to rebase and polish.

Thanks.
