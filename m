From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH 3/5] netfilter: add SYNPROXY core/target
Date: Wed, 7 Aug 2013 22:26:00 +0200
Message-ID: <20130807222600.51eeca09@redhat.com>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
	<1375897371-18430-4-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932343Ab3HGU0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 16:26:12 -0400
In-Reply-To: <1375897371-18430-4-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Aug 2013 19:42:49 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Add a SYNPROXY for netfilter. The code is split into two parts, the
> synproxy core with common functions and an address family specific
> target.
> 
> The SYNPROXY receives the connection request from the client,
> responds with a SYN/ACK containing a SYN cookie and announcing a zero
> window and checks whether the final ACK from the client contains a
> valid cookie.
> 
> It then establishes a connection to the original destination and, if
> successful, sends a window update to the client with the window size
> announced by the server.
> 
> Support for timestamps, SACK, window scaling and MSS options can be
> statically configured as target parameters if the features of the
> server are known. If timestamps are used, the timestamp value sent
> back to the client in the SYN/ACK will be different from the real
> timestamp of the server. In order to now break PAWS, the timestamps
> are translated in the direction server->client.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---

[...]

> +static void
> +synproxy_send_server_syn(const struct synproxy_net *snet,
> +			 const struct sk_buff *skb, const struct
> tcphdr *th,
> +			 const struct synproxy_options *opts)
> +{
> +	struct sk_buff *nskb;
> +	struct iphdr *iph, *niph;
> +	struct tcphdr *nth;
> +	unsigned int tcp_hdr_size;
> +
> +	iph = ip_hdr(skb);
> +
> +	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
> +	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + LL_MAX_HEADER,
> +			 GFP_ATOMIC);
> +	if (nskb == NULL)
> +		return;
> +	skb_reserve(nskb, LL_MAX_HEADER);
> +
> +	niph = synproxy_build_ip(nskb, iph->saddr, iph->daddr);
> +
> +	skb_reset_transport_header(nskb);
> +	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
> +	nth->source	= th->source;
> +	nth->dest	= th->dest;
> +	nth->seq	= htonl(ntohl(th->seq) - 1);
> +	nth->ack_seq	= htonl(ntohl(th->ack_seq) - 1);;

Strange double ";;"

Besides shouldn't nth->ack_seq be zero, in a SYN packet? This is the
SYN "replayed" towards the server right?

I also pointed to this in an earlier patch Martin showed me, but he
reported that changing this resulted in bad behavior.  So, I would
request Martin to re-test this part.


> +	tcp_flag_word(nth) = TCP_FLAG_SYN;
> +	if (opts->options & XT_SYNPROXY_OPT_ECN)
> +		tcp_flag_word(nth) |= TCP_FLAG_ECE | TCP_FLAG_CWR;
> +	nth->doff	= tcp_hdr_size / 4;
> +	nth->window	= th->window;
> +	nth->check	= 0;
> +	nth->urg_ptr	= 0;
> +
> +	synproxy_build_options(nth, opts);
> +
> +	synproxy_send_tcp(skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
> +			  niph, nth, tcp_hdr_size);
> +}

[...]

> +static unsigned int
> +synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
> +{
> +	const struct xt_synproxy_info *info = par->targinfo;
> +	struct synproxy_net *snet = synproxy_pernet(dev_net(par->in));
> +	struct synproxy_options opts = {};
> +	struct tcphdr *th, _th;
> +
> +	if (nf_ip_checksum(skb, par->hooknum, par->thoff, IPPROTO_TCP))
> +		return NF_DROP;
> +
> +	th = skb_header_pointer(skb, par->thoff, sizeof(_th), &_th);
> +	if (th == NULL)
> +		return NF_DROP;
> +
> +	synproxy_parse_options(skb, par->thoff, th, &opts);
> +
> +	if (th->syn) {
> +		/* Initial SYN from client */
> +		this_cpu_inc(snet->stats->syn_received);
> +
> +		if (th->ece && th->cwr)
> +			opts.options |= XT_SYNPROXY_OPT_ECN;
> +
> +		opts.options &= info->options;
> +		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
> +			synproxy_init_timestamp_cookie(info, &opts);
> +		else
> +			opts.options &= ~(XT_SYNPROXY_OPT_WSCALE |
> +					  XT_SYNPROXY_OPT_SACK_PERM |
> +					  XT_SYNPROXY_OPT_ECN);
> +
> +		synproxy_send_client_synack(skb, th, &opts);
> +	} else if (th->ack && !(th->fin || th->rst)) {

This could also match SYN+ACK... we are only interested in the ACK
(from the 3WHS) here, right?

> +		/* ACK from client */
> +		int mss = __cookie_v4_check(ip_hdr(skb), th,
> +					    ntohl(th->ack_seq) - 1);
> +		if (mss == 0) {
> +			this_cpu_inc(snet->stats->cookie_invalid);
> +			return NF_DROP;
> +		}
> +
> +		this_cpu_inc(snet->stats->cookie_valid);
> +		opts.mss = mss;
> +
> +		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
> +			synproxy_check_timestamp_cookie(&opts);
> +
> +		synproxy_send_server_syn(snet, skb, th, &opts);
> +	}
> +
> +	return NF_DROP;
> +}

[...]

> diff --git a/net/netfilter/nf_synproxy_core.c
> b/net/netfilter/nf_synproxy_core.c new file mode 100644
> index 0000000..d887a84
> --- /dev/null
> +++ b/net/netfilter/nf_synproxy_core.c
> @@ -0,0 +1,428 @@
> +/*
> + * Copyright (c) 2013 Patrick McHardy <kaber@trash.net>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
[...]
> +
> +void
> +synproxy_parse_options(const struct sk_buff *skb, unsigned int doff,
> +		       const struct tcphdr *th, struct synproxy_options *opts)
> +{
> +	int length = (th->doff * 4) - sizeof(*th);
> +	u8 buf[40], *ptr;
> +
> +	ptr = skb_header_pointer(skb, doff + sizeof(*th), length, buf);
> +	BUG_ON(ptr == NULL);
> +
> +	opts->options = 0;
> +	while (length > 0) {
> +		int opcode = *ptr++;
> +		int opsize;
> +
> +		switch (opcode) {
> +		case TCPOPT_EOL:
> +			return;
> +		case TCPOPT_NOP:
> +			length--;
> +			continue;
> +		default:
> +			opsize = *ptr++;
> +			if (opsize < 2)
> +				return;
> +			if (opsize > length)
> +				return;
> +
> +			switch (opcode) {
> +			case TCPOPT_MSS:
> +				if (opsize == TCPOLEN_MSS) {
> +					 opts->mss = get_unaligned_be16(ptr);

Strange indention, extra space before "opts->mss".

> +					 opts->options |= XT_SYNPROXY_OPT_MSS;

Strange indention, extra space before "opts->options".


> +				}
> +				break;
> +			case TCPOPT_WINDOW:
> +				if (opsize == TCPOLEN_WINDOW) {
> +					opts->wscale = *ptr;
> +					if (opts->wscale > 14)
> +						opts->wscale = 14;
> +					opts->options |= XT_SYNPROXY_OPT_WSCALE;
> +				}
> +				break;
> +			case TCPOPT_TIMESTAMP:
> +				if (opsize == TCPOLEN_TIMESTAMP) {
> +					opts->tsval = get_unaligned_be32(ptr);
> +					opts->tsecr = get_unaligned_be32(ptr + 4);
> +					opts->options |= XT_SYNPROXY_OPT_TIMESTAMP;
> +				}
> +				break;
> +			case TCPOPT_SACK_PERM:
> +				if (opsize == TCPOLEN_SACK_PERM)
> +					opts->options |= XT_SYNPROXY_OPT_SACK_PERM;
> +				break;
> +			}
> +
> +			ptr += opsize - 2;
> +			length -= opsize;
> +		}
> +	}
> +}
> +EXPORT_SYMBOL_GPL(synproxy_parse_options);

[...]

> +static int synproxy_cpu_seq_show(struct seq_file *seq, void *v)
> +{
> +	struct synproxy_stats *stats = v;
> +
> +	if (v == SEQ_START_TOKEN) {
> +		seq_printf(seq, "syn_received\tcookie_invalid\tcookie_valid\n");
> +		return 0;
> +	}
> +
> +	seq_printf(seq, "%08u\t%08x\t%08x\n",

Shouldn't all numbers be printed in hex? (%08u -> %08x)

Besides when using net->proc_net_stat, then the first entry is usually
"entries" which is not percpu, this will likely confusing the tool:
  lnstat -f synproxy -c 42


> +		   stats->syn_received,
> +		   stats->cookie_invalid,
> +		   stats->cookie_valid);
> +
> +	return 0;
> +}

[...]


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
