From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Tue, 14 Jan 2003 10:44:54 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0301140946230.1978-100000@dyn9-47-18-86.beaverton.ibm.com>
References: <200301140122.EAA10371@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>, <jgrimm2@us.ibm.com>,
   <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200301140122.EAA10371@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Jan 2003 kuznet@ms2.inr.ac.ru wrote:

> Hello!
> 
> > Is this more agreeable?
> 
> I did not disagree with the first one, actually. :-)
> It was cleaner, to be honest.

So can i go ahead and add an argument(ipfragok) to ip_queue_xmit()?

> 
> In any case, after reading mail by Jon Grimm, the things
> became cleaner. BTW what is "chunk" size in current implementation?

The maximum chunksize is set to (pmtu - SCTP+IPheadersizes).

> 
> Essentially, to make a compromise between usability and sanity,
> it is enough to make the thing which we make with UDP: to prevent
> sending bogus fragmented packets when IP_MTUDISC_DO is set by user
> and set chunk size to a value < min(512,current mtu) in this case,
> so no fragments will be generated. In that case I will be happy
> (done all that possible, all the flaws are directed to SCTP designers. :-))
> and default behaviour (it is IP_MTUDISC_WANT) still will be rfc compliant.

You seem to be suggesting the use of lowest possible pmtu as the max. chunk
size.  This is OK as long as the user messages are of small size. But it adds
additional overhead of 16 byte chunk headers for messages that are larger than
the chunk size, but lower than the pmtu. So we would like to opt for this 
solution only if you are totally against adding a new argument to
ip_queue_xmit().

Also SCTP uses control chunks(INIT_ACK, COOKIE_ECHO) for association setup
which can be larger than pmtu(although rare). The control chunks cannot be 
fragmented by SCTP, but it is perfectly OK for IP to fragment them.

> 
> 
> > If not, do you prefer SCTP having its own ip_xmit
> 
> Hey, only not this. :-)
> 
> BTW what did you make with IPv6? We even not have any analogue
> to ip_fragment there at the moment. Do not worry, we have to do this
> in any case, not depending on SCTP demands. :-)

Frankly, i haven't thought of IPV6 in detail. I was under the impression that
it is simpler in ipv6 as only source is allowed to do fragmentation and as there
is no DF bit, it will automatically fragment any packets larger than the pmtu.
But looking at ip6_xmit(), i realize that ICMPV6_PKT_TOOBIG error is generated
forcing the transport layer to do the fragmentation. TCP can handle this, but
SCTP cannot.

So looks like this problem needs to be solved even for ipv6. Is it possible to
add an argument to ip6_xmit() to force ip layer to fragment or use any other 
available interface like ip6_build_xmit() when we want ip to fragment. 

Thanks
Sridhar

> 
> Alexey
> 
> 
