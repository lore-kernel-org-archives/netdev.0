From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch] ipv4: initialize arp_tbl rw lock
Date: Sat, 15 Apr 2006 09:27:45 +0200
Message-ID: <20060415072745.GA17011@osiris.boeblingen.de.ibm.com>
References: <20060407081533.GC11353@osiris.boeblingen.de.ibm.com> <20060407074627.2f525b2e@localhost.localdomain> <20060408100213.GA9412@osiris.boeblingen.de.ibm.com> <20060408.031404.111884281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fpavlic@de.ibm.com, davem@sunset.davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:52692 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1750749AbWDOH15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 03:27:57 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060408.031404.111884281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Ok, so the problem seems to be that inet_init gets called after qeth_init.
> > Looking at the top level Makefile this seems to be true for all network
> > drivers in drivers/net/ and drivers/s390/net/ since we have
> > 
> > vmlinux-main := $(core-y) $(libs-y) $(drivers-y) $(net-y)
> > 
> > The patch below works for me... I guess there must be a better way to make
> > sure that any networking driver's initcall is made before inet_init?
> > 
> > Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> We could make inet_init() a subsystem init but I vaguely recall
> that we were doing that at one point and it broke things for
> some reason.
> 
> Perhaps fs_initcall() would work better.  Or if that causes
> problems we could create a net_initcall() that sits between
> fs_initcall() and device_initcall().
> 
> Or any other ideas?

Tried to figure out what is causing the delays I experienced when I replaced
module_init() in af_inet.c with fs_initcall(). After all it turned out that
synchronize_net() which is basicically nothing else than synchronize_rcu()
sometimes takes several seconds to complete?! No idea why that is...

callchain: inet_init() -> inet_register_protosw() -> synchronize_net()
