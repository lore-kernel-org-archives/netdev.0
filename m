From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Fri, 08 Jul 2005 00:30:14 -0700 (PDT)
Message-ID: <20050708.003014.125896217.davem@davemloft.net>
References: <20050706124206.GW16076@postel.suug.ch>
	<20050707.141718.85410359.davem@davemloft.net>
	<42CE22CE.7030902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42CE22CE.7030902@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 08 Jul 2005 08:53:02 +0200

> About making sk_buff smaller, I use this patch to declare 'struct
> sec_path *sp' only ifdef CONFIG_XFRM, what do you think ?  I also
> use a patch to declare nfcache, nfctinfo and nfct only if
> CONFIG_NETFILTER_CONNTRACK or CONFIG_NETFILTER_CONNTRACK_MODULE are
> defined, but thats more intrusive.  Also, tc_index is not used if
> CONFIG_NET_SCHED only is declared but none of CONFIG_NET_SCH_* In my
> case, I am using CONFIG_NET_SCHED only to be able to do : tc -s -d
> qdisc

Distributions enable all of the ifdefs, and that is thus the
size and resultant performance most users see.

That's why I'm working on shrinking the size assuming all the
config options are enabled, because that is the reality for most
installations.

For all of this stuff we could consider stealing some ideas from BSD,
namely doing something similar to their MBUF tags.

If a subsystem wants to add a cookie to a networking buffer, it
allocates a tag and links it into the struct.  So, you basically get
away with only one pointer (a struct hlist_head).  We could use this
for the security, netfilter, and TC stuff.  I don't know exactly what
our tags would look like, but perhaps:

struct skb_tag;
struct skb_tag_type {
	void (*destructor)(struct skb_tag *);
	kmem_cache_t	*slab_cache;
	const char	*name;
};

struct skb_tag {
	struct hlist_node	list;
	struct skb_tag_type	*owner;
	int			tag_id;
	char			data[0];
};

struct sk_buff {
	...
	struct hlist_head	tag_list;
	...
};

Then netfilter does stuff like:

	struct sk_buff *skb;
	struct skb_tag *tag;
	struct conntrack_skb_info *info;

	tag = skb_find_tag(skb, SKB_TAG_NETFILTER_CONNTRACK);
	info = (struct conntrack_skb_info *) tag->data;

etc. etc.

The downsides to this approach are:

1) Tagging an SKB eats a memory allocation, which isn't nice.
   This is mainly why I haven't mentioned this idea before.

   It may be that, on an active system, the per-cpu SLAB caches
   for such tag objects might keep the allocation costs real low.
   Another factor is that tags are relatively tiny, so a large
   number of them fit in one SLAB.

   But on the other hand we've been trying to remove per-packet
   kmalloc() counts, see the SKB fast-clone discussions about that.
   And people ask for SKB recycling all the time.

2) skb_clone() would get more expensive.  This is because you'd
   need to clone the SKB tags as well.

   There is the possibility to hang the tags off of the
   skb_shinfo() area.  I know this idea sounds crazy, but
   the theory goes that if the netfilter et. al info would
   change (and thus, so would the assosciative tags), then
   you'd need to COW the SKB anyways.

   This is actually an idea worth considering regardless of
   whether we do tags or not.  It would result in less reference
   counting when we clone an SKB with netfilter stuff or
   security stuff attached.

Overall I'm not too thrilled with the idea, but I'm enthusiatic
about being convinced otherwise since this would shrink sk_buff
dramatically. :-)
