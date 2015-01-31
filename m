From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/9] netfilter: nft_hash: add support for timeouts
Date: Sat, 31 Jan 2015 12:16:12 +0000
Message-ID: <20150131121611.GA31500@acer.localdomain>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
 <1422603994-5836-8-git-send-email-kaber@trash.net>
 <20150131042920.GA27480@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150131042920.GA27480@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.01, Herbert Xu wrote:
> On Fri, Jan 30, 2015 at 07:46:32AM +0000, Patrick McHardy wrote:
> >
> > +	mutex_lock(&priv->ht.mutex);
> > +	tbl = rht_dereference(priv->ht.tbl, &priv->ht);
> > +	for (i = 0; i < tbl->size; i++) {
> > +		rht_for_each_entry_safe(he, pos, next, tbl, i, node) {
> > +			if (!nft_set_ext_exists(&he->ext, NFT_SET_EXT_TIMEOUT))
> > +				continue;
> > +			timeout = *nft_set_ext_timeout(&he->ext);
> > +			if (time_before(jiffies, timeout))
> > +				continue;
> > +
> > +			rhashtable_remove(&priv->ht, &he->node);
> > +			nft_hash_elem_destroy(set, he);
> > +		}
> > +	}
> > +	mutex_unlock(&priv->ht.mutex);
> 
> What if somebody is currently walking over the table? Shouldn't
> you do an RCU free here instead of immediately destroying the
> element?

Yes, that's what I meant in mail 0/x regarding the existing races.
Probably will add some fixed sized batching here.
