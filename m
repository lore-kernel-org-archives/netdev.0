From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] batched tc to improve change throughput
Date: 26 Jan 2005 08:48:33 -0500
Message-ID: <1106747313.1107.7.camel@jzny.localdomain>
References: <20050117165626.GE26856@postel.suug.ch>
	 <1106002197.1046.19.camel@jzny.localdomain>
	 <20050118134406.GR26856@postel.suug.ch>
	 <1106058592.1035.95.camel@jzny.localdomain>
	 <20050118145830.GS26856@postel.suug.ch>
	 <1106144009.1047.989.camel@jzny.localdomain>
	 <20050119165421.GB26856@postel.suug.ch>
	 <1106232168.1041.125.camel@jzny.localdomain>
	 <20050120153559.GG26856@postel.suug.ch>
	 <1106576005.1652.1292.camel@jzny.localdomain>
	 <20050124150634.GT23931@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050124150634.GT23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-24 at 10:06, Thomas Graf wrote:

> I'm not talking of the nlmsg_seq but rather a a sequence number with
> global or nl_family scope. It gets increased whenever a netlink
> message of that family is processed and is returned with the ack. If
> a userspace application wants to enforce atomicy between two requests
> which cannot be batched because a answer is expected in between then
> it could provide the expected sequence number and the request is only
> fullfilled if this is true. Example:
> 
> --> RTM_NEWLINK
> <-- answer
> <-- ACK (seq = 222)
> --> RTM_SETLINK (expect = 222)
> <-- ACK
> 
> Now if another netlink app interfers:
> 
> --> RTM_NEWLINK
> <-- answer
> <-- ACK (seq = 222)
> 
> -- other app --
> --> RTM_SETLINK
> <-- ACK (seq = 223)
> 
> -- back to first app --
> --> RTM_SETLINK (expect = 222)
> <-- ERROR
> 
> The application can then retry it's operation a few times and
> finally give up.  The main problem I see is to extend nlmsghdr
> in a way it stays compatible.

The best thing you could get out of this is a warning that something
changed under you i.e doesnt really solve the synchronization issue. 
[And a lot more complexity is introduced - if you say you want to change
the netlink header and maintain state in the kernel].

> > My thoughts now are you need to build on top of libnetlink - another
> > library. Example, to administratively bring up a netdevice, one would
> > call something like
> > 
> > admin_up("eth0");
> > 
> > This is not to say you cant build a competing library to libnetlink, i
> > am just not sure it is worth the effort of having two competing
> > libraries doing almost the same thing (that need maintanance). 
> 
> I think it is, the feedback is overwhelming and people are already
> contributing to support more netlink users. As I said, 95% of the
> functionality is in iproute2 itself and not libnetlink. It is vital
> to have some kind of library to abstract the low level netlink
> functionality in a simple form to other applications. Currently it's
> quite hard to for example access the tc class tree, one can use
> libnetlink to do the request and parse the answer but everyone needs
> to write their own TLV parsing routines.

Your call really - you are the one who is going to maintain it;->
As for ease of use and avoiding users from knowing details of how
tlvs are put together etc - i think it doesnt matter how thats done
underneath the hood; it is still doable on top of current libnetlink. In
other words whats required, IMO, is something that hides netlink totaly
so that the programmer/user doesnt even get to see TLVs.
 
cheers,
jamal
