From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] batched tc to improve change throughput
Date: 24 Jan 2005 09:13:26 -0500
Message-ID: <1106576005.1652.1292.camel@jzny.localdomain>
References: <20050117160539.GD26856@postel.suug.ch>
	 <1105979807.1078.16.camel@jzny.localdomain>
	 <20050117165626.GE26856@postel.suug.ch>
	 <1106002197.1046.19.camel@jzny.localdomain>
	 <20050118134406.GR26856@postel.suug.ch>
	 <1106058592.1035.95.camel@jzny.localdomain>
	 <20050118145830.GS26856@postel.suug.ch>
	 <1106144009.1047.989.camel@jzny.localdomain>
	 <20050119165421.GB26856@postel.suug.ch>
	 <1106232168.1041.125.camel@jzny.localdomain>
	 <20050120153559.GG26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050120153559.GG26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-01-20 at 10:35, Thomas Graf wrote:
> * jamal <1106232168.1041.125.camel@jzny.localdomain> 2005-01-20 09:42
> > I like it. Assuming we can have arbitrary hierachies; you just show one
> > level - but that may be just the example at hand. Given that should be
> > able to meet the layout requirements that Lennert alluded to earlier.
> 
> It doesn't include any context code, the BNF:
> 
> PARSER    := TOPNODE*
> TOPNODE   := NODELIST DESC LONG_DESC
> NODELIST  := NODE*
> NODE      := DESC [ NODELIST ] [ ARGUMENT ] [ ATTRS ] [ END_POINT ]
> END_POINT := possible end of command
> ATTRS     := ATTR*
> ATTR      := KEY [ VALUE ]
> ARGUMENT  := VALUE [ DESC ]
> 
> Not sure if this helps, I attached a complete module below.

Theres a few holes in the BNF, but i dont think that matters that much.
When the time comes it can be cleaned up.
Should be noted that all iproute2 apps already have a very concise BNF. 

> > This is the part i am a little uncomfortable with. If you can make that
> > library maybe part of iproute2 it would ease maintanance. Extend
> > libnetlink or have another layer on top of it. 
> > I know you have already put the effort, but consider this thought.
> 
> We can move it into iproute2 but the code really differs from iproute2
> and code sharing is almost impossible. We can make iproute2 use it
> at some point but that doesn't make much sense for me.
> 

I am not sure which path would be better .. 

> 
> > >  - Seq counter in netlink, increased evertime a netlink message
> > >    gets processed and returned in ack. A netlink request may contain
> > >    a flag and the expected sequence number and the request gets only
> > >    processed if they match, otherwise the request fails. (my favourite)
> 
> Do you have any objections on this?

A seq number in netlink is infact a transaction identifier (as opposed
to a message identifier). We also have a window of 1 for a very good
reason - simplicty.
If what you are saying is we muck around seq numbers, i think its a bad
idea.

> Indeed, that would serve me well and we can avoid the userspace daemon.
> It doesn't even have to be a proxy, a simple callback hook capable of
> returning an action would be enough for my purpose.
> 

Sorry did not get an iota of time to work more on this over the weekend
(kid decided to own me over the weekend).
One thing to note is if you cant have multuiple apps requesting for 
RTM_XXXACTION redirects i.e you can only have one. And if this one app
disapears, it is a DOS. So a daemon may be necessary just so we can
check from the kernel if the app is still alive (after some timeout) and
if not we can cleanup state for other apps to reuse the redirect.

> NOTE: Read bottom-up:

Looks very good.
My thoughts now are you need to build on top of libnetlink - another
library. Example, to administratively bring up a netdevice, one would
call something like

admin_up("eth0");

This is not to say you cant build a competing library to libnetlink, i
am just not sure it is worth the effort of having two competing
libraries doing almost the same thing (that need maintanance). 

cheers,
jamal
