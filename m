From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Tue, 1 Feb 2005 14:31:38 +0100
Message-ID: <20050201133138.GM31837@postel.suug.ch>
References: <1107123123.8021.80.camel@jzny.localdomain> <20050131135810.GC31837@postel.suug.ch> <1107181169.7840.184.camel@jzny.localdomain> <20050131151532.GE31837@postel.suug.ch> <41FED514.7060702@dsl.pipex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
Content-Disposition: inline
In-Reply-To: <41FED514.7060702@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >>  X =  ----------------------------------------------------------
> >>       R*sqrt(2*b*p/3) + (t_RTO * (3*sqrt(3*b*p/8) * p * (1+32*p^2)))
> >>
> >>Where:
> >>
> >>     X is the transmit rate in bytes/second.
> >>     s is the packet size in bytes.
> >>     R is the round trip time in seconds.
> >>     p is the loss event rate, between 0 and 1.0, of the number of loss
> >>       events as a fraction of the number of packets transmitted.
> >>     t_RTO is the TCP retransmission timeout value in seconds.
> >>     b is the number of packets acknowledged by a single TCP
> >>       acknowledgement.
> 
> WRT policers I never figured out where you would put the effects of 
> playing with the burst size parameter and it's effects with few/many 
> connections and any burstiness caused into an equasion like that.

A burst buffer has impact on R on later packets, it can "smooth" R
and X and thus results in more stable rates. Depending on the actual
burst, it can avoid retransmits which stabilizes the rate as well.

> This sounds cool. For me in someways I think it could be nicer (in the 
> case of shaping from the wrong end of a slow link) to delay the real 
> packets - that way the tcps of the clients get to see the smoothed 
> version of the traffic and you can delay udp aswell.

It's impossible to never drop anything, for udp we can either drop
it or use ECN and hope the other ip stack takes care of it or the
application implements its own cc algorithm. Basically you can already
do that with (G)RED. Most UDP users which provide a continous stream
such as video streams, implement some kind of key datagram which contains
the number of datagrams received since the last key datagram and the
application throttles down based on that so dropping is often the only
way to achieve a general working solution. Delaying UDP packets and
then drop them if the buffer is full is very dangerous, often the
protocols based on UDP rely on the assumption that datagrams get lost
randomly and not succcessive. We can think about precicse policing
for UDP again once the current poor application level cc algorithms
have failed and the industry accepted ECN as the right thing. For
now most of them still suffer from the NIH syndrom in this area.

> How intelligent and how much, if any, per connection state do you/could 
> you keep?

I keep a rate estimator for every flow on ingress in a hash table and
lookup it up on egress with the flow parameters reversed. It gets
pretty expensive on huge amounts of connection usually one doesn't
want to do per connection policing on such boxes. ;->
