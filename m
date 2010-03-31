From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message size
 properly
Date: Wed, 31 Mar 2010 19:46:50 +0200
Message-ID: <4BB38A8A.9050501@trash.net>
References: <20100331151102.GB8043@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, davem@davemloft.net,
	Krzysztof Oledzki <ole@ans.pl>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20100331151102.GB8043@psychotron.lab.eng.brq.redhat.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko wrote:
> Message size should be dependent on net->ct.sysctl_acct, not on
> CONFIG_NF_CT_ACCT definition.

Krzysztof actually wanted to get rid of the config option entirely
some time ago, but at that time there were some (now solved) problems
that prevented his. I've CCed him, hoping that this will finally
get completed :)

> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
> index 569410a..2b0cfa4 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -426,6 +426,19 @@ ctnetlink_proto_size(const struct nf_conn *ct)
>  }
>  
>  static inline size_t
> +ctnetlink_counters_size(const struct nf_conn *ct)
> +{
> +	struct net *net = nf_ct_net(ct);
> +
> +	if (!net->ct.sysctl_acct)
> +		return 0;
> +	return 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
> +	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
> +	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
> +	       ;

This is also not fully correct since the sysctl only affects newly
created conntracks, existing ones still have counters that are dumped.
I'd suggest to simple check whether the conntrack has an accounting
extension.
