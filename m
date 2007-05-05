From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: How to find I/F to destination
Date: Sat, 5 May 2007 13:15:36 +0400
Message-ID: <20070505091535.GB5742@2ka.mipt.ru>
References: <20070504132934.GD2291@2ka.mipt.ru> <20070504131657.GA2291@2ka.mipt.ru> <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com> <7884.1178285089@redhat.com> <11217.1178285625@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:32857 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423148AbXEEJP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2007 05:15:56 -0400
Content-Disposition: inline
In-Reply-To: <11217.1178285625@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 02:33:45PM +0100, David Howells (dhowells@redhat.com) wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > That is the same, dst is dereferenced as rtable.
> > Cloned dst is returned, so it must be put back at the ned of the usage.
> 
> If that's the case, then why do you bother to clone it in route_get_raw()?
> Surely that'll give you *two* clones...
> 
> BTW, it seems to work.  The attached function gives me:
> 
> 	[0mount ] <== rxrpc_assess_MTU_size() [if_mtu 1500]
> 
> Thanks!
> 
> David
> 
> ---
> static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
> {
> 	struct rtable *rt;
> 	struct flowi fl;
> 	int ret;
> 
> 	peer->if_mtu = 1500;
> 
> 	memset(&fl, 0, sizeof(fl));
> 
> 	switch (peer->srx.transport.family) {
> 	case AF_INET:
> 		fl.oif = 0;
> 		fl.proto = IPPROTO_UDP,
> 		fl.nl_u.ip4_u.saddr = 0;
> 		fl.nl_u.ip4_u.daddr = peer->srx.transport.sin.sin_addr.s_addr;
> 		fl.nl_u.ip4_u.tos = 0;
> 		/* assume AFS.CM talking to AFS.FS */
> 		fl.uli_u.ports.sport = htonl(7001);
> 		fl.uli_u.ports.dport = htonl(7000);
> 		break;
> 	default:
> 		BUG();
> 	}
> 
> 	ret = ip_route_output_key(&rt, &fl);

This one is quite slow compared to atomic reference increase, so yes,
there are two clones - one for main 'route', which then is being cloned
for each used in fast path. When it is not needed anymore (netchannel is
removed), the first one is dropped.

> 	if (ret < 0) {
> 		kleave(" [route err %d]", ret);
> 		return;
> 	}
> 
> 	peer->if_mtu = dst_mtu(&rt->u.dst);
> 	kleave(" [if_mtu %u]", peer->if_mtu);
> }

-- 
	Evgeniy Polyakov
