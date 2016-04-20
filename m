From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: qdisc spin lock
Date: Wed, 20 Apr 2016 15:34:44 -0700
Message-ID: <1461191684.10638.265.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
	 <CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
	 <CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
	 <1460125157.6473.434.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAAmHdhzAEG-oXsA0P1mEJfseBTUdU7X_bEhgvkCLOLcqOHcQSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35132 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbcDTWeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 18:34:46 -0400
Received: by mail-pa0-f45.google.com with SMTP id fs9so22089006pac.2
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 15:34:46 -0700 (PDT)
In-Reply-To: <CAAmHdhzAEG-oXsA0P1mEJfseBTUdU7X_bEhgvkCLOLcqOHcQSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-20 at 14:24 -0700, Michael Ma wrote:
> 2016-04-08 7:19 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Thu, 2016-03-31 at 16:48 -0700, Michael Ma wrote:
> >> I didn't really know that multiple qdiscs can be isolated using MQ so
> >> that each txq can be associated with a particular qdisc. Also we don't
> >> really have multiple interfaces...
> >>
> >> With this MQ solution we'll still need to assign transmit queues to
> >> different classes by doing some math on the bandwidth limit if I
> >> understand correctly, which seems to be less convenient compared with
> >> a solution purely within HTB.
> >>
> >> I assume that with this solution I can still share qdisc among
> >> multiple transmit queues - please let me know if this is not the case.
> >
> > Note that this MQ + HTB thing works well, unless you use a bonding
> > device. (Or you need the MQ+HTB on the slaves, with no way of sharing
> > tokens between the slaves)
> 
> Actually MQ+HTB works well for small packets - like flow of 512 byte
> packets can be throttled by HTB using one txq without being affected
> by other flows with small packets. However I found using this solution
> large packets (10k for example) will only achieve very limited
> bandwidth. In my test I used MQ to assign one txq to a HTB which sets
> rate at 1Gbit/s, 512 byte packets can achieve the ceiling rate by
> using 30 threads. But sending 10k packets using 10 threads has only 10
> Mbit/s with the same TC configuration. If I increase burst and cburst
> of HTB to some extreme large value (like 50MB) the ceiling rate can be
> hit.
> 
> The strange thing is that I don't see this problem when using HTB as
> the root. So txq number seems to be a factor here - however it's
> really hard to understand why would it only affect larger packets. Is
> this a known issue? Any suggestion on how to investigate the issue
> further? Profiling shows that the cpu utilization is pretty low.

You could try 

perf record -a -g -e skb:kfree_skb sleep 5
perf report

So that you see where the packets are dropped.

Chances are that your UDP sockets SO_SNDBUF is too big, and packets are
dropped at qdisc enqueue time, instead of having backpressure.
