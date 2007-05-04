From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: How to find I/F to destination
Date: Fri, 4 May 2007 16:54:38 +0400
Message-ID: <20070504125438.GA5439@2ka.mipt.ru>
References: <5484.1178282928@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44472 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754590AbXEDMyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 08:54:52 -0400
Content-Disposition: inline
In-Reply-To: <5484.1178282928@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 01:48:48PM +0100, David Howells (dhowells@redhat.com) wrote:
> 
> Hi,

Hi David.

> I would like to determine through which interface packets sent to a particular
> UDP destination will go through, and so determine the MTU size for that
> interface.  Can anyone suggest a good way of doing this from within the
> kernel?

I used following code in netchannels:

static int netchannel_ip_route_output_flow(struct rtable **rp, struct flowi *flp, int flags)
{
	int err;

	err = __ip_route_output_key(rp, flp);
	if (err)
		return err;

	if (flp->proto) {
		if (!flp->fl4_src)
			flp->fl4_src = (*rp)->rt_src;
		if (!flp->fl4_dst)
			flp->fl4_dst = (*rp)->rt_dst;
	}

	return 0;
}

struct dst_entry *route_get_raw(u32 saddr, u32 daddr, u16 sport, u16 dport, u8 proto)
{
	struct rtable *rt;
	struct flowi fl = { .oif = 0,
			    .nl_u = { .ip4_u =
				      { .saddr = saddr,
					.daddr = daddr,
					.tos = 0 } },
			    .proto = proto,
			    .uli_u = { .ports =
				       { .sport = sport,
					 .dport = dport } } };

	if (netchannel_ip_route_output_flow(&rt, &fl, 0))
		goto no_route;
	return dst_clone(&rt->u.dst);

no_route:
	return NULL;
}

This is basically a copied input route code.
dst entry, obtained from route_get_raw() holds a pointer to network device.

-- 
	Evgeniy Polyakov
