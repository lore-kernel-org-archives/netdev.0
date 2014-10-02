From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Thu, 02 Oct 2014 10:32:47 -0700
Message-ID: <1412271167.22242.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <CA+mtBx8ecpd+S+E2o8A+Hzp3i2SO7XO0+F_DYA0ng+fjta7G5A@mail.gmail.com>
	 <20141002165215.GJ1803@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:58773 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbaJBRcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 13:32:52 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so2975894pab.40
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 10:32:51 -0700 (PDT)
In-Reply-To: <20141002165215.GJ1803@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-02 at 18:52 +0200, Florian Westphal wrote:
> Tom Herbert <therbert@google.com> wrote:
> > On Wed, Oct 1, 2014 at 1:35 PM, Jesper Dangaard Brouer
> > <brouer@redhat.com> wrote:
> > > This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> > > from the qdisc layer, to implement dequeue bulking.
> > >
> > > Patch01: "qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE"
> > >  - Implement basic qdisc dequeue bulking
> > >  - This time, 100% relying on BQL limits, no magic safe-guard constants
> > >
> > > Patch02: "qdisc: dequeue bulking also pickup GSO/TSO packets"
> > >  - Extend bulking to bulk several GSO/TSO packets
> > >  - Seperate patch, as it introduce a small regression, see test section.
> > >
> > > We do have a patch03, which exports a userspace tunable as a BQL
> > > tunable, that can byte-cap or disable the bulking/bursting.  But we
> > > could not agree on it internally, thus not sending it now.  We
> > > basically strive to avoid adding any new userspace tunable.
> > >
> > Unfortunately we probably still need something. If BQL were disabled
> > (by setting BQL min_limit to infinity) then we'll always dequeue all
> > the packets in the qdisc. Disabling BQL might be legitimate in
> > deployment if say a bug is found in a device that prevents prompt
> > transmit completions for some corner case.
> 
> Hmm.  Thats confusing.
> 
> So you are saying to disable bql one should do
> 
> cat limit_max > limit_min ?
> 
> But thats not the same as having a bql-unaware driver.
> 
> Seems to get same behavior as non-bql aware driver (where
> dql_avail always returns 0 since num_queued and adj_limit remain at 0)
> is to set
> 
> echo 0 > limit_max
> 
> ... which makes dql_avail() return 0, which then also turns off bulk
> dequeue.

So Tom point is that we might have a BQL enabled driver, but for some
reason admin wants to set limit_min to 10000000.

Then the admin wants also to restrict the xmit_more batches to 13
packets.

Then a debugging facility might be nice to have.

What about adding 2 attributes :

/sys/class/net/ethX/queues/tx-Y/xmit_more_inflight   (live number of
deferred frames on this TX queue, waiting a doorbell to kick the NIC)

/sys/class/net/ethX/queues/tx-Y/xmit_more_limit      (default to 8)
