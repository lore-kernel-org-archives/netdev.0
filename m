From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 10:40:44 -0500
Message-ID: <1107186044.1076.11.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <20050131135810.GC31837@postel.suug.ch>
	 <1107181169.7840.184.camel@jzny.localdomain>
	 <20050131151532.GE31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050131151532.GE31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 10:15, Thomas Graf wrote:

> Agreed, this was my first attempt and my current code is still based on
> this. I'm trying to avoid a retransmit battle, therefore I try to
> delay packets if possible with the hope that it's either just a peak
> or the slow down is fast enough. I use a simplified RED and
> tcp_xmit_retransmit_queue() input to avoid flick flack effects which
> works pretty well for bulky streams. A burst buffer takes care
> of interactive traffic with peaks but this doesn't work perfectly fine
> yet. Overall, my attempt works pretty well if the other side uses
> reno/bic and quite well for westwood and vegas. The problem is not that
> it doesn't work at all but achieving a certain _stable_ rate is very
> difficult, the delta of the requested and real rate is up to 25% depending
> on the constancy of the rtt and wether they follow one of the proposed
> tcp cc algorithms. The cc guessing code helps a bit but isn't very
> accurate.

My experience is that you end up dropping no more than a packet in a
burst with policing before TCP adjusts. Also depending on the gap
between bursts, that may be the only packet you drop altogether.
In long flows such as file transfers, avergae of one packet ever gets
dropped.

> > Something along the lines of what OBSD firewall does but selectively (If
> > i understood those OBSD fanatics at SUCON;-> correctly)..they track
> > at ingress before ip stack. The difference is we can allow selective 
> > tracking; something along the lines of:
> 
> This means we'd have to do the most important sanity cehcks ourselves
> like checksum and ip header consistencity. Which basically means a
> duplication of ip_rcv() and ipv6_rcv().
> 

checksum and other validity of ip header will have to be written as an
action if needed. Infact csum is on my list of mini actions. I could
decide to change something on egress of outgoing ip packet in pedit
and would therefore require to recompute csum.

> > tc filter add dev $DEV parent ffff: protocol ip prio 10  \
> >  u32 match u32 0x10000 0xff0000 at 8               \
> > action track \
> > action metamark here depending on whether we found contrack etc
> > 
> > I have the layout scribbeled on paper somewhere .. I will look it up
> > and provide more details
> > 
> > Track should just use iptables contracking code instead of reinventing
> > it.
> 
> This is exactly my thinking as well but I'd do it as ematch. Given
> we pass the netfilter conntrack code we'd then have access to the
> meta data of it such as direction, state and other attributes.
> 
> tc filter add dev $DEV parent ffff: protocol ip prio 10  \
>      u32 match u32 0x10000 0xff0000 at 8               \
>          and conntrack \
> 	 and meta nf_state eq ESTABLISHED \
> 	 and meta nf_status eq SEEN_REPLY \
>    action metamark here depending on whether we found contrack etc

Ok, I think both approaches are correct. ematch does the check/get
essentially; and action will create the set/tracking if needed.
For the example i gave, you are absolutely correct, ematch is
sufficient.

cheers,
jamal
