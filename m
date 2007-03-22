From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: Thu, 22 Mar 2007 21:59:44 +0300
Message-ID: <20070322185944.GA3802@2ka.mipt.ru>
References: <20070322180957.GA17793@2ka.mipt.ru> <20070322114304.1e516507@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57463 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964944AbXCVS74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 14:59:56 -0400
Content-Disposition: inline
In-Reply-To: <20070322114304.1e516507@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 11:43:04AM -0700, Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> 
> > 
> > diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> > index 2a20f48..f11b4e7 100644
> > --- a/include/linux/netlink.h
> > +++ b/include/linux/netlink.h
> > @@ -151,7 +151,6 @@ struct netlink_skb_parms
> >  #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
> >  #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
> >  
> > -
> >  extern struct sock *netlink_kernel_create(int unit, unsigned int groups, void (*input)(struct sock *sk, int len), struct module *module);
> >  extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
> >  extern int netlink_has_listeners(struct sock *sk, unsigned int group);
> 
> Minor nit this a one line blank only diff, probably just editing crap.

I tried to put there netlink socket definition, but it does not compile
without major surgery, so I removed it back and dropped one line.
Committed via 'git commit -a -m', so it was too late to change.
 
> >  static inline void udp_lib_close(struct sock *sk, long timeout)
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 8d65d64..abe1632 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -901,7 +901,9 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
> >  		sock_copy(newsk, sk);
> >  
> >  		/* SANITY */
> > +#ifndef CONFIG_MDT_LOOKUP
> >  		sk_node_init(&newsk->sk_node);
> > +#endif
> >  		sock_lock_init(newsk);
> >  		bh_lock_sock(newsk);
> 
> I would rather not see ifdef's in code. Could you just stub
> out the function in the include file?

I would prefer to get rid of hash tables at all - code is full of such
ifdefs. But in short run it can be replaced - I even started it with TCP's
inet_lookup and friends.
 
> >  
> > diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> > index 9e8ef50..5bfb0dc 100644
> > --- a/net/ipv4/Kconfig
> > +++ b/net/ipv4/Kconfig
> > @@ -1,6 +1,14 @@
> >  #
> >  # IP configuration
> >  #
> > +
> > +config MDT_LOOKUP
> > +	bool "Multidimensional trie socket lookup"
> > +	depends on !INET_TCP_DIAG
> > +	help
> > +	  This option replaces traditional hash table lookup for TCP sockets
> > +	  with multidimensional trie algorithm (similar to judy trie).
> 
> So you had to break the TCP_DIAG output to make this work.
> Please fix, the ss command is useful.

Yes, current code does not support statistics.
Existing stats run over whole hash table, I do not like such approach,
so I will introduce a per-protocol lists of all sockets, which can be
accessed from statistics code, but it is next step.

> > diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> > index cf358c8..8c32545 100644
> > --- a/net/ipv4/af_inet.c
> > +++ b/net/ipv4/af_inet.c
> > @@ -1360,6 +1360,7 @@ fs_initcall(inet_init);
> >  /* ------------------------------------------------------------------------ */
> >  
> >  #ifdef CONFIG_PROC_FS
> > +#ifndef CONFIG_MDT_LOOKUP
> >  static int __init ipv4_proc_init(void)
> >  {
> >  	int rc = 0;
> > @@ -1388,7 +1389,12 @@ out_raw:
> >  	rc = -ENOMEM;
> >  	goto out;
> >  }
> > -
> > +#else
> > +static int __init ipv4_proc_init(void)
> > +{
> > +	return 0;
> > +}
> > +#endif
> 
> If you are making it into a stub, why not get rid of it
> completely?

I did it for some parts, but created a stub for another.
Proc insterface as long as netlink statistics is not supported, since I
do not want to run over whole tree to search sockets, so I just removed
it.

> > +
> > +#define MDT_SET_LEAF_STORAGE(leaf, ptr) do { \
> > +	rcu_assign_pointer((leaf), (struct mdt_node *)(((unsigned long)(ptr)) | MDT_LEAF_STRUCT_BIT)); \
> > +} while (0)
> 
> Macro yuckinesss.

You did not see what Rusty created...
:)

> <rest deleted>
> 
> What is the code size change with this?

 include/linux/netlink.h            |    1 -
 include/net/af_unix.h              |    4 +-
 include/net/inet_connection_sock.h |    5 +-
 include/net/inet_hashtables.h      |    5 -
 include/net/inet_timewait_sock.h   |   12 +
 include/net/lookup.h               |  120 +++++++
 include/net/netlink.h              |   29 ++
 include/net/raw.h                  |    1 +
 include/net/sock.h                 |  106 ++++---
 include/net/tcp.h                  |    7 +-
 include/net/udp.h                  |    5 +
 net/core/sock.c                    |    2 +
 net/ipv4/Kconfig                   |    8 +
 net/ipv4/Makefile                  |    7 +-
 net/ipv4/af_inet.c                 |    8 +-
 net/ipv4/icmp.c                    |   10 +
 net/ipv4/inet_connection_sock.c    |    6 +-
 net/ipv4/inet_diag.c               |   11 +-
 net/ipv4/inet_timewait_sock.c      |   35 ++-
 net/ipv4/ip_input.c                |   10 +-
 net/ipv4/mdt.c                     |  598 ++++++++++++++++++++++++++++++++++++
 net/ipv4/raw.c                     |   47 +++-
 net/ipv4/tcp.c                     |   18 +-
 net/ipv4/tcp_ipv4.c                |   66 ++++-
 net/ipv4/tcp_minisocks.c           |    6 +
 net/ipv4/udp.c                     |  133 +++++---
 net/ipv4/udplite.c                 |   14 +-
 net/netlink/af_netlink.c           |  230 ++++++++------
 net/packet/af_packet.c             |   13 +-
 net/unix/af_unix.c                 |   51 +++-
 net/unix/garbage.c                 |   10 +-
 31 files changed, 1333 insertions(+), 245 deletions(-)

Nothing was deleted actually, but wrapped into ifdef/endif stuff all
over the place and moved from one file to another - tree should even 
compile if config option is not set.

Thanks for quick review...

> -- 
> Stephen Hemminger <shemminger@linux-foundation.org>

-- 
	Evgeniy Polyakov
