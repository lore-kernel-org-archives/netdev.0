From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/3 nf-next] netfilter: nf_tables: allow to bind table to
 net_device
Date: Tue, 26 May 2015 11:58:24 +0200
Message-ID: <20150526095824.GB3535@salvia>
References: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
 <1432558004-13481-3-git-send-email-pablo@netfilter.org>
 <20150526004840.GB23370@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150526004840.GB23370@vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 26, 2015 at 09:48:41AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> On Mon, May 25, 2015 at 02:46:41PM +0200, Pablo Neira Ayuso wrote:
> > This patch adds the internal NFT_AF_NEEDS_DEV flag to indicate that you must
> > attach this table to a net_device.
> > 
> > This change is required by the follow up patch that introduces the new netdev
> > table.
> > 
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > ---
> >  include/net/netfilter/nf_tables.h        |    8 ++++++
> >  include/uapi/linux/netfilter/nf_tables.h |    2 ++
> >  net/netfilter/nf_tables_api.c            |   46 ++++++++++++++++++++++++++----
> >  3 files changed, 51 insertions(+), 5 deletions(-)
> 
> [snip]
> 
> > diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
> > index 5fa1cd0..89a671e 100644
> > --- a/include/uapi/linux/netfilter/nf_tables.h
> > +++ b/include/uapi/linux/netfilter/nf_tables.h
> 
> [snip]
> 
> > @@ -423,6 +425,10 @@ static int nf_tables_fill_table_info(struct sk_buff *skb, struct net *net,
> >  	    nla_put_be32(skb, NFTA_TABLE_USE, htonl(table->use)))
> >  		goto nla_put_failure;
> >  
> > +	if (table->dev &&
> > +	    nla_put_string(skb, NFTA_TABLE_DEV, table->dev->name))
> > +		goto nla_put_failure;
> > +
> >  	nlmsg_end(skb, nlh);
> >  	return 0;
> >  
> > @@ -608,6 +614,11 @@ static int nf_tables_updtable(struct nft_ctx *ctx)
> >  	if (flags == ctx->table->flags)
> >  		return 0;
> >  
> > +	if ((ctx->afi->flags & NFT_AF_NEEDS_DEV) &&
> > +	    ctx->nla[NFTA_TABLE_DEV] &&
> > +	    nla_strcmp(ctx->nla[NFTA_TABLE_DEV], ctx->table->dev->name))
> > +		return -EOPNOTSUPP;
> > +
> >  	trans = nft_trans_alloc(ctx, NFT_MSG_NEWTABLE,
> >  				sizeof(struct nft_trans_table));
> >  	if (trans == NULL)
> 
> I'm a little unsure of the above logic.
> 
> Is it ok for NFT_AF_NEEDS_DEV to be set but ctx->nla[NFTA_TABLE_DEV] to
> be absent?

This path is only run if the table already exists.

So it basically checks if we're trying to update the binding, in that
case we hit -EOPNOTSUPP.

If we don't pass any NFTA_TABLE_DEV, then we assume we stick to the
existing binding.

This allows us to update the table flags without indicating the
binding, eg.

        nft add table netdev filter { flags dormant\; }

which basically disables the entire table content.
