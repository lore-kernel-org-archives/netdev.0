From: David Howells <dhowells@redhat.com>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 14:33:45 +0100
Message-ID: <11217.1178285625@redhat.com>
References: <20070504132934.GD2291@2ka.mipt.ru>  <20070504131657.GA2291@2ka.mipt.ru> <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <5910.1178284095@redhat.com> <7884.1178285089@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755198AbXEDNdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:33:50 -0400
In-Reply-To: <20070504132934.GD2291@2ka.mipt.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> That is the same, dst is dereferenced as rtable.
> Cloned dst is returned, so it must be put back at the ned of the usage.

If that's the case, then why do you bother to clone it in route_get_raw()?
Surely that'll give you *two* clones...

BTW, it seems to work.  The attached function gives me:

	[0mount ] <== rxrpc_assess_MTU_size() [if_mtu 1500]

Thanks!

David

---
static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
{
	struct rtable *rt;
	struct flowi fl;
	int ret;

	peer->if_mtu = 1500;

	memset(&fl, 0, sizeof(fl));

	switch (peer->srx.transport.family) {
	case AF_INET:
		fl.oif = 0;
		fl.proto = IPPROTO_UDP,
		fl.nl_u.ip4_u.saddr = 0;
		fl.nl_u.ip4_u.daddr = peer->srx.transport.sin.sin_addr.s_addr;
		fl.nl_u.ip4_u.tos = 0;
		/* assume AFS.CM talking to AFS.FS */
		fl.uli_u.ports.sport = htonl(7001);
		fl.uli_u.ports.dport = htonl(7000);
		break;
	default:
		BUG();
	}

	ret = ip_route_output_key(&rt, &fl);
	if (ret < 0) {
		kleave(" [route err %d]", ret);
		return;
	}

	peer->if_mtu = dst_mtu(&rt->u.dst);
	kleave(" [if_mtu %u]", peer->if_mtu);
}
