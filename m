From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
Date: Mon, 18 Jun 2012 21:07:33 +0300
Message-ID: <1340042853.2486.11.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1339616716.22704.661.camel@edumazet-glaptop>
 <20120615.153049.103988387813257203.davem@davemloft.net>
 <504C9EFCA2D0054393414C9CB605C37F1CF19E@SJEXCHMB06.corp.ad.broadcom.com>
 <1340005136.7491.609.camel@edumazet-glaptop>
 <CA+yapKM+H0DHA_UotD7v5LRZfYUeanupxb4=r89+fVSTo-Ad4w@mail.gmail.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"evansr@google.com" <evansr@google.com>,
	"Merav Sicron" <meravs@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"willemb@google.com" <willemb@google.com>
To: "Tomas Hruby" <thruby@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2654 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951Ab2FRSHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 14:07:55 -0400
In-Reply-To: <CA+yapKM+H0DHA_UotD7v5LRZfYUeanupxb4=r89+fVSTo-Ad4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 10:18 -0700, Tomas Hruby wrote:
> On Mon, Jun 18, 2012 at 12:38 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sat, 2012-06-16 at 07:40 +0000, Dmitry Kravkov wrote:
> >> Hi Eric and Tomas
> >>
> >> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> >> > owner@vger.kernel.org] On Behalf Of David Miller
> >> > Sent: Saturday, June 16, 2012 1:31 AM
> >> > To: eric.dumazet@gmail.com
> >> > Cc: netdev@vger.kernel.org; therbert@google.com; evansr@google.com;
> >> > Eilon Greenstein; Merav Sicron; Yaniv Rosner; willemb@google.com;
> >> > thruby@google.com
> >> > Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
> >> >
> >> > From: Eric Dumazet <eric.dumazet@gmail.com>
> >> > Date: Wed, 13 Jun 2012 21:45:16 +0200
> >> >
> >> > > From: Eric Dumazet <edumazet@google.com>
> >> > >
> >> > > There is a off by one error in the minimal number of BD in
> >> > > bnx2x_start_xmit() and bnx2x_tx_int() before stopping/resuming tx
> >> > queue.
> >> > >
> >> > > A full size GSO packet, with data included in skb->head really needs
> >> > > (MAX_SKB_FRAGS + 4) BDs, because of bnx2x_tx_split()
> >> > >
> >> > > This error triggers if BQL is disabled and heavy TCP transmit traffic
> >> > > occurs.
> >> > >
> >> > > bnx2x_tx_split() definitely can be called, remove a wrong comment.
> >> > >
> >> > > Reported-by: Tomas Hruby <thruby@google.com>
> >> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> >>
> >> Theoretically a can't see how we can reach the case with 4 BDs required apart of frags,
> >> Usually we need 2, when split invoked 3:
> >> 1.Start
> >> 2.Start(split)
> >> 3.Parsing
> >> + Frags
> >>
> >> Next pages descriptors and 2 extras for full indication are not counted as available.
> >>
> >> Practically I'm running the traffic for more then a day without hitting the panic.
> >>
> >> Can you describe the scenario you reproduced this in details? And which code has paniced?
> >
> > Thats pretty immediate.
> 
> yes
> 
> > Disable bql on your NIC.
> >
> > Say you have 4 queues :
> >
> > for q in 0 1 2 3
> > do
> >  echo max >/sys/class/net/eth0/queues/tx-$q/byte_queue_limits/limit_min
> > done
> >
> > Then start 40 netperf
> >
> > for i in `seq 1 40`
> > do
> >  netperf -H 192.168.1.4 &
> > done
> 
> this is enough in my case too, it is perfectly reproducible on
> different machines. Replacing +3 for +4 fixes the problem.

Thanks. We are now able to reproduce the issue and we have root-caused
it and found when it was introduced. We are considering few alternatives
and will send our conclusions tomorrow.

Eilon
