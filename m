From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v2] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Thu, 30 Jul 2015 13:54:34 +0200
Message-ID: <20150730115434.GA6960@salvia>
References: <20150717141757.01EBFA0A84@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150717141757.01EBFA0A84@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 17, 2015 at 04:17:56PM +0200, Michal Kubecek wrote:
> Currently nf_conntrack_proto_sctp module handles only packets between
> primary addresses used to establish the connection. Any packets between
> secondary addresses are classified as invalid so that usual firewall
> configurations drop them. Allowing HEARTBEAT and HEARTBEAT-ACK chunks to
> establish a new conntrack would allow traffic between secondary
> addresses to pass through. A more sophisticated solution based on the
> addresses advertised in the initial handshake (and possibly also later
> dynamic address addition and removal) would be much harder to implement.
> Moreover, in general we cannot assume to always see the initial
> handshake as it can be routed through a different path.

Applied, thanks.

I have remove the chunks below though, see explanation below.

> @@ -705,6 +756,18 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
>  	},
> +	{
> +		.procname	= "ip_conntrack_sctp_timeout_heartbeat_sent",
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_jiffies,
> +	},
> +	{
> +		.procname	= "ip_conntrack_sctp_timeout_heartbeat_acked",
> +		.maxlen		= sizeof(unsigned int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_jiffies,
> +	},
>  	{ }
>  };
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
[...]
> @@ -752,6 +817,8 @@ static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
>  	pn->ctl_compat_table[4].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT];
>  	pn->ctl_compat_table[5].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD];
>  	pn->ctl_compat_table[6].data = &sn->timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT];
> +	pn->ctl_compat_table[7].data = &sn->timeouts[SCTP_CONNTRACK_HEARTBEAT_SENT];
> +	pn->ctl_compat_table[8].data = &sn->timeouts[SCTP_CONNTRACK_HEARTBEAT_ACKED];
>  #endif
>  #endif
>  	return 0;

These are part of the compat sysctl interface (those entries that are
prefixed by "ip_conntrack_*) that we should remove at some point (the
new entries that are prefixed by "nf_conntrack_*" has been already
there for a bit less than ~10 years and we got a netlink interface to
configure this for several years already), so better skip those spots.
