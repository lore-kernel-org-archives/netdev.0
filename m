From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 09:19:30 -0500
Message-ID: <1107181169.7840.184.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <20050131135810.GC31837@postel.suug.ch>
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
In-Reply-To: <20050131135810.GC31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 08:58, Thomas Graf wrote:
> > 2) Allows for queueing incoming traffic for shaping instead of
> > dropping. I am not aware of any study that shows policing is 
> > worse than shaping in achieving the end goal of rate control.
> > I would be interested if anyone is experimenting. Nevertheless,
> > this is still an alternative as opposed to making a system wide
> > ingress change.
> 
> Agreed, the problem should be solved on egress by delaying ACKs
> so the other side's congestion control slows down. 

Or dropping packets. TCP will adjust itself either way; at least
thats true according to this formula [rfc3448] (originally derived from
Reno, but people are finding it works fine with all other variants of
TCP CC):

-----
The throughput equation is:

                                   s
   X =  ----------------------------------------------------------
        R*sqrt(2*b*p/3) + (t_RTO * (3*sqrt(3*b*p/8) * p * (1+32*p^2)))


Where:

      X is the transmit rate in bytes/second.
      s is the packet size in bytes.
      R is the round trip time in seconds.
      p is the loss event rate, between 0 and 1.0, of the number of loss
        events as a fraction of the number of packets transmitted.
      t_RTO is the TCP retransmission timeout value in seconds.
      b is the number of packets acknowledged by a single TCP
        acknowledgement.
----

dropping mucks with "p" and delaying ACKs (shaping) mucks with "R".
Plug into that formula either one and you see they affect the 
result for X the same way.
I am really hoping that someone will do experimental analysis - cant
believe no hungry students these days out there.

> I still don't
> have a solution which works for all ip stacks and ended up tuning
> parameters based on TTL numbers guessing the operating system.
> 
> For me, the purpose of ingress policing is to apply some policy for
> control datagrams and other unwanted traffic. One example would be
> dropping echo requests comming from nmap which reduces egress
> bandwidth consumption by 13% my border routers.
> 
> tc filter add dev $DEV parent ffff: protocol ip prio 10  \
>     u32 match u32 0x10000 0xff0000 at 8                  \
>         match u32 0x1c 0xffff at 0                       \
>         match u32 0x8000000 0xf000000 at 20              \
>     police mtu 1 drop flowid :1
> 
> I should convert this to actions at some point ;->
> 

You should ;->
And now you can actually _really_  drop, above will let some packets
through. More interestingly is you can now randomly drop or
determistically (drop every 10th packet)

> > --> Instead the plan is to have a contrack related action. This action
> > will selectively either query/create contrack state on incoming packets.
> > Packets could then be redirected to dummy based on what happens -> eg 
> > on incoming packets; if we find they are of known state we could send to
> > a different queue than one which didnt have existing state. This
> > all however is dependent on whatever rules the admin enters.
> 
> We could also do it in the meta ematch but this relies on the packet
> already having passed the conntrack code. How do you plan to do this
> in ingress?
> 

Something along the lines of what OBSD firewall does but selectively (If
i understood those OBSD fanatics at SUCON;-> correctly)..they track
at ingress before ip stack. The difference is we can allow selective 
tracking; something along the lines of:

tc filter add dev $DEV parent ffff: protocol ip prio 10  \
 u32 match u32 0x10000 0xff0000 at 8               \
action track \
action metamark here depending on whether we found contrack etc

I have the layout scribbeled on paper somewhere .. I will look it up
and provide more details

Track should just use iptables contracking code instead of reinventing
it. 

> 
> > tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
> > match ip src 192.168.200.200/32 flowid 1:2 \
> > action police rate 10kbit burst 90k drop \
> > action mirred egress mirror dev dummy0 
> 
> This is extremely useful. I'm not sure but I think you also had plans
> to allow mirroring to userspace?
> 

Yes via mmaped packet sockets. The other way (induced by laziness, so i
dont have to write a single line of code) is to
have redirection to ring device that was posted a while back by someone
since it provides a bridge between mmaped packet socket like interface
and kernel. 

> > My goal here is to start a discussion to see if people agree this is
> > a good replacement for IMQ or whether to go another path.
> 
> Sounds good to me. No complains from my side. I'll have a closer look
> at the patch later on.

Thanks for looking 

cheers,
jamal
