From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Dynamically classifying flows?
Date: Tue, 8 Mar 2005 02:14:31 +0100
Message-ID: <20050308011431.GY31837@postel.suug.ch>
References: <7bca1cb505030709502316f9b8@mail.gmail.com> <20050307203450.GX31837@postel.suug.ch> <7bca1cb505030716104856fe3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Asim Shankar <asimshankar@gmail.com>
Content-Disposition: inline
In-Reply-To: <7bca1cb505030716104856fe3@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Asim Shankar <7bca1cb505030716104856fe3@mail.gmail.com> 2005-03-07 18:10
> Filtering by size may not always work. An interactive flow may also
> generate big (MTU) size packets, but it is interactive because the
> _rate_ at which packets are produced is smaller. Though, if you think
> that such cases are purely theoretical and don't create problems in
> practice, do let me know.

It really depends on your needs and the accuracy you need. I guess,
there is not a single truth. I've been experimenting with a classifier
which classifies based on the packet rate over a certain time, relative
to the total packet rate, i.e. the higher the packet rate the more likely
it is supposd to be a bulk data transfer. It is quite successful for
high traffic scenarios where real connection tracking is not possible.
However, this only works for certain scenarios, there are dozens of
other ways to solve this problem, one of them is the recent additions
to netfilter as Patrick pointed out.

> Can you point me to some details on ematch? Specifically, how it
> supports dynamic  classifications of flows? Seems like this is
> something really new you guys are working on, so not much
> documentation is available.

The term "dynamic classification" is a bit wide and can be interpreted
in various ways. Ematch is not aiming towards a specific direction
but rather tries to provide a easy to use API for everyone to write
their own classification procedures or construct one by combining
existing ematches.

As you mentioned, it's quite new and still experimental and not well
documented but this will change together with the required userspace
additions.

> Won't we always have queues? After all a qdisc essentially specifies a
> de-queuing algorithm.

Yes but the queues will be empty most of the times except if you
apply some kind of rate limitation and that is exactly what should
be avoided while handling interactive flows. It would be possible of
course to try and pick all the packets belonging to a interactive flow
but why bother? Enqueueing them into a separate band is easier and
causes less troubles.

> I was thinking along the lines of process
> scheduling to be able to avoid having to manually specify flow
> priorities. Ideally speaking, it would automatically classify remote
> terminal flows such that they see the least possible queueing delays.

This would be nice but really is hard to achieve. The drawback of
any automation is that the worst-case scenarios are often much worse.
The classifier algorithm mentioned above aims into this direction
by automatically classifying packets into different bands based on
their packet rate relative to the total packet rate.

It is an interesting topic and has potention for great ideas and
concepts but it is harder than it looks at a first glance. It
gets quite worse when you try to guarantee some kind of QoS policy
because all dynamic approachs I've seen go totally berserk under
extreme conditions.

I'll give you some examples of what I mean:

  Assuming you to want detect and classify interactive flows. Does this
  mean that the connection handshake is included as well? If so, how
  do you differ between connection handshakes of interactive flows
  and bulk flows if not with the help of some static pattern? Depending
  on your actual policy you're likely being forced to drop out of band
  packets which will make the connection estabilishment very unreliable
  for interactive traffic which probably interfers with your QoS policy.

  Assuming you either ignore or solved the above problem, what happens
  if certain packets are classified wrong? Your flows are unreliable
  because they are subject to arbitary bursts of high latency or even
  packet loss.

  Assuming you use connection tracking and automatically classify all
  packets the same belonging to the same connection (which is a quite
  popular approach) what happens if parts of your interactive flows
  contain heavy bulky areas in between (e.g. ls -R / over a remote
  terminal connection)? It will pollute all your fine tuned interactive
  queues and take influence on other unrelated interactive flows.

As you can see it really depends on your needs and the actual problem
you're trying to solve. There is no easy and fully automatic solution
for the above. Actually it's quite hard to solve these with manual fine
tuned classification too but it is possible because you can divided
it into various problem domains and solve each independantly.

I will agree with you when you say that there is a possibility to
build a qdisc which will handle the typical home end-user setup with
remote terminal traffic, bulk data traffic and possibily some gaming
and I'll assist you in any way if you want to put effort into it
because it would be a good thing (tm).

> Though, you seem to be of the opinion that manual classification is
> easy enough and most traffic worth worrying about use DSCP flags
> effectively. Is that correct?

I think manually configurable classification tools have a more wide
spectrum of usability but I agree with you that those are harder to
use. I also think that DSCP is doing a good job and is enough for
more jobs than many people can imagine but it has strong limitations
and most problems need a combination of various techniques which is
the reason for the ematches to support logical expressions.

I think there is a big potential for making things easier to configure
but this needs time and a lot of effort. I think ematches are a step
in the right direction but a lot more effort needs to go into the
userspace tools. There is some work going on in the background but the
fact that usability is very time consuming makes it a slow process.
