From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: Resurrecting due to huge ipoib perf regression - [BUG] skb
 corruption and kernel panic at forwarding with fragmentation
Date: Fri, 8 Jul 2016 10:51:31 -0600
Message-ID: <20160708165131.GA23650@obsidianresearch.com>
References: <CAL1RGDV3u4bzuyGkMZGJQOiXje_qVh7AA-2nJMm2J2TR60H72g@mail.gmail.com>
 <CAKgT0UerNfn9Uas34y6_+Fa4ALCcToQvNdbEkH1erVosa=xvXg@mail.gmail.com>
 <CAL1RGDVgjRcb23jQQqJ4W-dfm8OkiH6n7hktVLX4mo-oUGj4gA@mail.gmail.com>
 <20160707231423.GA21039@obsidianresearch.com>
 <CAL1RGDWbUCi8OT1yGw7mhV9ivpmBqXa4jZ4Lp4op=L5ODK+r3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	Thadeu Lima de Souza Cascardo <cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAL1RGDWbUCi8OT1yGw7mhV9ivpmBqXa4jZ4Lp4op=L5ODK+r3w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 08, 2016 at 07:18:11AM -0700, Roland Dreier wrote:
> On Thu, Jul 7, 2016 at 4:14 PM, Jason Gunthorpe
> <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> > We have neighbour_priv, and ndo_neigh_construct/destruct now ..
> >
> > A first blush that would seem to be enough to let ipoib store the AH
> > and other path information in the neigh and avoid the cb? At least the
> > example in clip sure looks like what ipoib needs to do.
> 
> Do you think those new facilities let us go back to using the neigh
> and still avoid the issues that led to commit b63b70d87741 ("IPoIB:
> Use a private hash table for path lookup in xmit path")?

Well, the priv stuff were brought up in the discussion around
b63b70d87741 but never fully analyzed. Maybe it could have been used
to solve that problem, who knows.. I guess it doesn't help this exact
issue because we don't have a dst at hard header time anyhow.

But, DaveM suggested how to handle our current problem in the above thread:

http://marc.info/?l=linux-rdma&m=132813323907877&w=2

Which is the same route CLIP took:

331         struct dst_entry *dst = skb_dst(skb);
347         rt = (struct rtable *) dst;
348         if (rt->rt_gateway)
349                 daddr = &rt->rt_gateway;
350         else
351                 daddr = &ip_hdr(skb)->daddr;
352         n = dst_neigh_lookup(dst, daddr);

(DaveM said it should be &ip/ipv6_hdr(skb)->daddr, not the rtable cast)

Last time this was brought up you were concerned about ARP, ARP
sets skb_dst after calling dev_hard_header:

310         skb = arp_create(type, ptype, dest_ip, dev, src_ip,
311                          dest_hw, src_hw, target_hw);
312         if (!skb)
313                 return;
314
315         skb_dst_set(skb, dst_clone(dst));

However, there is at least one fringe case (arp_send) where the dst is
left NULL. Presumably there are other fringe cases too..

So, it appears, the dst and neigh can be used for all performances cases.

For the non performance dst == null case, can we just burn cycles and
stuff the daddr in front of the packet at hardheader time, even if we
have to copy?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
