From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Mon, 24 Jan 2005 16:06:34 +0100
Message-ID: <20050124150634.GT23931@postel.suug.ch>
References: <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118145830.GS26856@postel.suug.ch> <1106144009.1047.989.camel@jzny.localdomain> <20050119165421.GB26856@postel.suug.ch> <1106232168.1041.125.camel@jzny.localdomain> <20050120153559.GG26856@postel.suug.ch> <1106576005.1652.1292.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106576005.1652.1292.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1106576005.1652.1292.camel@jzny.localdomain> 2005-01-24 09:13
> On Thu, 2005-01-20 at 10:35, Thomas Graf wrote:
> > > >  - Seq counter in netlink, increased evertime a netlink message
> > > >    gets processed and returned in ack. A netlink request may contain
> > > >    a flag and the expected sequence number and the request gets only
> > > >    processed if they match, otherwise the request fails. (my favourite)
> > 
> > Do you have any objections on this?
> 
> A seq number in netlink is infact a transaction identifier (as opposed
> to a message identifier). We also have a window of 1 for a very good
> reason - simplicty.
> If what you are saying is we muck around seq numbers, i think its a bad
> idea.

I'm not talking of the nlmsg_seq but rather a a sequence number with
global or nl_family scope. It gets increased whenever a netlink
message of that family is processed and is returned with the ack. If
a userspace application wants to enforce atomicy between two requests
which cannot be batched because a answer is expected in between then
it could provide the expected sequence number and the request is only
fullfilled if this is true. Example:

--> RTM_NEWLINK
<-- answer
<-- ACK (seq = 222)
--> RTM_SETLINK (expect = 222)
<-- ACK

Now if another netlink app interfers:

--> RTM_NEWLINK
<-- answer
<-- ACK (seq = 222)

-- other app --
--> RTM_SETLINK
<-- ACK (seq = 223)

-- back to first app --
--> RTM_SETLINK (expect = 222)
<-- ERROR

The application can then retry it's operation a few times and
finally give up.  The main problem I see is to extend nlmsghdr
in a way it stays compatible.

> My thoughts now are you need to build on top of libnetlink - another
> library. Example, to administratively bring up a netdevice, one would
> call something like
> 
> admin_up("eth0");
> 
> This is not to say you cant build a competing library to libnetlink, i
> am just not sure it is worth the effort of having two competing
> libraries doing almost the same thing (that need maintanance). 

I think it is, the feedback is overwhelming and people are already
contributing to support more netlink users. As I said, 95% of the
functionality is in iproute2 itself and not libnetlink. It is vital
to have some kind of library to abstract the low level netlink
functionality in a simple form to other applications. Currently it's
quite hard to for example access the tc class tree, one can use
libnetlink to do the request and parse the answer but everyone needs
to write their own TLV parsing routines.
