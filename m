From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 03/10] net: add IEEE 802.15.4 socket family
	implementation
Date: Thu, 4 Jun 2009 15:16:34 +0400
Message-ID: <20090604111634.GA28064@doriath.ww600.siemens.net>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com> <20090603173214.6d3997f7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090603173214.6d3997f7.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 03, 2009 at 05:32:14PM -0700, Andrew Morton wrote:
> On Mon,  1 Jun 2009 18:54:44 +0400
> Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > Add support for communication over IEEE 802.15.4 networks. This implementation
> > is neither certified nor complete, but aims to that goal. This commit contains
> > only the socket interface for communication over IEEE 802.15.4 networks.
> > One can either send RAW datagrams or use SOCK_DGRAM to encapsulate data
> > inside normal IEEE 802.15.4 packets.
> > 
> > Configuration interface, drivers and software MAC 802.15.4 implementation will
> > follow.
> > 
> > Initial implementation was done by Maxim Gorbachyov, Maxim Osipov and Pavel
> > Smolensky as a research project at Siemens AG. Later the stack was heavily
> > reworked to better suit the linux networking model, and is now maitained
> > as an open project partially sponsored by Siemens.
> > 
> 
> Some drive-by nitpicking, and I saw a bug...
> 
> > +	switch (addr->addr_type) {
> > +	case IEEE802154_ADDR_LONG:
> > +		rtnl_lock();
> > +		dev = dev_getbyhwaddr(net, ARPHRD_IEEE802154, addr->hwaddr);
> > +		if (dev)
> > +			dev_hold(dev);
> > +		rtnl_unlock();
> > +		break;
> > +	case IEEE802154_ADDR_SHORT:
> > +		if (addr->pan_id != 0xffff && addr->short_addr != IEEE802154_ADDR_UNDEF && addr->short_addr != 0xffff) {
> > +			struct net_device *tmp;
> > +
> > +			rtnl_lock();
> > +
> > +			for_each_netdev(net, tmp) {
> > +				if (tmp->type == ARPHRD_IEEE802154) {
> > +					if (IEEE802154_MLME_OPS(tmp)->get_pan_id(tmp) == addr->pan_id
> > +					  && IEEE802154_MLME_OPS(tmp)->get_short_addr(tmp) == addr->short_addr) {
> 
> You must use very wide xterms :(

~120 chars in width :)  We prefer to have a single code line split between
several screen lines, rather than split it manually in some weird places
just to justify width of 80 chars.

> 
> > +						dev = tmp;
> > +						dev_hold(dev);
> > +						break;
> > +					}
> > +				}
> > +			}
> > +
> > +			rtnl_unlock();
> > +		}
> > +		break;
> > +	default:
> > +		pr_warning("Unsupported ieee802154 address type: %d\n", addr->addr_type);
> > +		break;
> > +	}
> > +
> > +	return dev;
> > +}
> > +
> >
> > ...
> >
> > +static int ieee802154_create(struct net *net, struct socket *sock, int protocol)
> > +{
> > +	struct sock *sk;
> > +	int rc;
> > +	struct proto *proto;
> > +	const struct proto_ops *ops;
> > +
> > +	/* FIXME: init_net */
> > +	if (net != &init_net)
> > +		return -EAFNOSUPPORT;
> 
> yeah, I was going to ask about that.  What's the problem here?

The FIXME was dedicated to the fact that I didn't understand what is
this. The code fragment is c&p from lots of examples of similar code
(check can, appletalk, etc. for example)

> > +	switch (sock->type) {
> > +	case SOCK_RAW:
> > +		proto = &ieee802154_raw_prot;
> > +		ops = &ieee802154_raw_ops;
> > +		break;
> > +	case SOCK_DGRAM:
> > +		proto = &ieee802154_dgram_prot;
> > +		ops = &ieee802154_dgram_ops;
> > +		break;
> > +	default:
> > +		rc = -ESOCKTNOSUPPORT;
> > +		goto out;
> > +	}
> > +
> > +	rc = -ENOMEM;
> > +	sk = sk_alloc(net, PF_IEEE802154, GFP_KERNEL, proto);
> > +	if (!sk)
> > +		goto out;
> > +	rc = 0;
> > +
> > +	sock->ops = ops;
> > +
> > +	sock_init_data(sock, sk);
> > +	/* FIXME: sk->sk_destruct */
> 
> ?

Oh... I nearly forgot about this. When writing this code, I examined
several existing address families. Usually (but not always) the sk_destruct
callback will purge sk_receive_queue and sk_write_queue. However I
didn't understand why and in which case should these queues (or others)
be purged. Could please one clarify this?

> > ...
> >
> > +static void af_ieee802154_remove(void)
> 
> Could be __exit, althugh __exit doesn't do much (it used to be
> implemented on UML and might still be).

Added. BTW: I thought, that __exit functions aren't added to (or are
stripped from) the final vmlinux image. Am I wrong?

> >
> > +static inline struct dgram_sock *dgram_sk(const struct sock *sk)
> > +{
> > +	return (struct dgram_sock *)sk;
> 
> Better to use container_of() - it's clearer and doesn't assume that
> dgram_sock.sk is the first member.

Fixed.

> > +}
> >
> > ...
> >
> > +static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
> > +{
> > +	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
> 
> sigh, more casting.  Often these things can be done in ways which are
> nicer to the C type system.

Unfortunately sockaddr things can't be done in a more clean way IMO.

> > +	struct dgram_sock *ro = dgram_sk(sk);
> > +	int err = 0;
> > +	struct net_device *dev;
> > +
> > +	ro->bound = 0;
> > +

> > ...
> >
> > +struct proto ieee802154_dgram_prot = {
> 
> I suspect this could/should be const.

No. proto_register changes the passed protocol struct during
registration.

> 
> > +	.name		= "IEEE-802.15.4-MAC",
> > +	.owner		= THIS_MODULE,
> > +	.obj_size	= sizeof(struct dgram_sock),
> > +	.init		= dgram_init,
> > +	.close		= dgram_close,
> > +	.bind		= dgram_bind,
> > +	.sendmsg	= dgram_sendmsg,
> > +	.recvmsg	= dgram_recvmsg,
> > +	.hash		= dgram_hash,
> > +	.unhash		= dgram_unhash,
> > +	.connect	= dgram_connect,
> > +	.disconnect	= dgram_disconnect,
> > +	.ioctl		= dgram_ioctl,
> > +};
> > +

-- 
With best wishes
Dmitry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
