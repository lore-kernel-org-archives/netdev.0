From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Sat, 31 Jan 2004 23:53:26 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040131205326.GA3089@usr.lcm.msu.ru>
References: <20040125202148.GA10599@usr.lcm.msu.ru> <1075074316.1747.115.camel@jzny.localdomain> <20040126001102.GA12303@usr.lcm.msu.ru> <1075086588.1732.221.camel@jzny.localdomain> <20040126093230.GA17811@usr.lcm.msu.ru> <1075124312.1732.292.camel@jzny.localdomain> <20040126135545.GA19497@usr.lcm.msu.ru> <1075127396.1746.370.camel@jzny.localdomain> <20040131185231.GA2608@usr.lcm.msu.ru> <1075580812.1035.83.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1075580812.1035.83.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 31, 2004 at 03:26:53PM -0500, jamal wrote:
> Hello Vladimir,
> 
> On Sat, 2004-01-31 at 13:52, Vladimir B. Savkin wrote:
> > Jamal, I think you did not understand the role of IMQ in my setup.
> > 
> [..]
> > > > 
> > > >                     +---------+       +-ppp0- ... - client0
> > > >                     |         +-eth1-<+-ppp1- ... - client1
> > > > Internet ----- eth0-+ router  |     . . . . . . . .
> > > >                     |         +-eth2-<  . . . . . .
> > > >                     +---------+       +-pppN- ... - clientN
> 
> > And here is what you suggest:
> 
> > > So why cant you attach a ingress qdisc on eth1-2 and use policing to
> > > mark excess traffic (not drop)? On eth0 all you do is based on the mark
> > > you stash them on a different class i.e move the stuff you have on
> > > IMQ0 to eth0. 
> > 
> > But in my case, eth0 is an ingress device, and eth1 and eth2 are 
> > (physical) egress devices.
> 
> You are correct to say i misundertood because i only covered only one
> direction. Lets cover both cases now. I am going to try to be verbose.
> 
> Lets take something like an ftp/http download as an example and hopefuly
> I can grasp your requirements if i am wrong.
> 
> Case1: bulk transfer going right->left  
> 
> In this case you want to restrict how much client0..N can send to the
> internet. There are two ways to do it, the first one as you say below:
> 
> > For traffic going other direction (from right to left) I could do
> > without IMQ, as you suggest. 
> 
> i.e based on client0..N you attach some rules on eth0.
> 
> The second scheme is what i was saying in my email to Tomas - it is
> achievable via the ingress qdisc on both eth1 and eth2 and egress root
> prio qdisc on eth0. A diagram would help to show how the policing is
> done:
> 
>   
>   ^
>   |
>   |
>   +--------- MAX available internet bandwidth for all clients
>   |
>   ^
>   |   Area B
>   | 
>   +--------- MAX available internet b/width for each of eth1/2
>   |
>   ^
>   |  Area A
>   |  
>   +----------MAX guaranteed bandwith available to client for internet
>   | 
>   +---------- 0 b/width
> 
> 
> Not sure if this diagram is clear or not - theres a gauge of bandwith
> going up vertically. The maximum is whatever bwidth you have on the
> internet side.
> Each client is given a guaranteed (long time) bandwidth. This is
> labelled "MAX guaranteed bandwith available to client for internet".
> What you do is fwmark the packet if it doesnt exceed its fair bandwith
> share - lets say mark 1. 
> If this is exceeded then the client is in "Area A" of the gauge above.
> Everything in Area A is what a combination of all clients on each device
> (eth1 for example) can use. If a client reaches this area you mark them
> with 2.
> If this is exceeded then the client is in area B. In this case, you mark
> the client with a 3.
> If they exceed "MAX available internet bandwidth for all clients"
> then no point in sending them on their way to eth0, just drop them
> 
> On eth0 side, all you need to do really is put the different marks
> (using fwmark classifier) on different priority queues (use simple prio
> qdisc nothing more).
> prioritiwise: mark 1 > mark 2 > mark 3.
> i.e as long as you have mark 1 packets send only those to the internet.
> If there are no more on mark 1 queue send mark 2. If no more of those
> send prio 3.
> Eventually some of these queues will be overflowing for clients which
> are greedy.
>  
> Note that Areas A and B are shared between many clients and is here to
> serve as an example just to show how you can do the following:
> a) a client gets a fair share i.e Guaranteed rate in a long period of
> time.

No, that's not what I mean by fairness!
No problem to give everyone their guaranteed rate.

> b) many clients coming from one device like eth1 share some excess
> bandwidth allocated for eth1 if it is available.
> c) Many clients share bandwidth allocated for the system (i.e
> fre-for-all for eth1 and eth2).

Yes, they will share it. But in what proportion?
Your proposal does not guarantee anything about this.
And I want client to share excess bandwidth fairly.
That's what round-robin schemes can give.

With your solution, if every client open some number of TCP connections
to download files, bandwidth will be divided between clients in
proportion to number of connections, since every connection will be in
equal conditions. That's exactly what I am to prevent.

> Ok, so lets take  a look at case 2 which is right <- left 
> i.e clients downloading from the internet.
> Repeat what i described as method 2 above with ingress qdisc at eth0
> and egress on eth1 and eth2.

There is no way for internet traffic to saturate fast ethernet link,
since uplink is only few megabits/sec.
So, egress queue will always be empty, priorities will have no effect
whatsoever, and packets will be neither dropped nor delayed.

See, my bandwidth limit is artificial and defined by political reasons.
And that's the only restriction that is defined, and the goal
is the maximal fairness. Minimal guaranteed rate for each client is
not enough.
With your proposal, there's just no place to put this aggregate
restriction, except a policer, which doesn't give fairness.

> 
> The nice thing about the policer is the ability to share bandwidth
> between devices and flows regardless of direction.
>  
> 
> > > The most important thing to know is that policers can be shared across 
> > > devices, flows etc using the "index" operator.
> > > 
> > 
> > Ok, this looks like typical diffserv setup, as they described in RFCs.
> > It doesn't assure fair bandwith sharing between active clients. 
> >
> > We just can't decide what traffic is excess using some predetermined
> > rate, we must look for current rates of other clients and penalize those
> > who use unfair shares. Such meters and policers could exist but I don't
> > know any. 
> > wrr and htb can do it, but they use queuing and round-robin
> > to achive fairness, not meters and policers.
> > 
> 
> Look at what i said above. A simple priority scheduler is sufficient no
> need for WRR or HTB. 

No, it's not, as described above.

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 
