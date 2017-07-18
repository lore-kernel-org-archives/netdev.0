From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC net 1/2] net: set skb hash for IP6 TCP reset packet
Date: Tue, 18 Jul 2017 11:59:05 -0700
Message-ID: <20170718185905.d3erulmh3ns6ddfs@kernel.org>
References: <cover.1499967945.git.shli@fb.com>
 <5595e60068d7c18c7f0749d8a355a008123ca0d8.1499967945.git.shli@fb.com>
 <1500281511.5566.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170717215322.vdbz2l76qmdtp4xu@kernel.org>
 <1500350577.5566.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Florent Fourcot <flo@fourcot.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54960 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751427AbdGRS7I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 14:59:08 -0400
Content-Disposition: inline
In-Reply-To: <1500350577.5566.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 17, 2017 at 09:02:57PM -0700, Eric Dumazet wrote:
> On Mon, 2017-07-17 at 14:53 -0700, Shaohua Li wrote:
> > On Mon, Jul 17, 2017 at 01:51:51AM -0700, Eric Dumazet wrote:
> > > On Thu, 2017-07-13 at 10:56 -0700, Shaohua Li wrote:
> > > > From: Shaohua Li <shli@fb.com>
> > > > 
> > > > Please see below tcpdump output:
> > > 
> > > > The tcp reset packet has a different flowlabel, which causes our router
> > > > doesn't correctly close tcp connection.
> > > 
> > > This looks a bug in your router, because (IPv6 only) flowlabel is not
> > > part of the tuple identifying a TCP flow.
> > 
> > Actually it's for load balance between several routers.
> 
> What happens then when flowlabel changes as I described ?
> 
> See commit 3acf3ec3f4b0 ("tcp: Change txhash on every SYN and RTO
> retransmit")

Frankly I have no idea. People in the team do think this is a problem in some
corner cases. Didn't get any report yet though.
 
> > > 
> > > >   The reason is the normal packet
> > > > gets the skb->hash from sk->sk_txhash, which is generated randomly.
> > > > ip6_make_flowlabel then uses the hash to create a flowlabel. The reset
> > > > packet doesn't get assigned a hash, so the flowlabel is calculated with
> > > > flowi6.
> > > > 
> > > > The solution is to save the hash value for timeout sock and use it for
> > > > reset packet.
> > > 
> > > I am a bit unsure why we need to add yet another field in TCP timewait
> > > structure, since :
> > > 
> > > 1) flowlabel can vary during a TCP flow lifetime.
> > > 2) flowlabel is different unde synflood (each syncookie gets a random
> > > flowlabel), and if 3rd packet comes back from the client to finish 3WHS,
> > > the flowlabel will again be different from the one that SYNACK used.
> > 
> > Is it acceptable we reuse tw_flowlabel as Florent Fourcot suggested? It makes
> > no sense to change flowlabel for no reason.
> 
> Sure, if you can find a way to keep storage as small as possible.
> 
> Current size is dangerously approaching 256 bytes, so we might soon use
> one additional cache line (64 bytes)

Will send a new patch.

Thanks,
Shaohua
