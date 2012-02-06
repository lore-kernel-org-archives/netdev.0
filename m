From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 6 Feb 2012 09:23:58 -0800
Message-ID: <CAG4TOxOBCbEEOtP62ZM1R3-6umebdbJFkK0bnjphLCZOgHzt1g@mail.gmail.com>
References: <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120206.113145.1284864994961472499.davem@davemloft.net> <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120206.115859.1384761795375582044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120206.115859.1384761795375582044.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2012 at 8:58 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrot=
e:
>
> So if IPoIB path resolution was properly integrated into the neighbou=
r
> cache state machine, instead of being implemented awkwardly in the
> device transmit path, this crap wouldn't be necessary right?
>
> So here we have yet another incredibly painful side effect of how
> IPoIB path resolution works.
>
> Roland, I want you to seriously consider a way, any way, to get rid o=
f
> how IPoIB does path resolution. =A0It must be fully integrated into t=
he
> neighbour layer, the neighbour layer must be knowledgable about how
> path resolution is a necessary step for a neighbour entry to enter th=
e
> valid state, and I want all of this awkward neighbour handling code
> removed from the transmit path of IPoIB.
>
> And finally it must not lie about it's hardware header length.

I would love to clean this up.  But I don't know how to do it.

IMHO the problem is in the IPoIB RFC: (4391) which makes
a distinction between an "encapsulation header" and the "link
layer address".  The LL address is what we put into ARP and
ND packets, and so I think we are forced into exposing that
to the network stack as our hardware address.

However this LL address is not actually what we need to send
a packet -- we need to take the GID of our destination and send
a query to the subnet manager to resolve it to a path.  And this
query really is an RPC to a remote entity somewhere else on
the network, so we have to do it asynchronously etc.

Now the part I don't know how to handle is when the network
stack gives us a LL address to send an ARP or something to
but the skb has no dst attached.  Suppose I don't have a path
for that LL address when I get that skb with no dst into my
=2Ehard_header method.  Where do I stick the LL addr to keep
around until the packet shows up in the xmit function?

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
