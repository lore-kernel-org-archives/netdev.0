From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 14:58:10 +0100
Message-ID: <20050131135810.GC31837@postel.suug.ch>
References: <1107123123.8021.80.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>
Content-Disposition: inline
In-Reply-To: <1107123123.8021.80.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 2) Allows for queueing incoming traffic for shaping instead of
> dropping. I am not aware of any study that shows policing is 
> worse than shaping in achieving the end goal of rate control.
> I would be interested if anyone is experimenting. Nevertheless,
> this is still an alternative as opposed to making a system wide
> ingress change.

Agreed, the problem should be solved on egress by delaying ACKs
so the other side's congestion control slows down. I still don't
have a solution which works for all ip stacks and ended up tuning
parameters based on TTL numbers guessing the operating system.

For me, the purpose of ingress policing is to apply some policy for
control datagrams and other unwanted traffic. One example would be
dropping echo requests comming from nmap which reduces egress
bandwidth consumption by 13% my border routers.

tc filter add dev $DEV parent ffff: protocol ip prio 10  \
    u32 match u32 0x10000 0xff0000 at 8                  \
        match u32 0x1c 0xffff at 0                       \
        match u32 0x8000000 0xf000000 at 20              \
    police mtu 1 drop flowid :1

I should convert this to actions at some point ;->

> --> Instead the plan is to have a contrack related action. This action
> will selectively either query/create contrack state on incoming packets.
> Packets could then be redirected to dummy based on what happens -> eg 
> on incoming packets; if we find they are of known state we could send to
> a different queue than one which didnt have existing state. This
> all however is dependent on whatever rules the admin enters.

We could also do it in the meta ematch but this relies on the packet
already having passed the conntrack code. How do you plan to do this
in ingress?


> tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
> match ip src 192.168.200.200/32 flowid 1:2 \
> action police rate 10kbit burst 90k drop \
> action mirred egress mirror dev dummy0 

This is extremely useful. I'm not sure but I think you also had plans
to allow mirroring to userspace?

> My goal here is to start a discussion to see if people agree this is
> a good replacement for IMQ or whether to go another path.

Sounds good to me. No complains from my side. I'll have a closer look
at the patch later on.
