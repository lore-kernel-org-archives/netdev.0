From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/17] netfilter: add struct nf_proto_net for register
 l4proto sysctl
Date: Wed, 23 May 2012 12:12:00 +0200
Message-ID: <20120523101200.GA2836@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1336985547-31960-2-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 04:52:11PM +0800, Gao feng wrote:
> From: Gao feng <gaofeng@cn.fujitus.com>
> 
> the struct nf_proto_net stroes proto's ctl_table_header and ctl_table,
> nf_ct_l4proto_(un)register_sysctl use it to register sysctl.
> 
> there are some changes for struct nf_conntrack_l4proto:
> - add field compat to identify if this proto should do compat.
> - the net_id field is used to store the pernet_operations id
>   that belones to l4proto.
> - init_net will be used to initial the proto's pernet data
> 
> and add init_net for struct nf_conntrack_l3proto too.

This patchset looks bette but there are still things that we have to
resolve.

The first one (regarding this patch 1/17) changes in:
* include/net/netfilter/nf_conntrack_l4proto.h
* include/net/netns/conntrack.h

should be included in:
[PATCH] netfilter: add namespace support for l4proto

And changes in:
* include/net/netfilter/nf_conntrack_l3proto.h

should be included in:
[PATCH] netfilter: add namespace support for l3proto

I already told you. A patch that adds a structure without using it,
is not good. The structure has to go together with the code uses it.

More comments below.

> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
> ---
>  include/net/netfilter/nf_conntrack_l3proto.h |    3 +++
>  include/net/netfilter/nf_conntrack_l4proto.h |    6 ++++++
>  include/net/netns/conntrack.h                |   12 ++++++++++++
>  3 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
> index 9699c02..9766005 100644
> --- a/include/net/netfilter/nf_conntrack_l3proto.h
> +++ b/include/net/netfilter/nf_conntrack_l3proto.h
> @@ -69,6 +69,9 @@ struct nf_conntrack_l3proto {
>  	struct ctl_table	*ctl_table;
>  #endif /* CONFIG_SYSCTL */
>  
> +	/* Init l3proto pernet data */
> +	int (*init_net)(struct net *net);
> +
>  	/* Module (if any) which this is connected to. */
>  	struct module *me;
>  };
> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
> index 3b572bb..a90eab5 100644
> --- a/include/net/netfilter/nf_conntrack_l4proto.h
> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
> @@ -22,6 +22,8 @@ struct nf_conntrack_l4proto {
>  	/* L4 Protocol number. */
>  	u_int8_t l4proto;
>  
> +	u_int8_t compat;

I don't see why we need this new field.

It seems to be set to 1 in each structure that has set:

.ctl_compat_table

to non-NULL. So, it's redundant.

Moreover, you already know from the protocol tracker itself if you
have to allocate the compat ctl table or not.

In other words: You set compat to 1 for nf_conntrack_l4proto_generic.
Then, you pass that compat value to generic_init_net via ->inet_net
again, but this information (that determines if the compat has to be
done or not) is already in the scope of the protocol tracker.

You have to fix this.

> +
>  	/* Try to fill in the third arg: dataoff is offset past network protocol
>             hdr.  Return true if possible. */
>  	bool (*pkt_to_tuple)(const struct sk_buff *skb, unsigned int dataoff,
> @@ -103,6 +105,10 @@ struct nf_conntrack_l4proto {
>  	struct ctl_table	*ctl_compat_table;
>  #endif
>  #endif
> +	int	*net_id;
> +	/* Init l4proto pernet data */
> +	int (*init_net)(struct net *net, u_int8_t compat);
> +
>  	/* Protocol name */
>  	const char *name;
>  
> diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
> index a053a19..1f53038 100644
> --- a/include/net/netns/conntrack.h
> +++ b/include/net/netns/conntrack.h
> @@ -8,6 +8,18 @@
>  struct ctl_table_header;
>  struct nf_conntrack_ecache;
>  
> +struct nf_proto_net {
> +#ifdef CONFIG_SYSCTL
> +	struct ctl_table_header *ctl_table_header;
> +	struct ctl_table        *ctl_table;
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	struct ctl_table_header *ctl_compat_header;
> +	struct ctl_table        *ctl_compat_table;
> +#endif
> +#endif
> +	unsigned int		users;
> +};
> +
>  struct netns_ct {
>  	atomic_t		count;
>  	unsigned int		expect_count;
