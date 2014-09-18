From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CPU scheduler to TXQ binding? (ixgbe vs. igb)
Date: Thu, 18 Sep 2014 09:34:24 -0700
Message-ID: <1411058064.7106.277.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140917152653.1c824a22@redhat.com>
	 <1410964359.7106.229.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5419A1E7.8040109@intel.com> <20140918085640.0815df6d@redhat.com>
	 <1411047209.7106.255.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411047689.7106.258.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411054951.7106.272.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140918175910.5fc67efa@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:42878 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239AbaIRQeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 12:34:25 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so725280pdi.2
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 09:34:25 -0700 (PDT)
In-Reply-To: <20140918175910.5fc67efa@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 17:59 +0200, Jesper Dangaard Brouer wrote:
> On Thu, 18 Sep 2014 08:42:31 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Thu, 2014-09-18 at 06:41 -0700, Eric Dumazet wrote:
> > 
> > > Last but not least, there is the fact that networking stacks use
> > > mod_timer() to arm timers, and that by default, timer migration is on 
> > > ( cf /proc/sys/kernel/timer_migration )
> 
> I don't have this proc file on my system, as I didn't select CONFIG_SCHED_DEBUG.

Interesting... this timer_migration stuff seems a bit scary to me.

> 
> > > We probably should use mod_timer_pinned(), but I could not really see
> > > any difference.
> > 
> > Hmm... actually its quite noticeable :
> 
> Interesting impact.
> 
> I'm looking for some 1G hardware without multiqueue, so I can get
> around this measurement constraint.  And possibly turning it down to
> 100Mbit/s, so I can more easily measure the HoL blocking effect.
> 

ethtool -L   eth0    rx 1 tx 1 

(Or similar if combined is used)


> 
> > # ./super_netperf 500 --google-pacing-rate 3000000 -H lpaa24 -l 1000 &
> > ...
> 
> Interesting option "--google-pacing-rate" ;-)

Its using upstream SO_MAX_PACING_RATE, nothing fancy ;)

> 
> > # echo 1 >/proc/sys/kernel/timer_migration
> > # vmstat 5
> > procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
> >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
> >  2  0      0 261178336  15812 1001880    0    0     5     1  185  217  0  4 96  0
> >  0  0      0 261173456  15812 1001884    0    0     0     0 1548055 35472  0 15 85  0
> >  2  0      0 261174880  15812 1001888    0    0     0     0 1533309 35163  0 15 85  0
> >  3  0      0 261176768  15812 1001896    0    0     0     0 1533442 35694  0 15 85  0
> []
> 
> > # echo 0 >/proc/sys/kernel/timer_migration
> > # vmstat 5
> > procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
> >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
> >  2  0      0 261172784  15812 1001936    0    0     5     1  165  228  0  5 95  0
> >  1  0      0 261175776  15812 1001940    0    0     0     0 1187446 32238  0 12 88  0
> >  2  0      0 261172752  15812 1001940    0    0     0     3 1166697 32060  0 12 88  0
> 
> Quite significant, both interrupts and especially CPU system usage drop.
> 

Yep...
