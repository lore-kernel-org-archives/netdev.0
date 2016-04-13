From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 0/2] tun: lockless xmit
Date: Wed, 13 Apr 2016 15:56:25 +0300
Message-ID: <20160413155146-mutt-send-email-mst@redhat.com>
References: <cover.1460393493.git.pabeni@redhat.com>
 <20160413132816-mutt-send-email-mst@redhat.com>
 <1460551817.10638.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45501 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030757AbcDMM43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 08:56:29 -0400
Content-Disposition: inline
In-Reply-To: <1460551817.10638.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 05:50:17AM -0700, Eric Dumazet wrote:
> On Wed, 2016-04-13 at 14:08 +0300, Michael S. Tsirkin wrote:
> > On Wed, Apr 13, 2016 at 11:04:45AM +0200, Paolo Abeni wrote:
> > > This patch series try to remove the need for any lock in the tun device
> > > xmit path, significantly improving the forwarding performance when multiple
> > > processes are accessing the tun device (i.e. in a nic->bridge->tun->vm scenario).
> > > 
> > > The lockless xmit is obtained explicitly setting the NETIF_F_LLTX feature bit
> > > and removing the default qdisc.
> > > 
> > > Unlikely most virtual devices, the tun driver has featured a default qdisc
> > > for a long period, but it already lost such feature in linux 4.3.
> > 
> > Thanks -  I think it's a good idea to reduce the
> > lock contention there.
> > 
> > But I think it's unfortunate that it requires
> > bypassing the qdisc completely: this means
> > that anyone trying to do traffic shaping will
> > get back the contention.
> > 
> > Can we solve the lock contention for qdisc?
> > E.g. add a small lockless queue in front of it,
> > whoever has the qdisc lock would be
> > responsible for moving things from there to qdisc
> > proper.
> > 
> > Thoughts? Is there a chance this might work reasonably well?
> 
> Adding any new queue in front of qdisc is problematic :
> - Adds a new buffer, with extra latencies.

Only where lock contention would previously occur, right?

> - If you want to implement priorities properly for X COS, you need X
> queues.

This definitely needs thought.

> - Who is going to service this extra buffer and feed the qdisc ?

The way I see it - whoever has the lock, at unlock time.

> - If the innocent guy is RT thread, maybe the extra latency will hurt.

Again - more than a lock?

> - Adding another set of atomic ops.

That's likely true. Use some per-cpu trick instead?

> We have such a schem here at Google (called holdq), but it was a
> nightmare to tune.
> 
> We never tried to upstream this beast, it is kind of ugly, and were
> expecting something better. Problem is : If you use HTB on a bonding
> device, you want still to properly use MQ on the slaves.
> 
> HTB queue. 20 netperf generating UDP packets 
> lpaa23:~# ./super_netperf 20 -H lpaa24 -t UDP_STREAM -l 3000 -- -m 100 &
> [1] 181993
> 
> 
> With the holdq feature turned on : about 1 Mpps
> 
> lpaa23:~# sar -n DEV 1 10|grep eth0|grep Average
> Average:         eth0     28.50 999071.60      3.07 138542.64      0.00
> 0.00      0.60
> 
> holdq turned off : about 620 Kpps
> 
> lpaa23:~# sar -n DEV 1 10|grep eth0|grep Average
> Average:         eth0     39.00 617765.40      4.73  85667.42      0.00
> 0.00      0.90
> 
