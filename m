From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Wed, 26 Jan 2005 15:35:45 +0100
Message-ID: <20050126143545.GK31837@postel.suug.ch>
References: <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118145830.GS26856@postel.suug.ch> <1106144009.1047.989.camel@jzny.localdomain> <20050119165421.GB26856@postel.suug.ch> <1106232168.1041.125.camel@jzny.localdomain> <20050120153559.GG26856@postel.suug.ch> <1106576005.1652.1292.camel@jzny.localdomain> <20050124150634.GT23931@postel.suug.ch> <1106747313.1107.7.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106747313.1107.7.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1106747313.1107.7.camel@jzny.localdomain> 2005-01-26 08:48
> On Mon, 2005-01-24 at 10:06, Thomas Graf wrote:
> 
> > I'm not talking of the nlmsg_seq but rather a a sequence number with
> > global or nl_family scope. It gets increased whenever a netlink
> > message of that family is processed and is returned with the ack. If
> > a userspace application wants to enforce atomicy between two requests
> > which cannot be batched because a answer is expected in between then
> > it could provide the expected sequence number and the request is only
> > fullfilled if this is true. Example:
> > 
> > --> RTM_NEWLINK
> > <-- answer
> > <-- ACK (seq = 222)
> > --> RTM_SETLINK (expect = 222)
> > <-- ACK
> > 
> > Now if another netlink app interfers:
> > 
> > --> RTM_NEWLINK
> > <-- answer
> > <-- ACK (seq = 222)
> > 
> > -- other app --
> > --> RTM_SETLINK
> > <-- ACK (seq = 223)
> > 
> > -- back to first app --
> > --> RTM_SETLINK (expect = 222)
> > <-- ERROR
> > 
> > The application can then retry it's operation a few times and
> > finally give up.  The main problem I see is to extend nlmsghdr
> > in a way it stays compatible.
> 
> The best thing you could get out of this is a warning that something
> changed under you i.e doesnt really solve the synchronization issue. 

Why? If we do the check with regard to the rtnl sem we can guarantee
atomicity. The comparison of the expected seq and the current seq must
be done before any action and within the rtnl semaphore. It is very
unlikely that someone interfers so strict locking is pretty inefficient.

rtnl_send_atomic(msg, expect_seq)
	retries := 10;
retry:
	res := send_msg(msg, expect_seq);
	if res = -ERETRY and --retries then
		goto retry;
	endif

	if retries = 0 then
		err "Timeout while trying to achieve atomic operation"
	endif

and in the kernel:

rtnl_lock();
if expect_seq != seq then
   rtnl_unlock()
   return -ERETRY;
endif

... atomic action can take place here ...

Of course this only works if netlink requests itself are
synchronized in the relevant netlink family.

> [And a lot more complexity is introduced - if you say you want to change
> the netlink header and maintain state in the kernel].

This is the big problem, there is no padding gap common to all rtnl users.

What we can do is to set a flag in nlmsghdr stating that a u32 block of
data follows the nlmsg header before the netlink user specific header,
i.e.

 +---------------------------------+
 | nlmsghdr flags |= NLM_F_EXP_SEQ |
 +---------------------------------+
 | expected_seq (u32)              |
 +---------------------------------+
 | netlink user specific data      |
 +---------------------------------+

I'd even go one step further and define a header options chain like in
IPv6 so we can add more header attributes later on, like:

 +--------------------------------+
 | nlmsghdr flags |= NLM_F_OPTS   |
 +--------------------------------+
 | size=4, type=expt_seq, next=0  |
 +- - - - - - - -  - - - - - - - -+
 | expected sequence              |
 +--------------------------------+
 | netlink user specific data     |
 +--------------------------------+

Thoughts?

> Your call really - you are the one who is going to maintain it;->
> As for ease of use and avoiding users from knowing details of how
> tlvs are put together etc - i think it doesnt matter how thats done
> underneath the hood; it is still doable on top of current libnetlink. In
> other words whats required, IMO, is something that hides netlink totaly
> so that the programmer/user doesnt even get to see TLVs.

Agreed, I even hide the structs exported to usersapce to avoid breakage,
i.e. i don't export tc_stats directly for example.
