From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Tue, 20 Aug 2013 00:07:00 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1308192330200.28532@blackhole.kfki.hu>
References: <521061B4.1030508@fatooh.org>   <1376839467.21329.36.camel@edumazet-glaptop>   <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>   <1376870425.4226.25.camel@edumazet-glaptop>   <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>
  <20130819123314.GC3583@cpaasch-mac>   <1376918657.4226.59.camel@edumazet-glaptop>   <20130819134919.GF3583@cpaasch-mac>  <1376920685.4226.61.camel@edumazet-glaptop>  <alpine.DEB.2.00.1308192207130.27869@blackhole.kfki.hu>
 <1376946527.4226.80.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376946527.4226.80.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Aug 2013, Eric Dumazet wrote:

> On Mon, 2013-08-19 at 22:13 +0200, Jozsef Kadlecsik wrote:
> > On Mon, 19 Aug 2013, Eric Dumazet wrote:
> > 
> > > On Mon, 2013-08-19 at 15:49 +0200, Christoph Paasch wrote:
> > >
> > > > It's a TCP-patch, that interprets duplicate-acks with invalid 
> > > > SACK-blocks as duplicate acks in tcp_sock->sacked_out.
> > > 
> > > Yeah, but here, this is conntrack who is blocking the thing.
> > > 
> > > TCP receiver has no chance to 'fix' it.
> > > 
> > > See conntrack is one of those buggy middle box as well.
> > > 
> > > So if you want to properly handle this mess, you'll also have to fix
> > > conntrack.
> > 
> > I beg you pardon: why conntrack should be relaxed, when it is expected
> > to do more strict TCP checkings (RFC5961, Section 5.).
> > 
> > Also, it's clearly a broken middle box. Don't shoot the messenger.
> 
> Frames are dropped by conntrack, before TCP receiver can even have a
> choice.
> 
> So Christoph patch would be of no use for Corey.

Yes, exactly.
 
> I do not think I shot anyone, only stated the truth.

There's a middlebox in the path wich breaks SACK completely and conntrack 
drops (technically marks as INVALID) the packets with bogus SACK options.

It can be fixed by fixing the middlebox, or disabling SACK by the 
TCPOPTSTRIP target, or by relaxing conntrack. For the latter, the next 
untested patch may be sufficient:

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 7dcc376..8b5d783 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -649,6 +649,11 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		 receiver->td_end, receiver->td_maxend, receiver->td_maxwin,
 		 receiver->td_scale);
 
+	/* Fall back to ACK when SACK is bogus */
+	if (!(before(sack, receiver->td_end + 1) &&
+	      after(sack, receiver->td_end - MAXACKWINDOW(sender) - 1)))
+		sack = ack;
+	      
 	pr_debug("tcp_in_window: I=%i II=%i III=%i IV=%i\n",
 		 before(seq, sender->td_maxend + 1),
 		 after(end, sender->td_end - receiver->td_maxwin - 1),

However it is good to cover the issue thus?
 
> We have workarounds in our stack to 'fix' bugs from others, there
> is no shame in this.
> 
> Glad to see you are interested in RFC 5961 support, as conntrack is
> known to break the ACK challenges in response to RST messages (section
> 3)

*Any* netfilter configuration where the non-allowed TCP packets are 
dropped and not rejected breaks the ACK challenges. That is why I consider 
only section 5 useful from RFC 5961.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
