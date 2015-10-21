From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [RFC PATCH 2/5] netfilter: Factor out nf_ct_get_info().
Date: Wed, 21 Oct 2015 12:45:56 +0200
Message-ID: <20151021104556.GC2135@salvia>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
 <1445379629-112880-2-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445379629-112880-2-git-send-email-jrajahalme@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 20, 2015 at 03:20:26PM -0700, Jarno Rajahalme wrote:
> Define a new inline function to map conntrack status to enum
> ip_conntrack_info.  This removes the need to otherwise duplicate this
> code in a later patch.

Where is that later patch that justifies this update?

> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
> ---
>  include/net/netfilter/nf_conntrack.h | 15 +++++++++++++++
>  net/netfilter/nf_conntrack_core.c    | 22 +++-------------------
>  2 files changed, 18 insertions(+), 19 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
> index fde4068..b3de10e 100644
> --- a/include/net/netfilter/nf_conntrack.h
> +++ b/include/net/netfilter/nf_conntrack.h
> @@ -125,6 +125,21 @@ nf_ct_tuplehash_to_ctrack(const struct nf_conntrack_tuple_hash *hash)
>  			    tuplehash[hash->tuple.dst.dir]);
>  }
>  
> +static inline enum ip_conntrack_info
> +nf_ct_get_info(const struct nf_conntrack_tuple_hash *h)
> +{
> +	const struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
> +
> +	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
> +		return IP_CT_ESTABLISHED_REPLY;
> +	/* Once we've had two way comms, always ESTABLISHED. */
> +	if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status))
> +		return IP_CT_ESTABLISHED;
> +	if (test_bit(IPS_EXPECTED_BIT, &ct->status))
> +		return IP_CT_RELATED;
> +	return IP_CT_NEW;
> +}

I would really like to see how you want to use this.
