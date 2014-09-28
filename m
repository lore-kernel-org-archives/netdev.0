From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 02:22:33 +0200
Message-ID: <1411863753.382032.172503561.649C2A51@webmail.messagingengine.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
 <1411861467.374982.172498061.37EB43B1@webmail.messagingengine.com>
 <1411862731.15768.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:48389 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753010AbaI1AWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 20:22:34 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id 24FBC2035D
	for <netdev@vger.kernel.org>; Sat, 27 Sep 2014 20:22:34 -0400 (EDT)
In-Reply-To: <1411862731.15768.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014, at 02:05, Eric Dumazet wrote:
> On Sun, 2014-09-28 at 01:44 +0200, Hannes Frederic Sowa wrote:
> > Hi Eric,
> > 
> > On Sun, Sep 28, 2014, at 00:56, Eric Dumazet wrote:
> > > -       ring->cons += txbbs_skipped;
> > > +
> > > +       /* we want to dirty this cache line once */
> > > +       ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
> > > +       ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
> > > +
> > 
> > Impressive work!
> > 
> > I wonder if another macro might be useful for those kind of
> > dereferences, because ACCESS_ONCE is associated with correctness in my
> > mind and those usages only try to optimize access patterns.
> > Does OPTIMIZER_HIDE_VAR generate the same code?
> 
> 
> If we have 
> 
> ring->cons += txbbs_skipped;
> 
> Then compiler might issue a RMW instruction.
> 
> And this is bad in this case.
> 
> I really want to _write_ into this location, and its fast because I
> already have in ring_cons the content I fetched maybe hundred of
> nanoseconds before, or even thousand of nanoseconds before.
> 
> ACCESS_ONCE(XXXX) = y
> 
> Is not only for correctness.
> 
> It exactly documents the fact that we want to perform a single write.
> 
> I believe it is time that people understand how useful is this helper
> (Less than 700 occurrences in the whole kernel today, not including
> Documentation/*)

Understood, thanks.

For me ACCESS_ONCE was something which slowed down code till today. Also
I have the feeling that instruction scheduling in the compiler could do
a better job in some places...

Now I wonder if it is worth it playing around with the restrict keyword
and strict-aliasing in networking. ;)

Bye,
Hannes
