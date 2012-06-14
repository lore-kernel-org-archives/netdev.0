From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 07/10] netfilter: nf_conntrack_l4proto_udplite[4,6]
 cleanup
Date: Thu, 14 Jun 2012 20:17:35 +0200
Message-ID: <20120614181735.GF10633@1984>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339668445-23848-7-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38338 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936Ab2FNSRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 14:17:40 -0400
Content-Disposition: inline
In-Reply-To: <1339668445-23848-7-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 14, 2012 at 06:07:22PM +0800, Gao feng wrote:
> some cleanup for nf_conntrack_l4proto_udplite[4,6],
> make codes more clearer and ready for moving the
> sysctl code to nf_conntrack_proto_*_sysctl.c to
> reduce the ifdef pollution.
> 
> and use nf_proto_net.users to identify if it's the first time
> we use the nf_proto_net. when it's the first time,we will
> initialized it.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/netfilter/nf_conntrack_proto_udplite.c |   42 +++++++++++++++++----------
>  1 files changed, 26 insertions(+), 16 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
> index d33e511..f6a789a 100644
> --- a/net/netfilter/nf_conntrack_proto_udplite.c
> +++ b/net/netfilter/nf_conntrack_proto_udplite.c
> @@ -234,29 +234,39 @@ static struct ctl_table udplite_sysctl_table[] = {
>  };
>  #endif /* CONFIG_SYSCTL */
>  
> +static int udplite_kmemdup_sysctl_table(struct nf_proto_net *pn)
> +{
> +#ifdef CONFIG_SYSCTL
> +	struct udplite_net *un = (struct udplite_net *)pn;
> +
> +	if (pn->ctl_table)
> +		return 0;
> +
> +	pn->ctl_table = kmemdup(udplite_sysctl_table,
> +				sizeof(udplite_sysctl_table),
> +				GFP_KERNEL);
> +	if (!pn->ctl_table)
> +		return -ENOMEM;
> +
> +	pn->ctl_table[0].data = &un->timeouts[UDPLITE_CT_UNREPLIED];
> +	pn->ctl_table[1].data = &un->timeouts[UDPLITE_CT_REPLIED];
> +#endif
> +	return 0;
> +}
> +
> +

Remove extra line.

>  static int udplite_init_net(struct net *net, u_int16_t proto)
>  {
> -	int i;
>  	struct udplite_net *un = udplite_pernet(net);
>  	struct nf_proto_net *pn = (struct nf_proto_net *)un;
> -#ifdef CONFIG_SYSCTL
> -	if (!pn->ctl_table) {
> -#else
> -	if (!pn->users++) {
> -#endif
> +
> +	if (!pn->users) {
> +		int i;
>  		for (i = 0 ; i < UDPLITE_CT_MAX; i++)
>  			un->timeouts[i] = udplite_timeouts[i];
> -#ifdef CONFIG_SYSCTL
> -		pn->ctl_table = kmemdup(udplite_sysctl_table,
> -					sizeof(udplite_sysctl_table),
> -					GFP_KERNEL);
> -		if (!pn->ctl_table)
> -			return -ENOMEM;
> -		pn->ctl_table[0].data = &un->timeouts[UDPLITE_CT_UNREPLIED];
> -		pn->ctl_table[1].data = &un->timeouts[UDPLITE_CT_REPLIED];
> -#endif
>  	}
> -	return 0;
> +
> +	return udplite_kmemdup_sysctl_table(pn);
>  }
>  
>  static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
> -- 
> 1.7.7.6
> 
