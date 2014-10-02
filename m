From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Thu, 2 Oct 2014 18:52:15 +0200
Message-ID: <20141002165215.GJ1803@breakpoint.cc>
References: <20141001203345.3321.99675.stgit@dragon>
 <CA+mtBx8ecpd+S+E2o8A+Hzp3i2SO7XO0+F_DYA0ng+fjta7G5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	Toke =?iso-8859-15?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40160 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751648AbaJBQwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 12:52:21 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx8ecpd+S+E2o8A+Hzp3i2SO7XO0+F_DYA0ng+fjta7G5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> wrote:
> On Wed, Oct 1, 2014 at 1:35 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> > from the qdisc layer, to implement dequeue bulking.
> >
> > Patch01: "qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE"
> >  - Implement basic qdisc dequeue bulking
> >  - This time, 100% relying on BQL limits, no magic safe-guard constants
> >
> > Patch02: "qdisc: dequeue bulking also pickup GSO/TSO packets"
> >  - Extend bulking to bulk several GSO/TSO packets
> >  - Seperate patch, as it introduce a small regression, see test section.
> >
> > We do have a patch03, which exports a userspace tunable as a BQL
> > tunable, that can byte-cap or disable the bulking/bursting.  But we
> > could not agree on it internally, thus not sending it now.  We
> > basically strive to avoid adding any new userspace tunable.
> >
> Unfortunately we probably still need something. If BQL were disabled
> (by setting BQL min_limit to infinity) then we'll always dequeue all
> the packets in the qdisc. Disabling BQL might be legitimate in
> deployment if say a bug is found in a device that prevents prompt
> transmit completions for some corner case.

Hmm.  Thats confusing.

So you are saying to disable bql one should do

cat limit_max > limit_min ?

But thats not the same as having a bql-unaware driver.

Seems to get same behavior as non-bql aware driver (where
dql_avail always returns 0 since num_queued and adj_limit remain at 0)
is to set

echo 0 > limit_max

... which makes dql_avail() return 0, which then also turns off bulk
dequeue.

Confused,
Florian
