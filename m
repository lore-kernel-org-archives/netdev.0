From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 05/17] netfilter: add namespace support for l4proto_tcp
Date: Fri, 25 May 2012 05:00:15 +0200
Message-ID: <20120525030015.GB21076@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-6-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1336985547-31960-6-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gao,

While having a look at this again, I have two new requests:

On Mon, May 14, 2012 at 04:52:15PM +0800, Gao feng wrote:
[...]
> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> index 4dfbfa8..dd19350 100644
> --- a/net/netfilter/nf_conntrack_proto_tcp.c
> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
[...]
> @@ -1549,10 +1532,80 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>  #endif /* CONFIG_SYSCTL */
>
> +static int tcp_init_net(struct net *net, u_int8_t compat)
> +{
> +	int i;
> +	struct nf_tcp_net *tn = tcp_pernet(net);
> +	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
> +#ifdef CONFIG_SYSCTL
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	if (compat) {
> +		pn->ctl_compat_table = kmemdup(tcp_compat_sysctl_table,
> +					       sizeof(tcp_compat_sysctl_table),
> +					       GFP_KERNEL);
> +		if (!pn->ctl_compat_table)
> +			return -ENOMEM;
> +
> +		pn->ctl_compat_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
> +		pn->ctl_compat_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT2];
> +		pn->ctl_compat_table[2].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
> +		pn->ctl_compat_table[3].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
> +		pn->ctl_compat_table[4].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
> +		pn->ctl_compat_table[5].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
> +		pn->ctl_compat_table[6].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
> +		pn->ctl_compat_table[7].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
> +		pn->ctl_compat_table[8].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
> +		pn->ctl_compat_table[9].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
> +		pn->ctl_compat_table[10].data = &tn->tcp_loose;
> +		pn->ctl_compat_table[11].data = &tn->tcp_be_liberal;
> +		pn->ctl_compat_table[12].data = &tn->tcp_max_retrans;

You can make a generic function to set the ctl_data that you can
reuse for this code above and the one below.

> +	}
> +#endif
> +	if (!pn->ctl_table) {
> +#else
> +	if (!pn->user++) {
> +#endif
> +		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
> +			tn->timeouts[i] = tcp_timeouts[i];
> +		tn->tcp_loose = nf_ct_tcp_loose;
> +		tn->tcp_be_liberal = nf_ct_tcp_be_liberal;
> +		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
> +#ifdef CONFIG_SYSCTL
> +		pn->ctl_table = kmemdup(tcp_sysctl_table,
> +					sizeof(tcp_sysctl_table),
> +					GFP_KERNEL);
> +		if (!pn->ctl_table) {
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +			if (compat) {
> +				kfree(pn->ctl_compat_table);
> +				pn->ctl_compat_table = NULL;
> +			}
> +#endif
> +			return -ENOMEM;
> +		}
> +		pn->ctl_table[0].data = &tn->timeouts[TCP_CONNTRACK_SYN_SENT];
> +		pn->ctl_table[1].data = &tn->timeouts[TCP_CONNTRACK_SYN_RECV];
> +		pn->ctl_table[2].data = &tn->timeouts[TCP_CONNTRACK_ESTABLISHED];
> +		pn->ctl_table[3].data = &tn->timeouts[TCP_CONNTRACK_FIN_WAIT];
> +		pn->ctl_table[4].data = &tn->timeouts[TCP_CONNTRACK_CLOSE_WAIT];
> +		pn->ctl_table[5].data = &tn->timeouts[TCP_CONNTRACK_LAST_ACK];
> +		pn->ctl_table[6].data = &tn->timeouts[TCP_CONNTRACK_TIME_WAIT];
> +		pn->ctl_table[7].data = &tn->timeouts[TCP_CONNTRACK_CLOSE];
> +		pn->ctl_table[8].data = &tn->timeouts[TCP_CONNTRACK_RETRANS];
> +		pn->ctl_table[9].data = &tn->timeouts[TCP_CONNTRACK_UNACK];
> +		pn->ctl_table[10].data = &tn->tcp_loose;
> +		pn->ctl_table[11].data = &tn->tcp_be_liberal;
> +		pn->ctl_table[12].data = &tn->tcp_max_retrans;
> +#endif

I have bad experience with code that has lots of #ifdef's.

Please, split all *_init_net into smaller functions.
