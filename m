From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: 30 Mar 2005 07:53:30 -0500
Message-ID: <1112187210.1090.140.camel@jzny.localdomain>
References: <1111864971.1092.904.camel@jzny.localdomain>
	 <20050326194707.GA9872@gondor.apana.org.au>
	 <1111867875.1089.915.camel@jzny.localdomain>
	 <20050327081848.GA13428@gondor.apana.org.au>
	 <1111950449.1089.938.camel@jzny.localdomain>
	 <20050330004903.GA3399@gondor.apana.org.au>
	 <1112184572.1089.80.camel@jzny.localdomain>
	 <20050330122321.GA10602@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050330122321.GA10602@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert,

On Wed, 2005-03-30 at 07:23, Herbert Xu wrote:

> > Thinking ... thinking .. Good point.
> > 
> > I defineteley need at least:
> > a) case original message sent via netlink: pid of the original process
> > so when i multicast in netlink i dont echo back to it.
> 
> I don't think you need to do that.  RFC 2367 says that the kernel should
> send that message to all listening processes.  It doesn't put an exception
> on the sending process.
> 
> This makes sense also because the echoed message is really a new packet
> sent by the kernel.  It's not necessarily equal to the original packet.
> 

I may be influenced by some of the behaviors of rtnetlink users then.
Typically (I may need to go back and double check), they dont echo back.
The final response of success is unicast though if a ACK flag was set in
the original message. Actually an echo may happen in addition to the
success indicator if such an echo is requested for by NLM_F_ECHO.
I will go back and scan, but example:

---
     netlink_broadcast(rtnl, skb, pid, RTMGRP_IPV4_ROUTE, GFP_KERNEL);
        if (n->nlmsg_flags&NLM_F_ECHO)
                netlink_unicast(rtnl, skb, pid, MSG_DONTWAIT);
----

> In fact checking the socket pid is not enough to avoid sending the
> message back to the originator.  For instance, if the originator
> used a different socket for receiving multicast messages then this
> wouldn't work anyway.
> 

True.

> For netlink it is important to use a different socket for receiving
> multicast messages since otherwise you run the risk of losing unicast
> messages when it overruns.
> 

This may be the reason actually now that i think of it. Its not the user
you are avoiding to echo back to, rather the overloading the user. What
i could do is double check for the NLM_F_ECHO as well so we give the
user a choice to receive the message as well if they indicate they need
it. i.e something along:

if (n->nlmsg_flags&NLM_F_ECHO)
  broadcast to all
else
  just send to all sans the originator

sounds reasonable?

I am actually indifferent - if you think strongly about it then i could
be swayed (pending testing)

cheers,
jamal  
