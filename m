From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 3/7] CAN: Add raw protocol
Date: 04 Oct 2007 13:52:13 +0200
Message-ID: <ygf8x6j14ia.fsf@janus.isnogud.escape.de>
References: <20071002131006.31727.0@janus.isnogud.escape.de>
	<20071002131108.31727.3@janus.isnogud.escape.de>
	<20071002143001.GF7881@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:36056 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757579AbXJDLzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 07:55:49 -0400
In-Reply-To: <20071002143001.GF7881@ghostprotocols.net>; from Arnaldo Carvalho de Melo on Tue, 2 Oct 2007 11:30:01 -0300
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:

> > +static inline struct raw_sock *raw_sk(const struct sock *sk)
> > +{
> > +	return (struct raw_sock *)sk;
> > +}
> 
> 
> What if I want to do some kernel module that uses INET raw sockets
> (include/net/icmp.h) and CAN raw sockets? Namespace collision, could you
> please use can_raw_ for this namespace?

raw_sk is static so you can't use in another file where you include
include/net/icmp.h.  There is no collision.  Also, since it's inline
you won't even see it in a symbol table.

Hm, it's more than 10 years that I've tested ctags(1) and etags(1)
with several identical static names in different files and I don't
remember my results.  Do these tools have a problem with multiple
defs?  I think they shouldn't since C is explicitly designed for that.

> > +static unsigned int raw_poll(struct file *file, struct socket *sock,
> > +			     poll_table *wait)
> > +{
> > +	unsigned int mask = 0;
> > +
> > +	DBG("socket %p\n", sock);
> > +
> > +	mask = datagram_poll(file, sock, wait);
> > +	return mask;
> 
> What is the value of 'mask' here? Leftover from debugging?

Ah, yes.  We should remove it.

> > +static int raw_setsockopt(struct socket *sock, int level, int optname,
> > +			  char __user *optval, int optlen)
> > +{

> > +		lock_sock(sk);
> > +
> > +		if (ro->bound && ro->ifindex)
> > +			dev = dev_get_by_index(&init_net, ro->ifindex);
> 
> dev_get_by_index can fail, are you sure that raw_enable_filters can cope
> with this possibility?

When ro->ifindex != 0, the call to dev_get_by_index() shouldn't fail.
We also use lock_sock() here and in NETDEV_UNREGISTER, so there should
be no problem.


urs
