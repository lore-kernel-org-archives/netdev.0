From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 4 Oct 2007 10:40:57 -0300
Message-ID: <20071004134057.GF3576@ghostprotocols.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131108.31727.2@janus.isnogud.escape.de> <20071002143855.GG7881@ghostprotocols.net> <ygfbqbf14j0.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:54431 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002AbXJDNlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 09:41:12 -0400
Received: by ug-out-1314.google.com with SMTP id z38so326455ugc
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2007 06:41:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ygfbqbf14j0.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Oct 04, 2007 at 01:51:47PM +0200, Urs Thuermann escreveu:
> Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:
> 
> > > +struct sockaddr_can {
> > > +	sa_family_t can_family;
> > > +	int         can_ifindex;
> > > +	union {
> > > +		struct { canid_t rx_id, tx_id; } tp16;
> > > +		struct { canid_t rx_id, tx_id; } tp20;
> > > +		struct { canid_t rx_id, tx_id; } mcnet;
> > > +		struct { canid_t rx_id, tx_id; } isotp;
> > > +	} can_addr;
> > 
> > Again being curious, what is the value of this union of all its members
> > have the same definition? Backward source code compatibility?
> 
> As Oliver already wrote, different CAN transport protocols may use
> different sockaddr structures.  Therefore, we have made can_addr a
> union.  The four we have defined already, all look the same, but
> other, future protocols may define a different structure.
> 
> > > +struct can_proto {
> > > +	int              type;
> > > +	int              protocol;
> > > +	int              capability;
> > > +	struct proto_ops *ops;
> > > +	struct proto     *prot;
> > > +};
> > > +
> > > +/* function prototypes for the CAN networklayer core (af_can.c) */
> > > +
> > > +extern int  can_proto_register(struct can_proto *cp);
> > > +extern void can_proto_unregister(struct can_proto *cp);
> > 
> > We have proto registering infrastructure for bluetooth, inet and now
> > CAN, have you looked at:
> > 
> > struct inet_protosw;
> > proto_{register,unregister}, etc?
> 
> Yes, I know inet_protosw and inet_{,un}register_protosw().  But we
> can't use inet_register_protosw().
> 
> And can_proto_register() does use proto_register().  What exactly do
> you want to suggest?

Sorry, I was in a hurry and didn't completed my thoughts on how to share
more code and data structures.

My first reaction was: hey, struct can_proto has almost the same
definition as struct inet_protosw, and can_proto_register() looks like
inet_register_protosw().

can_proto_register() calls proto_register, inet_register_protosw
doesn't. But protocols such as DCCP and SCTP, call both
inet_register_protosw and proto_register. Perhaps we can make
inet_register_protosw behave like can_proto_register and do the
proto_register(inet_protosw->prot) for us.

Looking at inet_init in net/ipv4/af_inet.c we see that we do the same
for udp, tcp and raw too. There we also call proto_register +
inet_register_protosw.

See the possibilites for code sharing? Having just one way of
registering protocols would reduce complexity for new protocol writers
and for people that browse the code only when trying to fix some problem
and don't want to get lost in many ways of doing the same thing.

struct can_proto could be removed and struct inet_protosw could be
renamed to reflect the fact that it is, after all, not inet specific at
all.

So this is not something to "fix" on your implementation. It looks OK.
But we could use more hands on reducing complexity on the Linux network
protocol infrastructure and you would get free fixes and improvements
when people improve the inet protocols 8)

DCCP has been collecting dividends for quite a while for working like
that 8)

- Arnaldo
