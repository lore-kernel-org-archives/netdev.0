From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Mon, 26 Jan 2004 20:41:22 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040126174122.GB20001@usr.lcm.msu.ru>
References: <20040125164431.GA31548@louise.pinerecords.com> <1075058539.1747.92.camel@jzny.localdomain> <20040125202148.GA10599@usr.lcm.msu.ru> <1075074316.1747.115.camel@jzny.localdomain> <20040126001102.GA12303@usr.lcm.msu.ru> <1075086588.1732.221.camel@jzny.localdomain> <20040126093230.GA17811@usr.lcm.msu.ru> <1075124312.1732.292.camel@jzny.localdomain> <20040126135545.GA19497@usr.lcm.msu.ru> <1075127396.1746.370.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1075127396.1746.370.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 26, 2004 at 09:29:56AM -0500, jamal wrote:
> > You can see for youself. Police users' traffic to half of the normal rate
> > and here them scream :) Then change policing to shaping using wrr
> > (or htb class for each user), and sfq on the leafs, and users are happy.
> > 
> 
> ;-> Sorry I dont have time. But this could be a nice paper since
> i havent seen this topic covered. If you want to write one i could
> help provide you an outline.

Over here every good networking engineer I have talked to knows this :)


> > Well, I use wrr + sfq exactly for fairness. No such thing can be
> > achieved with policing only.
> > 
> 
> Thats what i was assuming. Shaping alone is insufficient as well.

I don't quite understand what you mean here.
Ultimately, any packet will land in some leaf qdisc,
where there is a queue of some maximum size.
If a sender does not reduce its rate, queue overflows, and we drop.
But in my experience this rarely happens with TCP. I think that sender
just see measured RTT increase and reduce its rate or shrinks
its window. I don't know modern TCP implementations in detail, 
but I can see it works.
Is this what you call "shaping alone"? If yes, then I don't agree with
you here.

> 
> > Here it is:
> > 
> >                     +---------+       +-ppp0- ... - client0
> >                     |         +-eth1-<+-ppp1- ... - client1
> > Internet ----- eth0-+ router  |     . . . . . . . .
> >                     |         +-eth2-<  . . . . . .
> >                     +---------+       +-pppN- ... - clientN
> > 		    
> > 
> > Traffic flows from internet to clients. 
> > The ethX names are for example only, my setup is more complex actually,
> > but that complexity is not related to IMQ or traffic shaping.
> > Clients use PPTP or PPPoE to connect to router.
> > See, there's no single interface I can attach qdisc to, if I want
> > to put all clients into the same qdisc. 
> > 
> 
> So why cant you attach a ingress qdisc on eth1-2 and use policing to
> mark excess traffic (not drop)? On eth0 all you do is based on the mark

And where to drop then?

> you stash them on a different class i.e move the stuff you have on
> IMQ0 to eth0.
> 
> Example on ingress:
> 
> meter1=" police index 1 rate $CIR1"
> meter1a=" police index 2 rate $PIR1"
> 
> index 2 is shared by all flows for default.
> index 1 (and others) is guaranteeing rate (20Kbps) for each of the flows
> etc.
> Look for example at examples/Edge32-ca-u32
> 
> The most important thing to know is that policers can be shared across 
> devices, flows etc using the "index" operator.

So, it's just like IMQ, but without that Q bit, only marking?

But how would I calculate guaranteed rate for a client?
Suppose I have 100 clients connected, then I can only
guarantee a 1/100th of the pipe to each. But if only 5 of them
are active, then each can get 1/5th of the pipe.
Round-robin mechanism such as wrr effectively adjusts rates in dynamic.
I use two-layer hierarchy actually, by applying sfq to every wrr class,
so a user can download a file and play Quake at the same time,
with acceptable delays and no packet loss. At the same time,
user that opens 1000 connections with some evil multithreaded downloader
thing, has the same aggregate rate, but can't play Quake because
of high latency.  It works wonderfully.

I suppose we can have a flavor of wrr that will not queue packets,
only find over-active flows and mark or drop over-profile packets
but 1) no such thing exist AFAIK and 2) it will not have separate
queue for each user/flow, thus all flows will have same latency,
only drop probabilities will differ.

So, it seems to me that IMQ fits nicely when there're some artificial
bandwidth limits (as opposed to bandwidth of some physical interface)
and no single egress interface for all flows to be shaped.
> 
> I just noticed you are copying linux-kernel. Please take it off the list
> in your response, this is a netdev issue. This should warn anyone
> interested in the thread to join netdev.
> 

Done.

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 
